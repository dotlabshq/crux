# Onboarding: Linux Admin

> This file defines the onboarding sequence for the `linux-admin` agent.
> Onboarding configures SSH, host grouping, and Ansible operating defaults for safe Linux administration.

---

## Prerequisites

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/linux-admin/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Explain that this agent will:
- inspect Linux hosts and services
- use SSH for scoped remote operations
- review and run Ansible safely
- assess access hygiene and baseline hardening
- prefer inspection, validation, and verification before change

---

## Step 2 — Environment Discovery

Silently check:
- whether `ssh -V` works locally
- whether `ansible --version` works locally
- whether `ansible-playbook --version` works locally
- whether `.crux/docs/linux-operations-principles.md` exists
- whether `.crux/docs/ssh-safety-checklist.md` exists
- whether `.crux/docs/ansible-execution-guidelines.md` exists
- whether `.crux/docs/linux-hardening-baseline.md` exists

---

## Step 3 — User Questions

Ask one question at a time:
1. Which host groups should be treated as production-sensitive by default?
2. Should SSH operations default to inspect-only until explicit approval, or allow scoped fixes after approval?
3. Where is the primary Ansible inventory, if one exists?
4. Should Ansible executions default to `--check` first on every run?

Store answers in `.crux/workspace/linux-admin/MEMORY.md`.

---

## Step 4 — Generate Docs

If missing, generate:
- `.crux/docs/linux-operations-principles.md`
- `.crux/docs/ssh-safety-checklist.md`
- `.crux/docs/ansible-execution-guidelines.md`
- `.crux/docs/linux-hardening-baseline.md`

Use the agent-local source templates under `.crux/agents/linux-admin/assets/` before writing any generated `.crux/docs/*` file.

---

## Step 5 — Review & Confirm

Summarise:
- SSH availability
- Ansible availability
- production-sensitive groups
- default SSH mutation posture
- default Ansible check-mode posture

---

## Step 6 — Finalise

1. Write collected facts to `.crux/workspace/linux-admin/MEMORY.md`
2. Update agent status to `onboarded`
3. Broadcast `agent.onboarded`
4. Notify user that `@linux-admin` is ready
