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

resource "kubernetes_manifest" "vault" {
  depends_on = [
    helm_release.consul
  ]
  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "ServiceDefaults"
    "metadata" = {
      "name"      = "vault"
      "namespace" = "default"
    }
    "spec" = {
      "protocol" = "tcp"
    }
  }
}