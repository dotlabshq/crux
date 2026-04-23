---
name: kubernetes-tenant-onboarding
description: >
  Kubernetes-specific step of tenant onboarding. Creates namespace(s) with
  correct labels, applies ResourceQuota and LimitRange from the tier preset,
  enforces NetworkPolicy defaults (default-deny, allow-same-namespace,
  allow-monitoring), sets up RBAC for the tenant team, registers the tenant
  in Grafana (if enabled), and updates docs/tenants.md.
  Part of the multi-step tenant onboarding workflow (.crux/workflows/tenant-onboarding.md).
  Use when: Kubernetes provisioning step of tenant onboarding, or re-applying
  standards to a drifted tenant namespace (reconcile mode).
license: MIT
compatibility: opencode
metadata:
  owner: kubernetes-admin
  type: read-write
  approval: "Yes — namespace creation requires user confirmation"
---

# kubernetes-tenant-onboarding

**Owner**: `kubernetes-admin`
**Type**: `read-write`
**Approval**: `Yes — namespace creation and RBAC changes require explicit user confirmation`
**Workflow**: Part of `.crux/workflows/tenant-onboarding.md` — Step: Kubernetes

---

## What I Do

Provisions a fully-configured tenant namespace on the cluster:
- Namespace with required labels
- ResourceQuota + LimitRange from tier preset
- Three default NetworkPolicies (deny, allow-same-ns, allow-monitoring)
- RBAC RoleBinding for the tenant team
- Grafana folder registration (if grafana-integration: enabled)
- Entry in `docs/tenants.md` registry
- Audit log entry to `bus/kubernetes-admin/`

---

## When to Use Me

- User says: "add tenant", "onboard {team}", "create namespace for {tenant}"
- New customer or team joining the platform
- New environment needed for an existing tenant
- Drifted namespace needs standards re-applied (`--reconcile` mode)

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/kubernetes-admin/MEMORY.md
    Fields needed:
      tenant-namespace-pattern    (e.g. {tenant-id}-{env})
      production-namespaces       (for approval gate check)
      grafana-url                 (if grafana-integration: enabled)
      grafana-integration         (enabled | disabled)
      default-quota-tier          (small | medium | large)
      monitoring-stack-namespace  (for allow-monitoring NetworkPolicy)
      iac-mode                    (kustomize | cicd | direct)
      cicd-tool                   (argocd | flux | github-actions | etc | none)
      kustomize-base-path         (e.g. k8s/)

  .crux/docs/tenant-standards.md   (quota tiers, label requirements)

Does NOT preload docs/tenants.md — reads it only when updating.

Estimated token cost: ~450 tokens
Unloaded after: docs/tenants.md updated and bus event written
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| tenant-id | user | Yes |
| environment(s) | user | Yes |
| owner-email | user | Yes |
| tier | user or MEMORY.md → default-quota-tier | No — uses default |
| team-group | user | No — RBAC skipped if omitted |
| reconcile | flag | No — re-applies standards without recreating namespace |

**Tenant ID rules**: lowercase, alphanumeric + hyphens only, max 20 chars.
Validated before any kubectl command runs.

---

## Steps

