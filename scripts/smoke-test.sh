#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-smoke-demo}"
SERVICE="${SERVICE:-tiny-web}"
LOCAL_PORT="${LOCAL_PORT:-8080}"
EXPECTED="${EXPECTED:-kind-ci-smoke-ok}"
PORT_FORWARD_LOG="$(mktemp)"
RESPONSE_FILE="$(mktemp)"

cleanup() {
  if [[ -n "${PF_PID:-}" ]]; then
    kill "${PF_PID}" >/dev/null 2>&1 || true
  fi
  rm -f "${PORT_FORWARD_LOG}" "${RESPONSE_FILE}"
}
trap cleanup EXIT

echo "[smoke] starting port-forward ${SERVICE} -> localhost:${LOCAL_PORT}"
kubectl -n "${NAMESPACE}" port-forward "svc/${SERVICE}" "${LOCAL_PORT}:80" >"${PORT_FORWARD_LOG}" 2>&1 &
PF_PID=$!

for _ in {1..20}; do
  if curl -fsS "http://127.0.0.1:${LOCAL_PORT}" >"${RESPONSE_FILE}"; then
    break
  fi
  sleep 1
done

RESPONSE="$(cat "${RESPONSE_FILE}" 2>/dev/null || true)"
if [[ "${RESPONSE}" != *"${EXPECTED}"* ]]; then
  echo "[smoke] expected response to contain '${EXPECTED}' but got: ${RESPONSE}"
  echo "[smoke] port-forward logs:"
  cat "${PORT_FORWARD_LOG}" || true
  exit 1
fi

echo "[smoke] response OK: ${RESPONSE}"
