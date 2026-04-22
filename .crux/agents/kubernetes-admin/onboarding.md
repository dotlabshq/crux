# Onboarding: Kubernetes Admin

> This file defines the onboarding sequence for the `kubernetes-admin` agent.
> Onboarding runs automatically when the agent starts and
> MANIFEST.md shows `status: pending-onboard`.
> On completion, status is updated to `onboarded`.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/kubernetes-admin/AGENT.md` exists

If any are missing, stop and notify the user.

---

## Step 1 — Introduce

```
You are setting up the Kubernetes Admin agent.

This agent manages your Kubernetes cluster — nodes, namespaces,
networking, storage, workloads, and architecture documentation.
It enforces naming conventions, runs the tenant onboarding workflow,
and maintains SOC Type 2 compliance posture.

I will ask a few questions to configure it correctly.
Type "skip" at any point to defer a question — I will note it as pending.
```

---

## Step 2 — Environment Discovery

Run the following checks silently. Record results in
`.crux/workspace/kubernetes-admin/sessions/{id}/scratch.md`.

```
CLUSTER ACCESS
  kubectl cluster-info --request-timeout=5s
    OK  → record endpoint
    ERR → mark cluster-unreachable, surface in Step 3

  kubectl version -o json
    OK  → record server version, client version

  kubectl get nodes -o wide --no-headers
    OK  → record node count, roles, OS
    ERR → mark nodes-unreadable

NAMESPACE INVENTORY
  kubectl get namespaces --no-headers
    OK  → record namespace list
    Check for naming-convention violations (see tenant-standards — Step 4)

MULTI-TENANCY INDICATORS
  kubectl get namespaces -o json | jq '.items[].metadata.labels'
    Check: do namespaces carry tenant= label?
    Record: tenant-labels-present (yes / no / partial)

  kubectl get resourcequota -A --no-headers 2>/dev/null
    Record: quota-count per namespace

  kubectl get networkpolicies -A --no-headers 2>/dev/null
    Record: netpol-count, namespaces with no policies

SOC TYPE 2 — MONITORING
  kubectl get pods -A --no-headers | grep -Ei "prometheus|thanos|victoriametrics"
    OK  → record monitoring-stack, namespace
    ERR → mark monitoring-missing

  kubectl get pods -A --no-headers | grep -Ei "grafana"
    OK  → record grafana-namespace, attempt to get service URL
    ERR → mark grafana-missing

  kubectl get servicemonitor -A --no-headers 2>/dev/null
    OK  → record servicemonitor-count
    ERR → mark servicemonitor-missing (may indicate no Prometheus Operator)

SOC TYPE 2 — LOGGING
  kubectl get pods -A --no-headers | grep -Ei "loki|fluentd|fluent-bit|logstash|vector"
    OK  → record logging-stack, namespace
    ERR → mark logging-missing

  kubectl get pods -A --no-headers | grep -Ei "elasticsearch|opensearch"
    OK  → record search-backend
    ERR → (no action — loki may be the backend)

SOC TYPE 2 — AUDIT LOGGING
  kubectl get configmap -n kube-system audit-policy 2>/dev/null
  OR check: kubectl get pods -n kube-system -o yaml | grep "audit-policy-file"
    OK  → record audit-logging: enabled
    ERR → mark audit-logging-missing

SOC TYPE 2 — SECRET MANAGEMENT
  kubectl get pods -A --no-headers | grep -Ei "vault|external-secrets|sealed-secrets"
    OK  → record secret-manager, namespace
    ERR → mark secret-manager-missing

SOC TYPE 2 — IMAGE SCANNING
  kubectl get pods -A --no-headers | grep -Ei "trivy|falco|kyverno|gatekeeper"
    OK  → record policy-engine, namespace
    ERR → mark policy-engine-missing

STORAGE
  kubectl get storageclass --no-headers
    OK  → record storage-classes, default
  kubectl get pv --no-headers 2>/dev/null
    Record: pv-count
  kubectl get pvc -A --no-headers 2>/dev/null
    Record: pvc-count per namespace
```

---

## Step 3 — User Questions

Ask one at a time. Do not present a form.
Show discovered value as default where applicable.

```
Question 1 — Cluster identity
  "I found a cluster at {discovered-endpoint}. Should I use this cluster,
   or would you like to connect to a different one?"
  default: use discovered cluster
  stores-to: workspace/kubernetes-admin/MEMORY.md → cluster-endpoint

