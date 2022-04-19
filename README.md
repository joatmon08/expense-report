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

`${trip_id}` denotes the trip identifier passed in the body of the expense item
created in the `POST` method to `expense`. Since the `report` application is
currently only available in .NET Core, it runs by default on port `:5002`.
## Kubernetes

![How Expense Report Works](./image/kubernetes.png)

### Prerequisites

- Kubernetes. The configurations use a cluster set up in GKE as per the `/terraform` directory.
You can use the Terraform to create a Kubernetes cluster for all of the applications.

- [Locust](https://locust.io/) to mimic user traffic.

- Consul 1.11+

- Vault 1.9+

- Terraform 1.0+. For creating cluster and configuring Vault.

- Azure
  - Create a service principal with owner access to the subscription.

- Terraform Cloud account and three workspaces

    - `infrastructure`: working directory under `terraform/infrastructure`
       - Add Azure credentials
       - `prefix` variable for identification

    - `helm`: working directory under `terraform/helm`
       - `prefix` variable for identification
       - `vault_token` variable for logging into Vault
       - `tfc_workspace` variable referencing `infrastructure`
       - `tfc_organization` variable referencing your TFC organization

    - `vault`: working directory under `terraform/vault`
       - `tfc_workspace` variable referencing `helm`
       - `tfc_organization` variable referencing your TFC organization

### Create resources

- Run `terraform apply` for `infrastructure` workspace
- Run `terraform apply` for `helm` workspace
- Run `terraform apply` for `vault` workspace

### Deploy everything to Kubernetes

Deploy tracing and gateway.

```shell
bash scripts/kubernetes.sh tracing setup
```

Deploy databases. Enter `yes` to continue.

```shell
bash scripts/kubernetes.sh databases setup
```

Deploy expense service.

```shell
bash scripts/kubernetes.sh expense setup
```

Deploy report service.

```shell
bash scripts/kubernetes.sh report setup
```

Deploy split traffic configuration.

```shell
bash scripts/kubernetes.sh split setup
```

Deploy route traffic configuration.

```shell
bash scripts/kubernetes.sh route setup
```

### Cleanup

Remove everything from the Kubernetes cluster.

```shell
bash scripts/kubernetes.sh clean
```

Delete everything from the `vault` TFC workspace.

Delete everything from the `helm` TFC workspace.

Delete everything from the `infrastructure` TFC workspace.

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