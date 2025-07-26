variable "nginx_chart_version" {
  type        = string
  default     = "4.13.0"
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
