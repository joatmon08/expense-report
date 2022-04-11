resource "azuread_application" "oidc" {
  display_name = "${azurerm_resource_group.resources.name}-boundary-oidc-auth"
  owners       = [data.azuread_client_config.current.object_id]

  group_membership_claims = ["All"]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"
    }

    resource_access {
      id   = "b4e74841-8e56-480b-be8b-910348b18b4c" # User.ReadWrite
      type = "Scope"
    }

    resource_access {
      id   = "98830695-27a2-44f7-8c18-0c3ebc9698f6" # GroupMember.Read.All
      type = "Role"
    }
  }

  web {
    redirect_uris = ["${module.install.url}/v1/auth-methods/oidc:authenticate:callback"]
  }
}

resource "azuread_application_password" "oidc" {
  application_object_id = azuread_application.oidc.object_id
  display_name          = "Boundary secret"
}

resource "azuread_service_principal" "oidc" {
  application_id = azuread_application.oidc.application_id
  owners         = [data.azuread_client_config.current.object_id]
}