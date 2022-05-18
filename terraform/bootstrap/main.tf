terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.31.0"
    }
  }
}

provider "tfe" {}