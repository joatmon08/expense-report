output "project" {
  value = var.project
}

output "region" {
  value = var.region
}

output "key_ring_name" {
  value = google_kms_key_ring.vault.name
}

output "crypto_key_name" {
  value = google_kms_crypto_key.vault.name
}