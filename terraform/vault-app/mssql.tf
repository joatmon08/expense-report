// Database secrets engine for MSSQL
resource "vault_mount" "mssql" {
  path = "${var.application}/database/mssql"
  type = "database"
}

data "vault_generic_secret" "mssql_admin" {
  path = local.vault_generic_secret_path_mssql
}

resource "vault_database_secret_backend_connection" "mssql" {
  backend       = vault_mount.mssql.path
  name          = "mssql"
  allowed_roles = [var.application]
  mssql {
    connection_url = "sqlserver://{{username}}:{{password}}@localhost:${var.mssql_port}"
    username       = var.mssql_username
    password       = data.vault_generic_secret.mssql_admin.data["db_login_password"]
  }
}

resource "vault_database_secret_backend_role" "mssql" {
  backend             = vault_mount.mssql.path
  name                = var.application
  db_name             = vault_database_secret_backend_connection.mssql.name
  creation_statements = ["CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}';USE DemoExpenses;CREATE USER [{{name}}] FOR LOGIN [{{name}}];GRANT SELECT,UPDATE,INSERT,DELETE TO [{{name}}];"]
}