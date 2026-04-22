---
name: kubernetes-network-policy-apply
description: >
  Applies or updates Kubernetes NetworkPolicy resources for a target namespace.
  Supports standard policy templates (deny-all-ingress, allow-same-namespace,
  allow-ingress-controller, allow-monitoring) and custom policies from user input.
  Requires explicit user approval before applying any change.
  Use when: hardening a namespace, onboarding a new tenant, policy drift repair.
license: MIT
compatibility: opencode
metadata:
  owner: kubernetes-admin
  type: mutating
  approval: "Yes"
---

# kubernetes-network-policy-apply

**Owner**: `kubernetes-admin`
**Type**: `mutating`
**Approval**: `Yes`

---

## What I Do

Generates and applies NetworkPolicy manifests to a target namespace.
Operates in two modes:

- **Template mode** — applies one or more standard policies from the built-in library
- **Custom mode** — accepts a policy spec from the user and applies it after review

Always shows a full diff preview and requires explicit approval before applying.
Supports reconcile (re-apply without deleting existing policies).

---

## When to Use Me

- User requests: "apply network policy", "harden namespace", "add deny-all"
- New tenant namespace just provisioned — needs baseline policies
- Existing namespace is missing expected policies (detected by `kubernetes-namespace-audit`)
- Policy drift repair after cluster changes

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/kubernetes-admin/MEMORY.md
    Fields needed:
      ingress-controller-namespace  (default: ingress-nginx)
      monitoring-namespace          (default: monitoring)
      namespace-pattern             (to validate target namespace)

Estimated token cost: ~500 tokens
Unloaded after: policies applied and result confirmed
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| target-namespace | user | Yes |
| policies | user | No — defaults to standard baseline set |
| dry-run | user | No — default false |

**Standard policy templates** (use by name):
- `deny-all-ingress` — block all ingress by default
- `allow-same-namespace` — allow intra-namespace traffic
- `allow-ingress-controller` — allow traffic from ingress-nginx namespace
- `allow-monitoring` — allow scraping from monitoring namespace
- `allow-egress-dns` — allow DNS resolution (port 53 UDP/TCP)
- `deny-all-egress` — block all egress by default (strict mode)

---

## Steps

```
1. Validate target namespace
   kubectl get namespace {namespace} --no-headers 2>/dev/null
   IF not found → stop:
     "Namespace {namespace} does not exist.
      Create it first or check the name."

2. Resolve policy set
   IF policies not specified → use baseline: [deny-all-ingress,
     allow-same-namespace, allow-ingress-controller, allow-monitoring,
     allow-egress-dns]
   IF policies specified → validate each name against template library
     Unknown name → ask user to provide custom YAML or correct the name

3. Check existing policies
   kubectl get networkpolicy -n {namespace} -o yaml
   For each requested policy: note if a policy with the same name already exists
   Reconcile: existing policies with same name will be replaced (kubectl apply)

4. Generate manifests
   Build YAML for each policy (see Policy Templates section)
   Substitute namespace values from MEMORY.md

5. Show preview — REQUIRE APPROVAL
   Display full YAML for every policy to be applied
   List existing policies that will be replaced
   Print:
     "Ready to apply {n} NetworkPolicy resources to namespace {namespace}.
      Existing policies with matching names will be replaced.
      Proceed? (yes / no)"
   STOP — wait for explicit "yes"

6. Apply
   IF dry-run:
     kubectl apply --dry-run=server -f - <<EOF ... EOF
   ELSE:
     kubectl apply -f - <<EOF ... EOF
   Capture output, check for errors

7. Verify
   kubectl get networkpolicy -n {namespace} -o wide
   Confirm all applied policies appear in list

8. Report
   "Applied {n} NetworkPolicy resources to {namespace}:
    {policy-name}: created | configured | unchanged
    ...
    Current policies in namespace: {count}"

9. Log to .crux/bus/kubernetes-admin/
   action: network-policy-apply
   namespace: {namespace}
   policies: {list}
   approver: user
   timestamp: {ISO8601}
   outcome: success | failed — {reason}
```

---

## Policy Templates

```yaml
# deny-all-ingress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: {namespace}
  labels:
    managed-by: crux
spec:
  podSelector: {}
  policyTypes: [Ingress]

---
# allow-same-namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
  namespace: {namespace}
  labels:
    managed-by: crux
spec:
  podSelector: {}
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector: {}

---
# allow-ingress-controller
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-controller
  namespace: {namespace}
  labels:
    managed-by: crux
spec:
  podSelector: {}
  policyTypes: [Ingress]
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: {ingress-controller-namespace}

---
# allow-monitoring
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  namespace: {namespace}
  labels:
    managed-by: crux
spec:
  podSelector: {}
  policyTypes: [Ingress]
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: {monitoring-namespace}
      ports:
        - port: 9090
        - port: 8080
        - port: 3000

---
# allow-egress-dns
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-dns
  namespace: {namespace}
  labels:
    managed-by: crux
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
    - ports:
        - port: 53
          protocol: UDP
        - port: 53
          protocol: TCP
```

---

## Error Handling

| Condition | Action |
|---|---|
| Namespace does not exist | Stop. Notify with exact name provided. |
| kubectl apply fails | Show full error output. Do not retry silently. |
| Unknown policy name provided | List valid template names, ask user to choose or provide custom YAML. |
| User provides custom YAML with syntax error | Show parse error. Ask to correct and resubmit. |
| Cluster unreachable | Stop. Notify with endpoint, suggest kubeconfig check. |
