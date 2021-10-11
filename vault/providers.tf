terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~>2.24"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.5"
    }
    google = {
      source  = "hashicorp/google"
      version = "~>3.86"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~>2.14"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

# Configuration to retrieve Kubernetes information from a GKE cluster
# provider "google" {}

# data "google_client_config" "default" {}

# data "google_container_cluster" "cluster" {
#   name     = var.cluster_name
#   location = var.cluster_zone
# }

# provider "kubernetes" {
#   host                   = "https://${data.google_container_cluster.cluster.endpoint}"
#   token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
# }

provider "digitalocean" {}

data "digitalocean_kubernetes_cluster" "cluster" {
  name = var.cluster_name
}

locals {
  host = data.digitalocean_kubernetes_cluster.cluster.kube_config.0.host
}

provider "kubernetes" {
  host                   = local.host
  token                  = data.digitalocean_kubernetes_cluster.cluster.kube_config.0.token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
}

# Retrieve vault address for Vault provider
data "kubernetes_service" "vault" {
  metadata {
    name = "vault-ui"
  }
}

provider "vault" {
  address = "http://${data.kubernetes_service.vault.status.0.load_balancer.0.ingress.0.ip}:8200"
}
