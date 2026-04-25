# Ansible Execution Guidelines

This template is the source material for `.crux/docs/ansible-execution-guidelines.md`.
Use it when `linux-admin` reviews inventory or runs playbooks.

---

## Core Position

Ansible is safe only when targeting, rollout shape, and change intent are explicit.

---

## Pre-Run Checklist

- inventory path is known
- target hosts or groups are explicit
- variables and secrets assumptions are understood
- check-mode is used when feasible
- diff is enabled when useful
- serial or limit is used for risky rollouts

---

## Execution Heuristics

- prefer `--check` before apply
- prefer `--limit` before full inventory scope
- prefer `--tags` when only part of a playbook is intended
- call out handlers or reboots if they may fire
- do not treat a playbook as low risk just because it is "automated"

---

## Output Pattern

Summarise:
- inventory scope
- playbook target
- run mode: check or apply
- main changed areas
- follow-up verification needed
