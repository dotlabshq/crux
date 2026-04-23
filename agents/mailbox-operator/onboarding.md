# Onboarding: Mailbox Operator

> This file defines the onboarding sequence for the `mailbox-operator` agent.
> Onboarding configures read-only mailbox triage through Himalaya without
> storing credentials in Crux workspace files.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/mailbox-operator/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Greet the user and explain what this agent does.

```
You are setting up the Mailbox Operator agent.

This agent reads a configured mailbox through Himalaya in read-only mode, then:
- summarizes recent emails
- classifies request, information, approval, decision-candidate, risk, and noise messages
- extracts action plans and follow-ups
- routes human decisions to the Crux inbox
- routes domain-specific work to the relevant agent workspace

I will ask a few short questions so mailbox triage is scoped safely.
Crux will not store mailbox passwords or tokens.
```

---

## Step 2 — Environment Discovery

```
Run the following checks silently:
  1. Check Himalaya availability: himalaya --version
  2. Check configured accounts: himalaya account list
  3. Check available folders for the default account: himalaya folder list
  4. Check whether .crux/workspace/mailbox-operator/output/ exists
  5. Check whether .crux/docs/mailbox-triage-policy.md exists
     If missing, note that it can be generated from this agent's defaults during Step 4

For each check:
  IF successful   → record result in .crux/workspace/current/scratch.md
  IF failed       → note as "missing" and surface in Step 3 if relevant
```

Do not inspect or print credentials. Do not read `~/.config/himalaya/config.toml`
unless the user explicitly asks for configuration troubleshooting.

---

## Step 3 — User Questions

Ask one question at a time.

```
Question order:

1. "Which Himalaya account should mailbox triage use?
    I can use the default account, or you can name one from `himalaya account list`."
   default: default
   stores-to: MEMORY.md → mailbox-default-account

2. "Which folder should I scan by default?"
   default: INBOX
   stores-to: MEMORY.md → mailbox-default-folder

3. "What should the default scan scope be?
    Options: unread-only / since-last-scan / latest-page / date-range"
   default: latest-page
   stores-to: MEMORY.md → mailbox-default-scan-scope

4. "How many messages should I process in one scan by default?"
   default: 20
   stores-to: MEMORY.md → mailbox-default-page-size

5. "Should I store full message bodies, redacted summaries only, or metadata only?"
   default: redacted-summaries-only
   stores-to: MEMORY.md → mailbox-storage-policy

6. "Should mail-derived facts be written directly to agent MEMORY when confidence is high,
    or should they be proposed as candidate memory first?"
   default: candidate-memory-first
   stores-to: MEMORY.md → mailbox-memory-write-policy

7. "Which language should mailbox summaries and action plans use?"
   default: user's current language
   stores-to: MEMORY.md → mailbox-summary-language
```

---

## Step 4 — Generate Docs

Generate the initial mailbox triage policy if it is missing.

```
Required docs for this agent:
  .crux/docs/mailbox-triage-policy.md → generate from mailbox-triage classification rules if missing

Required workspace paths:
  .crux/workspace/mailbox-operator/output/
  .crux/workspace/mailbox-operator/output/scans/
  .crux/workspace/mailbox-operator/output/digests/
```

The policy should include:
- classification labels and meanings
- read-only Himalaya command boundary
- memory vs notes vs inbox routing rules
- redaction and raw-body storage defaults
- dispatch confidence levels

---

## Step 5 — Review & Confirm

Present a summary of what was discovered and configured.

```
Onboarding summary for Mailbox Operator:

  - Himalaya availability
  - default account
  - default folder
  - scan scope
  - page size
  - storage policy
  - memory write policy
  - summary language

Does this look correct?
  → Yes: finalise onboarding
  → No:  return to the relevant step
```

---

## Step 6 — Finalise

```
1. Write collected durable facts to .crux/workspace/mailbox-operator/MEMORY.md
2. Update .crux/workspace/MANIFEST.md:
     add or update agent row → mailbox-operator / pending-onboard → onboarded
3. Write event to .crux/bus/broadcast.jsonl:
     type: agent.onboarded
     from: mailbox-operator
4. Notify user:
   "Mailbox Operator is ready.
    You can now ask @mailbox-operator to scan the configured mailbox,
    summarize recent emails, or extract an action plan."
```

---

## Re-Onboarding

Re-run onboarding when:
- the Himalaya account changes
- the default folder or scan policy changes
- the user wants stricter storage or redaction rules
- mailbox triage should route to a different set of agents

Re-onboarding must not overwrite mailbox credentials or read secret values.
