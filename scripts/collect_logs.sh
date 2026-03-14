#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-smoke-demo}"

kubectl get all -n "${NAMESPACE}" || true
kubectl describe deployment tiny-web -n "${NAMESPACE}" || true
kubectl logs deployment/tiny-web -n "${NAMESPACE}" --all-containers=true || true
