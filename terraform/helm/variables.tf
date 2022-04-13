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

variable "vault_helm_version" {
  type        = string
  description = "Vault Helm chart version"
  default     = "0.19.0"
}

variable "grafana_helm_version" {
  type        = string
  description = "Vault Helm chart version"
  default     = "6.26.0"
}

variable "consul_agent_ca_pem" {
  type        = string
  description = "Base64 encoded CA PEM file contents for Consul agent. Use `consul tls ca create` to generate."
  sensitive   = true
}

variable "consul_agent_ca_key_pem" {
  type        = string
  description = "Base64 encoded CA key PEM file contents for Consul agent. Use `consul tls ca create` to generate."
  sensitive   = true
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
