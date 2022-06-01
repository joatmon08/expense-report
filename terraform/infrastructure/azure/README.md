# Example Terraform Deployment for Consul on AKS

Log into Azure.

Initialize Terraform.

```shell
terraform init
```

Run Terraform. This will deploy a publicly accessible AKS cluster named `checkpoint` in
the resource group `checkpoint-expense-report`.

```shell
terraform apply
```

The Terraform creates a few components:

- Self-signed root CA for Consul

- AKS Cluster (publicly accessible)

- Kubernetes namespace for Consul (called `consul`)

- Kubernetes secret for Consul CA
  ```shell
  $ kubectl get secrets -n consul consul-ca

    NAME        TYPE                DATA   AGE
    consul-ca   kubernetes.io/tls   2      11m
  ```

- Consul cluster via Consul Helm chart in `consul` namespace
  ```shell
  $ kubectl get pods -n consul

    NAME                                           READY   STATUS    RESTARTS   AGE
    consul-client-bw7kg                            1/1     Running   0          11m
    consul-client-vqksw                            1/1     Running   0          11m
    consul-client-xh8hh                            1/1     Running   0          11m
    consul-connect-injector-7c4ccd7849-c7g44       1/1     Running   0          5m40s
    consul-connect-injector-7c4ccd7849-wfwr5       1/1     Running   0          5m30s
    consul-controller-6655cfc5fc-kjf9m             1/1     Running   0          11m
    consul-ingress-gateway-5bd8698dd9-ckxn4        2/2     Running   0          5m40s
    consul-server-0                                1/1     Running   0          3m12s
    consul-server-1                                1/1     Running   0          4m18s
    consul-server-2                                1/1     Running   0          5m38s
    consul-webhook-cert-manager-7ff948f845-5mmlg   1/1     Running   0          11m
  ```

To access the Consul UI, connect to the `consul-ui` service's load balancer.

> Note: You are using a self-signed certificate so your browser may warn you the certificate authority is invalid. Proceed anyway.

```shell
export CONSUL_HTTP_ADDR=https:/$(kubectl get -n consul svc/consul-ui --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Log into the Consul UI using the bootstrap token.

```shell
export CONSUL_HTTP_TOKEN=$(kubectl get -n consul secrets/consul-bootstrap-acl-token --template='{{.data.token | base64decode }}')
```