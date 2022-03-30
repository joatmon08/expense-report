#!/bin/bash

DOTNET_VERSION="${DOTNET_VERSION:-6.0}"
JAVA_VERSION="${JAVA_VERSION:-2.6.5}"

MYSQL_VERSION="${MSQL_VERSION:-8}"
MSSQL_VERSION="${MSSQL_VERSION:-2019}"

function report() {
	docker build --no-cache -t joatmon08/report:dotnet-${DOTNET_VERSION} -f report/dotnet/Dockerfile .
}

function expense() {
    docker build --no-cache -t joatmon08/expense:java-${JAVA_VERSION}  expense/java/
	docker build --no-cache -t joatmon08/expense:dotnet-${DOTNET_VERSION} expense/dotnet/
}

function database() {
    docker build --no-cache -t joatmon08/expense-db:mssql database/mssql/
	docker build --no-cache -t joatmon08/expense-db:mysql database/mysql/
}

function database_push() {
    docker push joatmon08/expense-db:mssql-${MSSQL_VERSION}
	docker push joatmon08/expense-db:mysql-${MYSQL_VERSION}
}

function app_push() {
    docker push joatmon08/report:dotnet-${DOTNET_VERSION}
    docker push joatmon08/expense:java-${JAVA_VERSION}
    docker push joatmon08/expense:dotnet-${DOTNET_VERSION}
}

for arg in "$@"
do
    case $arg in
        all)
        database
        database_push
        expense
        report
        app_push
        shift
        ;;
        expense)
        expense
        shift
        ;;
        report)
        report
        shift
        ;;
        push)
        app_push
        shift
        ;;
        *)
        echo "cmd not found"
        shift
        ;;
    esac
done