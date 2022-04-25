resource "hcp_hvn" "cloud" {
  hvn_id         = "hvn"
  cloud_provider = "azure"
  region         = var.location
  cidr_block     = var.hcp_network_cidr_block
}

resource "hcp_consul_cluster" "consul" {
  cluster_id      = var.prefix
  hvn_id          = hcp_hvn.cloud.hvn_id
  tier            = "development"
  public_endpoint = true
}

resource "hcp_consul_cluster_root_token" "consul" {
  cluster_id = hcp_consul_cluster.consul.cluster_id
}

# resource "hcp_vault_cluster" "vault" {
#   cluster_id      = var.prefix
#   hvn_id          = hcp_hvn.cloud.hvn_id
#   tier            = "dev"
#   public_endpoint = true
# }

# resource "hcp_vault_cluster_admin_token" "vault" {
#   cluster_id = hcp_vault_cluster.vault.cluster_id
# }