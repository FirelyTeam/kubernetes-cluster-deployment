 terraform {
   required_providers {
     azurerm = {
       source  = "hashicorp/azurerm"
       version = ">= 4.37.0"
     }
   }
 }

provider "azurerm" {
  features {}
}

module "aks-cluster" {
  source = "./modules/aks-cluster"
  resource_group_name     = var.resource_group_name
  location                = var.location
  aks_cluster_name        = var.aks_cluster_name
  kubernetes_version      = var.kubernetes_version
  nodepool_node_vm_size   = var.nodepool_node_vm_size
  nodepool_node_count     = var.nodepool_node_count
  nodepool_min_node_count = var.nodepool_min_node_count
  nodepool_max_node_count = var.nodepool_max_node_count
  multi_zones_enabled     = var.multi_zones_enabled
}