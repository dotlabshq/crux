---
name: mailbox-triage
description: >
  Reads configured mailbox messages through Himalaya in read-only mode, then
  summarizes, classifies, extracts action items, and routes email-derived work
  into Crux inbox, notes, memory, or agent handoffs. Use when: scanning a
  mailbox, summarizing recent emails, extracting tasks from email, classifying
  request/info/approval messages, or producing an email-based work plan.
license: MIT
compatibility: opencode
metadata:
  owner: mailbox-operator
  type: read-write
  approval: "No for read-only analysis; Yes before mailbox-changing commands"
---

# mailbox-triage

**Owner**: `mailbox-operator`
**Type**: `read-write`
**Approval**: `No for read-only analysis; Yes before mailbox-changing commands`

---

## What I Do

Use Himalaya as the mailbox connector and convert recent emails into structured
Crux workspace outputs: summaries, action plans, inbox approvals, notes follow-ups,
and carefully sourced memory candidates.

---

## When to Use Me

- User asks to scan or summarize a mailbox
- User wants tasks, requests, or follow-ups extracted from email
- User wants information emails captured into Crux memory or notes
- User wants a digest of recent or unread messages
- Coordinator routes a mailbox review to `mailbox-operator`

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/mailbox-operator/MEMORY.md
    Fields used when present:
      mailbox-default-account
      mailbox-default-folder
      mailbox-default-scan-scope
      mailbox-default-page-size
      mailbox-storage-policy
      mailbox-memory-write-policy
      mailbox-summary-language
      mailbox-last-scan-at

Loads during execution (lazy):
  .crux/docs/mailbox-triage-policy.md      (generate from this skill if missing)
  .crux/workspace/inbox.md                 (when approval/question/handoff is detected)
  .crux/workspace/{role}/NOTES.md          (when a domain follow-up is routed)
  .crux/workspace/{role}/MEMORY.md         (only for high-confidence durable facts)
  .crux/workspace/mailbox-operator/output/ (for scan output and previous digest review)

External requirement:
  Himalaya CLI installed and configured outside Crux.
  Verify with: himalaya --version

Estimated token cost: ~900 tokens
Unloaded after: mailbox digest and dispatch summary are complete
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `account` | user / MEMORY.md / Himalaya default | No |
| `folder` | user / MEMORY.md | No — default: INBOX |
| `scope` | user / MEMORY.md | No — unread-only / since-last-scan / latest-page / date-range |
| `page-size` | user / MEMORY.md | No — default: 20 |
| `date-range` | user | No — required only when scope is date-range |
| `write-policy` | user / MEMORY.md | No — suggest-only / apply-safe-writes |
| `storage-policy` | user / MEMORY.md | No — metadata-only / redacted-summaries-only / full-body-with-approval |

---

## Read-Only Himalaya Boundary

Allowed by default:

```sh
himalaya --version
himalaya account list
himalaya folder list
himalaya envelope list --output json
himalaya message read <id>
```

Allowed with account or folder flags:

```sh
himalaya --account <account> envelope list --folder <folder> --page 1 --page-size <n> --output json
himalaya --account <account> message read <id>
```

Forbidden unless the user explicitly approves a mailbox-changing operation:

```sh
himalaya message reply
himalaya message write
himalaya message forward
himalaya message move
himalaya message copy
himalaya message delete
himalaya flag add
himalaya flag remove
himalaya attachment download
```

Do not run attachment downloads in v1 triage. Record attachment metadata only
when it appears in message content or envelope output.

---

## Steps

