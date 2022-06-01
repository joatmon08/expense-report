# Root CA
resource "tls_private_key" "ca_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem   = tls_private_key.ca_key.private_key_pem
  is_ca_certificate = true

  subject {
    common_name  = "Consul Agent CA"
    organization = "HashiCorp Inc."
  }

  validity_period_hours = 8760

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature"
  ]
}

resource "kubernetes_namespace" "consul" {
  depends_on = [azurerm_kubernetes_cluster.cluster]
  metadata {
    name = var.consul_namespace
  }
}

resource "kubernetes_secret" "consul_ca" {
  depends_on = [azurerm_kubernetes_cluster.cluster]
  metadata {
    name      = "consul-ca"
    namespace = kubernetes_namespace.consul.metadata.0.name
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.ca_cert.cert_pem
    "tls.key" = tls_private_key.ca_key.private_key_pem
  }
}