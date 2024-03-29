## Boundary exports to set up dynamic host catalog ##

output "subscription_id" {
  value       = data.azurerm_subscription.current.subscription_id
  description = "Subscription ID for Azure"
  sensitive   = true
}

## Kubernetes ##
output "kube_config" {
  value     = azurerm_kubernetes_cluster.cluster.kube_config.0
  sensitive = true
}

## HCP ##
# output "vault_token" {
#   value     = hcp_vault_cluster_admin_token.vault.token
#   sensitive = true
# }

# output "vault_cluster_id" {
#   value = hcp_vault_cluster.vault.cluster_id
# }

# output "vault_public_endpoint" {
#   value = hcp_vault_cluster.vault.vault_public_endpoint_url
# }


# output "consul_token" {
#   value     = hcp_consul_cluster_root_token.consul.secret_id
#   sensitive = true
# }

# output "consul_token_kubernetes_secret" {
#   value     = hcp_consul_cluster_root_token.consul.kubernetes_secret
#   sensitive = true
# }

# output "consul_cluster_id" {
#   value = hcp_consul_cluster.consul.cluster_id
# }
# output "consul_public_endpoint" {
#   value = hcp_consul_cluster.consul.consul_public_endpoint_url
# }