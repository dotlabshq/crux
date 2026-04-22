---
name: kubernetes-storage-health
description: >
  Inspects cluster storage health: PersistentVolumes, PersistentVolumeClaims,
  StorageClasses, and volume-related events. Identifies unbound PVCs, full or
  near-full volumes, and provisioner errors.
  Use when: storage questions, PVC issues, pre-release storage review,
  or on-demand capacity check.
license: MIT
compatibility: opencode
metadata:
  owner: kubernetes-admin
  type: read-only
  approval: "No"
---

# kubernetes-storage-health

**Owner**: `kubernetes-admin`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Connects to the live cluster and produces a complete storage health snapshot:
StorageClasses, PersistentVolumes (all phases), PersistentVolumeClaims (all
namespaces), and recent volume-related warning events. Identifies actionable
issues and presents a prioritised summary.

---

## When to Use Me

- User reports: "PVC stuck", "volume full", "storage issue", "disk pressure"
- Pre-release storage review
- Periodic capacity check
- kubernetes-architecture-analyser doc is stale for storage section

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/kubernetes-admin/MEMORY.md
    Fields needed:
      cluster-endpoint
      production-namespaces  (to flag production issues as higher priority)

Estimated token cost: ~400 tokens
Unloaded after: report delivered
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| target-namespace | user | No — checks all namespaces if omitted |
| target-pvc | user | No — narrows to one PVC if provided |

---

## Steps

```
1. Verify access
   kubectl cluster-info --request-timeout=5s
   IF unreachable → stop, notify

2. StorageClasses
   kubectl get storageclass -o wide
   Note: default storage class, provisioner, reclaim policy, volume binding mode

3. PersistentVolumes
   kubectl get pv -o wide
   For each PV:
     Phase:         Available / Bound / Released / Failed
     Reclaim:       Retain / Delete / Recycle
     Capacity:      record size
     Claim:         which PVC it is bound to (namespace/name)
   FLAG: PVs in Released or Failed phase → WARN

4. PersistentVolumeClaims
   IF target-namespace: kubectl get pvc -n {ns} -o wide
   ELSE:                kubectl get pvc -A -o wide
   IF target-pvc:       kubectl get pvc {pvc} -n {ns} -o yaml

   For each PVC:
     Phase:     Pending / Bound / Lost
     FLAG Pending > 2 min → FAIL (provisioning stuck)
     FLAG Lost            → FAIL (underlying PV gone)
     Capacity requested vs allocated

5. Volume events (last 30 minutes)
   kubectl get events -A \
     --field-selector=type=Warning \
     --sort-by='.lastTimestamp' 2>/dev/null \
   | grep -i -E "volume|pvc|pv|disk|storage|provision|mount|attach|detach"
   FLAG: FailedMount, FailedAttach, ProvisioningFailed → FAIL

6. Node disk pressure
   kubectl get nodes -o json \
   | jq '.items[] | select(.status.conditions[]
       | select(.type=="DiskPressure" and .status=="True"))
       | .metadata.name'
   FLAG: any node with DiskPressure → FAIL

7. Compile results
   Issues sorted by severity:
     FAIL   — action required (stuck PVC, Lost PVC, DiskPressure, FailedMount)
     WARN   — attention needed (Released PV, near-capacity)
     OK     — healthy

8. Report inline
   Summary + issue list with suggested remediation for each FAIL item
```

---

## Output

Delivered inline. Format:

```
## Storage Health — {DATE}

StorageClasses: {list with default marked}

### PersistentVolumes ({n} total)
  Bound:     {n}
  Available: {n}
  Released:  {n}  ← WARN if > 0
  Failed:    {n}  ← FAIL if > 0

### PersistentVolumeClaims ({n} total, {n} namespaces)
  Bound:   {n}
  Pending: {n}  ← FAIL if any Pending > threshold
  Lost:    {n}  ← FAIL if any

### Node Disk Pressure
  None  /  {node-list} under pressure ← FAIL

### Issues

| Severity | Resource | Namespace | Issue | Suggested Action |
|---|---|---|---|---|
| FAIL | pvc/data-0 | prod-acme | Pending 15m — no matching PV | Check StorageClass provisioner logs |
| WARN | pv/pvc-xxx | — | Released — reclaim manually or delete | kubectl delete pv {name} |

### Events (storage-related warnings)
{top 10 events with timestamp, namespace, resource, reason, message}
```

---

## Error Handling

| Condition | Action |
|---|---|
| kubectl not found | Stop. Notify: "kubectl is required." |
| Cluster unreachable | Stop. Notify with endpoint. |
| No PVCs found | Report: "No PersistentVolumeClaims found in {scope}." |
| jq not found | Skip disk pressure check, note in output. |
| Partial command failure | Mark affected section as `(error — {reason})`, continue. |
