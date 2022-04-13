output "vault_endpoint" {
  value = local.vault_endpoint
}

output "vault_token" {
  value     = local.vault_token
  sensitive = true
}

output "vault_kubernetes_auth_backend" {
  value = vault_auth_backend.kubernetes.path
}

output "vault_generic_secret_path_mysql" {
  value = vault_generic_secret.mysql.path
}

output "vault_generic_secret_path_mssql" {
  value = vault_generic_secret.mssql.path
}