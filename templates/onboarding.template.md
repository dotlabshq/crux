# Onboarding: {{AGENT_NAME}}

> This file defines the onboarding sequence for the `{{ROLE_ID}}` agent.
> Onboarding runs automatically when the agent starts and
> MANIFEST.md shows `status: pending-onboard`.
> On completion, status is updated to `onboarded`.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/MANIFEST.md` exists
- [ ] `agents/{{ROLE_ID}}/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Greet the user and explain what this agent does.

```
You are setting up the {{AGENT_NAME}} agent.

This agent is responsible for: {{AGENT_DESCRIPTION}}

I will now ask you a few questions to configure this agent correctly.
You can skip any question by typing "skip" — I will use defaults or
revisit it later.
```

---

## Step 2 — Environment Discovery

<!-- Automated checks the agent runs before asking the user anything -->
<!-- Remove checks that do not apply to this agent -->

```
Run the following checks silently:
  {{DISCOVERY_CHECK_1}}
  {{DISCOVERY_CHECK_2}}
  {{DISCOVERY_CHECK_3}}

For each check:
  IF successful   → record result in workspace/current/scratch.md
  IF failed       → note as "missing" — surface in Step 3
```

<!--
Discovery check examples for kubernetes-admin:
  Check default kubeconfig: kubectl cluster-info --request-timeout=5s
  Check available namespaces: kubectl get namespaces
  Check node count: kubectl get nodes

Discovery check examples for backend-developer:
  Scan directory structure: list top-level folders
  Detect language: look for package.json, go.mod, Cargo.toml, pyproject.toml
  Detect framework: check dependencies in manifest files
-->

---

## Step 3 — User Questions

Ask only what could not be discovered automatically in Step 2.
Ask questions one at a time — do not present a form.

```
Question order:

1. {{QUESTION_1}}
   default: {{QUESTION_1_DEFAULT}}
   stores-to: {{QUESTION_1_STORE}}

2. {{QUESTION_2}}
   default: {{QUESTION_2_DEFAULT}}
   stores-to: {{QUESTION_2_STORE}}

3. {{QUESTION_3}}
   default: {{QUESTION_3_DEFAULT}}
   stores-to: {{QUESTION_3_STORE}}
```

<!--
Question examples for kubernetes-admin:

1. "I found a cluster at {{discovered-endpoint}}. Should I use this cluster,
   or would you like to connect to a different one?"
   default: use discovered cluster
   stores-to: docs/kubernetes.md → Cluster.endpoint

2. "What CNI is this cluster using?"
   default: ask agent to detect from running pods
   stores-to: docs/kubernetes.md → Networking.cni

3. "Are there any namespaces I should treat as production (require approval
   before any changes)?"
   default: none
   stores-to: agents/kubernetes-admin/MEMORY.md → production-namespaces

Question examples for backend-developer:

1. "I detected a {{detected-language}} project using {{detected-framework}}.
   Is this correct?"
   default: yes
   stores-to: docs/backend.md → Stack

2. "What is the main entry point of this application?"
   default: detect from package.json/main or equivalent
   stores-to: docs/backend.md → Entry

3. "Are there any directories I should not modify?"
   default: none
   stores-to: agents/backend-developer/MEMORY.md → readonly-paths
-->

---

## Step 4 — Generate Docs

Run the appropriate skills to produce the required docs/ files.

```
For each missing doc:
  IF skill exists for this doc → run skill
  IF no skill exists           → generate from Q&A answers collected above

Required docs for this agent:
  {{REQUIRED_DOC_1}}    → skill: {{SKILL_FOR_DOC_1}}
  {{REQUIRED_DOC_2}}    → skill: {{SKILL_FOR_DOC_2}}
```

---

## Step 5 — Review & Confirm

Present a summary of what was discovered and configured.

```
Onboarding summary for {{AGENT_NAME}}:

  [list key facts collected in Steps 2–4]

Does this look correct?
  → Yes: finalise onboarding
  → No:  return to the relevant step
```

---

## Step 6 — Finalise

```
1. Write all collected facts to agents/{{ROLE_ID}}/MEMORY.md
2. Update MANIFEST.md:
     agents.{{ROLE_ID}}.status    → onboarded
     agents.{{ROLE_ID}}.docs      → ✓
     agents.{{ROLE_ID}}.last-session → {{DATE}}
3. Write event to bus/broadcast.jsonl:
     type: agent.onboarded
     from: {{ROLE_ID}}
4. Notify user:
   "{{AGENT_NAME}} is ready. You can now use @{{ROLE_ID}} to assign tasks."
```

---

## Re-Onboarding

Onboarding can be re-run at any time:
- User requests it explicitly
- A required docs/ file is deleted
- MANIFEST.md status is manually reset to `pending-onboard`

Re-onboarding does not overwrite existing MEMORY.md entries —
it appends or updates only the fields it collects.