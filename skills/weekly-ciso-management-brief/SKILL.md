---
name: weekly-ciso-management-brief
description: >
  Produces a weekly CISO management briefing as a Marp-compatible Markdown
  presentation. Use when: weekly cybersecurity notes, KPI/KRI data, incidents,
  vulnerabilities, threat intelligence, regulatory updates, or management
  decision needs must become an executive-ready cyber risk and security
  management brief.
license: MIT
compatibility: opencode
metadata:
  owner: ciso-advisor
  type: read-write
  approval: No
---

# weekly-ciso-management-brief

**Owner**: `ciso-advisor`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turn raw weekly cybersecurity activity, operational notes, KPI/KRI data,
incident summaries, external threat intelligence, regulatory updates, and
management decision needs into an executive-level weekly CISO briefing.

The default output is a Marp-compatible Markdown presentation. It is not a
technical activity report. It focuses on cyber risk posture, risk movement,
business impact, KPI/KRI visibility, executive decisions, next-week ownership,
and external threat or regulatory context.

---

## When to Use Me

- The user asks for a weekly CISO management presentation
- Weekly security notes must become a management-ready cybersecurity brief
- A Marp-based weekly cyber risk update is requested
- A weekly executive cybersecurity report needs standard structure and wording
- The user asks for the usual CISO weekly format

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ciso-advisor/MEMORY.md

Loads during execution (lazy):
  .crux/docs/ciso-communication-principles.md
  .crux/docs/risk-framing-patterns.md
  .crux/docs/incident-communication-guide.md
  .crux/docs/compliance-reporting-guide.md

Estimated token cost: ~900 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `week` | user / MEMORY.md | No |
| `presentation-date` | user / current date | No |
| `prepared-by` | user / MEMORY.md | No |
| `target-audience` | user / MEMORY.md | No |
| `completed-work` | user / notes / prior outputs | No |
| `ongoing-work` | user / notes / prior outputs | No |
| `new-or-changed-risks` | user / notes / prior outputs | No |
| `kpi-kri-data` | user / metrics / dashboards | No |
| `incident-monitoring-summary` | user / SOC notes / monitoring data | No |
| `management-decisions` | user / notes / prior outputs | No |
| `next-week-focus` | user / notes / prior outputs | No |
| `external-threat-regulatory-context` | user / report links / raw text | No |
| `emphasis-or-exclusions` | user | No |

If the provided data is partial, produce the best possible presentation and mark
missing fields as `Data pending`, `Not shared`, or `To be confirmed`. Ask
follow-up questions only when the missing information would materially change
the executive message.

---

## Input Capture Template

Use this form only when the user asks what to provide or when the missing inputs
block a useful brief. Do not ask every question if enough information is already
available.

```markdown
## 1. Presentation Information
- Week:
- Presentation date:
- Prepared by:
- Target audience:

## 2. Completed Work This Week
-

## 3. Ongoing Work
-

## 4. New or Changed Risks
-

## 5. KPI / KRI Data
- Critical security incidents:
- Critical vulnerabilities:
- Overdue critical vulnerabilities:
- Critical asset coverage ratio:
- Critical patch tracking scope:
- Automated analysis scenarios:
- Security awareness coverage:

## 6. Incident / Monitoring Summary
- Number of reviewed alerts:
- Critical incidents:
- False positives:
- Confirmed security incidents:
- Notable suspicious activity:
- Monitoring gaps:

## 7. Decisions or Support Required from Management
-

## 8. Next Week Focus Areas
-

## 9. External Threat / Regulation / Sector Developments
- Report, links, or raw text:
- Systems or business areas that may be affected:
- Priority areas to emphasize:

## 10. Topics to Emphasize or Exclude
-
```

---

## Executive Transformation Rules

Convert technical or activity-heavy inputs into management meaning.

| Raw Input Style | Executive Output Style |
|---|---|
| What we did | What changed for the business or risk posture |
| Tool or project names | Risk themes and business impact |
| Technical details | Decision relevance and operational exposure |
| Activity lists | Milestones, risk movement, ownership, and KPIs |
| Vulnerability lists | Patch management and exposure prioritisation |

