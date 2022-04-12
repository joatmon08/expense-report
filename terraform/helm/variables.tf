variable "prefix" {
  type        = string
  description = "Prefix to use for resources"
}

variable "tags" {
  type        = map(string)
  description = "Tags to attach to infrastructure resources"
  default = {
    source = "hashicorp-learn"
  }
}

variable "tfc_organization" {
  type        = string
  description = "Terraform Cloud Organization"
}

variable "tfc_workspace" {
  type        = string
  description = "Terraform Cloud Workspace with infrastructure"
}

variable "consul_helm_version" {
  type        = string
  description = "Consul Helm chart version"
  default     = "0.42.0"
}

variable "vault_helm_version" {
  type        = string
  description = "Vault Helm chart version"
  default     = "0.19.0"
}

data "terraform_remote_state" "infrastructure" {
  backend = "remote"
  config = {
    organization = var.tfc_organization
    workspaces = {
      name = var.tfc_workspace
    }
  }
}

locals {
  kube_config                        = data.terraform_remote_state.infrastructure.outputs.kube_config
  hcp_consul_cluster_id              = data.terraform_remote_state.infrastructure.outputs.consul_cluster_id
  hcp_consul_endpoint                = data.terraform_remote_state.infrastructure.outputs.consul_public_endpoint
  hcp_consul_token_kubernetes_secret = data.terraform_remote_state.infrastructure.outputs.consul_token_kubernetes_secret
  hcp_vault_cluster_id               = data.terraform_remote_state.infrastructure.outputs.vault_cluster_id
  hcp_vault_endpoint                 = data.terraform_remote_state.infrastructure.outputs.vault_public_endpoint
}
