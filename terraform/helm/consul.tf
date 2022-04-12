data "hcp_consul_agent_kubernetes_secret" "cluster" {
  cluster_id = local.hcp_consul_cluster_id
}

locals {
  consul_secrets    = yamldecode(data.hcp_consul_agent_kubernetes_secret.cluster.secret)
  consul_root_token = yamldecode(local.hcp_consul_token_kubernetes_secret)
}

resource "kubernetes_secret" "hcp_consul_secret" {
  metadata {
    name        = local.consul_secrets.metadata.name
    annotations = {}
    labels      = {}
  }

  data = {
    gossipEncryptionKey = base64decode(local.consul_secrets.data.gossipEncryptionKey)
    caCert              = base64decode(local.consul_secrets.data.caCert)
  }

  type = local.consul_secrets.type
}

resource "kubernetes_secret" "hcp_consul_token" {
  metadata {
    name        = local.consul_root_token.metadata.name
    annotations = {}
    labels      = {}
  }

  data = {
    token = local.hcp_consul_token
  }

  type = local.consul_root_token.type
}

resource "helm_release" "consul" {
  depends_on = [kubernetes_secret.hcp_consul_secret, kubernetes_secret.hcp_consul_token]
  name       = "consul"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul_helm_version

  values = [
    templatefile("templates/consul.yaml", {
      CONSUL_ADDR = replace(local.hcp_consul_endpoint, "https://", "")
      K8s_HOST    = replace(local.kube_config.host, ":443", "")
    })
  ]

  set {
    name  = "global.image"
    value = "hashicorp/consul-enterprise:1.11.4-ent"
  }
}