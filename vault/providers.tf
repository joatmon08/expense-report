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
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "vault" {}

provider "google" {}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
}
