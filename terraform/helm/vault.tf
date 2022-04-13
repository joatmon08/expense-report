resource "helm_release" "vault" {
  depends_on = [
    helm_release.consul
  ]
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = var.vault_helm_version

  values = [
    file("templates/vault.yaml")
  ]
}