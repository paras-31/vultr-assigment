#!/usr/bin/env bash
# Phase 1 cluster bootstrap. Requires kubectl context pointing at the VKE cluster.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISTIO_VERSION="${ISTIO_VERSION:-1.31.1}"
GATEWAY_API_VERSION="${GATEWAY_API_VERSION:-v1.6.0}"
KPS_RELEASE="${KPS_RELEASE:-kps}"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

need kubectl
need helm

kubectl cluster-info >/dev/null

if [[ -f "${ROOT}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${ROOT}/.env"
  set +a
fi

: "${POSTGRES_PASSWORD:?Set POSTGRES_PASSWORD in the environment or .env}"
: "${VALKEY_PASSWORD:?Set VALKEY_PASSWORD in the environment or .env}"
: "${QDRANT_API_KEY:?Set QDRANT_API_KEY in the environment or .env}"
: "${GRAFANA_ADMIN_PASSWORD:?Set GRAFANA_ADMIN_PASSWORD in the environment or .env}"
GRAFANA_ADMIN_USER="${GRAFANA_ADMIN_USER:-admin}"

echo "==> namespaces"
kubectl apply -f "${ROOT}/bootstrap/namespaces/namespaces.yaml"

upsert_secret() {
  local ns="$1" name="$2"
  shift 2
  kubectl -n "${ns}" create secret generic "${name}" "$@" --dry-run=client -o yaml | kubectl apply -f -
}

echo "==> bootstrap secrets (placeholders until Infisical syncs the same names)"
upsert_secret databases postgres-auth --from-literal=password="${POSTGRES_PASSWORD}"
upsert_secret databases valkey-auth --from-literal=password="${VALKEY_PASSWORD}"
upsert_secret databases qdrant-auth --from-literal=api-key="${QDRANT_API_KEY}"
upsert_secret monitoring grafana-admin \
  --from-literal=admin-user="${GRAFANA_ADMIN_USER}" \
  --from-literal=admin-password="${GRAFANA_ADMIN_PASSWORD}"
upsert_secret apps app-secrets \
  --from-literal=DATABASE_URL="postgresql://app:${POSTGRES_PASSWORD}@postgres.databases.svc.cluster.local:5432/appdb" \
  --from-literal=POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
  --from-literal=VALKEY_PASSWORD="${VALKEY_PASSWORD}" \
  --from-literal=QDRANT_API_KEY="${QDRANT_API_KEY}"

echo "==> Gateway API CRDs ${GATEWAY_API_VERSION}"
kubectl apply --server-side --force-conflicts -f \
  "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/experimental-install.yaml"

echo "==> Helm repos"
helm repo add istio https://blob.istio.io/istio-release/charts >/dev/null
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo add infisical-helm-charts https://dl.cloudsmith.io/public/infisical/helm-charts/helm/charts/ >/dev/null
helm repo update >/dev/null

echo "==> Istio Ambient ${ISTIO_VERSION}"
helm upgrade --install istio-base istio/base \
  -n istio-system \
  --version "${ISTIO_VERSION}" \
  --wait

helm upgrade --install istiod istio/istiod \
  -n istio-system \
  --version "${ISTIO_VERSION}" \
  --values "${ROOT}/bootstrap/istio/values/istiod.yaml" \
  --wait

helm upgrade --install istio-cni istio/cni \
  -n istio-system \
  --version "${ISTIO_VERSION}" \
  --values "${ROOT}/bootstrap/istio/values/cni.yaml" \
  --wait

helm upgrade --install ztunnel istio/ztunnel \
  -n istio-system \
  --version "${ISTIO_VERSION}" \
  --values "${ROOT}/bootstrap/istio/values/ztunnel.yaml" \
  --wait

kubectl apply -f "${ROOT}/bootstrap/istio/peer-authentication.yaml"

echo "==> databases (standalone Helm charts — not replicated HA)"
helm upgrade --install postgres "${ROOT}/bootstrap/databases/postgres" -n databases --wait --timeout 10m
helm upgrade --install valkey "${ROOT}/bootstrap/databases/valkey" -n databases --wait --timeout 10m
helm upgrade --install qdrant "${ROOT}/bootstrap/databases/qdrant" -n databases --wait --timeout 10m

echo "==> kube-prometheus-stack"
helm upgrade --install "${KPS_RELEASE}" prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --values "${ROOT}/bootstrap/monitoring/prometheus-values.yaml" \
  --wait --timeout 15m

kubectl apply -k "${ROOT}/bootstrap/monitoring/dashboards"
kubectl apply -f "${ROOT}/bootstrap/monitoring/alert-rules/application-alerts.yaml"
kubectl apply -f "${ROOT}/bootstrap/monitoring/servicemonitor-backend.yaml"

echo "==> Gateway and HTTPRoutes"
kubectl apply -f "${ROOT}/bootstrap/gateway-api/gateway.yaml"
kubectl apply -f "${ROOT}/bootstrap/gateway-api/httproutes.yaml"

echo "==> Infisical operator"
helm upgrade --install infisical-operator infisical-helm-charts/secrets-operator \
  -n infisical-system \
  --values "${ROOT}/bootstrap/infisical/operator-values.yaml" \
  --wait

if [[ -n "${INFISICAL_CLIENT_ID:-}" && -n "${INFISICAL_CLIENT_SECRET:-}" ]]; then
  upsert_secret infisical-system infisical-universal-auth \
    --from-literal=clientId="${INFISICAL_CLIENT_ID}" \
    --from-literal=clientSecret="${INFISICAL_CLIENT_SECRET}"
  kubectl apply -f "${ROOT}/bootstrap/infisical/connection.yaml"
  kubectl apply -f "${ROOT}/bootstrap/infisical/auth.yaml"
  echo "Create bootstrap/infisical/static-secret.yaml from the example, set YOUR_INFISICAL_PROJECT_ID, then kubectl apply it."
else
  echo "INFISICAL_CLIENT_ID/SECRET not set; operator is installed, secrets remain the bootstrap Kubernetes Secrets."
fi

echo "==> bootstrap complete"
kubectl get pods -n istio-system
kubectl get pods -n databases
kubectl get pods -n monitoring
kubectl get gateway -A
