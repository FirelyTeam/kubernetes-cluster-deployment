resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.nginx_chart_version
  namespace        = var.nginx_namespace
  create_namespace = true
  values           = [
    "${file("${path.module}/ingress-nginx-values.yaml")}"
  ]
  atomic           = true
}
