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
  default     = "0.41.1"
}

variable "consul_datacenter" {
  type        = string
  description = "Consul datacenter"
  default     = "useast"
}

variable "vault_helm_version" {
  type        = string
  description = "Vault Helm chart version"
  default     = "0.19.0"
}

variable "grafana_helm_version" {
  type        = string
  description = "Grafana Helm chart version"
  default     = "6.26.0"
}

variable "kong_helm_version" {
  type        = string
  description = "Kong Helm chart version"
  default     = "2.7.0"
}

variable "vault_token" {
  type        = string
  description = "Vault token for dev mode"
  sensitive   = true
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
  kube_config = data.terraform_remote_state.infrastructure.outputs.kube_config
}
