resource "helm_release" "consul" {
  depends_on = [azurerm_kubernetes_cluster.cluster, kubernetes_secret.consul_ca]
  name       = "consul"
  namespace  = kubernetes_namespace.consul.metadata.0.name

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul_helm_version

  values = [
    templatefile("templates/consul.yaml", {
      CONSUL_DATACENTER        = "dc1"
      K8S_SECRET_FOR_CONSUL_CA = kubernetes_secret.consul_ca.metadata.0.name
    })
  ]
}