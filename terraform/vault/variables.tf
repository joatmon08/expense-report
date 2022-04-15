variable "application" {
  type        = string
  description = "application prefix for secrets"
}
variable "namespace" {
  type        = string
  description = "namespace for services"
  default     = "default"
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

data "terraform_remote_state" "helm" {
  backend = "remote"
  config = {
    organization = var.tfc_organization
    workspaces = {
      name = var.tfc_workspace
    }
  }
}

locals {
  kube_config       = data.terraform_remote_state.helm.outputs.kube_config
  consul_datacenter = data.terraform_remote_state.helm.outputs.consul_datacenter
  vault_endpoint    = data.terraform_remote_state.helm.outputs.vault_endpoint
  vault_token       = data.terraform_remote_state.helm.outputs.vault_token
}
