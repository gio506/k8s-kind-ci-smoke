# k8s-kind-ci-smoke

Tiny Kubernetes app smoke-tested end-to-end in GitHub Actions using a local **kind** cluster.

## What this project does

- Spins up a kind cluster in CI.
- Deploys a tiny HTTP echo app.
- Waits for deployment rollout.
- Runs a real HTTP smoke test with `curl`.
- Collects Kubernetes diagnostics on failure.
- Tears down the cluster.

## CI pipeline stages

Workflow file: `.github/workflows/kind-ci.yml`

1. **Lint YAML** with `yamllint`.
2. **Create kind cluster** (`kind-ci-smoke`).
3. **Deploy** with `scripts/deploy.sh`.
4. **Wait/Rollout check** for `deployment/tiny-web`.
5. **Smoke tests** via `kubectl port-forward` + `curl`.
6. **Cleanup** deletes the kind cluster (runs even on failure).

## Local run (same flow as CI)

### Prerequisites

- Docker
- kind
- kubectl
- curl

### Commands

```bash
# 1) Lint manifests/workflow
python -m pip install --upgrade pip yamllint
yamllint -d '{extends: default, rules: {line-length: {max: 140}}}' k8s .github/workflows

# 2) Create cluster
./scripts/kind_up.sh

# 3) Deploy
./scripts/deploy.sh

# 4) Wait for rollout
kubectl -n smoke-demo rollout status deployment/tiny-web --timeout=180s

# 5) Run smoke test
./scripts/smoke.sh

# 6) Cleanup
kind delete cluster --name kind-ci-smoke
```

## Project tree

```text
.
├── .github/workflows/kind-ci.yml   # GitHub Actions pipeline with 6 CI stages
├── k8s/namespace.yaml              # Namespace isolation for the smoke app
├── k8s/deployment.yaml             # Tiny echo app deployment + readiness/liveness probes
├── k8s/service.yaml                # ClusterIP service exposing deployment on port 80
├── scripts/kind_up.sh              # Creates the local kind cluster
├── scripts/deploy.sh               # Applies the manifests
├── scripts/collect_logs.sh         # Failure diagnostics helper
├── scripts/smoke-test.sh           # Port-forward and curl-based assertion script
├── scripts/smoke.sh                # Wrapper used in CI and local runs
├── CHEATSHEET.md                   # Kubernetes/kind/GitHub Actions command reference
├── FILES_EXPLAINED.md              # File-by-file purpose map
└── README.md                       # Project overview and local/CI execution guide
```
