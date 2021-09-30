resource "vault_policy" "db" {
  name = var.db_service

  policy = <<EOT
path "${var.application}/static/data/mysql" {
  capabilities = ["read"]
}
EOT
}


resource "vault_policy" "application" {
  name = var.application

  policy = <<EOT
path "${vault_mount.db.path}/creds/expense" {
  capabilities = ["read"]
}
EOT
}

