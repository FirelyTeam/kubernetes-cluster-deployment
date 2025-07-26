# AKS Cluster Module

This module provisions an Azure Kubernetes Service (AKS) cluster, a resource group, a container registry, and a log analytics workspace.

## Inputs
- resource_group_name
- location
- aks_cluster_name
- kubernetes_version
- nodepool_node_vm_size
- nodepool_node_count
- nodepool_min_node_count
- nodepool_max_node_count
- multi_zones_enabled

## Outputs
- kube_config
- kube_admin_config
- aks_id
- aks_name
- resource_group_name
