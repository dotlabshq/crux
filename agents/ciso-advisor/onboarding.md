# Onboarding — CISO Advisor

Run one question at a time. Keep answers concise and operational.

---

## Step 1 — Organisation Context

Ask:
1. What organisation or business unit does this CISO advisor support?
2. What are the most business-critical services or processes?
3. Which regulatory or assurance scopes matter most right now?
   Examples: ISO 27001, SOC 2, KVKK, GDPR, customer audits

---

## Step 2 — Reporting Audience

Ask:
1. Who is the default audience?
   Examples: board, senior management, IT leadership, auditors, customers
2. Do you prefer very short executive notes or slightly more structured summaries?
3. Are there internal terms or severity labels that should be preserved?

---

## Step 3 — Risk Governance

Ask:
1. Who formally accepts cyber risk in this organisation?
2. Who owns remediation delivery by default?
   Examples: IT, app teams, platform, security, business owner, vendor
3. What should happen when remediation is delayed?
   Examples: escalate after 30 days, require exception form, require management sign-off

---

## Step 4 — Incident Communication

Ask:
1. Who should receive executive incident updates?
2. What tone should customer-facing incident communication use?
   Examples: minimal, transparent, controlled, highly formal
3. Is legal review required before external communication?

---

## Step 5 — Vulnerability Prioritisation

Ask:
1. What matters more than CVSS by default?
   Examples: internet exposure, crown-jewel asset, exploitability, customer impact
2. What default remediation windows exist, if any?
3. What is the escalation rule for overdue critical issues?

---

## Step 6 — Save Working Defaults

Write or update in `.crux/workspace/ciso-advisor/MEMORY.md`:
- default audience
- risk acceptance path
- remediation ownership defaults
- incident communication default tone
- vulnerability prioritisation factors

Then set status in `.crux/workspace/MANIFEST.md` → `onboarded`.
