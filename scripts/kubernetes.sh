#!/bin/bash

export VAULT_ADDR=$(cd terraform/helm && terraform output -raw vault_endpoint)
export VAULT_TOKEN=$(cd terraform/helm && terraform output -raw vault_token)
CONSUL_HTTP_ADDR=$(cd terraform/helm && terraform output -raw consul_endpoint)
INGRESS_ENDPOINT=http://$(kubectl get svc report-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

function tracing() {
    for arg in "$@"
    do
        case $arg in
            setup)
            kubectl apply -f kubernetes/tracing/
            kubectl rollout status deployment jaeger
            shift
            ;;
            remove)
            kubectl delete -f kubernetes/tracing/ --ignore-not-found
            shift
            ;;
            *)
            echo "arg not found"
            exit 1
            ;;
        esac
    done
}

function gateway() {
    for arg in "$@"
    do
        case $arg in
            setup)
            kubectl apply -f kubernetes/gateway/
            shift
            ;;
            test)
            shift
            ;;
            remove)
            kubectl delete -f kubernetes/gateway/ --ignore-not-found
            shift
            ;;
            *)
            echo "arg not found"
            exit 1
            ;;
        esac
    done
}

function databases() {
    for arg in "$@"
    do
        case $arg in
            setup)
            kubectl apply -f kubernetes/databases/
            kubectl rollout status deployment expense-db-mssql
            kubectl rollout status deployment expense-db-mysql
            check_databases
            shift
            ;;
            remove)
            kubectl delete -f kubernetes/databases/ --ignore-not-found
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

function vault_db() {
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
            cd terraform/vault-app && terraform destroy
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
            curl -X POST "${INGRESS_ENDPOINT}/api/expense" \
                -H 'Content-Type:application/json' -d @example/gas.json
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
            kubectl apply -f kubernetes/splitter.yaml
            shift
            ;;
            test)
            for i in {0..10}
            do
                curl "${INGRESS_ENDPOINT}/api/report/expense/version" -H 'Content-Type:application/json'
                echo ""
            done
            shift
            ;;
            remove)
            kubectl delete -f kubernetes/splitter.yaml --ignore-not-found
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
            kubectl apply -f kubernetes/report/
            shift
            ;;
            test)
            curl "${INGRESS_ENDPOINT}/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa" \
                -H 'Content-Type:application/json'
            shift
            ;;
            remove)
            kubectl delete -f kubernetes/report/ --ignore-not-found
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
            kubectl apply -f kubernetes/router.yaml
            shift
            ;;
            test)
            echo "*** With Header ***"
            curl -s -H 'X-Debug:1' ${INGRESS_ENDPOINT}/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa | jq .
            echo ""
            echo "*** Default (No Header) ***"
	        curl -s ${INGRESS_ENDPOINT}/api/report/trip/d7fd4bf6-aeb9-45a0-b671-85dfc4d095aa | jq .
            shift
            ;;
            remove)
            kubectl delete -f kubernetes/router.yaml --ignore-not-found
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
            kubectl delete --ignore-not-found deployment expense-db-mysql
            locust --autostart --autoquit 30 -f locust/locustfile.py --users 30 --spawn-rate 5 -t 15m \
                -H ${INGRESS_ENDPOINT}
            shift
            ;;
            reset)
            databases
            kubectl delete pods -l app=expense
            kubectl delete pods -l 'app.kubernetes.io/name=kong'
            shift
            ;;
            *)
            echo "arg not found"
            exit 1
            ;;
        esac
    done
}

case $1 in
    all)
    tracing setup
    databases setup
    check_databases
    vault_db setup
    expense setup
    report setup
    ;;
    tracing)
    tracing $2
    gateway $2
    ;;
    databases)
    databases $2
    vault_db $2
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
    vault_db remove
    databases remove
    tracing remove
    ;;
    *)
    echo $arg
    echo "cmd not found"
    ;;
esac