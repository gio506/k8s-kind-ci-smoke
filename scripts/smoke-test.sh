#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-smoke-demo}"
SERVICE="${SERVICE:-tiny-web}"
LOCAL_PORT="${LOCAL_PORT:-8080}"
EXPECTED="${EXPECTED:-kind-ci-smoke-ok}"

cleanup() {
  if [[ -n "${PF_PID:-}" ]]; then
    kill "${PF_PID}" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "[smoke] starting port-forward ${SERVICE} -> localhost:${LOCAL_PORT}"
kubectl -n "${NAMESPACE}" port-forward "svc/${SERVICE}" "${LOCAL_PORT}:80" >/tmp/port-forward.log 2>&1 &
PF_PID=$!

for _ in {1..20}; do
  if curl -fsS "http://127.0.0.1:${LOCAL_PORT}" >/tmp/smoke-response.txt; then
    break
  fi
  sleep 1
done

RESPONSE="$(cat /tmp/smoke-response.txt 2>/dev/null || true)"
if [[ "${RESPONSE}" != *"${EXPECTED}"* ]]; then
  echo "[smoke] expected response to contain '${EXPECTED}' but got: ${RESPONSE}"
  echo "[smoke] port-forward logs:"
  cat /tmp/port-forward.log || true
  exit 1
fi

echo "[smoke] response OK: ${RESPONSE}"
