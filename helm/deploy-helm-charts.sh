# Error function
error() {
    echo "ERROR: $*" >&2
}
#!/usr/bin/env bash

set -e

# Usage function
usage() {
    echo "Usage: $0 [--NginxNamespace <value>] [--NginxChartVersion <value>] [--CertManagerNamespace <value>] [--CertManagerChartVersion <value>] [--DeployLetsencryptIssuer <true|false>] [--LetsencryptEmail <value>]"
    echo "  --NginxNamespace           NGINX namespace (default: ingress-nginx)"
    echo "  --NginxChartVersion        NGINX chart version (default: 4.13.0)"
    echo "  --CertManagerNamespace     cert-manager namespace (default: cert-manager)"
    echo "  --CertManagerChartVersion  cert-manager chart version (default: 1.18.2)"
    echo "  --DeployLetsencryptIssuer  deploy letsencrypt issuer (true/false, default: true)"
    echo "  --LetsencryptEmail         letsencrypt email (required if issuer is deployed)"
    exit 1
}

# Default values
NginxNamespace="ingress-nginx"
NginxChartVersion="4.13.0"
CertManagerNamespace="cert-manager"
CertManagerChartVersion="1.18.2"
DeployLetsencryptIssuer="true"
LetsencryptEmail=""


# Parse long arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --NginxNamespace)
      NginxNamespace="$2"; shift 2;;
    --NginxChartVersion)
      NginxChartVersion="$2"; shift 2;;
    --CertManagerNamespace)
      CertManagerNamespace="$2"; shift 2;;
    --CertManagerChartVersion)
      CertManagerChartVersion="$2"; shift 2;;
    --DeployLetsencryptIssuer)
      DeployLetsencryptIssuer="$2"; shift 2;;
    --LetsencryptEmail)
      LetsencryptEmail="$2"; shift 2;;
    --help)
      usage;;
    *)
      echo "Unknown option: $1"; usage;;
  esac
done

# Check that helm and kubectl are installed
if ! command -v helm &> /dev/null; then
    error "Helm is not installed. Please install Helm to continue."
    exit 1
fi
if ! command -v kubectl &> /dev/null; then
    error "Kubectl is not installed. Please install Kubectl to continue."
    exit 1
fi

echo "Adding helm repositories and updating Helm repositories cache..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

echo "Deploying NGINX Ingress Controller..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace "$NginxNamespace" \
    --create-namespace \
    --version "$NginxChartVersion" \
    --atomic \
    -f ./nginx-ingress/nginx-ingress-values.yaml

echo "Getting the external IP of the NGINX Ingress Controller..."
nginxIngressService=$(kubectl get svc -n "$NginxNamespace" ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [[ -z "$nginxIngressService" ]]; then
    error "Failed to retrieve the external IP of the NGINX Ingress Controller."
    exit 1
fi
echo "NGINX Ingress Controller external IP: $nginxIngressService"
echo "NGINX Ingress Controller deployed or updated successfully."

echo "Deploying Cert-Manager..."
helm upgrade --install cert-manager jetstack/cert-manager \
    --namespace "$CertManagerNamespace" \
    --create-namespace \
    --version "$CertManagerChartVersion" \
    --atomic \
    --wait \
    --timeout 10m0s \
    --description "Cert-Manager deployment via script" \
    --values ./cert-manager/cert-manager-values.yaml

echo "Cert-Manager deployed or updated successfully."

if [[ "$DeployLetsencryptIssuer" != "true" ]]; then
    echo "Let’s Encrypt issuer deployment skipped."
else
    if [[ -z "$LetsencryptEmail" ]]; then
        error "Let’s Encrypt email is not set. Please set the 'LetsencryptEmail' parameter to continue."
        exit 1
    fi

    cat > letsencrypt-cluster-issuer.yaml <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-issuer
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $LetsencryptEmail
    privateKeySecretRef:
      name: letsencrypt-key
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

    kubectl apply -f letsencrypt-cluster-issuer.yaml
    rm letsencrypt-cluster-issuer.yaml
    echo "Let’s Encrypt ClusterIssuer deployed successfully."
fi