Question 2 — Production namespaces
  "Which namespaces should I treat as production?
   These will require your manual approval before any changes.
   (Discovered namespaces: {list})"
  default: none
  stores-to: workspace/kubernetes-admin/MEMORY.md → production-namespaces

Question 3 — Multi-tenancy
  "Is this cluster shared across multiple tenants (teams, customers, or environments
   that need namespace-level isolation)?"
  default: yes
  IF yes → continue to Question 4
  IF no  → skip Questions 4–6, set multi-tenant: false in MEMORY.md

Question 4 — Tenant namespace naming convention
  "What namespace naming convention should I enforce for tenants?
   Common patterns:
     {tenant-id}-{env}          e.g. acme-prod, acme-staging
     {env}-{tenant-id}          e.g. prod-acme, staging-acme
     {tenant-id}                e.g. acme (single-env clusters)
   Custom patterns are allowed — describe yours if different."
  default: {tenant-id}-{env}
  stores-to:
    workspace/kubernetes-admin/MEMORY.md → tenant-namespace-pattern
    docs/tenant-standards.md             → Naming Convention section

Question 5 — Existing tenants
  "List your existing tenants (one per line, format: tenant-id | team | owner-email).
   I will validate that their namespaces follow the naming convention."
  default: (skip — discover from namespace labels later)
  stores-to: docs/tenants.md → initial tenant rows

Question 6 — Grafana integration
  "Does tenant onboarding need to register tenants in Grafana?
   (I detected Grafana at: {grafana-url | not detected})"
  IF grafana detected → ask: "Confirm Grafana URL: {url}?"
  IF not detected    → ask: "Provide the Grafana URL, or type 'skip' to configure later."
  stores-to:
    workspace/kubernetes-admin/MEMORY.md → grafana-url
    workspace/kubernetes-admin/MEMORY.md → grafana-integration: enabled / disabled

Question 7 — Resource quota defaults
  "What default resource quotas should new tenant namespaces receive?
   Preset tiers (you can customise later):
     small:   2 CPU / 4Gi RAM / 20Gi storage
     medium:  8 CPU / 16Gi RAM / 100Gi storage
     large:   32 CPU / 64Gi RAM / 500Gi storage
   Or specify your own defaults."
  default: medium
  stores-to: docs/tenant-standards.md → Resource Quotas section
```

---

## Step 4 — Generate Docs

```
Run sequentially:

  1. kubernetes-architecture-analyser  →  docs/kubernetes.md
     Trigger: always during onboarding
     Condition: skip if cluster-unreachable (noted in NOTES.md)

  2. Generate docs/tenant-standards.md
     Trigger: if multi-tenant: true
     Source: answers from Questions 4, 5, 6, 7 + namespace discovery
     No skill required — write directly from collected data.
     See Output Format below.
     Note: these standards are referenced by the kubernetes-tenant-onboarding skill.

  3. Generate docs/tenants.md
     Trigger: if multi-tenant: true AND existing tenants provided
     Source: Question 5 answers + namespace discovery
     Write initial tenant registry.
     See Output Format below.
```

### Output Format — docs/tenant-standards.md

```markdown
# Tenant Standards

> Generated during kubernetes-admin onboarding on {DATE}.
> Update: @kubernetes-admin update tenant standards

## Naming Convention

Pattern: `{pattern}`  (e.g. `{tenant-id}-{env}`)

Valid environments: prod, staging, dev, preview
Tenant ID rules: lowercase, alphanumeric, hyphens allowed, max 20 chars

Examples:
  acme-prod
  acme-staging
  acme-dev

## Labels (Required on all tenant namespaces)

| Label | Value | Description |
|---|---|---|
| `tenant` | `{tenant-id}` | Tenant identifier |
| `env` | `{prod|staging|dev|preview}` | Environment |
| `managed-by` | `kubernetes-admin` | Do not change |
| `owner-email` | `{email}` | Team owner contact |

## Resource Quotas — Default Tiers

| Tier | CPU | Memory | Storage | Pods |
|---|---|---|---|---|
| small | 2 | 4Gi | 20Gi | 20 |
| medium | 8 | 16Gi | 100Gi | 100 |
| large | 32 | 64Gi | 500Gi | 500 |

Default tier: `{default-tier}`

## Network Policy Defaults

Every tenant namespace receives on creation:
  1. default-deny-ingress     — deny all ingress from other namespaces
  2. allow-same-namespace     — allow traffic within the namespace
  3. allow-monitoring         — allow Prometheus scraping from monitoring namespace

## Grafana Integration

Status: {enabled | disabled}
URL: {grafana-url | —}

