resource "azurerm_resource_group" "resources" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "cluster" {
  name                = var.prefix
  location            = azurerm_resource_group.resources.location
  resource_group_name = azurerm_resource_group.resources.name
  address_space       = [var.network_cidr_block]
}

# Create a Subnet for AKS
resource "azurerm_subnet" "cluster" {
  name                                           = "aks"
  virtual_network_name                           = azurerm_virtual_network.cluster.name
  resource_group_name                            = azurerm_resource_group.resources.name
  address_prefixes                               = [var.subnet_cidr_block]
  enforce_private_link_endpoint_network_policies = true
}