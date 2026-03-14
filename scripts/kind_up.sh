#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-kind-ci-smoke}"

kind create cluster --name "${CLUSTER_NAME}" --wait 120s
kubectl cluster-info --context "kind-${CLUSTER_NAME}"