```
PRE-FLIGHT

1. Verify Himalaya is installed:
     himalaya --version
   IF missing → stop and tell the user to install/configure Himalaya first.

2. Resolve scan settings:
     account      = input.account or MEMORY.md mailbox-default-account or Himalaya default
     folder       = input.folder or MEMORY.md mailbox-default-folder or INBOX
     page-size    = input.page-size or MEMORY.md mailbox-default-page-size or 20
     scope        = input.scope or MEMORY.md mailbox-default-scan-scope or latest-page
     write-policy = input.write-policy or suggest-only

3. List accounts/folders only if needed for disambiguation:
     himalaya account list
     himalaya folder list

FETCH

4. Fetch envelopes as JSON:
     himalaya --account {account} envelope list --folder {folder} --page 1 --page-size {page-size} --output json

   If the installed Himalaya version does not support one of the flags, retry
   with the nearest read-only equivalent and record the fallback in the scan summary.

5. Select candidate messages:
     latest-page       → process returned envelopes
     since-last-scan   → process messages received after mailbox-last-scan-at
     unread-only       → process only unread messages if unread status is available
     date-range        → process messages matching the requested date window

6. Read selected messages one by one:
     himalaya --account {account} message read {id}

   Keep message IDs tied to account, folder, scan timestamp, subject, sender, and
   received_at because Himalaya IDs may be folder/listing-relative.

CLASSIFY

7. For each message, classify as exactly one primary type:
     request             asks someone to do, answer, decide, fix, deliver, review, schedule, or follow up
     info                communicates reusable information without requiring action
     approval            asks for explicit permission, confirmation, rejection, or sign-off
     decision-candidate  proposes a durable policy, architecture, process, or standard change
     risk                signals incident, security, compliance, legal, delivery, or operational risk
     noise               newsletter, notification, duplicate, low-value automated message, or irrelevant content

8. Add secondary tags when useful:
     backend, frontend, platform, kubernetes, postgresql, compliance, security,
     personal-productivity, team-operations, customer, finance, vendor, urgent,
     waiting, blocked, deadline, attachment-present

9. Extract:
     summary
     sender intent
     requested action
     deadline or date mentioned
     owner candidate
     relevant Crux agent
     confidence: high | medium | low
     sensitive-data-notes
     memory-candidate facts
     follow-up questions

ROUTE

10. Routing rules:
      approval            → .crux/workspace/inbox.md / Pending Approvals
      blocked question    → .crux/workspace/inbox.md / Blocked Questions
      operator handoff    → .crux/workspace/inbox.md / Operator Handoffs
      temporary task      → .crux/workspace/{role}/NOTES.md / Pending Tasks
      reusable fact       → candidate memory unless high confidence and policy allows direct write
      policy decision     → inbox item requesting decision approval; do not write decisions/ directly
      noise               → include only in digest counts unless user asks for details

11. Domain routing hints:
      backend/API/code                  → backend-developer
      UI/component/state-flow           → frontend-developer
      runtime/deploy/CI/observability   → platform-engineer
      Kubernetes/namespace/workload     → kubernetes-admin
      PostgreSQL/schema/query/backup    → postgresql-admin
      compliance/vendor/policy/privacy  → compliance-governance-lead
      personal task/planning            → personal-productivity-coach
      team/process/blocker/ownership    → team-operations-coach
      pentest/security testing          → red-team-lead

WRITE OUTPUTS

12. Write a scan digest:
      .crux/workspace/mailbox-operator/output/digests/YYYY-MM-DD-mailbox-digest.md

13. Write a structured scan record:
      .crux/workspace/mailbox-operator/output/scans/YYYY-MM-DDTHHMMSS-mailbox-scan.json

14. If write-policy == suggest-only:
      show proposed inbox/notes/memory changes but do not apply them.

15. If write-policy == apply-safe-writes:
      apply only safe workspace writes:
        - inbox entries for approvals/questions/handoffs
        - NOTES pending tasks for routed follow-ups
        - MEMORY writes only when confidence is high and memory-write-policy allows direct writes
      Never write raw secrets or full raw mail bodies.

16. Update mailbox-last-scan-at only after a successful scan.

17. Return concise summary to the user:
      processed count
      classification counts
      top requests
      approvals/questions needing user action
      routed agent follow-ups
      memory candidates
      skipped/noise count
```

---

## Output

**Writes to**:
- `.crux/workspace/mailbox-operator/output/digests/YYYY-MM-DD-mailbox-digest.md`
- `.crux/workspace/mailbox-operator/output/scans/YYYY-MM-DDTHHMMSS-mailbox-scan.json`
- `.crux/workspace/inbox.md` when `write-policy == apply-safe-writes`
- `.crux/workspace/{role}/NOTES.md` when routed follow-ups are applied
- `.crux/workspace/{role}/MEMORY.md` only for approved/high-confidence durable facts

**Digest format**:

```markdown
# Mailbox Digest — YYYY-MM-DD

## Summary
- Processed:
- Requests:
- Info:
- Approvals:
- Risks:
- Noise:

## Top Actions
- [ ] ...

## Waiting On User
- ...

## Routed Follow-Ups
- @agent — ...

## Memory Candidates
- key: ...
  value: ...
  source: email from ... received ...
  confidence: ...

## Notes
- Sensitive or ambiguous items:
```

**Scan JSON shape**:

```json
{
  "scan_id": "YYYY-MM-DDTHHMMSS-mailbox",
  "account": "work",
  "folder": "INBOX",
  "scope": "latest-page",
  "processed_at": "ISO-8601",
  "messages": [
    {
      "mailbox_message_ref": {
        "account": "work",
        "folder": "INBOX",
        "himalaya_id": "42",
        "subject": "Subject",
        "from": "sender@example.com",
        "received_at": "ISO-8601"
      },
      "classification": "request",
      "secondary_tags": ["backend", "deadline"],
      "summary": "...",
      "actions": [
        {
          "description": "...",
          "owner_candidate": "backend-developer",
          "deadline": null,
          "confidence": "medium"
        }
      ],
      "routing": [
        {
          "target": ".crux/workspace/backend-developer/NOTES.md",
          "section": "Pending Tasks",
          "status": "proposed"
        }
      ],
      "memory_candidates": []
    }
  ]
}
```

---

## Approval Gate

```
Before any mailbox-changing command:

1. Present the exact Himalaya command
2. Explain how it changes mailbox state
3. Explain rollback limitations
4. Wait for explicit confirmation
5. Log to .crux/bus/mailbox-operator/
```

Mailbox-changing commands are not part of v1 triage. Prefer telling the user what
to do manually in their mail client.

---

## Error Handling

| Condition | Action |
|---|---|
| Himalaya not installed | Stop and tell user to install Himalaya before mailbox triage |
| Himalaya account missing | Stop and ask user to run `himalaya account configure` |
| Authentication fails | Do not inspect secrets; ask user to verify local Himalaya config |
| JSON output unavailable | Fall back to plain envelope output and record reduced fidelity |
| Message read fails | Skip message, record error in scan JSON, continue if remaining messages can be read |
| Email contains apparent secrets | Redact from outputs and mark `sensitive-data-notes` |
| Classification confidence low | Route to inbox as a blocked question or leave as candidate only |
| Unexpected failure | Stop. Write error to bus. Notify user. |
