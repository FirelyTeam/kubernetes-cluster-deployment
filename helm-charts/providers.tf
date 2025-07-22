terraform {
  required_version = ">= 1.3.0"
}

provider "kubernetes" {
    config_path            = var.aks_kubeconfig_path
}

provider "helm" {
  kubernetes = {
    config_path            = var.aks_kubeconfig_path
  }
}
