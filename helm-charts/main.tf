module "nginx" {
  source = "./modules/nginx"
  nginx_chart_version = var.nginx_chart_version
  nginx_namespace     = var.nginx_namespace
  nginx_values        = var.nginx_values
}

module "cert_manager" {
  source = "./modules/cert-manager"
  cert_manager_chart_version = var.cert_manager_chart_version
  cert_manager_namespace     = var.cert_manager_namespace
  cert_manager_values        = var.cert_manager_values
}

