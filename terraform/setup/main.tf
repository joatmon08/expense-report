variable "project" {
  type = string
}

locals {
  name = "terraform-cloud"
  services = [
    "serviceusage.googleapis.com",
    "container.googleapis.com",
    "cloudkms.googleapis.com"
  ]
  roles = [
    "roles/cloudkms.admin",
    "roles/container.serviceAgent",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountCreator",
    "roles/iam.serviceAccountDeleter"
  ]
}

resource "google_project_service" "project" {
  count   = length(local.services)
  project = var.project
  service = local.services[count.index]

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_service_account" "tfc" {
  account_id   = local.name
  display_name = local.name
}

resource "google_project_iam_member" "tfc" {
  count   = length(local.roles)
  project = var.project
  role    = local.roles[count.index]
  member  = "serviceAccount:${google_service_account.tfc.email}"
}