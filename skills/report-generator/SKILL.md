---
name: report-generator
description: >
  Generates a complete penetration test report from the finding registry.
  Produces an executive summary, methodology section, detailed findings (sorted by
  severity), and remediation roadmap. Writes draft and final versions.
  Use when: all testing is complete and findings are documented, or client requests
  interim report, or user says "generate report" / "write pentest report".
license: MIT
compatibility: opencode
metadata:
  owner: red-team-lead
  type: read-write
  approval: "No — generates report from existing findings, does not execute tests"
---

# report-generator

**Owner**: `red-team-lead`
**Type**: `read-write`
**Approval**: `No`
**Workflow**: `.crux/workflows/pentest-engagement.md` — Step 7

---

## What I Do

Reads all finding files from `engagements/{id}/vulnerabilities/`, consolidates them,
calculates risk statistics, and writes a complete penetration test report
in Markdown format. Suitable for conversion to PDF/DOCX via pandoc or similar.

---

## When to Use Me

- All testing complete and findings documented
- Interim report requested (documents findings to date)
- User says: "generate report", "write final report", "create pentest report"

---

## Context Requirements

```
Requires:
  engagements/{id}/scope.md              — engagement details
  engagements/{id}/authorization.md      — authorization reference
  engagements/{id}/vulnerabilities/*.md  — all finding files
  engagements/{id}/recon/               — recon data for methodology section
  .crux/workspace/red-team-lead/MEMORY.md — firm name, CVSS version, language

Estimated token cost: ~600 tokens (skill) + all finding files
Load finding files one at a time — do not load all simultaneously.
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| engagement-id | MEMORY.md | Yes |
| report-type | user | No — draft (default) or final |
| include-evidence | user | No — default: yes (references, not inline) |
| executive-summary-words | user | No — default: 300 |

---

## Steps

```
1. Verify engagement
   Load scope.md → client-name, type, expiry, target list
   Load authorization.md → auth reference, testers

