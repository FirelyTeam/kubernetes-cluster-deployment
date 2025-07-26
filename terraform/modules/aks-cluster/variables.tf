variable "resource_group_name" {
  type    = string
  description = "Name of the Azure resource group to create for the AKS cluster."
}

variable "location" {
  type    = string
  description = "Azure region to deploy the resources into."
}

variable "aks_cluster_name" {
  type    = string
  description = "Name of the AKS cluster."
}

variable "kubernetes_version" {
  type    = string
  description = "Kubernetes version to deploy for the AKS cluster."
}

variable "nodepool_node_vm_size" {
  type    = string
  description = "VM size for the node pool."
}

variable "nodepool_node_count" {
  type    = number
  description = "Number of nodes in the node pool."
}

variable "nodepool_min_node_count" {
  type    = number
  description = "Minimum number of nodes for autoscaling."
}

variable "nodepool_max_node_count" {
  type    = number
  description = "Maximum number of nodes for autoscaling."
}

variable "multi_zones_enabled" {
  type    = bool
  description = "Enable multi-zone node pools."
}
