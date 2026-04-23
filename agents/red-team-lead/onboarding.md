# Onboarding: Red Team Lead

> This file defines the onboarding sequence for the `red-team-lead` agent.
> Onboarding runs once when MANIFEST.md shows `status: pending-onboard`.
> On completion, status is updated to `onboarded`.

---

## Prerequisites

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/red-team-lead/AGENT.md` exists

If any are missing, stop and notify the user.

---

## Step 1 — Introduce

```
You are setting up the Red Team Lead agent.

This agent manages penetration testing engagements end-to-end:
scope definition, authorization tracking, specialist coordination
(@web-pentester, @api-pentester, @mobile-pentester, @network-pentester),
finding consolidation, and client reporting.

I will ask a few questions to configure the workspace for your firm.
Type "skip" to defer any question.
```

---

## Step 2 — Environment Discovery

Run silently. Record in session scratch.

```
TOOL STACK — check which tools are in PATH:
  command -v nmap          → record nmap-available
  command -v nuclei        → record nuclei-available
  command -v ffuf          → record ffuf-available
  command -v nikto         → record nikto-available
  command -v sqlmap        → record sqlmap-available
  command -v httpx         → record httpx-available
  command -v jwt_tool      → record jwt-tool-available
  command -v frida         → record frida-available
  command -v apktool       → record apktool-available
  command -v objection     → record objection-available
  command -v adb           → record adb-available
  command -v burpsuite     → record burp-available
  command -v masscan       → record masscan-available
  command -v whatweb       → record whatweb-available
  command -v gobuster      → record gobuster-available
  command -v arjun         → record arjun-available
  command -v jadx          → record jadx-available
  command -v mitmproxy     → record mitmproxy-available

ENGAGEMENT DIRECTORY:
  ls engagements/ 2>/dev/null
    OK  → record existing-engagements (list)
    ERR → engagements/ does not exist yet (created on first engagement-setup)

EXISTING CONFIG:
  ls .crux/workspace/red-team-lead/MEMORY.md 2>/dev/null
    If exists → check if firm-name already set (re-onboarding guard)
```

---

## Step 3 — User Questions

Ask one at a time.

```
Question 1 — Firm identity
  "What is your firm or team name?
   This will appear in all report headers."
  stores-to: MEMORY.md → firm-name

Question 2 — Certifications
  "Which certifications does your team hold? (optional — used for report credibility section)
   Examples: OSCP, CEH, CREST, GPEN, GWAPT, BSCP
   (press enter to skip)"
  stores-to: MEMORY.md → certifications

Question 3 — Default CVSS version
  "Which CVSS version should I use for scoring findings?
   Options: 3.1 | 4.0
   (default: 3.1)"
  default: 3.1
  stores-to: MEMORY.md → cvss-version

Question 4 — Report language
  "In which language should reports be written?
   Options: en | tr | (other — specify)
   (default: en)"
  default: en
  stores-to: MEMORY.md → report-language

Question 5 — Engagements directory
  "Where should engagement files be stored?
   This directory will hold scope files, findings, evidence, and reports.
   It is gitignored — client data never leaves this machine via git.
   (default: engagements/)"
  default: engagements/
  stores-to: MEMORY.md → engagements-dir

Question 6 — Missing tools
  IF any critical tools not found (nmap, ffuf, nuclei, httpx):
    "The following tools were not found in PATH: {list}
     These are used by specialist agents. Should I note them as unavailable?
     You can install them later and re-run onboarding.
     (yes — note as unavailable / skip)"
  stores-to: MEMORY.md → tools-unavailable: [{list}]
```

---

## Step 4 — Initialise Workspace

```
1. Create engagements/ directory structure:
   mkdir -p {engagements-dir}/.gitkeep
   (directory created; .gitkeep ensures it is tracked even when empty — but
    content is gitignored via .gitignore entry)

2. Ensure .gitignore contains:
   engagements/
   IF not present → add it
   Notify: "Added 'engagements/' to .gitignore — client data stays local."

3. Write docs/pentest-methodology.md (if missing):
   A reference card for OWASP Web Top 10, OWASP API Top 10 (2023),
   OWASP MASVS, and MITRE ATT&CK network techniques.
   Used as lazy-load context by specialist agents.
   (concise — max 800 tokens)

4. Generate `.crux/workflows/pentest-engagement.md` (if missing):
   source: `.crux/agents/red-team-lead/assets/pentest-engagement.workflow.template.md`
   purpose: coordinator orchestration for setup → recon → specialist testing → findings → report
   rule: do not commit the generated workflow file in the framework source repo
```

---

## Step 5 — Summary & Confirm

```
"Onboarding summary for Red Team Lead:

  Firm:              {firm-name}
  Certifications:    {list | none}
  CVSS version:      {version}
  Report language:   {language}
  Engagements dir:   {dir}/
  Tools available:   {n} / {total checked}
  Tools missing:     {list | none}

  engagements/ added to .gitignore: {yes | already present}

Does this look correct?
  → yes: finalise
  → no: tell me what to fix"
```

---

## Step 6 — Finalise

```
1. Write .crux/workspace/red-team-lead/MEMORY.md:
   firm-name:          {value}
   certifications:     [{list}]
   cvss-version:       {3.1 | 4.0}
   report-language:    {en | tr | other}
   engagements-dir:    {value}
   tools-available:    [{list}]
   tools-unavailable:  [{list}]
   active-engagement-id: —
   onboarded-date:     {DATE}

2. Update .crux/workspace/MANIFEST.md:
   agents.red-team-lead.status       → onboarded
   agents.red-team-lead.last-session → {DATE}

3. Write .crux/bus/broadcast.jsonl:
   { "type": "agent.onboarded", "from": "red-team-lead", "ts": "..." }

4. Notify:
   "Red Team Lead is ready.
    Start a new engagement: @red-team-lead new engagement
    Or use the pentest workflow: coordinator → pentest-engagement workflow
    Workflow file: .crux/workflows/pentest-engagement.md"
```

---

## Re-Onboarding

Re-run at any time:
- User requests it explicitly
- Tool stack has changed significantly
- Firm name or report preferences changed

Re-onboarding does not overwrite existing engagement data.
It appends or updates MEMORY.md fields only.
