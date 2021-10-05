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

resource "vault_policy" "application" {
  name = var.application

  policy = <<EOT
path "${vault_mount.mssql.path}/creds/${var.application}" {
  capabilities = ["read"]
}
EOT
}


resource "vault_policy" "application_v2" {
  name = var.application_v2

  policy = <<EOT
path "${vault_mount.mysql.path}/creds/${var.application_v2}" {
  capabilities = ["read"]
}
EOT
}
