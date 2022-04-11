resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.prefix}-cluster"
  location            = azurerm_resource_group.resources.location
  resource_group_name = azurerm_resource_group.resources.name
  dns_prefix          = var.prefix

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}