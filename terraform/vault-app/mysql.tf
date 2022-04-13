// Database secrets engine for MySQL
resource "vault_mount" "mysql" {
  path = "${var.application}/database/mysql"
  type = "database"
}

data "vault_generic_secret" "mysql_admin" {
  path = local.vault_generic_secret_path_mysql
}

resource "vault_database_secret_backend_connection" "mysql" {
  backend       = vault_mount.mysql.path
  name          = "mysql"
  allowed_roles = [var.application_v2]
  mysql {
    connection_url = "{{username}}:{{password}}@tcp(localhost:${var.mysql_port})/"
    username       = var.mysql_username
    password       = data.vault_generic_secret.mysql_admin.data["db_login_password"]
  }
}

resource "vault_database_secret_backend_role" "mysql" {
  backend             = vault_mount.mysql.path
  name                = var.application_v2
  db_name             = vault_database_secret_backend_connection.mysql.name
  creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL PRIVILEGES ON DemoExpenses.expense_item TO '{{name}}'@'%';"]
}