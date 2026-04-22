---
name: web-recon
description: >
  Web application reconnaissance: technology fingerprinting, directory and file
  enumeration, JavaScript analysis, form and input discovery, authentication
  surface mapping, and HTTP header security review.
  Read-only discovery — no exploitation.
  Use when: starting web application testing, mapping attack surface before exploitation,
  or user requests "web recon" / "enumerate web app".
license: MIT
compatibility: opencode
metadata:
  owner: web-pentester
  type: read-only
  approval: "No — but active scanning requires scope confirmation"
---

# web-recon

**Owner**: `web-pentester`
**Type**: `read-only` (active scanning — scope gate required)
**Approval**: `No` (scanner invocation asks per AGENT.md permission model)
**Workflow**: `.crux/workflows/pentest-engagement.md` — Step 2 (web)

---

## What I Do

Maps the web application attack surface: pages, endpoints, technologies,
authentication forms, input parameters, and HTTP security headers.
Produces `engagements/{id}/recon/web.md` for use in the exploitation phase.

---

## Scope Gate (runs before any active step)

```
1. Load engagements/{id}/scope.md
2. Verify target URL is in scope
3. Load authorization.md — verify expiry >= TODAY
4. IF either fails → STOP, notify red-team-lead
5. Log: target, timestamp, engagement-id → evidence/web/scope-checks.log
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| engagement-id | MEMORY.md | Yes |
| target-url | scope.md or user | Yes |
| auth-credentials | user | No — authenticated scan if provided |
| scan-profile | MEMORY.md → default-scan-profile | No — default: standard |

---

## Steps

```
PASSIVE (no target contact)

  1. Run scope gate (see above)

  2. Technology fingerprinting (passive)
     IF whatweb available:
       whatweb {target-url} --log-brief=/tmp/ww.txt 2>/dev/null
     ELSE:
       curl -s -I {target-url}  (headers only)
     Extract: server, framework, CMS, language, CDN, WAF indicators

ACTIVE (target contacted — scope gate must pass)

  3. HTTP header security review
     curl -s -I -L {target-url}
     Check presence and values of:
       Strict-Transport-Security
       Content-Security-Policy
       X-Content-Type-Options
       X-Frame-Options
       Referrer-Policy
       Permissions-Policy
       Set-Cookie (Secure, HttpOnly, SameSite flags)
     FINDING candidates:
       Missing HSTS → Low
       Missing CSP → Low-Medium
       Missing X-Frame-Options → Low (clickjacking)
       Cookie missing Secure/HttpOnly → Medium

  4. Robots.txt and sitemap
     curl -s {target-url}/robots.txt
     curl -s {target-url}/sitemap.xml
     Extract: disallowed paths (often sensitive), sitemap URLs

  5. Directory enumeration
     IF ffuf available:
       ffuf -u {target-url}/FUZZ \
            -w /usr/share/wordlists/dirb/common.txt \
            -mc 200,201,301,302,401,403 \
            -t 20 -rate 50 \
            -o /tmp/ffuf-{id}.json 2>/dev/null
     ELSE IF gobuster available:
       gobuster dir -u {target-url} \
                    -w /usr/share/wordlists/dirb/common.txt \
                    -t 10 --delay 200ms \
                    -o /tmp/gobuster-{id}.txt 2>/dev/null
     Rate: respect scan-profile (standard = 50 req/s)

  6. Common sensitive paths (manual curl)
     Check these paths regardless of directory scan:
       /.git/              (git repo exposed)
       /.env               (environment file)
       /backup.zip         (backup files)
       /admin              (admin panel)
       /phpinfo.php        (PHP info)
       /wp-admin           (WordPress admin)
       /api                (API endpoint root)
       /swagger.json       (API docs)
       /openapi.json
       /api-docs
       /.well-known/security.txt
     FINDING candidates:
       /.git/ accessible → Critical (source code disclosure)
       /.env accessible  → Critical (credentials exposure)

  7. JavaScript file analysis
     curl -s {target-url} | grep -Eo 'src="[^"]*\.js[^"]*"' | head -20
     For each JS file (up to 5):
       curl -s {js-url} | grep -Eo '(api|endpoint|url|secret|key|token)[^;]{0,100}'
     Look for: API endpoints, secret keys, auth tokens, internal domains

  8. Form discovery
     curl -s {target-url}
     Parse HTML for <form> elements: action, method, input names, type
     Identify:
       Login forms
       Search inputs
       File upload inputs
       Hidden fields
     Mark as: authentication surface, injection candidates, upload surface

  9. Authentication surface
     Note all login, registration, password reset, OAuth, and SSO endpoints
     Record: auth mechanism, token type visible in URLs/headers

10. Write recon output
    engagements/{id}/recon/web.md (see Output section)

11. Notify
    "Web recon complete for {target-url}.
     Endpoints: {n} | Forms: {n} | Interesting paths: {list}
     Report: engagements/{id}/recon/web.md
     Potential findings noted: {list or none}"
```

---

## Output

**Writes to**: `engagements/{id}/recon/web.md`

```markdown
# Web Recon — {target-url}

> Engagement: {engagement-id} | Date: {DATE}
> Scope: confirmed | Auth: {expiry}

## Technology Stack

| Component | Detected | Confidence |
|---|---|---|
| Web server | {nginx/apache/caddy} | {high/medium} |
| Framework | {laravel/django/rails} | {high/medium} |
| CMS | {wordpress/drupal/—} | {high/medium} |
| CDN/WAF | {cloudflare/akamai/—} | {medium} |
| Language | {php/python/ruby/go} | {medium} |

## HTTP Security Headers

| Header | Present | Value | Finding |
|---|---|---|---|
| HSTS | {yes/no} | {value} | {OK / Missing — Low} |
| CSP | {yes/no} | {value} | {OK / Missing — Medium} |
| X-Frame-Options | {yes/no} | {value} | {OK / Missing} |

## Interesting Paths

| Path | Status | Notes |
|---|---|---|
| /admin | 302 → /login | Admin panel exists |
| /.git/ | 403 | Exists but forbidden — partial disclosure possible |
| /swagger.json | 200 | API docs exposed — pass to api-pentester |

## Directory Enumeration Results

{top 20 interesting paths from ffuf/gobuster}

## Forms and Input Points

| Endpoint | Method | Inputs | Type |
|---|---|---|---|
| /login | POST | username, password | Authentication |
| /search | GET | q | Injection candidate |
| /upload | POST | file | File upload |

## JavaScript Findings

| File | Finding | Detail |
|---|---|---|
| /static/app.js | API endpoint | /api/v1/users discovered |
| /static/app.js | Potential secret | "apiKey": "..." |

## Authentication Surface

{list of auth endpoints and mechanisms}

## Preliminary Findings

| Severity | Issue | Path |
|---|---|---|
| Medium | Missing CSP header | All pages |
| Low | X-Frame-Options missing | All pages |

---
*Next step: web-exploit skill for confirmed injection candidates*
```

---

## Error Handling

| Condition | Action |
|---|---|
| Target unreachable | Stop. Notify: "Target {url} is not reachable. Check scope and network access." |
| 403 on all paths | Note WAF or IP block. Suggest: try with different IP or VPN per engagement rules. |
| ffuf/gobuster not found | Run manual curl checks on sensitive paths only. Note limitation. |
| WAF detected | Note WAF type in recon. Reduce scan rate. Flag for web-exploit: bypass needed. |
