Param (
  [string]$NginxNamespace = "nginx-ingress",
  [string]$NginxChartVersion = "4.13.0",
  [string]$CertManagerNamespace = "cert-manager",
  [string]$CertManagerChartVersion = "1.18.2",
  [bool]$DeployLetsencryptIssuer = $true,
  [string]$LetsencryptEmail = ""
)
 
# Check that helm and kubectl are installed
if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
    Write-Error "Helm is not installed. Please install Helm to continue."
    exit 1
}
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Error "Kubectl is not installed. Please install Kubectl to continue."
    exit 1
}

Write-Host 'Adding helm repositories and Updating Helm repositories cache...'
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

Write-Host "Deploying NGINX Ingress Controller..."
helm upgrade --install nginx-ingress `
    --namespace $NginxNamespace `
    --create-namespace `
    --version $NginxChartVersion `
    --atomic `
    ingress-nginx/ingress-nginx `
    -f ./nginx-ingress/nginx-ingress-values.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to deploy NGINX Ingress Controller."
    Restore-Kubeconfig
    exit $LASTEXITCODE
}
Write-Host "NGINX Ingress Controller deployed or updated successfully."

Write-Host "Deploying Cert-Manager..."
helm upgrade --install cert-manager jetstack/cert-manager `
    --namespace $CertManagerNamespace `
    --create-namespace `
    --version $CertManagerChartVersion `
    --atomic `
    --wait `
    --timeout 10m0s `
    --description "Cert-Manager deployment via script" `
    --values ./cert-manager/cert-manager-values.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to deploy Cert-Manager."
    Restore-Kubeconfig
    exit $LASTEXITCODE
}
Write-Host "Cert-Manager deployed or updated successfully."

if (-not $DeployLetsencryptIssuer) {
    Write-Host "Let’s Encrypt issuer deployment skipped."
}
else {
    if ($LetsencryptEmail -eq "") {
        Write-Error "Let’s Encrypt email is not set. Please set the LetsencryptEmail parameter to continue."
        Restore-Kubeconfig
        exit 1
    }
    $issuerYaml = @"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $LetsencryptEmail
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
"@

    $issuerFilePath = "letsencrypt-cluster-issuer.yaml"
    $issuerYaml | Out-File -Encoding utf8 -FilePath $issuerFilePath
    kubectl apply -f $issuerFilePath
    $kubectlExitCode = $LASTEXITCODE
    Remove-Item $issuerFilePath
    if ($kubectlExitCode -ne 0) {
        Write-Error "Failed to deploy Let’s Encrypt ClusterIssuer."
        Restore-Kubeconfig
        exit $kubectlExitCode
    }
    Write-Host "Let’s Encrypt ClusterIssuer deployed successfully."

# Restore KUBECONFIG at the end
Restore-Kubeconfig
}