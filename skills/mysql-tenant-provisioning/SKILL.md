---
name: mysql-tenant-provisioning
description: >
  Provisions tenant-level MySQL resources such as database, user, and grants in
  a controlled way. Use when: coordinator routes a MySQL tenant provisioning
  step, or the user explicitly asks for database-per-tenant or account-per-tenant
  setup on MySQL or MariaDB.
license: MIT
compatibility: opencode
metadata:
  owner: mysql-admin
  type: read-write
  approval: Yes
---

# mysql-tenant-provisioning

**Owner**: `mysql-admin`
**Type**: `read-write`
**Approval**: `Yes`

---

## What I Do

Plans and, after approval, applies tenant-level MySQL provisioning steps such as database creation,
user creation, and scoped grants.

---

## When to Use Me

- Tenant onboarding requires a MySQL step
- User asks for database/user provisioning on MySQL

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/mysql-admin/AGENT.md
  .crux/workspace/mysql-admin/MEMORY.md
  .crux/decisions/tenant-naming-conventions.md   (if available)

Estimated token cost: ~700 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `tenant-id` | coordinator / user | Yes |
| `environment` | coordinator / user | Yes |
| `provisioning-model` | MEMORY.md / user | No |

---

## Steps

```
1. Resolve naming pattern and provisioning model
2. Produce exact SQL plan for database, user, and grants
3. Present approval gate with affected resources
4. Apply only after explicit approval
5. Update mysql tenant docs if applicable
6. Skill complete — unload
```

---

## Output

**Writes to**: `.crux/docs/mysql-tenants.md` when applicable
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Tenant naming unclear | stop and clarify naming convention |
| Privilege scope too broad | present narrower alternative |
| Unexpected failure | Stop. Write error to bus. Notify user. |
