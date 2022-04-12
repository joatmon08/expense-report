resource "vault_policy" "mssql" {
  name = var.mssql_service

  policy = <<EOT
path "${var.application}/static/data/mssql" {
  capabilities = ["read"]
}
EOT
}

resource "vault_policy" "mysql" {
  name = var.mysql_service

  policy = <<EOT
path "${var.application}/static/data/mysql" {
  capabilities = ["read"]
}
EOT
}