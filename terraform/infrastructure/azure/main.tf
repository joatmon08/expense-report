terraform {
  required_version = ">=1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.95.0"
    }
    # hcp = {
    #   source  = "hashicorp/hcp"
    #   version = "~> 0.25.0"
    # }
  }
}

# provider "hcp" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resources" {
  name     = local.resource_group_name
  location = var.location
}