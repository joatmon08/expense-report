output "consul_endpoint" {
  value = local.consul_public_endpoint
}

output "consul_datacenter" {
  value = var.consul_datacenter
}