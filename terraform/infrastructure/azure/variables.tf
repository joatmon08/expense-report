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

locals {
  resource_group_name = "${var.prefix}-expense-report"
}