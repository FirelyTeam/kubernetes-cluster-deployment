variable "kubeconfig_path" {
  description = "Path to the kubeconfig file."
  default     = "../kubeconfig.yaml"
  type        = string
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt notifications."
  type        = string
}
