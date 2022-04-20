// Static passwords at kv-v2

resource "vault_mount" "static" {
  path        = "${var.application}/static"
  type        = "kv-v2"
  description = "For ${var.application} static secrets"
}

// Create a MySQL database password for bootstrap
resource "random_password" "mysql" {
  length           = 12
  special          = true
  override_special = "!#"
}

resource "vault_generic_secret" "mysql" {
  path = "${vault_mount.static.path}/mysql"

  data_json = <<EOT
{
  "db_login_password": "${random_password.mysql.result}"
}
EOT
}

resource "random_password" "mssql" {
  length           = 12
  special          = false
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
}

resource "vault_generic_secret" "mssql" {
  path = "${vault_mount.static.path}/mssql"

  data_json = <<EOT
{
  "db_login_password": "${random_password.mssql.result}"
}
EOT
}

