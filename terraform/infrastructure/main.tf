terraform {
  required_version = ">=1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.95.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.17.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  controller_subnet_id = module.vnet.vnet_subnets[0]
  worker_subnet_id     = module.vnet.vnet_subnets[1]
  backend_subnet_id    = module.vnet.vnet_subnets[2]
  vault_subnet_id      = module.vnet.vnet_subnets[3]
}

resource "time_sleep" "wait" {
  depends_on      = [module.vnet]
  create_duration = "30s"
}

module "install" {
  depends_on           = [time_sleep.wait, azurerm_resource_group.resources, module.vnet]
  source               = "joatmon08/boundary/azurerm"
  version              = "0.0.1"
  resource_group_name  = azurerm_resource_group.resources.name
  location             = var.location
  controller_subnet_id = local.controller_subnet_id
  worker_subnet_id     = local.worker_subnet_id
  tags                 = var.tags
}

module "vault" {
  depends_on          = [azurerm_resource_group.resources, module.install]
  source              = "joatmon08/vault/azurerm"
  version             = "0.0.1"
  resource_group_name = azurerm_resource_group.resources.name
  location            = var.location
  server_subnet_id    = local.vault_subnet_id
  tags                = var.tags
}