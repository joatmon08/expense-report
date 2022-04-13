#!/bin/bash

CONSUL_HTTP_ADDR=$(cd terraform/helm && terraform output -raw consul_endpoint)
VAULT_ADDR=$(cd terraform/helm && terraform output -raw vault_endpoint)
VAULT_TOKEN=$(cd terraform/helm && terraform output -raw vault_token)
EXPENSE_ENDPOINT_DOTNET=http://localhost:15001
EXPENSE_ENDPOINT_JAVA=http://localhost:18080
REPORT_ENDPOINT=http://localhost:15002

function databases() {
    for arg in "$@"
    do
        case $arg in
            setup)
            kubectl apply -f kubernetes/databases/mssql.yaml
            kubectl rollout status deployment expense-db-mssql
            kubectl apply -f kubernetes/databases/mysql.yaml
            kubectl rollout status deployment expense-db-mysql
            kubectl apply -f kubernetes/databases/intentions.yaml
            shift
            ;;
            remove)
            kubectl delete -f kubernetes/databases/intentions.yaml --ignore-not-found
            kubectl delete -f kubernetes/databases/mssql.yaml --ignore-not-found
            kubectl delete -f kubernetes/databases/mysql.yaml --ignore-not-found
            shift
            ;;
            *)
            echo "arg not found"
            exit 1
            ;;
        esac
    done
}

function configure_vault_db() {
    for arg in "$@"
    do
        case $arg in
            setup)
            cd terraform/vault-app
            terraform init
            terraform apply
            shift
            ;;
            remove)
            vault lease revoke -f -prefix expense/database/mssql
            vault lease revoke -f -prefix expense/database/mysql
            cd terraform/vault-app
            terraform destroy
            shift
            ;;
            *)
            echo "arg not found"
            exit 1
            ;;
        esac
    done
}

function expense() {
    for arg in "$@"
    do
        case $arg in
            setup)
            kubectl apply -f kubernetes/expenses/v1.yaml
            kubectl rollout status deployment expense
            kubectl apply -f kubernetes/expenses/v2.yaml
            kubectl rollout status deployment expense-v2
            kubectl apply -f kubernetes/expenses/intentions.yaml
            shift
            ;;
            test)
            curl -X POST "${EXPENSE_ENDPOINT_DOTNET}/api/expense" \
                -H 'Content-Type:application/json' -d @example/gas.json
            curl -X POST "${EXPENSE_ENDPOINT_JAVA}/api/expense" \
                -H 'Content-Type:application/json' -d @example/food.json
            shift
            ;;
            remove)
            kubectl delete -f kubernetes/expenses/intentions.yaml --ignore-not-found
            kubectl delete -f kubernetes/expenses/v2.yaml --ignore-not-found
            kubectl delete -f kubernetes/expenses/v1.yaml --ignore-not-found
            shift
            ;;
            *)
            echo "arg not found"
            exit 1
            ;;
        esac
    done
}

function split_traffic() {
    for arg in "$@"
    do
        case $arg in
            setup)
            consul config delete -kind service-router -name expense
            consul config write compose_configs/traffic_config/expense-resolver.hcl
            consul config write compose_configs/traffic_config/expense-splitter.hcl
            shift
            ;;
            test)
            for i in {0..10}
            do
                curl "${REPORT_ENDPOINT}/api/report/expense/version" -H 'Content-Type:application/json'
                echo ""
            done
            shift
            ;;
            remove)
            consul config delete -kind service-splitter -name expense
            consul config delete -kind service-resolver -name expense
            shift
            ;;
            *)
            echo "arg not found"
            exit 1
            ;;
        esac
    done
}

function route_traffic() {
    for arg in "$@"
    do
        case $arg in
            setup)
            consul config delete -kind service-splitter -name expense
            consul config write compose_configs/traffic_config/expense-resolver.hcl
            consul config write compose_configs/traffic_config/expense-router.hcl
            shift
            ;;
            test)
            echo "*** With Header ***"
            docker exec -it expense-report-report_proxy-1 curl -H 'X-Request-ID:java' 127.0.0.1:5001/api
            echo ""
            echo "*** Default (No Header) ***"
	        docker exec -it expense-report-report_proxy-1 curl 127.0.0.1:5001/api
            shift
            ;;
            remove)
            consul config delete -kind service-router -name expense
            consul config delete -kind service-resolver -name expense
            shift
            ;;
            *)
            echo "arg not found"
            exit 1
            ;;
        esac
    done

}

function report() {
    for arg in "$@"
    do
        case $arg in
            setup)
            docker-compose -f docker-compose-report.yml up -d
            shift
            ;;
            test)
            curl "${REPORT_ENDPOINT}/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa" \
                -H 'Content-Type:application/json'
            shift
            ;;
            remove)
            docker-compose -f docker-compose-report.yml down
            shift
            ;;
            *)
            echo "arg not found"
            exit 1
            ;;
        esac
    done
}

function circuit_break() {
    for arg in "$@"
    do
        case $arg in
            test)
            docker stop expense-report-expense-db-mssql-1
            for i in {1..1000}
            do
                curl -s -o /dev/null -w "%{http_code}" ${REPORT_ENDPOINT}/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa
                echo ""
                sleep 1
            done
            shift
            ;;
            reset)
            docker start expense-report-expense-db-mssql-1
            docker restart expense-report-expensedb_proxy_mssql-1
            shift
            ;;
            *)
            echo "arg not found"
            exit 1
            ;;
        esac
    done
}

function check_databases() {
    until curl -s --get ${CONSUL_HTTP_ADDR}/v1/health/checks/expense-db-mssql --data-urlencode filter="Status==passing" | grep passing
    do
        echo "Waiting for MSSQL database to start"
        sleep 1
    done
    until curl -s --get ${CONSUL_HTTP_ADDR}/v1/health/checks/expense-db-mysql --data-urlencode filter="Status==passing" | grep passing
    do
        echo "Waiting for MYSQL database to start"
        sleep 1
    done
}

case $1 in
    all)
    databases setup
    check_databases
    expense setup
    split_traffic setup
    report setup
    ;;
    databases)
    databases $2
    check_databases
    configure_vault_db $2
    ;;
    expense)
    expense $2
    ;;
    report)
    report $2
    ;;
    split)
    split_traffic $2
    ;;
    route)
    route_traffic $2
    ;;
    circuit_break)
    circuit_break $2
    ;;
    clean)
    split_traffic remove
    route_traffic remove
    report remove
    expense remove
    consul_server remove
    ;;
    *)
    echo $arg
    echo "cmd not found"
    ;;
esac