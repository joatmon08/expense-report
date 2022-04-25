data "azurerm_subscription" "current" {}

variable "prefix" {
  type        = string
  description = "Prefix to use for resources"
}

variable "tags" {
  type        = map(string)
  description = "Tags to attach to infrastructure resources"
  default = {
    source = "expense-report"
  }
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "network_cidr_block" {
  type        = string
  description = "CIDR Block for network"
  default     = "10.8.0.0/16"
}

variable "subnet_cidr_block" {
  type        = string
  description = "CIDR Block for subnetwork"
  default     = "10.8.1.0/24"
}

variable "hcp_network_cidr_block" {
  type        = string
  description = "CIDR Block for HCP Network"
  default     = "172.25.16.0/20"
}

variable "client_cidr_blocks" {
  type        = list(string)
  description = "CIDR Blocks to access to Kubernetes API Server for debugging"
  default     = []
}

locals {
  resource_group_name = "${var.prefix}-expense-report"
}