---
name: engagement-setup
description: >
  Creates a new penetration testing engagement: directory structure, scope.md,
  and authorization.md. Validates scope entries, records client information,
  and sets the active engagement in red-team-lead MEMORY.md.
  This skill MUST run before any other pentest skill.
  Use when: starting a new engagement, "new pentest", "set up engagement for {client}".
license: MIT
compatibility: opencode
metadata:
  owner: red-team-lead
  type: read-write
  approval: "Yes — scope review required"
---

# engagement-setup

**Owner**: `red-team-lead`
**Type**: `read-write`
**Approval**: `Yes — scope and authorization must be confirmed before proceeding`
**Workflow**: `.crux/workflows/pentest-engagement.md` — Step 0

---

## What I Do

Creates the engagement directory structure, collects and validates scope,
records authorization details, and sets the engagement as active in MEMORY.md.
No active testing can run before this skill completes.

---

## When to Use Me

- Starting any new penetration test engagement
- User says: "new engagement", "start pentest", "set up pentest for {client}"
- Re-scoping an existing engagement (adds entries to scope.md)

---

## Inputs

| Input | Source | Required |
|---|---|---|
| client-name | user | Yes |
| engagement-type | user | Yes — web / api / mobile / network / full |
| scope | user | Yes — IP ranges, domains, URLs, or app file paths |
| authorization-reference | user | Yes — reference to written auth (email subject, doc, contract ID) |
| authorization-expiry | user | Yes — YYYY-MM-DD |
| engagement-id | user or auto-generated | No — auto: {client-slug}-{YYYYMMDD} |
| tester-names | user | No — appears in report header |
| engagement-notes | user | No — special rules, exclusions, rate limits |

---

## Steps

```
1. Generate engagement ID
   IF user provides → use it
   ELSE → generate: {client-slug}-{YYYYMMDD}
     client-slug = lowercase, hyphens only, max 20 chars
     e.g. "Acme Corp" → "acme-corp", date "2026-04-22" → "acme-corp-20260422"

2. Collect scope
   Ask user to provide all in-scope targets. Accept as:
     - IP ranges: 192.168.1.0/24
     - Individual IPs: 10.0.0.1
     - Domains: example.com, *.staging.example.com
     - URLs: https://app.example.com
     - APK/IPA paths: /path/to/app.apk
   Validate:
     - IP ranges must be valid CIDR notation
     - Domains must not be broad wildcards (*) without explicit client confirmation
     - URLs must include scheme (https://)
   Ask explicitly: "Are there any explicitly OUT-OF-SCOPE targets I should note?"
   Record out-of-scope list separately.

3. Collect authorization details
   "Provide the written authorization reference:
    - Email subject / date
    - Contract or SOW number
    - Bug bounty program URL
    - Other written confirmation"
   Record: authorization-reference, authorization-date, authorization-expiry

4. Show scope summary — REQUIRE APPROVAL
   "Engagement: {engagement-id}
    Client:     {client-name}
    Type:       {type}
    Testers:    {list | not specified}
    Expiry:     {date}
    Auth ref:   {reference}

    IN SCOPE ({n} targets):
    {formatted list}

    OUT OF SCOPE (explicitly excluded):
    {list | none specified}

    Special rules: {notes | none}

    Confirm this scope is correct and you have written authorization
    to test these targets? (yes / no)"
   STOP — wait for "yes"

5. Create directory structure
   base = MEMORY.md → engagements-dir  (default: engagements/)
   path = {base}/{engagement-id}/

   Create:
     {path}/
     {path}/scope.md
     {path}/authorization.md
     {path}/recon/
     {path}/vulnerabilities/
     {path}/exploits/
     {path}/evidence/
     {path}/evidence/web/
     {path}/evidence/api/
     {path}/evidence/mobile/
     {path}/evidence/network/
     {path}/report/

6. Write {path}/scope.md

   Content:
   ---
   engagement: {engagement-id}
   client: {client-name}
   type: {type}
   status: active
   created: {DATE}
   expiry: {authorization-expiry}
   ---

   # Scope — {client-name}

   > Engagement: {engagement-id}
   > Type: {type}
   > Created: {DATE}
   > Expiry: {authorization-expiry}
   > Status: ACTIVE

   ## In-Scope Targets

   | Target | Type | Notes |
   |---|---|---|
   | {target} | {ip-range | domain | url | apk | ipa} | {notes} |

   ## Out-of-Scope (Explicitly Excluded)

   | Target | Reason |
   |---|---|
   | {target} | {reason | not specified} |

   ## Special Rules

   {notes | None specified.}

   ---
   *Scope authorised by: {auth-reference}*
   *Authorization expires: {date}*

7. Write {path}/authorization.md

   Content:
   ---
   reference: {auth-reference}
   issued-date: {date}
   expiry: {authorization-expiry}
   client: {client-name}
   engagement: {engagement-id}
   ---

   # Authorization — {client-name}

   > This document records the written authorization for penetration testing.
   > Testing must stop immediately if authorization expires or is revoked.

   ## Authorization Details

   - **Reference**: {auth-reference}
   - **Issued**: {issued-date}
   - **Expires**: {authorization-expiry}
   - **Client contact**: {contact | not recorded}
   - **Scope covered**: see scope.md

   ## Authorized Testers

   {tester-names | Not specified — all firm testers authorized}

   ## Restrictions

   {special rules from engagement-notes | None specified beyond scope.md}

   ---
   *Never test targets not listed in scope.md.*
   *Stop immediately if this authorization is revoked or expired.*

8. Update red-team-lead MEMORY.md
   active-engagement-id: {engagement-id}
   client:               {client-name}
   engagement-type:      {type}
   status:               setup

9. Log to bus
   Write to .crux/bus/red-team-lead/to-coordinator.jsonl:
   {
     "type": "engagement.started",
     "from": "red-team-lead",
     "engagement": "{engagement-id}",
     "client": "{client-name}",
     "type": "{engagement-type}",
     "ts": "{ISO-8601}"
   }

10. Notify user
    "Engagement {engagement-id} created.
     Path: {path}
     Scope: {n} targets
     Expires: {date}

     Next step: run passive-recon, or activate a specialist:
       @web-pentester     (web application)
       @api-pentester     (API)
       @mobile-pentester  (mobile app)
       @network-pentester (network range)"
```

---

## Error Handling

| Condition | Action |
|---|---|
| Engagement ID already exists | Ask: "Engagement {id} already exists. Update scope, or create new with different ID?" |
| Scope entry fails validation | Explain rule, ask user to correct before continuing |
| Authorization expiry in the past | Stop: "Authorization expiry {date} is in the past. Obtain updated authorization first." |
| Authorization expiry < 3 days | Warn prominently, allow user to continue with confirmation |
| engagements-dir not set in MEMORY.md | Use default: engagements/. Notify user. |
