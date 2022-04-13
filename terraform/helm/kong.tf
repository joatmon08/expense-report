resource "helm_release" "kong" {
  depends_on = [
    helm_release.consul
  ]

  name = "report"

  repository = "https://charts.konghq.com"
  chart      = "kong"
  version    = var.kong_helm_version

  values = [
    file("templates/kong.yaml")
  ]
}