resource "boundary_scope" "global" {
  description  = "Global Scope"
  global_scope = true
  name         = "global"
  scope_id     = "global"
}

resource "boundary_scope" "org" {
  scope_id    = boundary_scope.global.id
  name        = local.boundary_organization
  description = "Organization scope for ${local.boundary_organization}"
}

resource "boundary_scope" "db_infra" {
  name                     = "db_infra"
  description              = "Database infrastructure project"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}