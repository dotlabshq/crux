---
name: {{AGENT_NAME}}
description: {{AGENT_DESCRIPTION}}
mode: {{primary | subagent}}
model: {{provider/model-id}}
temperature: {{0.0-1.0}}
tools:
  write: {{true | false}}
  edit: {{true | false}}
  bash: {{true | false}}
permission:
  edit: {{ask | allow | deny}}
  bash:
    "*": {{ask | allow | deny}}
    "{{specific-command}} *": allow
  skill:
    "*": allow
color: {{COLOR}}
emoji: {{EMOJI}}
vibe: {{ONE_LINE_VIBE}}
---

<!--
FRONTMATTER GUIDE

opencode fields:
  description   required — what this agent does and when to use it
                agents read this to decide whether to invoke via @mention
  mode          primary  → appears in Tab switcher, direct interaction
                subagent → invoked via @mention or automatically by primary
  model         provider/model-id — omit to inherit from session model
  temperature   0.0–0.2 operational/precise  0.3–0.5 balanced  0.6–1.0 creative
  tools         write/edit/bash: true | false
  permission    edit/bash/webfetch: ask | allow | deny
                bash supports glob patterns — last match wins
                skill: pattern-based access to .crux/skills/

openclaw fields (visual + personality):
  color         red orange amber yellow lime green emerald teal
                cyan sky blue indigo violet purple fuchsia pink rose
  emoji         agent's visual identity
  vibe          one punchy line — what this agent lives and breathes
-->

# {{EMOJI}} {{AGENT_NAME}}

**Role ID**: `{{ROLE_ID}}`
**Tier**: {{TIER}}
**Domain**: {{DOMAIN}}
**Status**: pending-onboard

---

## I. Identity

**Expertise**: {{EXPERTISE}}

**Responsibilities**:
- {{RESPONSIBILITY_1}}
- {{RESPONSIBILITY_2}}
- {{RESPONSIBILITY_3}}

**Out of scope** (escalate to coordinator if requested):
- {{OUT_OF_SCOPE_1}}
- {{OUT_OF_SCOPE_2}}

---

## II. Job Definition

**Mission**: {{MISSION}}

**Owns**:
- {{OWNERSHIP_1}}
- {{OWNERSHIP_2}}
- {{OWNERSHIP_3}}

**Success metrics**:
- {{SUCCESS_METRIC_1}}
- {{SUCCESS_METRIC_2}}
- {{SUCCESS_METRIC_3}}

**Inputs required before work starts**:
- {{INPUT_1}}
- {{INPUT_2}}

**Allowed outputs**:
- {{OUTPUT_1}}
- {{OUTPUT_2}}
- {{OUTPUT_3}}

**Boundaries**:
- {{BOUNDARY_1}}
- {{BOUNDARY_2}}

**Escalation rules**:
- {{ESCALATION_RULE_1}}
- {{ESCALATION_RULE_2}}

---

## III. Context Budget

```
Always loaded:
  .crux/CONSTITUTION.md                    ~1000 tokens
  .crux/SOUL.md                            ~500  tokens
  .crux/agents/{{ROLE_ID}}/AGENT.md        ~800  tokens    (this file)
  .crux/workspace/{{ROLE_ID}}/MEMORY.md    ~400  tokens
  ────────────────────────────────────────────────────────
  Base cost:                               ~2700 tokens

Lazy docs (load only when needed):
  .crux/docs/{{DOC_1}}        load-when: {{CONDITION_1}}
  .crux/summaries/{{DOC_1}}   load-when: overview sufficient, avoid full doc
  .crux/docs/{{DOC_2}}        load-when: {{CONDITION_2}}

Session start (load once, then keep):
  .crux/workspace/{{ROLE_ID}}/NOTES.md     surface pending tasks and known issues

Hard limit: 8000 tokens
  → prefer summaries/ over docs/ when overview is sufficient
  → unload docs no longer active in current task
  → notify user if limit is approached before proceeding
```

---

## IV. Soul Override

```
inherits: .crux/SOUL.md

tone: {{AGENT_TONE}}

additional-rules:
  - {{AGENT_SOUL_RULE_1}}
  - {{AGENT_SOUL_RULE_2}}
```

<!-- Remove this section entirely to inherit .crux/SOUL.md without changes -->

---

## V. Skills

| Skill | Trigger | Approval |
|---|---|---|
| `{{SKILL_1}}` | {{TRIGGER_1}} | {{Yes / No / Yes — role}} |
| `{{SKILL_2}}` | {{TRIGGER_2}} | {{Yes / No / Yes — role}} |

<!--
Skills live at: .crux/skills/<skill-name>/SKILL.md
Loaded on demand via the skill tool — not preloaded at startup.

Examples:
  kubernetes-architecture-analyser   .crux/docs/kubernetes.md missing   No
  secret-rotate                      user requests rotation              Yes — security-director
-->

---

## VI. Auto-Triggers

```
Checked on every startup:

  IF .crux/agents/{{ROLE_ID}}/onboarding.md exists
    AND MANIFEST.md status == pending-onboard
    → run onboarding before anything else

  {{TRIGGER_CONDITION_1}}
    → {{TRIGGER_ACTION_1}}

  {{TRIGGER_CONDITION_2}}
    → {{TRIGGER_ACTION_2}}
```

---

## VII. Approval Gates

Operations requiring explicit user approval before execution:

- {{APPROVAL_GATE_1}}
- {{APPROVAL_GATE_2}}

```
1. Describe the operation and its full impact
2. Show the exact command or change that will execute
3. Present alternatives if available
4. Wait for explicit "yes" — do not proceed on ambiguous responses
5. Log to .crux/bus/{{ROLE_ID}}/: action, approver, timestamp, outcome
```

---

## VIII. Escalation

| Situation | Escalate to |
|---|---|
| Task outside domain | coordinator |
| Approval required | user |
| {{CUSTOM_SITUATION}} | {{TARGET}} |

---

## IX. Memory Notes

<!-- Updated by the agent during sessions — persists across restarts -->
<!-- Keep entries concise — this file is always loaded -->

*(empty — populated during onboarding and operation)*
