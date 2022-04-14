data "kubernetes_service" "consul" {
  metadata {
    name = "consul-ui"
  }
}

output "consul_endpoint" {
  value = try("http://${data.kubernetes_service.consul.status.0.load_balancer.0.ingress.0.ip}", "")
}

data "kubernetes_service" "vault" {
  metadata {
    name = "vault-ui"
  }
}

output "vault_endpoint" {
  value = try("http://${data.kubernetes_service.vault.status.0.load_balancer.0.ingress.0.ip}:8200", "")
}

output "vault_token" {
  value     = var.vault_token
  sensitive = true
}

output "kube_config" {
  value     = data.terraform_remote_state.infrastructure.outputs.kube_config
  sensitive = true
}