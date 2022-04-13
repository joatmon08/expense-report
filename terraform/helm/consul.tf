resource "kubernetes_secret" "consul" {
  metadata {
    name        = "consul-ca-cert"
    annotations = {}
    labels      = {}
  }

  data = {
    "tls.crt" = base64decode(var.consul_agent_ca_pem)
    "tls.key" = base64decode(var.consul_agent_ca_key_pem)
  }

  type = "Opaque"
}

resource "helm_release" "consul" {
  name = "consul"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul_helm_version

  values = [
    file("templates/consul.yaml")
  ]
}