locals {
  database_group = "${azurerm_resource_group.resources.name}-database"
}

data "azuread_user" "existing" {
  user_principal_name = var.azure_database_admin
}

resource "azuread_group" "database" {
  display_name     = local.database_group
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  members          = [data.azuread_user.existing.object_id]
}