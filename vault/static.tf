// Static passwords at kv-v2

resource "vault_mount" "static" {
  path        = "${var.application}/static"
  type        = "kv-v2"
  description = "For ${var.application} static secrets"
}

// Create a MySQL database password for bootstrap

resource "vault_generic_secret" "database" {
  path = "${vault_mount.static.path}/database"

  data_json = <<EOT
{
  "db_login": "${var.db_username}",
  "db_login_password": "${var.db_password}"
}
EOT
}
