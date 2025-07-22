# Kubernetes Cluster Deployment

This repository contains Terraform scripts to provision a production-ready Kubernetes cluster on Azure (AKS), including:
- An Azure Kubernetes Service (AKS) cluster
- NGINX Ingress Controller (via Helm)
- cert-manager (via Helm) with automated Let's Encrypt integration

## Structure

- `infra/` — Provisions Azure infrastructure (AKS, resource group, log analytics)
  - `modules/aks` — AKS cluster, resource group, and log analytics workspace
- `helm-charts/` — Deploys Kubernetes resources to the cluster (Helm)
  - `modules/nginx` — NGINX ingress controller (Helm)
  - `modules/cert-manager` — cert-manager (Helm)
- `extra-k8s-manifests/` — Applies extra Kubernetes manifests that depend on CRDs (e.g., ClusterIssuer for Let's Encrypt)

## What the scripts do

1. **AKS Module**: Provisions a resource group, Log Analytics workspace, and an AKS cluster with configurable node pool and monitoring.
2. **NGINX Module**: Installs the NGINX ingress controller using Helm, enabling HTTP routing into your cluster.
3. **cert-manager Module**: Installs cert-manager using Helm.
4. **extra-k8s-manifests**: Applies CRD-based resources (e.g., ClusterIssuer for Let's Encrypt) after cert-manager is ready.

## Prerequisites
- [Terraform](https://www.terraform.io/) >= 1.3
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Azure subscription with sufficient permissions
- **Your Azure subscription must have enough quota for the selected VM size and number of nodes.**

## Usage

### 1. Clone the repository

```sh
git clone <repo-url>
cd kubernetes-cluster-deployment
```

### 2. Configure Azure CLI
We recommend using a service principal for Terraform deployments. This allows for better security and automation. If you prefer to use your user account, you can skip the service principal steps and simply use `az login` to log in.

#### Create a service principal
Automated tools that deploy or use Azure services - such as Terraform - should always have restricted permissions. Instead of having applications sign in as a fully privileged user, Azure offers service principals.

The most common pattern is to interactively sign in to Azure, create a service principal, test the service principal, and then use that service principal for future authentication (either interactively or from your scripts).

To create a service principal, run `az ad sp create-for-rbac`.
```powershell
az login
az ad sp create-for-rbac --name <service_principal_name> --role Contributor --scopes /subscriptions/<subscription_id>
```
**Key points**:
- You can replace the `<service-principal-name>` with a custom name for your environment or omit the parameter entirely. If you omit the parameter, the service principal name is generated based on the current date and time.
- Upon successful completion, `az ad sp create-for-rbac` displays several values. The appId, password, and tenant values are used in the next step.

#### Specify service principal credentials in environment variables
Once you create a service principal, you can specify its credentials to Terraform via environment variables.

To set the environment variables within a specific PowerShell session, use the following code. Replace the placeholders with the appropriate values for your environment.

```powershell
$env:ARM_CLIENT_ID="<service_principal_app_id>"
$env:ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
$env:ARM_TENANT_ID="<azure_subscription_tenant_id>"
$env:ARM_CLIENT_SECRET="<service_principal_password>"
```
To set the environment variables for every PowerShell session, [create a PowerShell profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles) and set the environment variables within your profile.



### 3. Deploy AKS infrastructure (Stage 1)

```sh
cd infra
# Edit variables in variables.tf or provide a terraform.tfvars file as needed
terraform init
terraform apply
```

After apply, copy the `aks_kube_configraw` output to a file using the following command:
```sh
terraform output -raw kube_config_raw > ../kubeconfig.yaml
```


### 3. Deploy Kubernetes resources (Stage 2)
If you copied the kubeconfig file to `../kubeconfig.yaml`, you can proceed with deploying Kubernetes resources.
Otherwise, you need to override the `kubeconfig_path` variable in the `terraform.tfvars` file.

```sh
cd ../helm-charts
terraform init
terraform apply
```

### 4. Apply extra Kubernetes manifests (Stage 3)
After cert-manager and other controllers are installed, apply extra manifests (e.g., ClusterIssuer):

```sh
cd ../extra-k8s-manifests
terraform init
terraform apply
```

### 5. Access your cluster

You can fetch credentials with:

```sh
az aks get-credentials --resource-group <resource-group> --name <aks-cluster-name>
```

**Key points**:
- The `resource-group` and `aks-cluster-name` should match the values you set for your infra variables.


### 6. Verify deployments

Check that NGINX ingress and cert-manager pods are running:

```sh
kubectl get pods -A
```

## Notes
- The ClusterIssuer and other CRD-based resources are now managed in `extra-k8s-manifests/` and applied after cert-manager is ready.
- You can customize Helm values for NGINX and cert-manager by editing the respective variables.

## Cleanup
To destroy all resources:
Go sequentially into `extra-k8s-manifests`, `helm-charts`, and `infra` directories and run:
```sh
terraform destroy
```

---

For more details, see the README files in each module directory.
