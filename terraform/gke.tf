resource "google_container_cluster" "primary" {
  name               = var.name
  location           = var.zone
  initial_node_count = 3
  node_config {
    machine_type    = "e2-standard-4"
    service_account = google_service_account.vault.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_service_account" "vault" {
  account_id   = var.name
  display_name = var.name
}

resource "google_project_iam_member" "vault" {
  project = var.project
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:${google_service_account.vault.email}"
}

resource "random_string" "key_ring" {
  length  = 8
  special = false
}

resource "google_kms_key_ring" "vault" {
  name     = "${var.name}-${random_string.key_ring.result}"
  location = var.region
}

resource "google_kms_crypto_key" "vault" {
  name            = var.name
  key_ring        = google_kms_key_ring.vault.id
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = false
  }
}
