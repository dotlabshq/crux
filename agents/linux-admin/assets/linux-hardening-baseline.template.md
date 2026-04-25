# Linux Hardening Baseline

This template is the source material for `.crux/docs/linux-hardening-baseline.md`.
Use it when `linux-admin` needs a practical host hardening review baseline.

---

## Baseline Review Areas

- SSH daemon posture
- password vs key auth policy
- sudo hygiene
- package update posture
- firewall status
- intrusion-prevention basics where applicable
- logging and audit visibility
- unnecessary exposed services

---

## Practical Framing

The goal is not theoretical perfection.
The goal is a safer practical baseline appropriate to host criticality and operator maturity.

---

## Common Review Questions

- Is root SSH login disabled or justified?
- Are unused users or stale keys still present?
- Are update and patch expectations clear?
- Is the firewall enabled and understandable?
- Are failed services or suspicious listeners already visible?

---

## Review Output Pattern

Summarise:
- current posture
- highest-risk gaps
- easiest fixes
- changes that should wait for explicit approval
