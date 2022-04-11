terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "~>1.0"
    }
  }
}

provider "boundary" {
  addr             = local.url
  tls_insecure     = true
  recovery_kms_hcl = <<EOT
kms "azurekeyvault" {
    purpose       = "recovery"
    tenant_id     = "${local.recovery_service_principal_tenant_id}"
    client_id     = "${local.recovery_service_principal_client_id}"
    client_secret = "${local.recovery_service_principal_client_secret}"
    vault_name    = "${local.vault_name}"
    key_name      = "recovery"
}
EOT
}