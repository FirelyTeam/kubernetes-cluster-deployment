output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "kube_config_raw" {
  value     = module.aks.kube_config_raw
  sensitive = true
}

output "aks_id" {
  value = module.aks.aks_id
}

output "aks_name" {
  value = module.aks.aks_name
}

output "resource_group_name" {
  value = module.aks.resource_group_name
}

output "log_analytics_workspace_id" {
  value = module.aks.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  value = module.aks.log_analytics_workspace_name
}
