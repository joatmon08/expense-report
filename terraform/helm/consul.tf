resource "helm_release" "consul" {
  name = "consul"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul_helm_version

  values = [
    templatefile("templates/consul.yaml", {
      consul_datacenter = var.consul_datacenter
    })
  ]
}