Use project names only when they help, especially in milestone, action, and
appendix slides. In executive slides, prefer risk themes and business impact.

| Raw Term / Initiative Type | Management Theme |
|---|---|
| Application security control work | Application security control maturity |
| Control measurement or tracking integration | Measurable and trackable security controls |
| AI-assisted analysis initiative | Security analysis capacity and consistency |
| Asset inventory work | Critical asset visibility |
| Certification or compliance roadmap | Certification and compliance timeline |
| Awareness or training activity | Security awareness and human risk |
| CVE / vulnerabilities | Critical patch management and vulnerability tracking |
| Open-source infrastructure vulnerabilities | Infrastructure component maintenance risk |
| Mail server vulnerabilities | Mail infrastructure security |
| Web server vulnerabilities | Web service layer security |
| Hosting control panel vulnerabilities | Hosting management panel risk |
| SOC alerts | Security operations visibility |
| EDR review | Endpoint and infrastructure detection coverage |

---

## Steps

```
1. Identify the reporting period, audience, source material, and requested mode.
   IF the user did not provide a mode
     → use Full Mode.

2. Separate facts, assumptions, missing data, and management decisions.
   Do not invent KPI/KRI values, incident counts, owners, or dates.

3. Convert operational details into risk posture, business impact, decision need,
   KPI/KRI visibility, and next-week ownership.

4. Apply repetition control.
   Use each project or tool name only where it adds value.
   Do not repeat the same message across multiple main slides.

5. Place content by purpose:
   - posture and top-level message → 1-Minute Executive Summary
   - three memorable points → 3 Things Management Should Know This Week
   - risk increase/decrease → Cyber Risk Radar
   - metrics → KPI / KRI
   - external threat/regulation → Cyber Agenda
   - concrete deliverables → Completed Milestones
   - budget/resource/risk/timeline/ownership choices → Decisions
   - operational execution → Next Week Focus and Ownership
   - long technical detail → Appendices

6. Handle external threat, regulation, and CVE content calmly.
   Prioritise by exposure, internet-facing status, privilege impact,
   exploitability, business criticality, and affected technology family.

7. Produce valid Marp-compatible Markdown using the required header and slide
   structure for the selected mode.

8. Run the quality checklist before returning the final output.

9. Skill complete — unload.
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `Marp-compatible markdown`

If the user requests a file path, write the presentation there. Otherwise return
the Markdown directly.

### Required Marp Header

Every presentation must start with this header unless the user requests a
different format.

```markdown
---
marp: true
theme: default
paginate: true
size: 16:9
---

<style>
section {
  font-size: 22px;
  line-height: 1.35;
}

h1 {
  font-size: 32px;
  margin-bottom: 16px;
}

h2 {
  font-size: 24px;
  margin-top: 8px;
  color: #333;
}

h3 {
  font-size: 21px;
}

p, li {
  font-size: 20px;
}

table {
  font-size: 15.5px;
  line-height: 1.25;
}

th, td {
  padding: 5px 7px;
  vertical-align: top;
}

strong {
  font-weight: 700;
}

.small {
  font-size: 18px;
}

.note {
  font-size: 17px;
  color: #555;
}

.compact table {
  font-size: 14px;
}

.compact th, .compact td {
  padding: 4px 6px;
}

.two-columns {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 28px;
}
</style>
```

### Default Slide Structure

```text
1. Cover
2. Agenda
3. 1-Minute Executive Summary
4. 3 Things Management Should Know This Week
5. Cyber Risk Radar
6. KPI / KRI — Weekly Cybersecurity Indicators
7. What Happened in the Cyber Agenda?
8. Completed Milestones
9. Decisions / Support Required from Management
10. Next Week Focus and Ownership
11. Appendix A1 — Weekly Activity Summary
12. Appendix A2 — Incident / Monitoring Summary
13. Appendix A3 — Data Visibility and Metric Maturity
14. Appendix A4 — Open Risk and Action Register
```

### Slide Templates

```markdown
# Weekly Cyber Risk and Security Management Briefing

