provider "kubernetes" {
  config_path = var.kubeconfig_path
}

resource "kubernetes_manifest" "letsencrypt_clusterissuer" {
  manifest = yamldecode(templatefile("${path.module}/clusterissuer-letsencrypt.yaml.tpl", {
    letsencrypt_email = var.letsencrypt_email
  }))
}
