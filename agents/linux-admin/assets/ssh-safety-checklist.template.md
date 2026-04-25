# SSH Safety Checklist

This template is the source material for `.crux/docs/ssh-safety-checklist.md`.
Use it when `linux-admin` performs or plans SSH-based remote work.

---

## Before Running Commands

- confirm target host
- confirm target user
- confirm whether production sensitivity applies
- confirm whether the action is inspect-only or mutating
- confirm whether sudo is required

---

## Safer Defaults

- start with read-only commands
- capture service state before restart or config change
- avoid inline config edits without first reading current content
- avoid access changes without confirming recovery path

---

## High-Risk Areas

- `sshd_config`
- firewall rules
- sudoers
- user deletion
- key removal
- reboot-triggering package changes

For these, state impact and recovery posture before execution.
