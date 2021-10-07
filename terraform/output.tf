output "vault_helm" {
  value = templatefile("templates/vault.yaml", {
    project    = var.project,
    region     = var.region,
    key_ring   = google_kms_key_ring.vault.name,
    crypto_key = google_kms_crypto_key.vault.name
  })
  sensitive = true
}
