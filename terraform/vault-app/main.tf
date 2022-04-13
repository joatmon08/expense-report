terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.4.1"
    }
  }
}

provider "vault" {
  address = local.vault_endpoint
  token   = local.vault_token
}
