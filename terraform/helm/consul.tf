data "hcp_consul_agent_kubernetes_secret" "cluster" {
  cluster_id = local.hcp_consul_cluster_id
}

data "hcp_consul_agent_helm_config" "cluster" {
  cluster_id          = local.hcp_consul_cluster_id
  kubernetes_endpoint = local.kube_config.host
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
    token = base64decode(local.consul_root_token.data.token)
  }

  type = local.consul_root_token.type
}

# resource "helm_release" "consul" {
#   depends_on = [kubernetes_secret.hcp_consul_secret, kubernetes_secret.hcp_consul_token]
#   name       = "consul"

#   repository = "https://helm.releases.hashicorp.com"
#   chart      = "consul"
#   version    = var.consul_helm_version

#   values = [
#     data.hcp_consul_agent_helm_config.cluster.config
#   ]

#   set {
#     name  = "externalServers.hosts"
#     value = "[\"${local.hcp_consul_endpoint}\"]"
#   }

#   set {
#     name  = "global.metrics.enabled"
#     value = "true"
#   }

#   set {
#     name  = "global.metrics.enableAgentMetrics"
#     value = "true"
#   }

#   set {
#     name  = "controller.enabled"
#     value = "true"
#   }

#   set {
#     name  = "prometheus.enabled"
#     value = "true"
#   }

#   set {
#     name  = "ui.enabled"
#     value = "true"
#   }

#   set {
#     name  = "controller.enabled"
#     value = "true"
#   }
# }