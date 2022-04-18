resource "helm_release" "vault" {
  depends_on = [
    helm_release.consul
  ]
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = var.vault_helm_version

  values = [
    templatefile("templates/vault.yaml", {
      VAULT_TOKEN = var.vault_token
    })
  ]
}

resource "kubernetes_manifest" "vault" {
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