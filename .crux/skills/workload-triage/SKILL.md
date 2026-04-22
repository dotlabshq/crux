---
name: workload-triage
description: >
  Diagnoses non-running or unhealthy pods across the cluster or a target namespace.
  Collects pod status, recent events, container logs, and resource pressure signals
  to produce a prioritised issue list with remediation hints.
  Use when: pods are CrashLooping, Pending, OOMKilled, or Evicted; user reports
  a deployment issue; or non-running pods detected at session start.
license: MIT
compatibility: opencode
metadata:
  owner: kubernetes-admin
  type: read-only
  approval: "No"
---

# workload-triage

**Owner**: `kubernetes-admin`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Connects to the live cluster and identifies pods that are not in a healthy
Running/Completed state. For each unhealthy pod, collects events, container
status, last log lines, and node-level pressure signals to produce a
root-cause hypothesis with recommended next steps.

---

## When to Use Me

- User reports: "pods are down", "deployment failing", "CrashLoop", "OOMKilled"
- Auto-trigger: non-running pods detected at kubernetes-admin session start
- After a deployment or rollout to verify it succeeded
- Periodic health sweep on production namespaces

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/kubernetes-admin/MEMORY.md
    Fields needed:
      production-namespaces (to flag severity)

Estimated token cost: ~400 tokens
Unloaded after: triage report delivered
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| target-namespace | user | No — checks all namespaces if omitted |
| target-pod | user | No — narrows to one pod if provided |
| include-logs | user | No — default true, last 50 lines per container |

---

## Steps

```
1. Verify access
   kubectl cluster-info --request-timeout=5s
   IF unreachable → stop, notify

2. Find unhealthy pods
   IF target-pod provided:
     kubectl get pod {pod} -n {ns} -o wide
   ELSE IF target-namespace:
     kubectl get pods -n {ns} -o wide --field-selector=status.phase!=Running
     Also include Running pods with restarts > 10 in last hour
   ELSE:
     kubectl get pods -A -o wide \
       --field-selector='status.phase!=Running,status.phase!=Succeeded'
     kubectl get pods -A -o json \
       | identify Running pods with restartCount > 10

   Categorise each pod:
     Pending      — scheduling or image pull issue
     CrashLoopBackOff — container keeps crashing
     OOMKilled    — memory limit exceeded
     ImagePullBackOff / ErrImagePull — bad image or registry auth
     Error        — container exited non-zero
     Evicted      — node resource pressure
     Terminating  — stuck finalizer or force-delete needed
     Other        — any other non-Running phase

3. For each unhealthy pod (up to 20, prioritise production namespaces)

   3a. Get pod details
       kubectl describe pod {pod} -n {ns}
       Extract: node assignment, conditions, events (last 10), resource requests/limits

   3b. Get container status
       kubectl get pod {pod} -n {ns} -o jsonpath=
         '{.status.containerStatuses[*].{name,ready,restartCount,lastState}}'
       Note last termination reason and exit code

   3c. Get logs (if include-logs)
       For each container in pod:
         kubectl logs {pod} -n {ns} -c {container} --tail=50 2>/dev/null
       If pod has previous crashed container:
         kubectl logs {pod} -n {ns} -c {container} --previous --tail=30 2>/dev/null

   3d. Check node health
       kubectl describe node {node} | grep -A5 "Conditions:"
       Flag: MemoryPressure, DiskPressure, PIDPressure = True

4. Hypothesise root cause per pod
   Map observed signals to cause category:

   OOM exit code 137 + reason OOMKilled
     → memory limit too low or memory leak

   CrashLoopBackOff + log contains "connection refused" / "dial tcp"
     → dependency not ready or wrong host/port in config

   CrashLoopBackOff + exit code 1 + application error in logs
     → application startup failure — check config/env vars

   Pending + no node assigned + events "Insufficient cpu/memory"
     → node capacity exhausted — check quotas and node resources

   ImagePullBackOff + event "unauthorized" / "not found"
     → registry auth missing or image tag does not exist

   Evicted + reason "DiskPressure"
     → node disk full — check PV usage and log volume

   Terminating > 5 min
     → stuck finalizer or volume detach — may need force delete

5. Report
   Prioritised list:
     CRITICAL — production namespace + service-affecting
     HIGH     — production namespace + partial impact
     MEDIUM   — non-production or minor impact
     LOW      — completed/evicted with no current impact

   For each pod: status, hypothesis, supporting evidence (log excerpt or event),
     recommended kubectl commands to remediate
```

---

## Output

Delivered inline. Format:

```
## Workload Triage — {DATE}

Healthy pods:    {n}
Unhealthy pods:  {n}
  CrashLoopBackOff: {n}
  Pending:          {n}
  OOMKilled:        {n}
  Other:            {n}

### Issues

#### CRITICAL — {namespace}/{pod}
Status: CrashLoopBackOff (restarts: {n})
Hypothesis: Application startup failure — missing DATABASE_URL env var
Evidence:
  > panic: required env var DATABASE_URL not set (last log line)
Remediation:
  kubectl describe pod {pod} -n {ns}  ← verify env vars
  kubectl edit deployment {deploy} -n {ns}  ← add missing env

---
#### MEDIUM — {namespace}/{pod}
...
```

---

## Error Handling

| Condition | Action |
|---|---|
| kubectl not found | Stop. Notify: "kubectl is required." |
| Cluster unreachable | Stop. Notify with endpoint. |
| All pods healthy | Report: "No unhealthy pods found in {scope}. All workloads appear healthy." |
| Log collection fails for a pod | Note `(logs unavailable — {reason})`, continue with other pods. |
| More than 20 unhealthy pods | Triage first 20, prioritise production namespaces. Note count truncated. |
