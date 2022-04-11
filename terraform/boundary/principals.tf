## Set up Azure AD groups for database admins to log in
resource "boundary_managed_group" "database" {
  auth_method_id = boundary_auth_method_oidc.azuread.id
  description    = "Database administrators team managed group linked to Azure AD"
  name           = "db-admins"
  filter         = "\"${local.azuread_group_db}\" in \"/token/groups\""
}