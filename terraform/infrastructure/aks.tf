data "tfe_ip_ranges" "addresses" {}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                    = var.prefix
  location                = azurerm_resource_group.resources.location
  resource_group_name     = azurerm_resource_group.resources.name
  dns_prefix              = var.prefix
  private_cluster_enabled = false

  default_node_pool {
    name           = "default"
    node_count     = 3
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.cluster.id

    tags = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}