variable "nginx_chart_version" {
  type        = string
  default     = "4.10.1"
  description = "Version of the NGINX ingress Helm chart to deploy."
}
variable "nginx_namespace" {
  type        = string
  default     = "ingress-nginx"
  description = "Kubernetes namespace to deploy the NGINX ingress controller into."
}
variable "nginx_values" {
  type        = any
  default     = {}
  description = "Custom values to pass to the NGINX ingress Helm chart."
}

variable "cert_manager_chart_version" {
  type        = string
  default     = "1.18.2"
  description = "Version of the cert-manager Helm chart to deploy."
}
variable "cert_manager_namespace" {
  type        = string
  default     = "cert-manager"
  description = "Kubernetes namespace to deploy cert-manager into."
}
variable "cert_manager_values" {
  type        = any
  default     = {}
  description = "Custom values to pass to the cert-manager Helm chart."
}
variable "aks_kubeconfig_path" {
  type        = string
  default     = "../kubeconfig.yaml"
  description = "Path to the kubeconfig file for the AKS cluster."
}

