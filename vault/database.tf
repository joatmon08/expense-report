// Database secrets engine for MySQL

resource "vault_mount" "db" {
  path = "${var.application}/database"
  type = "database"
}

resource "vault_database_secret_backend_connection" "mysql" {
  backend       = vault_mount.db.path
  name          = "mysql"
  allowed_roles = [var.application]
  mysql {
    connection_url = "${var.db_username}:${var.db_password}@tcp(localhost:${var.db_port})/"
  }
}

resource "vault_database_secret_backend_role" "role" {
  backend             = "${var.application}/database"
  name                = var.application
  db_name             = vault_database_secret_backend_connection.mysql.name
  creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL PRIVILEGES ON DemoExpenses.expense_item TO '{{name}}'@'%';"]
}