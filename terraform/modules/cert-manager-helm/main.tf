resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_chart_version
  namespace        = var.cert_manager_namespace
  create_namespace = true
  atomic           = true
  values           = [
    "${file("${path.module}/cert-manager-values.yaml")}"
  ]
}
