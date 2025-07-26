# Kubernetes Cluster Deployment

This repository contains Terraform scripts to provision a production-ready Kubernetes cluster on Azure (AKS), including:
- An Azure Kubernetes Service (AKS) cluster
- NGINX Ingress Controller (via Helm)
- cert-manager (via Helm) with automated Let's Encrypt integration

## Structure

- `terraform/` — Provisions Azure infrastructure (AKS, resource group, log analytics)
  - `modules/aks` — AKS cluster, resource group, and log analytics workspace
  - `modules/nginx` — NGINX ingress controller (Helm)
  - `modules/cert-manager` — cert-manager (Helm)
- `extra-k8s-manifests/` — Applies extra Kubernetes manifests that depend on CRDs (e.g., ClusterIssuer for Let's Encrypt)

## What the scripts do

1. **AKS Module**: Provisions a resource group, Log Analytics workspace, and an AKS cluster with configurable node pool and monitoring (terraform/modules/aks).
2. **NGINX Module**: Installs the NGINX ingress controller using Helm (terraform/modules/nginx).
3. **cert-manager Module**: Installs cert-manager using Helm (terraform/modules/cert-manager).
4. **extra-k8s-manifests/**: Applies CRD-based resources (e.g., ClusterIssuer for Let's Encrypt) after cert-manager is ready.

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
In this segment, we'll establish the authentication mechanism that Terraform will utilize. Once this setup is complete, you won't need to revisit this process in the future.

#### Authenticate to Azure via a Microsoft account
A Microsoft account is a username (associated with an email and its credentials) that is used to sign in to Microsoft services - such as Azure. A Microsoft account can be associated with one or more Azure subscriptions, with one of those subscriptions being the default.

The following steps show you how:

- Sign in to Azure interactively using a Microsoft account
- List the account's associated Azure subscriptions (including the default)
- Set the current subscription.


1. Open a command line that has access to the Azure CLI.

1. Run `az login` without any parameters and follow the instructions to sign in to Azure.
```powershell
> az login 
```
3. To confirm the current Azure subscription, run `az account show`.
```powershell
> az account show
```
4. To use a specific Azure subscription, run `az account set`.
```powershell
> az account set --subscription "<subscription_id_or_subscription_name>"
```
**Key points**:
- Replace the `<subscription_id_or_subscription_name>` placeholder with the ID or name of the subscription you want to use. For Firely that would be `FHIR Test`.


#### Create a service principal (optional)

Automated tools that deploy or use Azure services—such as Terraform—should ideally use restricted permissions via a service principal. If you prefer to use your user account, you can skip the service principal steps and simply use `az login` to log in. For user accounts, you only need to set the subscription ID to ensure Terraform uses the correct subscription:

```powershell
$env:ARM_SUBSCRIPTION_ID = '<your_subscription_id>'
```

If you want to use a service principal, create one with:

```powershell
az login
az ad sp create-for-rbac --name <service_principal_name> --role Contributor --scopes /subscriptions/<subscription_id>
```
**Key points**:
- You can replace the `<service-principal-name>` with a custom name for your environment or omit the parameter entirely. If you omit the parameter, the service principal name is generated based on the current date and time.
- Upon successful completion, `az ad sp create-for-rbac` displays several values. The appId, password, and tenant values are used in the next step.

#### Specify service principal credentials in environment variables (only needed for service principal)
Once you create a service principal, you can specify its credentials to Terraform via environment variables:

```powershell
$env:ARM_CLIENT_ID="<service_principal_app_id>"
$env:ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
$env:ARM_TENANT_ID="<azure_subscription_tenant_id>"
$env:ARM_CLIENT_SECRET="<service_principal_password>"
```
To set the environment variables for every PowerShell session, [create a PowerShell profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles) and set the environment variables within your profile.



### 3. Deploy AKS infrastructure (Stage 1)

```sh
cd terraform
# Edit variables in variables.tf or provide a terraform.tfvars file as needed
terraform init
terraform apply
```

After apply, copy the `aks_kube_configraw` output to a file using the following command:
```sh
terraform output -raw kube_config_raw > ../kubeconfig.yaml
```


### 5. Apply extra Kubernetes manifests (Stage 3)
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



### 7. Verify deployments

Check that NGINX ingress and cert-manager pods are running:

```sh
kubectl get pods -A
```

## Notes
- The ClusterIssuer and other CRD-based resources are now managed in `extra-k8s-manifests/` and applied after cert-manager is ready.
- You can customize Helm values for NGINX and cert-manager by editing the respective variables.

## Cleanup
To destroy all resources:
Go sequentially into `extra-k8s-manifests`, `helm-charts`, and `terraform` directories and run:
```sh
terraform destroy
```

---

For more details, see the README files in each module directory.
