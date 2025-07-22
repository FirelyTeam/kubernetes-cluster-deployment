# Extra Kubernetes Manifests (ClusterIssuer, etc)

This Terraform project manages extra Kubernetes manifests that depend on CRDs installed by other controllers (e.g., cert-manager's ClusterIssuer).

## Prerequisites
- The AKS cluster and kubeconfig must already exist (from the `infra` stage).
- cert-manager and other controllers must already be installed (from the `helm-charts` stage).

## Usage
1. Ensure you have run `terraform apply` in the `infra` and `helm-charts` directories first.
2. Copy or symlink your kubeconfig file (from infra output) to a known location.
3. In this `extra-k8s-manifests` directory, create a `terraform.tfvars` file with:

```hcl
kubeconfig_path    = "../path/to/kubeconfig.yaml"
letsencrypt_email  = "your@email.com"
```

4. Initialize and apply:
```sh
terraform init
terraform apply
```

## What this does
- Applies a ClusterIssuer manifest for Let's Encrypt using cert-manager.
- You can add other CRD-based resources here as needed.
- Does not install cert-manager or any other controllers.

## Order of operations
1. `infra/`           → creates AKS and kubeconfig
2. `helm-charts/`     → installs cert-manager and other controllers
3. `extra-k8s-manifests/` → creates the ClusterIssuer and other CRD-based resources

---

If you need to update the email or re-apply the issuer, just re-run `terraform apply` in this directory.
