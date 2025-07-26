 terraform {
   required_providers {
     azurerm = {
       source  = "hashicorp/azurerm"
       version = ">= 4.37.0"
     }
     helm = {
       source  = "hashicorp/helm"
       version = ">= 3.0.2"
     }
     kubernetes = {
       source  = "hashicorp/kubernetes"
       version = ">= 2.38.0"
     }
   }
 }

data "azurerm_kubernetes_cluster" "default" {
  depends_on          = [module.aks-cluster] # refresh cluster state before reading
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
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

module "nginx-helm" {
  depends_on = [module.aks-cluster]
  source     = "./modules/nginx-helm"
}
module "cert-manager" {
  depends_on = [module.aks-cluster]
  source     = "./modules/cert-manager-helm"
}