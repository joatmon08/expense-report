// Database secrets engine for MySQL
resource "vault_mount" "mysql" {
  path = "${var.application}/database/mysql"
  type = "database"
}

resource "vault_database_secret_backend_connection" "mysql" {
  backend       = vault_mount.mysql.path
  name          = "mysql"
  allowed_roles = [var.application_v2]
  mysql {
    connection_url = "${var.mysql_username}:${var.mysql_password}@tcp(localhost:${var.mysql_port})/"
  }
}

resource "vault_database_secret_backend_role" "mysql" {
  backend             = vault_mount.mysql.path
  name                = var.application_v2
  db_name             = vault_database_secret_backend_connection.mysql.name
  creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL PRIVILEGES ON DemoExpenses.expense_item TO '{{name}}'@'%';"]
}

// Database secrets engine for MSSQL
resource "vault_mount" "mssql" {
  path = "${var.application}/database/mssql"
  type = "database"
}

resource "vault_database_secret_backend_connection" "mssql" {
  backend       = vault_mount.mssql.path
  name          = "mssql"
  allowed_roles = [var.application]
  mssql {
    connection_url = "sqlserver://${var.mssql_username}:${var.mssql_password}@localhost:${var.mssql_port}"
  }
}

resource "vault_database_secret_backend_role" "mssql" {
  backend             = vault_mount.mssql.path
  name                = var.application
  db_name             = vault_database_secret_backend_connection.mssql.name
  creation_statements = ["CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}';USE DemoExpenses;CREATE USER [{{name}}] FOR LOGIN [{{name}}];GRANT SELECT,UPDATE,INSERT,DELETE TO [{{name}}];"]
}