# Expense Report

A set of .NET Core and Java Spring Boot services that records expenses
and returns a report for a given trip identifier.

## What it does

Expense Report uses Consul for service mesh, application configuration,
and feature toggling capabilities.

For multiple frameworks, Consul Connect provides service mesh capabilities
that enable a consistent method of configuring:

* Service Discovery
* Network Policy (via Consul intentions)
* Load balancing
* Additional Tracing Metadata
* Circuit Breaking (AKA Outlier Detection)

## Expense Report Application

The report application connects to the expense application, which retrieves information
from a database. You'll find two versions of the expense application, one in .NET and one in Java.

![How Expense Report Works](./image/diagram.png)

Below are the most useful endpoints for the `expense` service:

- GET `/api/expense`: Get a list of expenses
- POST `/api/expense`: Create a new expense. See schema under `example/expense.json`.

Java defaults to `:8080` and .NET Core
defaults to `:5001`.

Below are the most useful endpoints for the `report` service:

- GET `/api/report/expense/version`: Gets the version of the expense application for debugging
- GET `/api/report/trip/${trip_id}`: Gets a list of expenses for a given trip.

`${trip_id}` denotes the trip identifer passed in the body of the expense item
created in the `POST` method to `expense`. Since the `report` application is
currently only available in .NET Core, it runs by default on port `:5002`.
## Kubernetes

![How Expense Report Works](./image/kubernetes.png)

### Prerequisites

- Kubernetes. The configurations use a cluster set up in GKE as per the `/terraform` directory.
You can use the Terraform to create a Kubernetes cluster for all of the applications.

- [Locust](https://locust.io/) to mimic user traffic.

- Consul 1.10+

- Vault 1.8+

- Terraform 1.0+. For creating cluster and configuring Vault.

### Setup

You can run `make k8s` to deploy all of the components you'll need to run in the cluster
to the `default` namespace.

```shell
$ make k8s
```

The order of operations __does matter__, especially because we're enabling tracing and metrics
in the cluster.

- Consul: by Helm chart, review `helm/consul.yaml` for values.

- Grafana: by Helm chart, review `helm/grafana.yaml` for values. __Not in service mesh.__
  It adds two dashboards.
  - Expense Report (custom application dashboard)
  - Kong (default dashboard for Kong metrics)

- Jaeger: for tracing, review `kubernetes/jaeger.yaml`. __Not in service mesh.__

- Ingress with Kong API Gateway: by Helm chart, review `helm/kong.yaml` for values.
  It installs two plugins.
  - Zipkin (for tracing)
  - Prometheus (for metrics)

- Vault: by Helm chart, review `helm/consul.yaml` for values.
  It has a configuration expressed in Terraform under `vault/` and adds the following.
  - Database root password for MSSQL as a static secret.
  - Database root password for MySQL as a static secret.
  - Database secrets engine for MSSQL username and password for expense application.
  - Database secrets engine for MySQL username and password for expense application.

- Microsoft SQL Server Database (MSSQL) 2019: for expense application. Table under `DemoExpenses`.

- MySQL Database: for expense application, version 2. Table under `DemoExpenses`.

- Expense Application: two versions. Uses a Consul [service splitter](https://www.consul.io/docs/connect/config-entries/service-splitter)
  to manage traffic between versions.
  - `joatmon08/expense:dotnet`: Uses Microsoft SQL Server with a .NET Core 2.2 application.
  - `joatmon08/expense:java-v2`: Uses MySQL with a Sprint Boot application.

- Report Application: two versions. Uses Consul [service router](https://www.consul.io/docs/connect/config-entries/service-router)
  to route traffic based on headers for debugging.
  - `joatmon08/report:dotnet-v2`: Does not include a field for total reimbursable expenses.
  - `joatmon08/report:dotnet-v3`: Does include a field for total reimbursable expenses.

### Cleanup

Run `make clean-k8s` to remove everything from the Kubernetes cluster.

```shell
$ make clean-k8s
```

## Docker-Compose

This is for local demonstration purposes only. The Consul server
has a different configuration than what you would expect for production!
It does not use Vault for dynamic secrets.
### Prerequisites

* Docker
* docker-compose

### Startup

To start, bring up the Consul server, MySQL database, Microsoft SQL
Server database, Jaeger for tracing,
the expense services in .NET and Java, and the report service
in .NET.

```shell
bash scripts/compose.sh all
```

This will not only bring up the stack but add the application configuration
for the `expense` service.

![Consul UI after bringing up main stack](./image/makeall.png)

Open Jaeger on http://localhost:16686 and Consul on http://localhost:8500.

### Service Networking with Consul Service Mesh

To try out:

* Service discovery
* Network policy
* Load balancing
* Additional tracing metadata

#### Traffic Splitting

When you start the demo by default, it sets a `service-splitter`
and `service-router` that divides traffic equally between the Java
and .NET applications.

Test this by calling the version API endpoint. You'll notice half the
responses are `6.0` (.NET) and `0.0.1-SNAPSHOT` (Java). This means
that the proxy is separating traffic between the two service
instances for expense.

```shell
bash scripts/compose.sh split test
```

You can adjust `compose_configs/traffic_config/expense-splitter.hcl`
with the ratio of your choice to test this further. Re-apply
the configuration with the following command:

```shell
bash scripts/compose.sh split setup
```

#### Route Based on Header

Sometimes, you want to test an application but only
if you pass a specific header. You can set a `service-resolver`
with a `service-router`.

Set them up using the following command.

```shell
bash scripts/compose.sh route setup
```

Test this by going into the report proxy's container
and passing a header. You'll notice that the response
routes to `0.0.1-SNAPSHOT` (Java) if you set the header
or `6.0` (.NET) by default.

```shell
bash scripts/compose.sh route test
```

#### Circuit Breaking

To try __circuit breaking__ (outlier detection in Envoy), note that it the
configuration requires an unsupported Consul escape hatch override. It cannot
have any service resolver or splitter configuration.

Stop the Microsoft SQL Server database. This will fail calls to the .NET Core
`expense` service. As a result, circuit breaker will trip in the `report`
service and route all traffic to the Java `expense` service.

Issue the command for testing.

```shell
bash scripts/compose.sh circuit_break test
```

After you are done, reset the circuit breaker.

```shell
bash scripts/compose.sh circuit_break reset
```

### Clean Up

Remove everything using a command.

```shell
bash scripts/compose.sh clean
```