// Database secrets engine for MySQL

resource "vault_mount" "db" {
  path = "${var.application}/database"
  type = "database"
}

resource "vault_database_secret_backend_connection" "mysql" {
  backend       = "vault_mount.db.path"
  name          = "mysql"
  allowed_roles = [var.application]
  mysql {
    connection_url = "${var.db_username}:${var.db_password}@tcp(${var.db_service}:${var.db_port})"
  }
  depends_on = [aws_db_instance.example]
}

resource "vault_database_secret_backend_role" "role" {
  backend             = "${var.application}/database"
  name                = "application"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"]
}