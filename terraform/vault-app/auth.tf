resource "vault_kubernetes_auth_backend_role" "application" {
  backend                          = local.vault_kubernetes_auth_backend
  role_name                        = var.application
  bound_service_account_names      = [var.application]
  bound_service_account_namespaces = [var.namespace]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.application.name]
}

resource "vault_kubernetes_auth_backend_role" "application_v2" {
  backend                          = local.vault_kubernetes_auth_backend
  role_name                        = var.application_v2
  bound_service_account_names      = [var.application_v2]
  bound_service_account_namespaces = [var.namespace]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.application_v2.name]
}