```
PRE-FLIGHT

  0. Validate inputs
     tenant-id must match: ^[a-z0-9][a-z0-9-]{0,19}$
     environment must be one of: prod, staging, dev, preview
     IF validation fails → stop, explain the rule, ask user to correct

  1. Derive namespace name(s)
     Apply pattern from MEMORY.md → tenant-namespace-pattern
     e.g. pattern "{tenant-id}-{env}" + tenant "acme" + env "prod"
          → namespace "acme-prod"

  2. Check for namespace collision
     kubectl get namespace {namespace} 2>/dev/null
     IF exists AND --reconcile not set → ask user:
       "Namespace {namespace} already exists.
        Run in reconcile mode to re-apply standards without recreating? (yes / no)"
     IF exists AND --reconcile set → skip to RECONCILE mode

  3. Derive manifest path
     base_path = MEMORY.md → kustomize-base-path  (e.g. k8s/)
     tenant_path = {base_path}/tenants/{tenant-id}/{env}/
     e.g. k8s/tenants/acme/prod/

WRITE MANIFESTS

  4. Write tenant Kustomize overlay
     Create directory: {tenant_path}

     Write {tenant_path}/kustomization.yaml:
       apiVersion: kustomize.config.k8s.io/v1beta1
       kind: Kustomization
       namespace: {namespace}
       resources:
         - ../../base
       patches:
         - path: namespace-patch.yaml
         - path: quota-patch.yaml  (only if tier differs from base)

     Write {tenant_path}/namespace-patch.yaml:
       apiVersion: v1
       kind: Namespace
       metadata:
         name: {namespace}
         labels:
           tenant: {tenant-id}
           env: {env}
           managed-by: kubernetes-admin
           owner-email: {email}

     Write {tenant_path}/quota-patch.yaml (tier values — see Manifests section):
       apiVersion: v1
       kind: ResourceQuota
       metadata:
         name: tenant-quota
       spec:
         hard:
           requests.cpu: "{cpu}"
           requests.memory: {mem}
           limits.cpu: "{cpu}"
           limits.memory: {mem}
           requests.storage: {storage}
           count/pods: "{pods}"

     IF team-group provided:
       Write {tenant_path}/rbac.yaml:
         apiVersion: rbac.authorization.k8s.io/v1
         kind: RoleBinding
         metadata:
           name: {tenant-id}-team-edit
           namespace: {namespace}
         subjects:
           - kind: Group
             name: {team-group}
             apiGroup: rbac.authorization.k8s.io
         roleRef:
           kind: ClusterRole
           name: edit
           apiGroup: rbac.authorization.k8s.io
       Add rbac.yaml to kustomization.yaml resources list

APPROVAL GATE

  5. Show what will be applied
     Run: kubectl diff -k {tenant_path}
     Display diff output to user.

     Present:
       "Manifest files written to: {tenant_path}
        kubectl diff output: (above)

        Namespace(s) to create: {list}
        Labels: tenant={tenant-id}, env={env}, managed-by=kubernetes-admin
        Quota tier: {tier} — CPU: {cpu}, Memory: {mem}, Storage: {storage}
        Network policies: deny-all-ingress, allow-same-namespace, allow-monitoring (from base)
        RBAC: {team-group} → edit role | skipped
        Grafana folder: {tenant-id} | skipped

        Proceed? (yes / no)"

     Wait for explicit "yes". Do not proceed on ambiguous responses.

APPLY

  6. Apply based on iac-mode

     IF iac-mode == kustomize:
       kubectl apply -k {tenant_path}
       Capture output. Check for errors. Stop if any resource fails.

     IF iac-mode == cicd:
       DO NOT run kubectl apply.
       Show:
         "Manifests written to {tenant_path}
          Your {cicd-tool} pipeline will apply these changes.
          If you need to trigger it manually: {relevant command per tool}
            ArgoCD:          argocd app sync {app-name}
            Flux:            flux reconcile kustomization {name}
            GitHub Actions:  push to trigger workflow
            GitLab CI:       push or trigger pipeline"
       Skip to INTEGRATIONS step.

     IF iac-mode == direct:
       Warn:
         "iac-mode is set to 'direct'. Changes will be applied without a pipeline.
          Manifests have been written to {tenant_path} for reference."
       kubectl apply -k {tenant_path}

  7. Verify (kustomize and direct modes only)
     kubectl get namespace {namespace} --no-headers
     kubectl get resourcequota -n {namespace} --no-headers
     kubectl get networkpolicy -n {namespace} --no-headers
     All expected resources must be present. Report any missing.

INTEGRATIONS

  8. Grafana registration (if grafana-integration: enabled)
     POST to Grafana API: create folder named {tenant-id}
     Endpoint: {grafana-url}/api/folders
     Body: { "title": "{tenant-id}", "uid": "{tenant-id}" }
     IF API call fails → warn user, continue (non-blocking)
     Record: grafana-folder-url in docs/tenants.md

DOCUMENTATION

  9. Update docs/tenants.md
     IF file does not exist → create with header.
     Append or update row in Tenant Registry table.
     Append or update Tenant Detail section.
     Add: manifest-path: {tenant_path}

  10. Update MANIFEST.md
      Update docs/tenants.md last-updated timestamp.

  11. Log to bus
      Write to .crux/bus/kubernetes-admin/to-coordinator.jsonl:
      {
        "type": "tenant.onboarded",
        "from": "kubernetes-admin",
        "tenant": "{tenant-id}",
        "namespaces": ["{namespace}", ...],
        "tier": "{tier}",
        "manifest-path": "{tenant_path}",
        "iac-mode": "{iac-mode}",
        "ts": "{ISO-8601}"
      }

  12. Notify user
      "Tenant {tenant-id} onboarded.
       Namespace(s): {list}
       Manifests: {tenant_path}
       Applied: {yes — kubectl apply -k | pending — pipeline will apply | yes — direct}
       Grafana folder: {url | skipped}
       Entry added to docs/tenants.md"
```

