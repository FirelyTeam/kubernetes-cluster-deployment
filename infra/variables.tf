variable "location" {
  type        = string
  default     = "westeurope"
  description = "Azure region to deploy the resources into."
}
variable "resource_group_name" {
  type        = string
  default     = "aks-firely-cluster-rg"
  description = "Name of the Azure resource group to create for the AKS cluster."
}
variable "aks_cluster_name" {
  type        = string
  default     = "aks-firely-cluster"
  description = "Name of the AKS cluster."
}
variable "kubernetes_version" {
  type        = string
  default     = "1.33.1"
  description = "Kubernetes version to deploy for the AKS cluster."
}
variable "multi_zones_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable multiple availability zones for the node pool."
}
variable "nodepool_node_vm_size" {
  type        = string
  default     = "Standard_DS2_v2"
  description = "VM size for the node pool."
}
variable "nodepool_node_count" {
  type        = number
  default     = 2
  description = "Number of nodes in the node pool."
}
variable "nodepool_min_node_count" {
  type        = number
  default     = 1
  description = "Minimum number of nodes for autoscaling."
}
variable "nodepool_max_node_count" {
  type        = number
  default     = 3
  description = "Maximum number of nodes for autoscaling."
}
