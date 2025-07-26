output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0]
  sensitive = true
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  value = azurerm_resource_group.aks.name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.log_analytics.id
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.log_analytics.name
}