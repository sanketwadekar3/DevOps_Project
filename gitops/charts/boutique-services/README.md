# Generic Microservice Helm Chart

This chart deploys **one microservice per Helm release**. It intentionally has
no list of applications or `components` loop. Reuse the same chart by choosing
a different release name and values file for each service.

## Files

- `values.yaml` — simple, generic defaults for one service.
- `templates/deployment.yaml` — the service Deployment.
- `templates/service.yaml` — an optional Service.
- `templates/serviceaccount.yaml` — an optional ServiceAccount.
- `templates/hpa.yaml` — an optional CPU-based `autoscaling/v2` HPA.
- `templates/servicemonitor.yaml` — an optional Prometheus Operator monitor.
- `../k8s/boutique-microservices/*.yaml` — values for current services.

The chart does not create namespaces, Secrets, databases, or monitoring
resources. Those remain managed by the surrounding GitOps configuration.

The existing `gitops/kustomization.yml` is still used for the database,
namespace, Secrets, and Grafana resources. It no longer manages a standalone
ServiceMonitor.

## Values for one service

The important values are top-level fields:

```yaml
nameOverride: inventory
replicaCount: 2
image:
  repository: sanketwadekar3/inventory-service
  tag: a1b2c3d
  pullPolicy: IfNotPresent
containerPort: 3010
env:
  - name: NODE_ENV
    value: production
resources:
  requests: { cpu: 100m, memory: 128Mi }
  limits: { cpu: 500m, memory: 512Mi }
```

`image.repository`, `image.tag`, and `containerPort` are required. A Service
is enabled by default; set `service.enabled: false` when the workload should
not receive a Kubernetes Service.

## Install multiple services

Each service gets its own Helm release. Run from the repository root:

```bash
CHART=gitops/charts/boutique-services
helm upgrade --install auth "$CHART" -n boutique --create-namespace \
  -f gitops/k8s/boutique-microservices/auth.yaml
helm upgrade --install gateway "$CHART" -n boutique \
  -f gitops/k8s/boutique-microservices/gateway.yaml
```

Repeat the same command for the remaining values files. Release names become
resource names unless `nameOverride` is set.

## Optional features

```yaml
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/inventory
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 8
  targetCPUUtilizationPercentage: 70
serviceMonitor:
  enabled: true
  namespace: monitoring
  labels:
    release: kube-prometheus-stack
  path: /metrics
  interval: 15s
```

An HPA requires Metrics Server and CPU requests. A ServiceMonitor requires the
Prometheus Operator CRD and scrapes the Helm release Service on its `http`
port. Add `livenessProbe` and `readinessProbe` using normal Kubernetes probe
syntax.

## Validate

```bash
helm lint gitops/charts/boutique-services \
  -f gitops/k8s/boutique-microservices/auth.yaml
helm template auth gitops/charts/boutique-services -n boutique \
  -f gitops/k8s/boutique-microservices/auth.yaml
```

Review rendered output before applying it. The `argo/argocd-apps` chart manages
one Argo CD Application per service using the values in
`gitops/argocd/apps-values.yaml`.