---

## RECONCILE Mode

Triggered when namespace exists and user confirms reconcile.

```
Reconcile does NOT:
  - Delete or recreate the namespace
  - Remove existing workloads
  - Change the namespace name

Reconcile DOES:
  - Update manifest files in {kustomize-base-path}/tenants/{tenant-id}/{env}/
  - Re-apply via kubectl apply -k (or show git instructions if iac-mode: cicd)
  - Update docs/tenants.md entry
  - Log reconcile event to bus

Approval gate for reconcile:
  Run: kubectl diff -k {tenant_path}
  Show diff output.
  "Manifest path: {tenant_path}
   diff output above shows what will change.
   No resources will be deleted. Proceed? (yes / no)"
```

---

## Manifests

### ResourceQuota — Tier Presets

```yaml
# small
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-quota
  namespace: {namespace}
  labels:
    tenant: {tenant-id}
    managed-by: kubernetes-admin
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "2"
    limits.memory: 4Gi
    requests.storage: 20Gi
    count/pods: "20"
---
# medium
spec:
  hard:
    requests.cpu: "8"
    requests.memory: 16Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    requests.storage: 100Gi
    count/pods: "100"
---
# large
spec:
  hard:
    requests.cpu: "32"
    requests.memory: 64Gi
    limits.cpu: "32"
    limits.memory: 64Gi
    requests.storage: 500Gi
    count/pods: "500"
```

### LimitRange

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: tenant-limits
  namespace: {namespace}
  labels:
    tenant: {tenant-id}
    managed-by: kubernetes-admin
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 100m
        memory: 128Mi
      default:
        cpu: 500m
        memory: 512Mi
      max:
        cpu: "4"
        memory: 8Gi
```

### NetworkPolicy — default-deny-ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: {namespace}
  labels:
    tenant: {tenant-id}
    managed-by: kubernetes-admin
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

### NetworkPolicy — allow-same-namespace

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
  namespace: {namespace}
  labels:
    tenant: {tenant-id}
    managed-by: kubernetes-admin
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector: {}
```

### NetworkPolicy — allow-monitoring

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  namespace: {namespace}
  labels:
    tenant: {tenant-id}
    managed-by: kubernetes-admin
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: {monitoring-stack-namespace}
      ports:
        - port: 9090
          protocol: TCP
        - port: 8080
          protocol: TCP
        - port: 3000
          protocol: TCP
```

---

## Error Handling

| Condition | Action |
|---|---|
| Tenant ID format invalid | Stop. Explain rule. Ask user to correct. |
| Namespace already exists (no reconcile) | Ask user: reconcile or abort? |
| kubectl apply fails | Stop. Show error. Do not continue to next step. |
| Grafana API call fails | Warn. Continue. Note in docs/tenants.md as `grafana: pending`. |
| docs/tenants.md not writable | Write to workspace/kubernetes-admin/output/tenants-update.md. Notify user. |
| MEMORY.md missing required fields | Stop. Notify: "Re-run onboarding to configure tenant settings." |
