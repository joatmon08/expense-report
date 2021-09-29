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
path "${var.application}/static/mysql/*" {
  capabilities = ["read"]
}

path "${vault_mount.db.path}/*" {
  capabilities = ["read"]
}
EOT
}

