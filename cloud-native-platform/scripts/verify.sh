#!/usr/bin/env bash
set -euo pipefail

kubectl get nodes -o wide
kubectl get pods -A
kubectl get pvc -A
kubectl get gateway -A
kubectl get httproute -A
kubectl get hpa -A || true
kubectl get pdb -A || true
kubectl get servicemonitor -A
kubectl get prometheusrule -A
kubectl get secrets -n databases
kubectl get secrets -n apps
kubectl get peerauthentication -n apps
kubectl get svc -n gateway

if command -v istioctl >/dev/null 2>&1; then
  istioctl ztunnel-config workloads
else
  echo "istioctl not installed; skip ztunnel-config. Install istioctl ${ISTIO_VERSION:-1.31.1} to inspect ambient workloads."
fi

echo
echo "Grafana admin user is in secret monitoring/grafana-admin"
echo "Gateway address (Vultr LB) appears on: kubectl get gateway public-gateway -n gateway -o yaml"
