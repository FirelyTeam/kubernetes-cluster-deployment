

data "kubernetes_service" "nginx_ingress_service" {
  depends_on = [ helm_release.nginx_ingress ]
  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = var.nginx_namespace
  }
}

output "nginx_ingress_service_ip" {
  value = data.kubernetes_service.nginx_ingress_service.status.0.load_balancer.0.ingress.0.ip
}