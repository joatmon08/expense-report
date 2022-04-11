terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = local.kube_config.host
    username               = local.kube_config.username
    password               = local.kube_config.password
    client_certificate     = base64decode(local.kube_config.client_certificate)
    client_key             = base64decode(local.kube_config.client_key)
    cluster_ca_certificate = base64decode(local.kube_config.cluster_ca_certificate)
  }
}