output "vault_seal_gcpckms" {
  value = <<EOF
project     = "${var.project}"
region      = "${var.region}"
key_ring    = "${google_kms_key_ring.vault.name}"
crypto_key  = "${google_kms_crypto_key.vault.name}"
  EOF
}