resource "local_file" "infrastructure" {
  content = templatefile("templates/remote.tf", {
    TFC_ORGANIZATION = tfe_organization.expense_report.name
    TFC_WORKSPACE    = tfe_workspace.infrastructure.name
  })
  filename = "../infrastructure/aws/backend.tf"
}
