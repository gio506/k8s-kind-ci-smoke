# Files Explained

- `.github/workflows/kind-ci.yml`: 6-stage CI pipeline for lint, cluster creation, deploy, rollout, smoke, and cleanup.
- `CHEATSHEET.md`: quick commands for kind, kubectl, and CI troubleshooting.
- `FILES_EXPLAINED.md`: short purpose statement for every tracked file.
- `README.md`: project overview, local usage, and CI flow.
- `k8s/deployment.yaml`: tiny echo application with probes.
- `k8s/namespace.yaml`: dedicated namespace for the smoke app.
- `k8s/service.yaml`: ClusterIP service exposing the app.
- `scripts/collect_logs.sh`: diagnostic helper for failures.
- `scripts/deploy.sh`: applies the namespace, deployment, and service manifests.
- `scripts/kind_up.sh`: creates the local kind cluster.
- `scripts/smoke-test.sh`: performs the HTTP response assertion.
- `scripts/smoke.sh`: wrapper used by CI and local runs.
