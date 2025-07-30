output "resource_group_name" {
  value = module.aks-cluster.resource_group_name
}
output "kube_config_raw" {
  value     = module.aks-cluster.kube_config_raw
  sensitive = true
}
output "aks_cluster_id" {
  value = module.aks-cluster.aks_id
}
output "aks_cluster_name" {
  value = module.aks-cluster.aks_name
}
