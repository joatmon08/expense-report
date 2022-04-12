variable "cluster_name" {
  type        = string
  description = "cluster name"
}

variable "cluster_zone" {
  type        = string
  description = "cluster zone from GKE"
  default     = ""
}

variable "namespace" {
  type        = string
  description = "namespace for services"
  default     = "default"
}

variable "application" {
  type        = string
  description = "application prefix for secrets"
}

variable "application_v2" {
  type        = string
  description = "application (v2) name for secrets"
}

variable "mysql_username" {
  type        = string
  description = "admin username for mysql database"
  default     = "root"
}

variable "mysql_service" {
  type        = string
  description = "endpoint for mysql database"
}

variable "mysql_port" {
  type        = string
  description = "port for mysql database"
  default     = "3306"
}

variable "mssql_username" {
  type        = string
  description = "admin username for mssql database"
  default     = "SA"
}

variable "mssql_service" {
  type        = string
  description = "endpoint for mssql database"
}

variable "mssql_port" {
  type        = string
  description = "port for mysql database"
  default     = "1433"
}

variable "tfc_organization" {
  type        = string
  description = "Terraform Cloud Organization"
}

variable "tfc_workspace" {
  type        = string
  description = "Terraform Cloud Workspace with infrastructure"
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
  kube_config        = data.terraform_remote_state.infrastructure.outputs.kube_config
  hcp_vault_endpoint = data.terraform_remote_state.infrastructure.outputs.vault_public_endpoint
  hcp_vault_token    = data.terraform_remote_state.infrastructure.outputs.vault_token
}
