terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.2"
    }
  }
}

provider "kubernetes" {
  host                   = local.kube_config.host
  username               = local.kube_config.username
  password               = local.kube_config.password
  client_certificate     = base64decode(local.kube_config.client_certificate)
  client_key             = base64decode(local.kube_config.client_key)
  cluster_ca_certificate = base64decode(local.kube_config.cluster_ca_certificate)
}

# Retrieve vault address for Vault provider
data "kubernetes_service" "vault" {
  metadata {
    name = "vault-ui"
  }
}

provider "vault" {
  address   = local.hcp_vault_endpoint
  token     = local.hcp_vault_token
  namespace = "admin"
}
