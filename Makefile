.EXPORT_ALL_VARIABLES:
CONSUL_HTTP_ADDR = http://localhost:8500
CONSUL_DOMAIN := $(shell curl -s http://localhost:8500/v1/connect/ca/roots | jq -r .TrustDomain)

all: consul expense-app report-app

build:
	docker build -t joatmon08/expense-db:mssql database/mssql/
	docker build -t joatmon08/expense-db:mysql database/mysql/
	docker build -t joatmon08/expense:java expense/java/
	docker build -t joatmon08/expense:dotnet expense/dotnet/
	docker build -t joatmon08/report:dotnet -f report/dotnet/Dockerfile .

push:
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

consul:
	docker-compose up -d
	until consul kv put configuration/expense/application.properties @expense/java/application.properties; do sleep 10; done
	consul config write traffic_config/deny-intentions.hcl

expense-app:
	docker-compose -f docker-compose-expense.yml up -d

clean-expense-app:
	docker-compose -f docker-compose-expense.yml down || true

report-app:
	docker-compose -f docker-compose-report.yml up -d

clean-report-app:
	docker-compose -f docker-compose-report.yml down || true

clean: clean-report-app clean-expense-app
	docker-compose down --remove-orphans || true

get-envoy-config:
	 docker exec expense-report_expensedb_proxy_mysql_1 curl -s localhost:19000/config_dump | jq '.configs[2].dynamic_active_listeners[0].listener.filter_chains[0].tls_context'

traffic:
	consul config write traffic_config/expense-resolver.hcl
	consul config write traffic_config/expense-splitter.hcl
	consul config write traffic_config/expense-intentions.hcl
	consul config write traffic_config/expense-db-mssql-intentions.hcl
	consul config write traffic_config/expense-db-mysql-intentions.hcl
	consul config write traffic_config/expense-router.hcl

clean-traffic:
	consul config delete -kind service-splitter -name expense
	consul config delete -kind service-resolver -name expense

toggle-on:
	consul kv put toggles/enable-number-of-items true

toggle-off:
	consul kv put toggles/enable-number-of-items false

router-on:
	consul config write traffic_config/expense-resolver.hcl
	sleep 10
	curl -X GET 'http://localhost:5002/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa' | jq '.'
	consul config write traffic_config/expense-router.hcl

router-off:
	consul config delete -kind service-router -name expense
	consul config delete -kind service-resolver -name expense

write-expense:
	curl -X POST 'http://localhost:5001/api/expense' -H 'Content-Type:application/json' -d @example/expense.json

test-report:
	curl -s -X GET 'http://localhost:5002/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa' | jq '.'

test-router:
	docker exec -it expense-report_report_1 curl -H 'X-Request-ID:java' localhost:5001/api/expense | jq '.'
	docker exec -it expense-report_report_1 curl localhost:5001/api/expense | jq '.'

kubeconfig:
	gcloud container clusters get-credentials kubecon --zone us-central1-c

k8s-consul: kubeconfig
	helm upgrade --install consul hashicorp/consul -f helm/consul.yaml
	helm upgrade --install grafana grafana/grafana -f helm/grafana.yaml

k8s-vault:
	helm upgrade --install csi secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system  -f helm/csi.yaml
	helm upgrade --install vault hashicorp/vault -f helm/vault.yaml
	kubectl apply -f kubernetes/vault.yaml

k8s-vault-init:
	kubectl exec -it vault-0 -c vault -- vault operator init -format=json > vault-root.json || true
	kubectl wait --for=condition=ready pod vault-0
	kubectl wait --for=condition=ready pod vault-1
	kubectl wait --for=condition=ready pod vault-2
	source variables.env && cd vault && terraform init && terraform apply

k8s-jaeger:
	kubectl apply -f kubernetes/jaeger.yaml
	kubectl apply -f kubernetes/proxy-defaults.yaml
	kubectl apply -f kubernetes/intentions.yaml

k8s-ingress:
	helm upgrade --install report kong/kong -f helm/kong.yaml
	kubectl rollout status deployment report-kong
	kubectl apply -f kubernetes/ingress-gateway.yaml

k8s-database:
	kubectl apply -f kubernetes/database-mysql.yaml
	kubectl rollout status deployment expense-db-mysql
	kubectl apply -f kubernetes/database-mssql.yaml
	kubectl rollout status deployment expense-db-mssql
	source variables.env && cd vault && terraform init && terraform apply

k8s-java:
	kubectl apply -f kubernetes/expense.yaml
	kubectl apply -f kubernetes/expense-v2.yaml
	kubectl apply -f kubernetes/splitter.yaml

k8s-dotnet:
	kubectl apply -f kubernetes/expense.yaml
	kubectl apply -f kubernetes/expense-v1.yaml

k8s-expense: k8s-dotnet k8s-java

k8s-report:
	kubectl apply -f kubernetes/report.yaml
	kubectl apply -f kubernetes/report-v2.yaml
	kubectl apply -f kubernetes/router.yaml
	kubectl apply -f kubernetes/report-v3.yaml

clean-k8s-java:
	kubectl delete --ignore-not-found -f kubernetes/splitter.yaml
	kubectl delete --ignore-not-found -f kubernetes/expense-v2.yaml
	kubectl delete --ignore-not-found -f kubernetes/expense.yaml

clean-k8s-dotnet:
	kubectl delete --ignore-not-found -f kubernetes/expense-v1.yaml
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
	kubectl delete --ignore-not-found -f kubernetes/ingress-gateway.yaml
	helm del report || true
	kubectl delete --ignore-not-found $(shell kubectl get crds -o name | grep kong)

clean-k8s-jaeger:
	kubectl delete -f kubernetes/intentions.yaml || true
	kubectl delete -f kubernetes/jaeger.yaml || true
	kubectl delete -f kubernetes/proxy-defaults.yaml

clean-k8s-consul:
	helm del grafana || true
	kubectl delete --ignore-not-found -f kubernetes/splitter.yaml
	kubectl delete --ignore-not-found -f kubernetes/router.yaml
	helm del consul || true
	kubectl delete --ignore-not-found $(shell kubectl get pvc -l chart=consul-helm -o name)
	kubectl delete --ignore-not-found $(shell kubectl get secret -o name | grep consul)
	kubectl delete --ignore-not-found serviceaccount consul-tls-init

clean-k8s-vault:
	source variables.env && cd vault && terraform destroy -auto-approve || true
	helm del vault || true
	kubectl delete --ignore-not-found -f kubernetes/vault.yaml
	helm del vault || true
	helm del csi --namespace=kube-system || true
	kubectl delete --ignore-not-found $(shell kubectl get pvc -l 'app.kubernetes.io/instance=vault' -o name)
	rm -f secrets.env

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
	kubectl delete --ignore-not-found -f kubernetes/splitter.yaml
	@sleep 5
	for i in {1..3}; do curl -s http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")/api/report/expense/version; echo ""; sleep 1; done
	kubectl delete --ignore-not-found deployment expense-db-mysql
	for i in {1..1000}; do curl -s -w "%{http_code}" http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa; echo ""; sleep 1; done

k8s-circuit-break-recover:
	kubectl apply -f kubernetes/database-mysql.yaml
	kubectl apply -f kubernetes/splitter.yaml
	for i in {1..1000}; do curl -s -w " %{http_code}" http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa; echo ""; sleep 1; done

k8s-vault-leases:
	vault list sys/leases/lookup/expense/database/mysql/creds/expense || true
	vault list sys/leases/lookup/expense/database/mssql/creds/expense

k8s-vault-leases-revoke:
	source variables.env && vault lease revoke -prefix expense/database/mysql/creds
	source variables.env && vault lease revoke -prefix expense/database/mssql/creds