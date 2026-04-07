# Kubernetes Concepts — Applied to This Project

Notes on K8s concepts as implemented in this k8s-kind-ci-smoke lab.

## Why kind for Local Testing?

`kind` (Kubernetes in Docker) creates a real Kubernetes cluster inside Docker containers. Unlike Minikube (VM-based), kind:
- Starts in ~30 seconds
- Works inside Docker (great for CI)
- Supports multi-node clusters (useful for testing topology constraints)
- Uses the actual Kubernetes API (not a simulation)

The `kind-config.yml` in this repo creates a 1-node cluster (1 control-plane). For production-like testing, you'd add `extraPortMappings` and worker nodes.

---

## Manifest Structure Applied Here

```text
k8s/
├── namespace.yaml      create isolated namespace for testing
├── deployment.yaml     run the app with replicas + resource limits
├── service.yaml        expose the app inside the cluster
└── ingress.yaml        route external traffic (optional in kind)
```

Each resource is separate — avoids a monolithic YAML and allows individual `kubectl apply`.

---

## Security Contexts Explained

In `deployment.yaml`:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  seccompProfile:
    type: RuntimeDefault
```

- **runAsNonRoot**: Pod will fail if the container image tries to run as root. Kubernetes-enforced.
- **allowPrivilegeEscalation: false**: Process cannot gain more capabilities than its parent.
- **readOnlyRootFilesystem**: Container can't write to its own image layers. Forces statefulness to mounted volumes only.
- **seccompProfile RuntimeDefault**: Applies Docker's default seccomp filter — blocks dangerous syscalls.

---

## Resource Requests vs Limits

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "200m"
```

- **Requests** = what Kubernetes reserves on the node for scheduling
- **Limits** = hard ceiling — container is OOM-killed if it exceeds memory limit

**Why these specific values?** This is a minimal Go HTTP server. 64Mi memory request is generous — the actual process uses ~10MB idle. The 200m CPU limit (0.2 vCPU) prevents a runaway process from starving other pods.

---

## Debugging Commands

```bash
# View events in the namespace
kubectl -n smoke-demo get events --sort-by='.lastTimestamp'

# Shell into a running pod
kubectl -n smoke-demo exec -it $(kubectl -n smoke-demo get pod -o name | head -1) -- sh

# View resource usage on the node
kubectl top nodes

# Get pod details including init container status
kubectl -n smoke-demo describe pod <pod-name>

# Stream logs from all pods with the app label
kubectl -n smoke-demo logs -l app=tiny-web --follow
```