On tenant creation: a Grafana folder named `{tenant-id}` is created.
Dashboards are the tenant's responsibility.

## SOC Type 2 Notes

- All tenant namespaces must have ResourceQuota and LimitRange applied.
- NetworkPolicy default-deny is mandatory for production tenants.
- Namespace creation requires approval gate (logged to bus/kubernetes-admin/).
- Audit events for namespace operations are logged to {audit-log-location}.
```

### Output Format — docs/tenants.md

```markdown
# Tenant Registry

> Source of truth for all tenants onboarded to this cluster.
> Updated automatically by tenant-onboarding skill.
> Manual changes require re-running the doc-summariser skill.

| Tenant ID | Environments | Owner | Tier | Onboarded | Status |
|---|---|---|---|---|---|
| {id} | {list} | {email} | {tier} | {DATE} | active |

---

## Tenant Detail

### {tenant-id}

- **Namespaces**: `{tenant-id}-prod`, `{tenant-id}-staging`
- **Owner**: {email}
- **Tier**: {tier}
- **Grafana folder**: `{tenant-id}` {url if available}
- **Onboarded**: {DATE}
- **Notes**: —
```

---

## Step 5 — SOC Type 2 Gap Report

After discovery, compile a gap report. Surface it to the user.

```
IF any of the following were marked missing during Step 2:
  monitoring-missing
  grafana-missing
  logging-missing
  audit-logging-missing
  secret-manager-missing
  policy-engine-missing

Present to user:

  "SOC Type 2 compliance gaps detected:

   ✗ Monitoring (Prometheus/Grafana)   — no metrics collection found
   ✗ Centralised logging              — no Loki/Fluentd/Vector found
   ✗ Kubernetes audit logging         — API server audit policy not detected
   ✗ Secret management                — no Vault/External Secrets Operator found
   ✗ Policy engine                    — no Kyverno/OPA Gatekeeper/Falco found

   I have added these as pending tasks in your NOTES.md.
   Address them before your next SOC Type 2 review.
   Type 'skip' to defer, or 'prioritise {item}' to address one now."

Write each gap to .crux/workspace/kubernetes-admin/NOTES.md
under: ## Pending Tasks — SOC Type 2 Gaps
with: status: open, discovered: {DATE}
```

---

## Step 6 — Review & Confirm

```
"Onboarding summary for Kubernetes Admin:

  Cluster:          {endpoint}
  Version:          {version}
  Nodes:            {count} ({roles})
  Production namespaces: {list | none}
  Multi-tenant:     {yes | no}
  Namespace pattern: {pattern | —}
  Tenant count:     {n | —}
  Grafana:          {url | not configured}
  Default quota tier: {tier}

  Docs generated:
    {✓ | ✗} docs/kubernetes.md
    {✓ | ✗} docs/tenant-standards.md
    {✓ | ✗} docs/tenants.md

  SOC Type 2 gaps: {n gaps | none detected}

Does this look correct?
  → yes: finalise
  → no: tell me what to fix"
```

---

## Step 7 — Finalise

```
1. Write all collected facts to .crux/workspace/kubernetes-admin/MEMORY.md:
   cluster-endpoint:         {value}
   kubernetes-version:       {value}
   node-count:               {value}
   cni:                      {value | unknown}
   production-namespaces:    [{list}]
   multi-tenant:             {true | false}
   tenant-namespace-pattern: {value | —}
   grafana-url:              {value | —}
   grafana-integration:      {enabled | disabled}
   default-quota-tier:       {value}
   monitoring-stack:         {value | missing}
   logging-stack:            {value | missing}
   audit-logging:            {enabled | missing}
   secret-manager:           {value | missing}
   policy-engine:            {value | missing}
   onboarded-date:           {DATE}

2. Update .crux/workspace/MANIFEST.md:
     agents.kubernetes-admin.status       → onboarded
     agents.kubernetes-admin.docs         → ✓
     agents.kubernetes-admin.last-session → {DATE}
   Add doc rows: kubernetes.md, tenant-standards.md, tenants.md

3. Write event to .crux/bus/broadcast.jsonl:
   { "type": "agent.onboarded", "from": "kubernetes-admin", "ts": "..." }

4. Notify user:
   "Kubernetes Admin is ready.
    Type @kubernetes-admin to assign tasks."
```

---

## Re-Onboarding

Onboarding can be re-run at any time:
- User requests it explicitly
- A required docs/ file is deleted
- MANIFEST.md status is manually reset to `pending-onboard`

Re-onboarding does not overwrite existing MEMORY.md entries —
it appends or updates only the fields it collects.
