resource "boundary_host_catalog_static" "db_admin" {
  name        = "database"
  description = "MSSSQL database"
  scope_id    = boundary_scope.db_infra.id
}

resource "boundary_host_static" "db_admin" {
  type            = "static"
  name            = "database"
  description     = "MSSSQL database"
  address         = local.database_url
  host_catalog_id = boundary_host_catalog_static.db_admin.id
}

resource "boundary_host_set_static" "db_admin" {
  type            = "static"
  name            = "database"
  description     = "Host set for MSSQL Database"
  host_catalog_id = boundary_host_catalog_static.db_admin.id
  host_ids        = [boundary_host_static.db_admin.id]
}

resource "boundary_target" "db_admin" {
  type                     = "tcp"
  name                     = "database"
  description              = "MSSQL Database"
  scope_id                 = boundary_scope.db_infra.id
  session_connection_limit = 2
  default_port             = 1433
  host_source_ids = [
    boundary_host_set_static.db_admin.id
  ]
}