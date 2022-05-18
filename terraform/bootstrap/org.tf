resource "tfe_organization" "expense_report" {
  name  = local.tfc_org_name
  email = var.tfc_email
}

resource "tfe_variable_set" "tfc_organization" {
  name         = "Backend"
  description  = "References for backend state access"
  organization = tfe_organization.expense_report.name
  global       = true
}

resource "tfe_variable" "tfc_organization" {
  key             = "tfc_organization"
  value           = tfe_organization.expense_report.name
  category        = "terraform"
  description     = "Backend reference for TFC Organization"
  variable_set_id = tfe_variable_set.tfc_organization.id
}

resource "tfe_variable_set" "credentials" {
  name          = "Cloud Provider Credentials"
  description   = "Credentials for various cloud providers"
  organization  = tfe_organization.expense_report.name
  workspace_ids = [tfe_workspace.infrastructure.id]
}

resource "tfe_variable" "hcp_client_id" {
  key             = "HCP_CLIENT_ID"
  value           = var.hcp_credentials.hcp_client_id
  category        = "env"
  description     = "HCP Client ID"
  variable_set_id = tfe_variable_set.credentials.id
}

resource "tfe_variable" "hcp_client_secret" {
  key             = "HCP_CLIENT_SECRET"
  value           = var.hcp_credentials.hcp_client_secret
  category        = "env"
  description     = "HCP Client Secret"
  sensitive       = true
  variable_set_id = tfe_variable_set.credentials.id
}