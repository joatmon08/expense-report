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
	curl -X GET 'http://localhost:5002/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa'
	consul config write traffic_config/expense-router.hcl

router-off:
	consul config delete -kind service-router -name expense
	consul config delete -kind service-resolver -name expense

write-expense:
	curl -X POST 'http://localhost:5001/api/expense' -H 'Content-Type:application/json' -d @example/expense.json

test-report:
	curl -s -X GET 'http://localhost:5002/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa' | jq '.'