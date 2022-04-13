data "kubernetes_service" "vault" {
  metadata {
    name = "vault-ui"
  }
}

output "vault_endpoint" {
  value = "http://${data.kubernetes_service.vault.status.0.load_balancer.0.ingress.0.ip}:8200"
}

output "vault_token" {
  value = var.vault_token
  sensitive = true
}