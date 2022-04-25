resource "helm_release" "consul" {
  name = "consul"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul_helm_version

  values = [
    local.consul_helm_config
  ]

  set {
    name  = "global.image"
    value = "hashicorp/consul:${local.consul_version}"
  }

  set {
    name  = "controller.enabled"
    value = "true"
  }
}