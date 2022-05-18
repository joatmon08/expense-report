output "vpc_id" {
  value = module.vpc.vpc_id
}

output "region" {
  value = var.region
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "hcp_vault_cluster" {
  value = module.hcp.hcp_vault_id
}

output "hcp_vault_token" {
  value     = hcp_vault_cluster_admin_token.cluster.token
  sensitive = true
}

output "hcp_vault_private_address" {
  value = module.hcp.hcp_vault_private_endpoint
}

output "hcp_vault_public_address" {
  value = var.hcp_vault_public_endpoint ? trim(module.hcp.hcp_vault_public_endpoint, "/") : ""
}

output "product_database_address" {
  value = aws_db_instance.products.address
}

output "product_database_username" {
  value = aws_db_instance.products.username
}

output "product_database_password" {
  value     = aws_db_instance.products.password
  sensitive = true
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

output "kubeconfig" {
  value = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}



provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  username               = null
  password               = null
  client_certificate     = null
  client_key             = null
  cluster_ca_certificate = data.aws_eks_cluster.cluster.certificate_authority.0.data
}