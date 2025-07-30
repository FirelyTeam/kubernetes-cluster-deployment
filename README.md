# Kubernetes Cluster Deployment


This repository provisions a production-ready Kubernetes cluster on Azure (AKS) using Terraform, and deploys NGINX Ingress Controller and cert-manager using Helm via a PowerShell script. Let's Encrypt integration is automated after cert-manager is installed.

**Deployment workflow:**
- Provision AKS and supporting Azure resources with Terraform
- Deploy NGINX Ingress Controller and cert-manager using the provided PowerShell script (`helm/deploy-helm-charts.ps1`)
- Apply extra Kubernetes manifests (e.g., ClusterIssuer) after cert-manager is ready


## Structure

- `terraform/` — Provisions Azure infrastructure (AKS, resource group, log analytics)
  - `modules/aks` — AKS cluster, resource group, and log analytics workspace
- `helm/` — PowerShell script and values files for deploying Helm charts (NGINX, cert-manager)
- `extra-k8s-manifests/` — Applies extra Kubernetes manifests that depend on CRDs (e.g., ClusterIssuer for Let's Encrypt)


## What the scripts do

1. **AKS Infrastructure**: Provisions a resource group, Log Analytics workspace, and an AKS cluster with configurable node pool and monitoring (`terraform/modules/aks`).
2. **Helm Deployments**: Installs the NGINX ingress controller and cert-manager using the PowerShell script (`helm/deploy-helm-charts.ps1`).
3. **Extra Manifests**: Applies CRD-based resources (e.g., ClusterIssuer for Let's Encrypt) after cert-manager is ready (`extra-k8s-manifests/`).

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




### 3. Deploy AKS cluster and resources with Terraform
Navigate to the `terraform` directory and then run `init` and `apply` to initialize and deploy Terraform:

```sh
cd terraform
# Edit variables in variables.tf or provide a terraform.tfvars file as needed
terraform init
terraform apply
```

After apply, copy the `kube_config_raw` output to a file:
```sh
terraform output -raw kube_config_raw > ../kubeconfig.yaml
```

Then, set the `KUBECONFIG` environment variable to point to the generated kubeconfig file:

```powershell
$env:KUBECONFIG = (Resolve-Path "../kubeconfig.yaml").Path
```

### 4. Deploy NGINX Ingress Controller and cert-manager with Helm

Prerequisites:
- [Helm](https://helm.sh/docs/intro/install/) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured to access your AKS cluster
- environment variable `KUBECONFIG` set to the path of your kubeconfig file (as done in the previous step).


Use the provided PowerShell script to deploy nginx-ingress and cert-manager charts:

```powershell
cd ../helm
./deploy-helm-charts.ps1
```

You can customize Helm values by editing the YAML files in the `helm/` directory.

As part of the script, the letsencrypt ClusterIssuer is created, which allows cert-manager to issue certificates using Let's Encrypt.


### 5. Verify deployments

Check that NGINX ingress and cert-manager pods are running:

```sh
kubectl get pods -A
```

## Cleanup
To destroy all resources:
Go to `terraform` directory and run:
```sh
terraform destroy
```
This will remove the AKS cluster, resource group, and all associated resources.