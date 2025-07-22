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
  default     = { }
  description = "Custom values to pass to the cert-manager Helm chart."
}

