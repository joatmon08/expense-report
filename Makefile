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

k8s-consul:
	helm upgrade --install consul hashicorp/consul -f helm/consul.yaml

k8s-ingress:
	helm upgrade --install report kong/kong -f helm/kong.yaml
	kubectl apply -f kubernetes/ingress-gateway.yaml

k8s-jaeger:
	kubectl apply -f kubernetes/proxy-defaults.yaml
	kubectl apply -f kubernetes/jaeger.yaml
	kubectl apply -f kubernetes/intentions.yaml

k8s-java:
	kubectl apply -f kubernetes/database-mysql.yaml
	kubectl apply -f kubernetes/expense.yaml
	kubectl apply -f kubernetes/expense-v2.yaml

k8s-report:
	kubectl apply -f kubernetes/report.yaml

k8s-dotnet:
	kubectl apply -f kubernetes/database-mssql.yaml
	kubectl apply -f kubernetes/expense.yaml
	kubectl apply -f kubernetes/expense-v1.yaml

clean-k8s-java:
	kubectl delete -f kubernetes/expense-v2.yaml || true
	kubectl delete -f kubernetes/expense.yaml || true
	kubectl delete -f kubernetes/database-mysql.yaml

clean-k8s-dotnet:
	kubectl delete -f kubernetes/expense-v1.yaml || true
	kubectl delete -f kubernetes/expense.yaml || true
	kubectl delete -f kubernetes/database-mssql.yaml

clean-k8s-report:
	kubectl delete -f kubernetes/report.yaml

clean-k8s-ingress:
	kubectl delete -f kubernetes/ingress-gateway.yaml

clean-k8s-jaeger:
	kubectl delete -f kubernetes/splitter.yaml || true
	kubectl delete -f kubernetes/intentions.yaml || true
	kubectl delete -f kubernetes/jaeger.yaml
	kubectl delete -f kubernetes/proxy-defaults.yaml || true

clean-k8s-consul:
	helm del consul || true
	kubectl delete --ignore-not-found $(shell kubectl get pvc -l chart=consul-helm -o name)
	kubectl delete --ignore-not-found $(shell kubectl get secret -o name | grep consul)
	kubectl delete --ignore-not-found serviceaccount consul-tls-init

k8s-split:
	kubectl apply -f kubernetes/splitter.yaml

k8s-create-expense:
	curl -X POST 'http://localhost:15001/api/expense' -H 'Content-Type:application/json' -d @example/expense.json
	curl -X POST 'http://localhost:15001/api/expense' -H 'Content-Type:application/json' -d @example/food.json

k8s-expense-version:
	curl -s http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")/api/report/expense/version

k8s-get-report:
	curl -s http://$(shell kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa | jq .