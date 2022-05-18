resource "random_pet" "tfc" {
  length = 1
}

variable "tfc_organization" {
  type        = string
  description = "Name of TFC Organization"
  default     = "expense-report"
}

variable "tfc_email" {
  type        = string
  description = "Email for TFC Organization"
}

variable "hcp_credentials" {
  type = object({
    hcp_client_id     = string
    hcp_client_secret = string
  })
  description = "HCP Credentials"
  sensitive   = true
}

locals {
  tfc_org_name = "${random_pet.tfc.id}-${var.tfc_organization}"
}