data "kubernetes_service_account" "vault" {
  metadata {
    name = "vault"
  }
}

data "kubernetes_secret" "vault" {
  metadata {
    name = data.kubernetes_service_account.vault.default_secret_name
  }
}
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "cluster" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = local.kube_config.host
  kubernetes_ca_cert     = data.kubernetes_secret.vault.data["ca.crt"]
  token_reviewer_jwt     = data.kubernetes_secret.vault.data["token"]
  disable_iss_validation = "true"
}

resource "vault_kubernetes_auth_backend_role" "mssql" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = var.mssql_service
  bound_service_account_names      = [var.mssql_service]
  bound_service_account_namespaces = [var.namespace]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.mssql.name]
}

resource "vault_kubernetes_auth_backend_role" "mysql" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = var.mysql_service
  bound_service_account_names      = [var.mysql_service]
  bound_service_account_namespaces = [var.namespace]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.mysql.name]
}

