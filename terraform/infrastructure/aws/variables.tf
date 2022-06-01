variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "hcp_region" {
  description = "HCP Region"
  type        = string
  default     = ""
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block of VPC for EKS cluster"
}

variable "hcp_cidr_block" {
  type        = string
  default     = "172.25.16.0/20"
  description = "CIDR block of the HashiCorp Virtual Network"
}

variable "hcp_consul_public_endpoint" {
  type        = string
  default     = true
  description = "Enable HCP Consul public endpoint for cluster"
}

variable "hcp_vault_public_endpoint" {
  type        = string
  default     = true
  description = "Enable HCP Vault public endpoint for cluster"
}

variable "tags" {
  type        = map(any)
  description = "Tags to add resources"
}

variable "additional_tags" {
  default     = {}
  type        = map(any)
  description = "Tags to add resources"
}

variable "public_access_cidrs" {
  default     = []
  type        = list(string)
  description = "List of CIDR blocks to allow public access to endpoints"
}