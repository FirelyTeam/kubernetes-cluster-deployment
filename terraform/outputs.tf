output "kube_config_raw" {
  value     = module.aks-cluster.kube_config_raw
  sensitive = true
}

output "public_ip" {
  value = module.nginx-helm.nginx_ingress_service_ip
}

