---
name: dependency-audit
description: >
  Audits project dependencies for known vulnerabilities, outdated packages,
  and license compliance issues. Uses native tooling (go vuln, npm audit,
  pip-audit, cargo audit) and reports findings by severity.
  Use when: security review, dependency update cycle, SOC Type 2 review,
  or before a major release.
license: MIT
compatibility: opencode
metadata:
  owner: backend-developer
  type: read-only
  approval: "No"
---

# dependency-audit

**Owner**: `backend-developer`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Detects the project language and package manager, runs the appropriate
vulnerability scanner, and produces a prioritised list of dependency issues
(CVEs, outdated packages, license concerns). Read-only — does not modify
`go.mod`, `package.json`, or any dependency manifest.

---

## When to Use Me

- User asks: "dependency audit", "any CVEs?", "security review", "check dependencies"
- Before a major release or SOC Type 2 audit
- After a security disclosure that may affect the stack
- Periodic dependency hygiene check

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/backend-developer/MEMORY.md
    Fields needed:
      language    (go | node | python | rust | unknown)
      framework   (optional — for context in report)

Estimated token cost: ~400 tokens
Unloaded after: report delivered
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| target-path | user | No — project root if omitted |
| check-licenses | user | No — default false (license scan is optional) |
| severity-filter | user | No — default: show all (critical, high, medium, low) |

---

## Steps

```
1. Detect language and package manager
   IF MEMORY.md has language → use it
   ELSE detect from filesystem:
     go.mod                      → Go
     package.json + package-lock.json → Node/npm
     package.json + yarn.lock    → Node/yarn
     package.json + pnpm-lock.yaml → Node/pnpm
     requirements.txt / pyproject.toml → Python
     Cargo.toml + Cargo.lock     → Rust
   IF multiple detected → audit all
   IF none detected → ask user

2. Run vulnerability scanner

   Go:
     govulncheck ./... 2>&1
     IF govulncheck not installed:
       go list -json -m all 2>/dev/null | note "govulncheck not installed"
       Suggest: go install golang.org/x/vuln/cmd/govulncheck@latest

   Node (npm):
     npm audit --json 2>/dev/null
     Fallback: npm audit 2>&1

   Node (yarn):
     yarn audit --json 2>/dev/null

   Node (pnpm):
     pnpm audit --json 2>/dev/null

   Python:
     pip-audit --format=json 2>/dev/null
     IF pip-audit not installed:
       safety check 2>/dev/null
       IF safety not installed: note "pip-audit not installed"
       Suggest: pip install pip-audit

   Rust:
     cargo audit --json 2>/dev/null
     IF cargo-audit not installed:
       note "cargo-audit not installed"
       Suggest: cargo install cargo-audit

3. Parse vulnerability findings
   For each finding extract:
     - Package name + version
     - CVE ID (if available)
     - Severity: critical / high / medium / low / informational
     - Description (truncated to 200 chars)
     - Fixed version (if available)
     - Direct vs transitive dependency

   Apply severity-filter if set

4. Check for outdated packages (optional, best-effort)

   Go:    go list -m -u all 2>/dev/null | grep '\[' (outdated marker)
   Node:  npm outdated --json 2>/dev/null
   Python: pip list --outdated --format=json 2>/dev/null
   Rust:  cargo outdated 2>/dev/null (if installed)

   Flag: major version updates (breaking changes)
   Note: minor/patch updates (informational)

5. License check (if check-licenses = true)

   Node:  npx license-checker --json 2>/dev/null
   Python: pip-licenses --format=json 2>/dev/null
   Go:    go-licenses check ./... 2>/dev/null

   Flag licenses that are typically incompatible with commercial use:
     GPL-2.0, GPL-3.0, AGPL-3.0, LGPL (transitive only — flag for review)
   Note permissive licenses: MIT, Apache-2.0, BSD-*, ISC

6. Compile results
   CRITICAL — CVEs with CVSS ≥ 9.0 or public exploits
   HIGH     — CVSS 7.0–8.9
   MEDIUM   — CVSS 4.0–6.9
   LOW      — CVSS < 4.0
   INFO     — outdated packages, license notes

7. Report inline
```

---

## Output

Delivered inline. Format:

```
## Dependency Audit — {DATE}

Language:    {language}
Scanner:     {govulncheck | npm audit | pip-audit | cargo audit}
Packages:    {n} direct, {n} transitive

### Vulnerability Summary

  Critical: {n}
  High:     {n}
  Medium:   {n}
  Low:      {n}

### Critical & High Vulnerabilities

| Severity | Package | Version | CVE | Fixed In | Direct? |
|---|---|---|---|---|---|
| CRITICAL | {pkg} | {ver} | CVE-XXXX | {ver} | Yes |
| HIGH     | {pkg} | {ver} | CVE-XXXX | {ver} | No (via {parent}) |

**{pkg} @ {ver} — {CVE}**
{description}
Fix: upgrade to {fixed-version}
  go get {pkg}@{fixed-version}
  — or —
  npm install {pkg}@{fixed-version}

### Outdated Packages (major versions)

| Package | Current | Latest | Breaking |
|---|---|---|---|
| {pkg} | {ver} | {ver} | Yes — review changelog |

### License Notes (if requested)

| Package | License | Risk |
|---|---|---|
| {pkg} | GPL-3.0 | Review required for commercial use |

### Recommendations

1. Immediate: upgrade {n} critical/high packages (CVEs with known exploits)
2. Planned: review {n} major version upgrades
3. {License note if applicable}
```

---

## Error Handling

| Condition | Action |
|---|---|
| Language not detected | Ask user. |
| Scanner not installed | Note which tool is missing, provide install command, continue with what is available. |
| Network not available (npm audit needs it) | Note: "npm audit requires network access. Run from an environment with internet." |
| No vulnerabilities found | Report: "No known vulnerabilities found. {n} packages scanned." |
| Scanner exits non-zero with findings | This is expected — parse output normally. |
| JSON parse fails | Fall back to text output, note parsing limitation. |
