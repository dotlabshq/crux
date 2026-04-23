---
name: passive-recon
description: >
  Passive reconnaissance: OSINT, DNS enumeration, certificate transparency,
  WHOIS, Shodan/Censys queries, GitHub/public code leaks, and email harvesting.
  No direct contact with target systems — all sources are public.
  Use when: starting an engagement, gathering intel before active testing,
  or performing OSINT on a domain or organization.
license: MIT
compatibility: opencode
metadata:
  owner: red-team-lead
  type: read-only
  approval: "No — passive only, no target contact"
---

# passive-recon

**Owner**: `red-team-lead`
**Type**: `read-only` (no direct target contact)
**Approval**: `No`
**Workflow**: `.crux/workflows/pentest-engagement.md` — Step 1

---

## What I Do

Collects publicly available information about the target without touching their systems.
Sources: DNS, WHOIS, certificate transparency logs, search engines, GitHub,
public code repositories, email patterns, job postings, and technology profiles.

---

## When to Use Me

- First step after engagement-setup
- Before any active scanning or testing
- Client asks for OSINT scope expansion
- Passive intelligence is needed without risk of detection

---

## Context Requirements

```
Requires:
  engagements/{id}/scope.md   — to know what domains/orgs are in scope

No active testing — does not require authorization date check
(passive recon generates no logs on target systems)

Estimated token cost: ~400 tokens
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| engagement-id | MEMORY.md | Yes |
| target-domains | scope.md | Yes |
| target-org-name | user or scope.md | No — improves search results |

---

## Steps

```
1. Load scope
   Read engagements/{id}/scope.md
   Extract: domains, IP ranges, org name

2. DNS enumeration
   For each domain in scope:

   dig {domain} ANY +short
   dig {domain} MX +short
   dig {domain} TXT +short
   dig {domain} NS +short
   host {domain}

   Subdomain patterns to check (passive — dictionary-based, no brute force):
     www, mail, api, app, dev, staging, test, admin, vpn, remote, portal,
     login, auth, sso, cdn, static, assets, beta, preview, old, legacy

   Zone transfer attempt (passive technique — most fail, but worth trying):
     dig axfr {domain} @{ns-server}
     Expected: REFUSED — note if successful (finding: zone transfer allowed)

3. Certificate transparency
   Query: https://crt.sh/?q={domain}&output=json
   Parse: all certificates issued for domain and subdomains
   Extract: unique subdomain list from certificate SANs
   Note: any interesting subdomains (admin, internal, vpn, uat, staging)

4. WHOIS
   whois {domain}  (or whois {ip} for IP ranges)
   Extract: registrar, registration date, expiry, registrant org/email (if public)
   Note: privacy-protected vs exposed registrant info

5. Search engine dorking
   Construct queries (report as queries to run — do not automate):
     site:{domain}
     site:{domain} filetype:pdf
     site:{domain} inurl:login
     site:{domain} inurl:admin
     site:{domain} "internal use only"
     "{org-name}" "api key" OR "secret" OR "password" site:github.com
     "{org-name}" "internal" site:linkedin.com

   Note: present queries as suggestions — user runs them in browser to avoid
   rate limits and captchas from automated requests.

6. GitHub / public code search
   Search queries to investigate (note as manual steps):
     org:{github-org} if known
     {domain} password
     {domain} api_key
     {domain} secret
     {domain} AKIA (AWS key prefix)
     {domain} "BEGIN RSA PRIVATE KEY"
   IF nuclei available AND gitdork templates exist:
     nuclei -t exposures/ -target https://github.com/search?q={domain} (note limitation)

7. Email pattern discovery
   Common patterns to test:
     firstname.lastname@{domain}
     first.last@{domain}
     f.lastname@{domain}
   Check: mail server accepts these? (MX record presence)
   Note: email harvesting from LinkedIn/Hunter.io is manual — list queries for user

8. Technology fingerprint (passive sources)
   Check without touching target:
     Shodan query: hostname:{domain} OR org:"{org}"  (manual — requires Shodan API key)
     Censys query: parsed.names:{domain}              (manual — note for user)
     BuiltWith or Wappalyzer (browser extension — note as manual step)

9. Compile findings
   Write engagements/{id}/recon/passive.md (see Output format)

10. Notify
    "Passive recon complete for {engagement-id}.
     Subdomains discovered: {n}
     Interesting findings: {list or none}
     Report: {path}/recon/passive.md"
```

---

## Output

**Writes to**: `engagements/{id}/recon/passive.md`

```markdown
# Passive Recon — {client-name}

> Engagement: {engagement-id}
> Date: {DATE}
> Method: passive only — no target contact

## DNS

### Records
| Type | Record | Value |
|---|---|---|
| A | {domain} | {ip} |
| MX | {domain} | {mail-server} |
| TXT | {domain} | {spf, dkim, etc} |
| NS | {domain} | {nameserver} |

### Subdomains Discovered ({n} total)
| Subdomain | Source | Notes |
|---|---|---|
| api.{domain} | crt.sh | Interesting — API endpoint |
| admin.{domain} | crt.sh | HIGH INTEREST |

### Zone Transfer
{REFUSED (normal) | ALLOWED — FINDING: zone transfer permitted on {ns-server}}

## WHOIS
- Registrar: {value}
- Registered: {date}
- Expires: {date}
- Registrant: {org | privacy-protected}

## Certificate Transparency
- Certificates found: {n}
- Unique subdomains: {n}
- Notable: {list}

## Technology Indicators
{From Shodan/Censys/BuiltWith if available}

## GitHub / Code Leaks
| Query | Status | Finding |
|---|---|---|
| {query} | clean | — |
| {query} | POTENTIAL LEAK | {description} |

## Email Patterns
- Likely pattern: {pattern}
- Mail server: {mx-record}

## Recommended Manual Steps
{List of search engine dork queries, Shodan queries, LinkedIn searches}

## Summary
- Attack surface: {n} subdomains, {n} IP ranges
- High-interest targets: {list}
- Potential leaks to investigate: {list | none}

---
*Source: passive only — no systems contacted*
```

---

## Error Handling

| Condition | Action |
|---|---|
| dig not found | Note: DNS queries manual. Use nslookup or online tools. |
| crt.sh unreachable | Note: CT logs unavailable. Try manually at crt.sh in browser. |
| No subdomains found | Report: only base domain discovered. May indicate limited external presence. |
| Zone transfer succeeds | FINDING: document as high severity. Write to vulnerabilities/ immediately. |
