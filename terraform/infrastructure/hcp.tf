resource "hcp_hvn" "cloud" {
  hvn_id         = "hvn"
  cloud_provider = "aws"
  region         = "us-east-1"
  cidr_block     = "172.25.16.0/20"
}

resource "hcp_consul_cluster" "consul" {
  cluster_id = var.prefix
  hvn_id     = hcp_hvn.cloud.hvn_id
  tier       = "development"
}

resource "hcp_consul_cluster_root_token" "consul" {
  cluster_id = hcp_consul_cluster.consul.cluster_id
}

resource "hcp_vault_cluster" "vault" {
  cluster_id = var.prefix
  hvn_id     = hcp_hvn.cloud.hvn_id
  tier       = "dev"
}

resource "hcp_vault_cluster_admin_token" "vault" {
  cluster_id = hcp_vault_cluster.vault.cluster_id
}