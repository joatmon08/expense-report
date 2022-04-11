## Boundary exports to set up dynamic host catalog ##

output "subscription_id" {
  value       = data.azurerm_subscription.current.subscription_id
  description = "Subscription ID for Azure"
  sensitive   = true
}

## Boundary exports to set up OIDC authentication method ##
output "boundary_oidc_azure_ad" {
  value = {
    tenant_id     = data.azurerm_client_config.current.tenant_id
    client_id     = azuread_application.oidc.application_id
    client_secret = azuread_application_password.oidc.value
    issuer        = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
  }
  sensitive   = true
  description = "Azure AD attributes for Boundary's OIDC authentication method application"
}

output "boundary_oidc_application_id" {
  value       = azuread_application.oidc.application_id
  description = "Azure AD Application ID for Boundary's OIDC authentication method application"
}

## Auzre AD Users and Groups ##
output "azuread_group_database" {
  value       = azuread_group.database.object_id
  description = "Object ID of Azure AD group for database admin"
}

output "azuread_user_database" {
  value = {
    object_id           = data.azuread_user.existing.object_id
    name                = data.azuread_user.existing.display_name
    user_principal_name = data.azuread_user.existing.user_principal_name
  }
  description = "List of Name and Object ID of Azure AD user for database administrator"
  sensitive   = true
}

## Boundary exports to set up Terraform provider ##
output "boundary_recovery_service_principal_tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "Boundary's recovery key in Azure Key Vault. Tenant ID."
}

output "boundary_recovery_service_principal_client_id" {
  value       = module.install.client_id
  description = "Boundary's recovery key in Azure Key Vault. Client ID."
}

output "boundary_recovery_service_principal_client_secret" {
  value       = module.install.client_secret
  sensitive   = true
  description = "Boundary's recovery key in Azure Key Vault. Client secret."
}

output "boundary_url" {
  value       = module.install.url
  description = "URL of Boundary"
}

output "boundary_fqdn" {
  value       = module.install.public_dns_name
  description = "Domain name of Boundary"
}

output "key_vault_name" {
  value       = module.install.key_vault_name
  description = "Name of Azure Key Vault with Boundary recovery keys"
}

output "private_key" {
  value       = base64encode(module.install.private_key)
  sensitive   = true
  description = "Private key file to SSH into Boundary controller, worker, and backend VMs"
}

## Azure SQL Server Outputs ##
output "mssql_url" {
  value       = azurerm_mssql_server.database.fully_qualified_domain_name
  description = "MSSQL database domain name"
}

output "mssql_ip_address" {
  value       = azurerm_private_endpoint.boundary.private_service_connection.0.private_ip_address
  description = "MSSQL database private IP address"
}

output "mssql_password" {
  value       = random_password.database.result
  description = "MSSQL database admin password"
  sensitive   = true
}

output "mssql_server_name" {
  value       = azurerm_mssql_server.database.name
  description = "MSSQL server name"
}

output "mssql_database_name" {
  value       = azurerm_mssql_database.database.name
  description = "MSSQL database name"
}

output "mssql_admin_username" {
  value       = data.azuread_user.existing.user_principal_name
  description = "Azure AD database admin username to log into the MSSQL database"
  sensitive   = true
}

## Vault ##
output "vault_url" {
  value = module.vault.url
}

output "vault_fqdn" {
  value = module.vault.public_dns_name
}

output "vault_private_key" {
  value       = base64encode(module.vault.private_key)
  sensitive   = true
  description = "Private key file to SSH into Vault VMs"
}

output "vault_mssql_ip_address" {
  value       = azurerm_private_endpoint.vault.private_service_connection.0.private_ip_address
  description = "MSSQL database private IP address for Vault to connect"
}

## Kubernetes ##
output "kube_config" {
  value     = azurerm_kubernetes_cluster.cluster.kube_config.0
  sensitive = true
}