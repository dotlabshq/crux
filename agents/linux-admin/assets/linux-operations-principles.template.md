# Linux Operations Principles

This template is the source material for `.crux/docs/linux-operations-principles.md`.
Use it when `linux-admin` needs a baseline host operations model.

---

## Core Position

Host operations should be evidence-based, reversible where possible, and explicit about scope.

Default posture:
- inspect before change
- prefer the smallest viable intervention
- verify after every meaningful change
- keep host and fleet actions distinct

---

## Change Discipline

For any host change:
1. identify target host or host group
2. inspect current state
3. state the intended change
4. assess likely service impact
5. apply only after approval when required
6. verify resulting state

---

## Safety Heuristics

- one host before many hosts
- one service before many services
- check-mode before live Ansible apply when feasible
- avoid changing SSH, sudo, or firewall posture without clear rollback awareness
- production-sensitive groups should be treated conservatively by default

---

## Operational Outputs

Preferred outputs:
- host audit summary
- service triage note
- package action plan
- access review findings
- Ansible execution note
