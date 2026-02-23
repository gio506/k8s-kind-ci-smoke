# Kubernetes + kind + CI Cheatsheet

A practical command reference for daily and advanced troubleshooting.

## kind cluster lifecycle

- `kind create cluster --name demo` - Create a local Kubernetes-in-Docker cluster.
- `kind get clusters` - List local kind clusters.
- `kind delete cluster --name demo` - Delete a specific kind cluster.
- `kind export kubeconfig --name demo` - Merge cluster kubeconfig into your default config.
- `kind load docker-image myapp:dev --name demo` - Load local Docker image into kind nodes.
- `kind get nodes --name demo` - Show node container names.

## kubectl basics

- `kubectl cluster-info` - Show control plane and DNS endpoints.
- `kubectl config get-contexts` - List available contexts.
- `kubectl config use-context kind-demo` - Switch active context.
- `kubectl get ns` - List namespaces.
- `kubectl get all -n smoke-demo` - Quick resource overview in namespace.
- `kubectl apply -f k8s/` - Create/update resources from manifests.
- `kubectl delete -f k8s/` - Remove resources created from manifests.
- `kubectl describe pod <pod> -n smoke-demo` - Detailed pod state/events.
- `kubectl logs deploy/tiny-web -n smoke-demo --tail=100` - Tail deployment logs.

## rollout and availability

- `kubectl rollout status deployment/tiny-web -n smoke-demo --timeout=180s` - Wait for deployment to become ready.
- `kubectl rollout history deployment/tiny-web -n smoke-demo` - Revision history.
- `kubectl rollout undo deployment/tiny-web -n smoke-demo` - Roll back to previous revision.
- `kubectl scale deployment/tiny-web -n smoke-demo --replicas=2` - Scale up/down.

## networking and smoke tests

- `kubectl get svc -n smoke-demo` - List services.
- `kubectl port-forward svc/tiny-web -n smoke-demo 8080:80` - Expose service to localhost.
- `curl -fsS http://127.0.0.1:8080` - Test app response.
- `kubectl run tmp-curl --rm -it --restart=Never --image=curlimages/curl -- curl -sS tiny-web.smoke-demo.svc.cluster.local` - In-cluster DNS/service test.

## debugging (popular + less common)

- `kubectl get events -n smoke-demo --sort-by=.metadata.creationTimestamp` - Chronological events.
- `kubectl top pod -n smoke-demo` - Pod resource usage (metrics-server required).
- `kubectl api-resources` - All supported resource types.
- `kubectl explain deployment.spec.template.spec` - API schema help.
- `kubectl get pod <pod> -n smoke-demo -o jsonpath='{.status.containerStatuses[*].ready}'` - Readiness flags.
- `kubectl debug pod/<pod> -n smoke-demo -it --image=busybox:1.36 --target=tiny-web` - Ephemeral debug container.
- `kubectl auth can-i create deployments -n smoke-demo` - RBAC quick check.
- `kubectl diff -f k8s/` - Preview changes before apply.
- `kubectl wait --for=condition=available deployment/tiny-web -n smoke-demo --timeout=180s` - Declarative wait.
- `kubectl get --raw='/readyz?verbose'` - API server readiness details.

## manifest linting and validation

- `yamllint k8s/` - YAML style/syntax lint.
- `kubectl apply --dry-run=client -f k8s/` - Client-side validation without apply.
- `kubectl apply --dry-run=server -f k8s/` - Server-side validation using API server.

## GitHub Actions quick checks

- `act -l` - List workflows runnable via `act` locally.
- `act -j kind-smoke` - Run the `kind-smoke` job locally (if `act` is installed).
- `gh run list --workflow kind-ci.yml` - List recent workflow runs.
- `gh run watch` - Stream workflow logs live.

## shell helpers

- `watch -n 1 kubectl get pods -n smoke-demo` - Live pod watch.
- `kubectl get pods -n smoke-demo -o wide | awk '{print $1, $6, $7}'` - Pod name + IP + node snapshot.
- `for p in $(kubectl get po -n smoke-demo -o name); do kubectl logs -n smoke-demo "$p" --tail=20; done` - Gather logs for all pods.
