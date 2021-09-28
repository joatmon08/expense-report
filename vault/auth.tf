resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "cluster" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://${data.google_container_cluster.cluster.endpoint}"
  kubernetes_ca_cert     = data.kubernetes_secret.vault.data["ca.crt"]
  token_reviewer_jwt     = data.kubernetes_secret.vault.data["token"]
  issuer                 = "api"
  disable_iss_validation = "true"
}