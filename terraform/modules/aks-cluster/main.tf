resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "${var.aks_cluster_name}-log"
  location            = var.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.log_analytics.location
  resource_group_name   = azurerm_log_analytics_workspace.log_analytics.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_kubernetes_cluster" "aks" {
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      maintenance_window_auto_upgrade[0].utc_offset
    ]
  }
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "${var.aks_cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version
  node_resource_group = "${var.aks_cluster_name}-nodes"

  default_node_pool {
    name                 = "nodepool"
    node_count           = var.nodepool_node_count
    auto_scaling_enabled  = true
    min_count            = var.nodepool_min_node_count
    max_count            = var.nodepool_max_node_count
    vm_size              = var.nodepool_node_vm_size
    zones                = var.multi_zones_enabled ? ["1", "2", "3"] : null

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                    = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "01:00"
  }

  network_profile {
    network_plugin      = "azure"   
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
  }

  # No container registry needed for public images
}
