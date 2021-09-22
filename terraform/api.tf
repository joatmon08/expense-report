locals {
  services = [
    "container.googleapis.com",
    "cloudkms.googleapis.com",
    "serviceusage.googleapis.com"
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