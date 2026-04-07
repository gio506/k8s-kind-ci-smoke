#!/usr/bin/env bash
# Purpose: Port-forward the smoke-demo app to localhost for manual testing
# Usage: bash scripts/port-forward.sh [local-port]

set -euo pipefail

NAMESPACE="smoke-demo"
LOCAL_PORT="${1:-8080}"
LABEL="app=tiny-web"

echo "Looking for pods in namespace: $NAMESPACE"

POD=$(kubectl -n "$NAMESPACE" get pod -l "$LABEL" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD" ]; then
  echo "ERROR: No pod found with label $LABEL in namespace $NAMESPACE"
  echo "Check cluster state with: kubectl -n $NAMESPACE get pods"
  exit 1
fi

echo "Forwarding $POD port 8080 → localhost:$LOCAL_PORT"
echo "Press Ctrl+C to stop"
echo ""
echo "Test with:"
echo "  curl http://localhost:$LOCAL_PORT/"
echo "  curl http://localhost:$LOCAL_PORT/health"

kubectl -n "$NAMESPACE" port-forward "pod/$POD" "${LOCAL_PORT}:8080"
