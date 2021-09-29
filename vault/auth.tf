resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "cluster" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://${data.google_container_cluster.cluster.endpoint}"
  kubernetes_ca_cert     = data.kubernetes_secret.vault.data["ca.crt"]
  token_reviewer_jwt     = data.kubernetes_secret.vault.data["token"]
  issuer                 = "api"
}

resource "vault_kubernetes_auth_backend_role" "db" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = var.db_service
  bound_service_account_names      = [var.db_service]
  bound_service_account_namespaces = [var.namespace]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.db.name]
  audience                         = "vault"
}

resource "vault_token" "example" {
  policies = [vault_policy.db.name]

  renewable = true
  ttl       = "24h"
}
output "token" {
  value = vault_token.example.client_token
  sensitive = true
}