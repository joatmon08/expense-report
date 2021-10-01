// Static passwords at kv-v2

resource "vault_mount" "static" {
  path        = "${var.application}/static"
  type        = "kv-v2"
  description = "For ${var.application} static secrets"
}

// Create a MySQL database password for bootstrap

resource "vault_generic_secret" "mysql" {
  path = "${vault_mount.static.path}/mysql"

  data_json = <<EOT
{
  "db_login_password": "${var.mysql_password}"
}
EOT
}

resource "vault_generic_secret" "mssql" {
  path = "${vault_mount.static.path}/mssql"

  data_json = <<EOT
{
  "db_login_password": "${var.mssql_password}"
}
EOT
}