## [Organization / Security Team] | Week [X]

Prepared by: [Name]
Presentation Date: [Date]

---

# Agenda

<div class="two-columns">

- Executive summary
- Management takeaways
- Cyber risk radar
- KPI / KRI indicators

- Cyber agenda
- Completed milestones
- Decisions required
- Next-week focus

</div>

---

# 1-Minute Executive Summary

| Topic | Management Message |
|---|---|
| Overall Cyber Risk Posture | ... |
| Main Improvement This Week | ... |
| Main Open Risk | ... |
| Operational Opportunity | ... |
| Decision Required from Management | ... |

---

# 3 Things Management Should Know This Week

| # | Management Message | Business Impact | Expected Next Step |
|---:|---|---|---|
| 1 | ... | ... | ... |
| 2 | ... | ... | ... |
| 3 | ... | ... | ... |

---

# Cyber Risk Radar

| Risk Area | Status | Trend | Change This Week | Management Comment |
|---|---|---|---|---|
| ... | Medium | ↓ | ... | ... |

---

# KPI / KRI — Weekly Cybersecurity Indicators

| Indicator | This Week | Previous Week | Trend | Management Comment |
|---|---:|---:|---|---|
| Critical security incidents | Data pending | Data pending | → | ... |
| Completed security control sets | Data pending | Data pending | → | ... |
| Critical asset coverage ratio | Data pending | Data pending | → | ... |
| Overdue critical vulnerabilities | Data pending | Data pending | → | ... |
| Critical patch tracking scope | Data pending | Data pending | → | ... |
| Automated analysis scenarios | Data pending | Data pending | → | ... |
| Security awareness coverage | Data pending | Data pending | → | ... |

---

# What Happened in the Cyber Agenda?

| Topic | Potential Impact on the Organization | Priority Action |
|---|---|---|
| ... | ... | ... |

---

# Completed Milestones

| Deliverable | Evidence / Output | Next Use |
|---|---|---|
| ... | ... | ... |

---

# Decisions / Support Required from Management

| Decision Topic | Options | Recommendation | Impact If Not Decided |
|---|---|---|---|
| ... | ... | ... | ... |

---

# Next Week Focus and Ownership

| Priority | Action | Owner | Dependency | Success Criteria |
|---:|---|---|---|---|
| 1 | ... | ... | ... | ... |

---

# Appendix A1 — Weekly Activity Summary

| Period | Activity | Technical Area | Business / Risk Impact | Status | Next Action |
|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... |

---

# Appendix A2 — Incident / Monitoring Summary

| Topic | This Week's Status |
|---|---|
| Reviewed alerts | Data pending |
| Critical incidents | Data pending |
| False positives | Data pending |
| Confirmed security incidents | Data pending |
| Notable suspicious activity | Data pending |
| Monitoring gaps | Data pending |

---

# Appendix A3 — Data Visibility and Metric Maturity

| Area | Current State | Risk | Improvement Action |
|---|---|---|---|
| ... | ... | ... | ... |

---

# Appendix A4 — Open Risk and Action Register

| Risk / Action | Owner | Target Date | Status | Management Dependency |
|---|---|---|---|---|
| ... | ... | To be confirmed | ... | ... |
```

### Optional Mode Variants

| Mode | Use When | Structure |
|---|---|---|
| `Short Executive Mode` | Time or audience attention is limited | Cover, Executive Summary, 3 Things, Risk Radar, KPI/KRI, Cyber Agenda, Decisions, Next Week Focus |
| `Full Mode` | Default weekly management presentation is requested | Complete default structure with appendices |
| `No-Repetition Mode` | Prior drafts repeat project names or messages | Full Mode with strict project-name and message deduplication |
| `Threat-Heavy Mode` | Major advisories, critical CVEs, sector incidents, or regulatory updates dominate the week | Full Mode plus expanded cyber agenda, priority vulnerabilities, exposure assessment, and patch/mitigation ownership |

---

## Content Rules

- Write for management, not technical teams.
- Keep the main presentation decision-relevant and concise.
- Use exactly three rows in `3 Things Management Should Know This Week`.
- Use risk themes, not project names, in `Cyber Risk Radar`.
- Use `Low`, `Medium`, `High`, or `Critical` as risk status values.
- Use `↑`, `↓`, or `→` as trend values.
- Do not turn risk slides into activity lists.
- Do not put normal operational tasks on the management decisions slide.
- Every management decision must include a recommendation and the consequence
  of no decision.
- Every next-week action must include owner, dependency, and success criteria.
- Move technical detail and long activity lists to appendices.
- Treat missing data as a visibility or metric maturity issue when appropriate.

---

## External Threat and CVE Handling

When the user provides a threat report, vulnerability bulletin, CVE list,
regulatory update, or sector development:

```
1. Summarise it in management language.
2. Identify affected technology families, countries, systems, or business areas.
3. Prioritise by exposure, internet-facing status, privilege impact,
   exploitability, and business criticality.
