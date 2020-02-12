.EXPORT_ALL_VARIABLES:
CONSUL_HTTP_ADDR = http://localhost:8500
CONSUL_DOMAIN := $(shell curl -s http://localhost:8500/v1/connect/ca/roots | jq -r .TrustDomain)

all: consul expense-app

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

circuit-break: clean-traffic clean-report-app
	sed 's/CONSUL_FQDN/${CONSUL_DOMAIN}/g' circuit_breaking/template.tpl > circuit_breaking/report.hcl
	docker-compose -f docker-compose-circuit-break.yml up -d

circuit-break-test:
	docker stop expense-report_expense-db-mssql_1
	for i in {1..50}; do curl -s -o /dev/null -w "%{http_code}" localhost:5002/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d09544; echo ""; sleep 1; done

clean-circuit-break:
	docker start expense-report_expense-db-mssql_1
	docker restart expense-report_expensedb_proxy_mssql_1
	docker-compose -f docker-compose-circuit-break.yml down || true
	rm -f circuit_breaking/report.hcl

db-run: clean build
	docker run --name expenses-db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=Testing!123 -d joatmon08/expense-db:mysql

consul:
	docker-compose up -d
	until consul kv put configuration/expense/application.properties @expense/java/application.properties; do sleep 10; done

expense-app:
	docker-compose -f docker-compose-expense.yml up -d

clean-expense-app:
	docker-compose -f docker-compose-expense.yml down || true

report-app: clean-circuit-break
	docker-compose -f docker-compose-report.yml up -d

clean-report-app:
	docker-compose -f docker-compose-report.yml down || true

clean: clean-circuit-break clean-report-app clean-expense-app
	docker-compose down || true
	docker rm -f expenses-db expenses || true

get-envoy-config:
	 docker exec expense-report_expensedb_proxy_mysql_1 curl localhost:19000/config_dump | jq '.configs[2].dynamic_active_listeners[0].listener.filter_chains[0].tls_context'

traffic:
	consul config write traffic_config/expense-resolver.hcl
	consul config write traffic_config/expense-splitter.hcl

clean-traffic:
	consul config delete -kind service-splitter -name expense
	consul config delete -kind service-resolver -name expense

toggle-on:
	consul kv put toggles/enable-number-of-items true

toggle-off:
	consul kv put toggles/enable-number-of-items false