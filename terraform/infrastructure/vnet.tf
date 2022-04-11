resource "azurerm_resource_group" "resources" {
  name     = local.resource_group_name
  location = var.location
}

# Virtual network with three subnets for controller, workers, and backends
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "~> 2.0"
  resource_group_name = azurerm_resource_group.resources.name
  vnet_name           = azurerm_resource_group.resources.name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names

  # Service endpoints used for Key Vault and Postgres DB access
  subnet_service_endpoints = {
    (var.subnet_names[0]) = ["Microsoft.KeyVault", "Microsoft.Sql"]
    (var.subnet_names[1]) = ["Microsoft.KeyVault", "Microsoft.Sql"]
    (var.subnet_names[2]) = ["Microsoft.Sql"]
    (var.subnet_names[3]) = ["Microsoft.Sql"]
  }

  subnet_enforce_private_link_endpoint_network_policies = {
    (var.subnet_names[1]) = true
    (var.subnet_names[2]) = true
    (var.subnet_names[3]) = true
  }

  tags = var.tags

  depends_on = [azurerm_resource_group.resources]
}