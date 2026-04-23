---
name: {{WORKFLOW_NAME}}
description: >
  {{WORKFLOW_DESCRIPTION}}
  Multi-step workflow orchestrated by the coordinator across multiple agents.
trigger: {{what causes this workflow to run}}
version: 1.0.0
---

# {{WORKFLOW_NAME}}

> Workflows are orchestrated by the coordinator.
> Each step is delegated to the owning agent via @mention.
> Steps may be sequential (default) or parallel (marked explicitly).
> Any step can be marked optional — workflow continues if skipped.

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `{{INPUT_1}}` | user | {{Yes / No}} |
| `{{INPUT_2}}` | user | {{Yes / No}} |

Inputs are collected by the coordinator before any steps run.
Pass all inputs to each step that needs them.

---

## Composition Roles

Optional workflow-scoped roles used when domain agents alone are not enough.

| Role | Required | When |
|---|---|---|
| `security-agent` | {{Yes / No}} | {{pre-flight policy, isolation, least-privilege, approvals}} |
| `planner` | {{Yes / No}} | {{complex sequencing, branching, rollback-sensitive work}} |
| `reviewer` | {{Yes / No}} | {{completeness and consistency check after execution}} |
| `auditor` | {{Yes / No}} | {{policy, standards, compliance, evidence check after execution}} |

Rules:
- `security-agent` is a durable domain agent, not a temporary helper
- `planner`, `reviewer`, and `auditor` are temporary workflow roles by default
- omit any role that the workflow does not need

---

## Steps

```
Step 1 — {{STEP_NAME}}
  agent:    @{{ROLE_ID}}
  skill:    {{SKILL_NAME}}
  inputs:   {{which inputs to pass}}
  required: {{yes | no}}
  on-fail:  {{stop | warn-and-continue | skip}}
  stores-to: {{where output goes}}

Step 2 — {{STEP_NAME}}
  agent:    @{{ROLE_ID}}
  skill:    {{SKILL_NAME}}
  inputs:   {{which inputs + output from Step 1 if needed}}
  required: {{yes | no}}
  depends:  Step 1   ← remove if parallel
  on-fail:  {{stop | warn-and-continue | skip}}

[PARALLEL] Step 3 and Step 4 run simultaneously when Step 2 completes:

  Step 3 — {{STEP_NAME}}
    agent:  @{{ROLE_ID}}
    skill:  {{SKILL_NAME}}
    inputs: {{...}}

  Step 4 — {{STEP_NAME}}
    agent:  @{{ROLE_ID}}
    skill:  {{SKILL_NAME}}
    inputs: {{...}}

Step 5 — Finalise
  Run by coordinator (no agent delegation needed).
  Update MANIFEST.md.
  Write bus event: { "type": "workflow.completed", "workflow": "{{WORKFLOW_NAME}}", ... }
  Notify user: summary of all steps.
```

---

## State

The coordinator tracks step state in
`.crux/workspace/sessions/{id}/scratch.md` during the run.

```
workflow: {{WORKFLOW_NAME}}
started:  {ISO-8601}
inputs:   { ... }
steps:
  step-1: pending | running | completed | failed | skipped
  step-2: pending | running | completed | failed | skipped
  ...
composition:
  security-agent: pending | completed | skipped
  planner:        pending | completed | skipped
  reviewer:       pending | completed | skipped
  auditor:        pending | completed | skipped
```

---

## Rollback

```
IF a required step fails:
  1. Notify user: "Step {n} ({name}) failed: {reason}"
  2. List what completed successfully.
  3. Ask: "Roll back completed steps? (yes / no / manual)"
     yes    → run rollback for each completed step in reverse order
     no     → leave as-is, note in NOTES.md for affected agents
     manual → provide instructions for manual cleanup

Rollback actions per step:
  Step 1 → {{rollback action or "no rollback needed"}}
  Step 2 → {{rollback action or "no rollback needed"}}
```

---

## Re-Running

A workflow can be re-run at any time.
Completed steps may be skipped if their output already exists.
Pass `--force` to re-run all steps regardless.

---

<!--
HOW TO USE THIS TEMPLATE

1. Copy to .crux/workflows/{workflow-name}.md
2. Fill frontmatter: name, description, trigger
3. Define inputs — collect these before any steps run
4. Define steps in order — mark parallel steps explicitly
5. Each step references one agent + one skill
6. Decide which composition roles are actually needed; do not add them by default
7. Define rollback behaviour for any destructive steps
8. Add a row to MANIFEST.md → Workflows table (add section if missing)

NAMING CONVENTION
  workflow file:  .crux/workflows/{workflow-name}.md
  workflow name:  kebab-case, descriptive
  e.g. tenant-onboarding, secret-rotation, incident-response

COORDINATOR BEHAVIOUR
  Coordinator loads the workflow file on trigger.
  Collects inputs. Runs steps in order (or parallel where marked).
  Each step is an @mention routed per COORDINATOR.md Section IV.
  Coordinator does not run skills directly — always delegates to agents.
-->
