data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azuread_client_config" "current" {}

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

variable "location" {
  type    = string
  default = "eastus"
}

## For Virtual Network
variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  type = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "subnet_names" {
  type = list(string)
  default = [
    "controllers",
    "workers",
    "targets",
    "vault"
  ]
}

variable "sql_service_tag" {
  type        = string
  default     = "Sql.EastUS"
  description = "SQL service tag for location. Allows communication between VMs and Azure SQL server."
}

variable "azure_database_admin" {
  type        = string
  description = "Azure Database Administrator you want to add as a user."
}

variable "database_name" {
  type        = string
  description = "Name of database for application"
  default     = "DemoExpenses"
}

locals {
  resource_group_name = "${var.prefix}-learn"
}