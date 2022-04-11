output "azuread_auth_method_id" {
  value       = boundary_auth_method_oidc.azuread.id
  description = "Azure AD auth method ID"
}

output "database_admin_target_id" {
  value       = boundary_target.db_admin.id
  description = "Target ID for static MSSQL endpoint for database admins"
}