4. Keep technical depth out of the main slide.
5. Move long CVE details into a compact technical slide or appendix.
6. Do not imply that open-source technologies are inherently insecure.
7. Frame the issue as patch management, asset visibility, and operational
   discipline.
```

Use this message when open-source component risk is relevant:

```markdown
This does not mean open-source technologies are inherently insecure. The risk
comes from not tracking advisories, not applying security updates on time, and
not maintaining accurate infrastructure inventory.
```

If there is a long CVE list, add this compact slide:

```markdown
<section class="compact">

# Priority Vulnerabilities to Track

| Component | CVE / Vulnerability | Risk Summary | Priority |
|---|---|---|---|
| ... | ... | ... | ... |

</section>
```

Recommended management framing:

```markdown
This is not a panic topic. It is a reminder that vulnerability tracking, patch
management, accurate asset inventory, and post-update validation must operate
as a disciplined management process.
```

---

## Quality Checklist

Before returning the final output, verify:

1. The presentation is written for management, not technical teams.
2. Each slide answers a different question.
3. Project names are not repeated unnecessarily.
4. Risk slides are free from activity-list language.
5. Decision slides contain only real management decisions.
6. Operational tasks are placed in next-week ownership.
7. Technical details are moved to appendices.
8. KPI/KRI values are factual and not invented.
9. Missing metrics are clearly marked.
10. External threat content is calm, risk-based, and actionable.
11. Open-source risks are framed correctly.
12. Every next-week action has owner, dependency, and success criteria.
13. Recommendations are clear where management decisions are requested.
14. The output is valid Marp-compatible Markdown.

---

## Error Handling

| Condition | Action |
|---|---|
| Inputs are partial | Produce the best possible brief and mark gaps as `Data pending`, `Not shared`, or `To be confirmed`. |
| KPI/KRI values are missing | Do not invent values. Treat the gap as a visibility and metric maturity issue where relevant. |
| Source content is too technical | Translate to risk, business impact, owner, and decision relevance; move detail to appendices. |
| Too many repeated project names | Switch to risk themes in main slides and keep project names for milestones, actions, or appendices. |
| External threat content is long | Summarise in the cyber agenda and move CVE/detail lists to a compact slide or appendix. |
| Management decision is unclear | State the likely decision type and mark recommendation as `To be confirmed`. |
| Unexpected failure | Stop. Write error to bus. Notify user. |

---

## Example Executive Language Transformations

| Technical / Raw Input | Better Executive Wording |
|---|---|
| Application security controls are complete. | Application security controls are moving from documentation to measurable implementation. |
| Asset inventory work started. | Critical asset visibility remains a key operational risk until the inventory is complete. |
| AI-assisted analysis proof of concept worked. | AI-assisted security analysis can reduce manual workload and improve security team capacity. |
| Certification roadmap created. | Certification readiness now requires management approval to protect the timeline. |
| Mail server CVEs announced. | Mail infrastructure requires prioritised patch and exposure validation. |
| Operating system kernel vulnerabilities announced. | Multi-user and virtualization platforms require kernel patch validation and maintenance planning. |
| SOC data was not shared. | Security operations metric visibility must be standardized. |