2. Load all findings
   List: engagements/{id}/vulnerabilities/*.md
   Load each finding file sequentially. Extract:
     id, title, severity, cvss-score, cvss-vector, category, target,
     status (confirmed only — exclude informational from risk count),
     description (first paragraph), remediation (recommended fix only)
   Sort: Critical → High → Medium → Low → Informational

3. Calculate statistics
   Total findings:    {n}
   By severity:       Critical: {n}, High: {n}, Medium: {n}, Low: {n}, Info: {n}
   Confirmed:         {n}  (status == confirmed)
   Potential:         {n}  (status == potential — noted but not confirmed)
   Overall risk:
     IF any Critical:  CRITICAL
     ELIF any High:    HIGH
     ELIF any Medium:  MEDIUM
     ELSE:             LOW

4. Determine tested areas
   From recon files present:
     recon/passive.md  → passive recon performed
     recon/web.md      → web application tested
     recon/api.md      → API tested
     recon/mobile.md   → mobile app tested
     recon/network.md  → network tested

5. Write report
   Path: engagements/{id}/report/draft.md  (or final.md if report-type == final)
   (see Output section)

6. Update MEMORY.md
   status: reporting (if draft) | closed (if final)

7. Notify
   "Report generated: engagements/{id}/report/{draft|final}.md
    Findings: {n} total — Critical: {n}, High: {n}, Medium: {n}, Low: {n}
    Overall risk: {level}

    To convert to PDF: pandoc {path} -o report.pdf
    To convert to DOCX: pandoc {path} -o report.docx"
```

---

## Output

**Writes to**: `engagements/{id}/report/draft.md` or `final.md`

```markdown
---
title: Penetration Test Report
client: {client-name}
engagement: {engagement-id}
date: {DATE}
version: {1.0-draft | 1.0-final}
classification: CONFIDENTIAL
---

# Penetration Test Report
## {client-name}

**Classification**: CONFIDENTIAL — For authorized recipients only
**Engagement ID**: {engagement-id}
**Test Period**: {start-date} – {end-date}
**Report Date**: {DATE}
**Version**: {version}
**Prepared by**: {firm-name}
**Testers**: {tester-names | {firm-name} security team}
**Certifications**: {list | —}

---

## Table of Contents

1. Executive Summary
2. Scope and Authorization
3. Methodology
4. Findings Summary
5. Detailed Findings
6. Remediation Roadmap
7. Appendix

---

## 1. Executive Summary

{firm-name} was engaged by {client-name} to perform a {type} penetration test
between {dates}. The assessment identified **{n} vulnerabilities** across the tested
scope, including **{n} Critical**, **{n} High**, **{n} Medium**, and **{n} Low**
severity findings.

**Overall Risk Rating: {CRITICAL | HIGH | MEDIUM | LOW}**

{2-3 sentence narrative of the most significant findings and their business impact.}

### Key Findings

| Severity | Count | Most Critical Finding |
|---|---|---|
| 🔴 Critical | {n} | {title of highest CVSS finding} |
| 🟠 High | {n} | {title} |
| 🟡 Medium | {n} | {title} |
| 🟢 Low | {n} | — |

### Immediate Actions Required

{List Critical and High findings with one-line remediation each.
These are the items requiring immediate attention.}

---

## 2. Scope and Authorization

### Authorization

This assessment was conducted with written authorization from {client-name}.

- **Reference**: {auth-reference}
- **Authorization Date**: {auth-date}
- **Expiry**: {auth-expiry}

### Tested Scope

| Target | Type | Result |
|---|---|---|
| {target} | {type} | {tested | partially tested | not reachable} |

### Out-of-Scope

{out-of-scope list | No targets were explicitly excluded.}

---

## 3. Methodology

### Approach

This engagement followed a {black-box | grey-box | white-box} methodology
using the following frameworks:

{IF web or api}: OWASP Web Application Top 10 (2021)
{IF api}:        OWASP API Security Top 10 (2023)
{IF mobile}:     OWASP Mobile Application Security Verification Standard (MASVS)
{IF network}:    MITRE ATT&CK Framework (Enterprise)

### Testing Phases

| Phase | Status | Details |
|---|---|---|
| Passive Reconnaissance | {Complete | Not performed} | {summary} |
| {Web/API/Mobile/Network} Testing | {Complete | Partial} | {summary} |
| Exploitation | {Complete | Partial} | {n} vulnerabilities confirmed |
| Documentation | Complete | {n} findings documented |

---

## 4. Findings Summary

### Risk Distribution

| Severity | Count | % of Total |
|---|---|---|
| Critical (9.0–10.0) | {n} | {pct}% |
| High (7.0–8.9) | {n} | {pct}% |
| Medium (4.0–6.9) | {n} | {pct}% |
| Low (0.1–3.9) | {n} | {pct}% |
| Informational | {n} | — |
| **Total** | **{n}** | |

### Findings Overview

| ID | Severity | CVSS | Title | Target |
|---|---|---|---|---|
{sorted findings table — Critical first}

---

## 5. Detailed Findings

{For each finding, in severity order:}

---

### {finding-id} — {title}

**Severity**: {severity} | **CVSS {version}**: {score}
**Category**: {category}
**Target**: `{target}`

#### Description

{description}

#### Impact

{impact}

#### Evidence

{evidence summary — link to evidence files, do not embed raw evidence in final report}
Evidence: `engagements/{id}/evidence/{path}`

#### Reproduction Steps

{steps}

#### Remediation

{remediation — recommended fix}

**Priority**: {Immediate | Short-term | Long-term}
**References**: {links}

---

## 6. Remediation Roadmap

### Immediate (Critical & High — address within 72 hours)

| Finding | Action | Owner |
|---|---|---|
{Critical and High findings with one-line action}

### Short-term (Medium — address within 30 days)

| Finding | Action | Owner |
|---|---|---|
{Medium findings}

### Long-term (Low — address in next release cycle)

| Finding | Action | Owner |
|---|---|---|
{Low findings}

---

## 7. Appendix

### Tool List

{tools used during this engagement}

### Testing Timeline

{dates and phases}

### Limitations

{What was NOT tested, time constraints, access limitations, WAF interference, etc.}

---

*This report is confidential and intended solely for {client-name} and authorized personnel.*
*{firm-name} accepts no liability for use of this report beyond its intended purpose.*
```

---

## Error Handling

| Condition | Action |
|---|---|
| No findings found | Generate report noting no confirmed vulnerabilities. Include disclaimer that absence of findings does not guarantee security. |
| Finding file missing expected fields | Note "(incomplete)" next to finding. Continue with available data. |
| report/ directory missing | Create it. |
| Engagement status == closed | Warn: "Engagement {id} is already closed. Generate historical report? (yes / no)" |
