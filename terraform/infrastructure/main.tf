terraform {
  required_version = ">=1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.95.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.26.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.31.0"
    }
  }
}

provider "hcp" {}

provider "azurerm" {
  features {}
}

provider "tfe" {}