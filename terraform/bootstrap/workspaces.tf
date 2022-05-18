resource "tfe_workspace" "infrastructure" {
  name                      = "infrastructure"
  organization              = tfe_organization.expense_report.name
  remote_state_consumer_ids = [tfe_workspace.helm_consul.id]
}

resource "tfe_variable" "prefix" {
  key          = "prefix"
  value        = random_pet.tfc.id
  category     = "terraform"
  workspace_id = tfe_workspace.infrastructure.id
  description  = "Prefix for all infrastructure resources"
}

resource "tfe_workspace" "helm_consul" {
  name                      = "helm-consul"
  organization              = tfe_organization.expense_report.name
  remote_state_consumer_ids = [tfe_workspace.helm_vault.id]
}

resource "tfe_variable" "helm_consul" {
  key          = "tfc_workspace"
  value        = tfe_workspace.infrastructure.name
  category     = "terraform"
  workspace_id = tfe_workspace.helm_consul.id
  description  = "Backend reference for TFC Workspace"
}

resource "tfe_workspace" "helm_vault" {
  name                      = "helm-vault"
  organization              = tfe_organization.expense_report.name
  remote_state_consumer_ids = [tfe_workspace.vault.id]
}

resource "tfe_variable" "helm_vault" {
  key          = "tfc_workspace"
  value        = tfe_workspace.infrastructure.name
  category     = "terraform"
  workspace_id = tfe_workspace.helm_vault.id
  description  = "Backend reference for TFC Workspace"
}

resource "tfe_workspace" "vault" {
  name                      = "vault"
  organization              = tfe_organization.expense_report.name
  remote_state_consumer_ids = [tfe_workspace.vault_app.id]
}

resource "tfe_variable" "vault" {
  key          = "tfc_workspace"
  value        = tfe_workspace.helm_vault.name
  category     = "terraform"
  workspace_id = tfe_workspace.vault.id
  description  = "Backend reference for TFC Workspace"
}

resource "tfe_workspace" "vault_app" {
  name         = "vault-app"
  organization = tfe_organization.expense_report.name
}

resource "tfe_variable" "vault_app" {
  key          = "tfc_workspace"
  value        = tfe_workspace.vault.name
  category     = "terraform"
  workspace_id = tfe_workspace.vault_app.id
  description  = "Backend reference for TFC Workspace"
}