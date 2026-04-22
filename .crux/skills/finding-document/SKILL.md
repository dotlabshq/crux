---
name: finding-document
description: >
  Documents a single penetration testing finding with full CVSS scoring,
  evidence, reproduction steps, and remediation recommendations.
  Writes a structured finding file to engagements/{id}/vulnerabilities/{vuln-id}.md
  and updates the finding registry in engagements/{id}/report/findings-index.md.
  Use when: a specialist agent reports a confirmed vulnerability, or user wants
  to manually record a finding.
license: MIT
compatibility: opencode
metadata:
  owner: red-team-lead
  type: read-write
  approval: "No"
---

# finding-document

**Owner**: `red-team-lead`
**Type**: `read-write`
**Approval**: `No`
**Workflow**: `.crux/workflows/pentest-engagement.md` — Step 6

---

## What I Do

Takes a vulnerability report from a specialist agent or user input, classifies it,
scores it with CVSS, and writes a structured finding document to the finding registry.

---

## When to Use Me

- Specialist agent confirms a vulnerability and passes it to red-team-lead
- User says: "document this finding", "add finding", "record vulnerability"
- During report generation to ensure all findings are properly formatted

---

## Inputs

| Input | Source | Required |
|---|---|---|
| engagement-id | MEMORY.md | Yes |
| title | user or specialist | Yes |
| category | user or specialist | Yes — OWASP category or CVE |
| target | user or specialist | Yes — URL, IP, endpoint, file |
| severity | user or specialist | No — derived from CVSS if not provided |
| description | user or specialist | Yes |
| evidence | user or specialist | Yes — request/response, screenshot path, tool output |
| reproduction-steps | user or specialist | Yes |
| cvss-vector | user or specialist | No — calculated interactively if not provided |
| remediation | user or specialist | Yes |

---

## Steps

```
1. Verify engagement is active
   Load MEMORY.md → active-engagement-id
   Load engagements/{id}/scope.md → verify engagement is active, not closed

2. Generate finding ID
   Auto: {engagement-id}-{seq:03d}  e.g. acme-corp-20260422-001
   Seq: count existing files in engagements/{id}/vulnerabilities/ + 1

3. Classify finding
   Category options (pick primary):
     OWASP Web:     A01-A10 (2021)
     OWASP API:     API1-API10 (2023)
     OWASP Mobile:  M1-M10 (2024 MASVS)
     Network/Infra: CVE-{id}, CWE-{id}, or custom
     Business Logic: custom description

4. Calculate CVSS score (if vector not provided)
   Ask user for each metric:

   IF cvss-version == 3.1:
     Attack Vector (AV):        N(etwork) / A(djacent) / L(ocal) / P(hysical)
     Attack Complexity (AC):    L(ow) / H(igh)
     Privileges Required (PR):  N(one) / L(ow) / H(igh)
     User Interaction (UI):     N(one) / R(equired)
     Scope (S):                 U(nchanged) / C(hanged)
     Confidentiality (C):       N(one) / L(ow) / H(igh)
     Integrity (I):             N(one) / L(ow) / H(igh)
     Availability (A):          N(one) / L(ow) / H(igh)
     Calculate base score using CVSS 3.1 formula
     Map to severity: 0.0=None, 0.1-3.9=Low, 4.0-6.9=Medium, 7.0-8.9=High, 9.0-10.0=Critical

   IF cvss-version == 4.0:
     Use CVSS 4.0 nomenclature (AV, AC, AT, PR, UI, VC, VI, VA, SC, SI, SA)
     Calculate using CVSS 4.0 formula

5. Write finding file
   Path: engagements/{id}/vulnerabilities/{finding-id}.md
   (see Output section)

6. Update finding index
   Path: engagements/{id}/report/findings-index.md
   IF file does not exist → create with header
   Append row to findings table

7. Notify
   "Finding documented: {finding-id}
    Title: {title}
    Severity: {severity} (CVSS: {score})
    File: engagements/{id}/vulnerabilities/{finding-id}.md"
```

---

## Output

**Writes to**: `engagements/{id}/vulnerabilities/{finding-id}.md`

```markdown
---
id: {finding-id}
title: {title}
severity: Critical | High | Medium | Low | Informational
cvss-score: {score}
cvss-vector: CVSS:3.1/AV:{}/AC:{}/PR:{}/UI:{}/S:{}/C:{}/I:{}/A:{}
category: {OWASP-category or CVE-ID or custom}
target: {url or ip or file}
status: confirmed | potential | informational
discovered: {DATE}
discovered-by: {agent-role}
engagement: {engagement-id}
---

# {finding-id} — {title}

**Severity**: {severity} | **CVSS**: {score} ({vector})
**Category**: {category}
**Target**: `{target}`
**Discovered**: {DATE} by {agent-role}

---

## Description

{Clear explanation of what the vulnerability is, why it exists, and what
an attacker could achieve by exploiting it.}

## Impact

{Specific impact in the context of this application or system.
What data, functionality, or systems are at risk?}

## Evidence

{evidence-type: request/response | screenshot | tool output | code snippet}

\```
{evidence content — raw HTTP request/response, Frida output, nmap output, etc.}
\```

Evidence files: `engagements/{id}/evidence/{subdir}/{filename}`

## Reproduction Steps

1. {Step 1}
2. {Step 2}
3. {Step 3}
   Expected result: {what you see}
   Confirms: {what this proves}

## CVSS Breakdown

| Metric | Value | Rationale |
|---|---|---|
| Attack Vector | {AV} | {reason} |
| Attack Complexity | {AC} | {reason} |
| Privileges Required | {PR} | {reason} |
| User Interaction | {UI} | {reason} |
| Scope | {S} | {reason} |
| Confidentiality | {C} | {reason} |
| Integrity | {I} | {reason} |
| Availability | {A} | {reason} |

**Base Score**: {score} ({severity})

## Remediation

### Recommended Fix
{Specific, actionable remediation for this finding.}

### References
- {OWASP link or CVE link or CWE link}
- {Vendor advisory if applicable}

### Priority
{Immediate — exploit in the wild | Short-term — patch before next release | Long-term — architectural change}
```

**Updates**: `engagements/{id}/report/findings-index.md`

```markdown
# Findings Index — {engagement-id}

| ID | Severity | CVSS | Title | Target | Category | Status |
|---|---|---|---|---|---|---|
| {id} | Critical | {score} | {title} | {target} | {cat} | confirmed |
```

---

## Error Handling

| Condition | Action |
|---|---|
| No active engagement | Stop: "No active engagement. Run engagement-setup first." |
| CVSS vector invalid | Recalculate interactively, ask user to confirm each metric |
| Evidence path does not exist | Warn: "Evidence file not found. Document path for manual verification." |
| Duplicate finding title | Warn: "Similar finding exists: {id}. Create new or update existing?" |
