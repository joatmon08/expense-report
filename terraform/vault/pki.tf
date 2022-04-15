# locals {
#   root_max_ttl = 87600 * 3600
#   int_max_ttl  = 43800 * 3600
#   role_max_ttl = 720 * 3600
#   domain       = "${local.consul_datacenter}.consul"
# }
# resource "vault_mount" "consul_certs" {
#   path                      = "consul/certs_root"
#   type                      = "pki"
#   default_lease_ttl_seconds = 3600
#   max_lease_ttl_seconds     = local.root_max_ttl
# }

# resource "vault_pki_secret_backend_root_cert" "consul" {
#   depends_on  = [vault_mount.consul_certs]
#   backend     = vault_mount.consul_certs.path
#   type        = "internal"
#   common_name = "${local.consul_datacenter}.consul"
#   ttl         = local.root_max_ttl
# }

# resource "vault_pki_secret_backend_config_urls" "consul" {
#   depends_on              = [vault_mount.consul_certs]
#   backend                 = vault_mount.consul_certs.path
#   issuing_certificates    = ["http://127.0.0.1:8200/v1/pki/ca"]
#   crl_distribution_points = ["http://127.0.0.1:8200/v1/pki/crl"]
# }

# resource "vault_mount" "consul_certs_int" {
#   path                      = "consul/certs_int"
#   type                      = "pki"
#   default_lease_ttl_seconds = 3600
#   max_lease_ttl_seconds     = local.int_max_ttl
# }

# resource "vault_pki_secret_backend_intermediate_cert_request" "consul" {
#   depends_on  = [vault_mount.consul_certs]
#   backend     = vault_mount.consul_certs.path
#   type        = "internal"
#   common_name = "${local.domain} Intermediate Authority"
# }

# resource "vault_pki_secret_backend_root_sign_intermediate" "consul" {
#   depends_on  = [vault_pki_secret_backend_intermediate_cert_request.consul]
#   backend     = vault_mount.consul_certs.path
#   csr         = vault_pki_secret_backend_intermediate_cert_request.consul.csr
#   common_name = "${local.domain} Intermediate CA"
# }

# resource "vault_pki_secret_backend_intermediate_set_signed" "consul" {
#   backend     = vault_mount.consul_certs_int.path
#   certificate = vault_pki_secret_backend_root_sign_intermediate.consul.certificate
# }

# resource "vault_pki_secret_backend_role" "consul" {
#   backend          = vault_mount.consul_certs.path
#   name             = "consul"
#   allowed_domains  = [local.domain]
#   allow_subdomains = true
#   generate_lease   = true
#   max_ttl          = local.role_max_ttl
# }