.EXPORT_ALL_VARIABLES:
CONSUL_HTTP_ADDR = http://localhost:8500
CONSUL_DOMAIN := $(shell curl -s http://localhost:8500/v1/connect/ca/roots | jq -r .TrustDomain)

image_build:
	docker build -t joatmon08/expense-db:mssql database/mssql/
	docker build -t joatmon08/expense-db:mysql database/mysql/
	docker build -t joatmon08/expense:java expense/java/
	docker build -t joatmon08/expense:dotnet expense/dotnet/
	docker build -t joatmon08/report:dotnet -f report/dotnet/Dockerfile .

image_push:
	docker push joatmon08/expense-db:mssql
	docker push joatmon08/expense-db:mysql
	docker push joatmon08/expense:java
	docker push joatmon08/expense:dotnet
	docker push joatmon08/report:dotnet

circuit-break-test:
	docker stop expense-report_expense-db-mssql_1
	for i in {1..1000}; do curl -s -o /dev/null -w "%{http_code}" localhost:5002/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d09544; echo ""; sleep 1; done

circuit-break-reset:
	docker start expense-report_expense-db-mssql_1
	docker restart expense-report_expensedb_proxy_mssql_1

compose: compose-consul compose-expense compose-report

compose-consul:
	docker-compose up -d
	until consul kv put configuration/expense/application.properties @expense/java/application.properties; do sleep 10; done
	consul config write compose_configs/traffic_config/deny-intentions.hcl
	consul config write compose_configs/traffic_config/expense-db-mssql-intentions.hcl
	consul config write compose_configs/traffic_config/expense-db-mysql-intentions.hcl

compose-expense:
	docker-compose -f docker-compose-expense.yml up -d
	consul config write compose_configs/traffic_config/expense-intentions.hcl
	consul config write compose_configs/traffic_config/expense-resolver.hcl
	consul config write compose_configs/traffic_config/expense-splitter.hcl
	consul config write compose_configs/traffic_config/expense-router.hcl

compose-report:
	docker-compose -f docker-compose-report.yml up -d

clean-compose-expense:
	docker-compose -f docker-compose-expense.yml down || true

clean-compose-report:
	docker-compose -f docker-compose-report.yml down || true

clean-compose: clean-compose-report clean-compose-expense
	docker-compose down --remove-orphans || true

compose-toggle-on:
	consul kv put toggles/enable-number-of-items true

compose-toggle-off:
	consul kv put toggles/enable-number-of-items false

compose-create-expense:
	curl -X POST 'http://localhost:15001/api/expense' -H 'Content-Type:application/json' -d @example/expense.json
	curl -X POST 'http://localhost:15001/api/expense' -H 'Content-Type:application/json' -d @example/food.json

compose-expense-version:
	curl -s -X GET 'http://localhost:5002/api/report/expense/version'

compose-get-expense:
	curl -s -X GET 'http://localhost:15001/api/expense' -H 'Content-Type:application/json' | jq .
	curl -s -X GET 'http://localhost:18080/api/expense' -H 'Content-Type:application/json' | jq .

compose-get-report:
	curl -s -X GET 'http://localhost:5002/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa' | jq '.'

compose-get-expense-debug:
	docker exec -it expense-report_report_1 curl -H 'X-Request-ID:java' 127.0.0.1:5001/api/expense | jq .
	docker exec -it expense-report_report_1 curl 127.0.0.1:5001/api/expense | jq .

kubeconfig:
	gcloud container clusters get-credentials kubecon --zone us-central1-c

k8s: k8s-consul k8s-grafana k8s-jaeger k8s-ingress k8s-vault k8s-vault-init k8s-database k8s-expense k8s-report

k8s-consul: kubeconfig
	helm upgrade --install consul hashicorp/consul -f helm/consul.yaml
	kubectl apply -f kubernetes/intentions.yaml
	kubectl apply -f kubernetes/proxy-defaults.yaml

k8s-grafana:
	helm upgrade --install grafana grafana/grafana -f helm/grafana.yaml || true

k8s-jaeger:
	kubectl apply -f kubernetes/jaeger.yaml

k8s-ingress:
	helm upgrade --install report kong/kong -f helm/kong.yaml
	kubectl rollout status deployment report-kong
	kubectl apply -f kubernetes/ingress-gateway.yaml

k8s-vault:
	cd terraform && terraform output -raw vault_helm > ../helm/vault.yaml
	helm upgrade --install vault hashicorp/vault -f helm/vault.yaml
	kubectl apply -f kubernetes/vault.yaml

k8s-vault-init:
	kubectl wait --for=condition=initialized pod vault-0
	kubectl exec -it vault-0 -c vault -- vault operator init -format=json > vault-root.json || true
	kubectl wait --for=condition=ready pod vault-0
	kubectl delete --ignore-not-found pods vault-1 vault-2
	kubectl wait --for=condition=ready pod vault-1
	kubectl wait --for=condition=ready pod vault-2
	source variables.env && cd vault && terraform init && terraform apply

k8s-database:
	kubectl apply -f kubernetes/database-mssql.yaml
	kubectl rollout status deployment expense-db-mssql
	kubectl apply -f kubernetes/database-mysql.yaml
	kubectl rollout status deployment expense-db-mysql
	source variables.env && cd vault && terraform init && terraform apply

k8s-java:
	kubectl apply -f kubernetes/expense-v2.yaml
	kubectl apply -f kubernetes/splitter.yaml

k8s-dotnet:
	kubectl apply -f kubernetes/expense.yaml

k8s-expense: k8s-dotnet k8s-java

k8s-report: k8s-report-v2 k8s-report-v3

k8s-report-v2:
	kubectl apply -f kubernetes/report.yaml
	kubectl apply -f kubernetes/report-v2.yaml

k8s-report-v3:
	kubectl apply -f kubernetes/router.yaml
	kubectl apply -f kubernetes/report-v3.yaml

clean-k8s-java:
	kubectl delete --ignore-not-found -f kubernetes/splitter.yaml
	kubectl delete --ignore-not-found -f kubernetes/expense-v2.yaml

clean-k8s-dotnet:
	kubectl delete --ignore-not-found -f kubernetes/splitter.yaml
	kubectl delete --ignore-not-found -f kubernetes/expense.yaml

clean-k8s-expense: clean-k8s-dotnet clean-k8s-java

clean-k8s-database:
	kubectl delete --ignore-not-found -f kubernetes/database-mssql.yaml
	kubectl delete --ignore-not-found -f kubernetes/database-mysql.yaml

clean-k8s-report:
	kubectl delete --ignore-not-found -f kubernetes/report-v3.yaml
	kubectl delete --ignore-not-found -f kubernetes/router.yaml
	kubectl delete --ignore-not-found -f kubernetes/report-v2.yaml
	kubectl delete --ignore-not-found -f kubernetes/report.yaml

clean-k8s-ingress:
	kubectl delete --ignore-not-found -f kubernetes/ingress-gateway.yaml || true
	helm del report || true
	kubectl delete --ignore-not-found $(shell kubectl get crds -o name | grep kong) || true

clean-k8s-jaeger:
	kubectl delete --ignore-not-found -f kubernetes/jaeger.yaml

clean-k8s-consul:
	kubectl delete --ignore-not-found -f kubernetes/splitter.yaml
	kubectl delete --ignore-not-found -f kubernetes/router.yaml
	kubectl delete --ignore-not-found -f kubernetes/intentions.yaml
	helm del consul || true
	kubectl delete --ignore-not-found $(shell kubectl get pvc -l chart=consul-helm -o name)
	kubectl delete --ignore-not-found $(shell kubectl get secret -o name | grep consul)
	kubectl delete --ignore-not-found serviceaccount consul-tls-init

clean-k8s-grafana:
	helm del grafana || true

clean-k8s-vault:
	source variables.env && cd vault && terraform destroy -auto-approve || true
	kubectl delete --ignore-not-found -f kubernetes/vault.yaml
	helm del vault || true
	kubectl delete --ignore-not-found $(shell kubectl get pvc -l 'app.kubernetes.io/instance=vault' -o name) || true

clean-k8s: clean-k8s-report clean-k8s-expense k8s-vault-leases-revoke clean-k8s-database clean-k8s-vault clean-k8s-ingress clean-k8s-jaeger clean-k8s-grafana clean-k8s-consul

k8s-get-expense:
	curl -s http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")/api/expense

k8s-create-expense:
	curl -X POST 'http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")/api/expense' -H 'Content-Type:application/json' -d @example/expense.json
	curl -X POST 'http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")/api/expense' -H 'Content-Type:application/json' -d @example/food.json

k8s-expense-version:
	curl -s http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")/api/report/expense/version

k8s-get-report:
	curl -s http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa | jq .

k8s-get-report-debug:
	curl -s -H 'X-Debug:1' http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa | jq .

k8s-circuit-break:
	kubectl delete --ignore-not-found deployment expense-db-mysql
	locust --autostart --autoquit 30 -f locust/locustfile.py --users 30 --spawn-rate 5 -t 15m \
		-H http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

k8s-circuit-break-recover: k8s-database
	kubectl delete pods -l app=expense
	kubectl delete pods -l 'app.kubernetes.io/name=kong'

k8s-vault-leases:
	vault list sys/leases/lookup/expense/database/mysql/creds/expense || true
	vault list sys/leases/lookup/expense/database/mssql/creds/expense

k8s-vault-leases-revoke:
	source variables.env && vault lease revoke -prefix expense/database/mysql/creds || true
	source variables.env && vault lease revoke -prefix expense/database/mssql/creds || true