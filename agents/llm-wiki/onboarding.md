# Onboarding: LLM Wiki

> This file defines the onboarding sequence for the `llm-wiki` agent.
> Onboarding configures a private markdown LLM Wiki based on the Karpathy
> pattern: immutable raw sources, generated wiki pages, and a schema that keeps
> future sessions disciplined.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/llm-wiki/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Greet the user and explain what this agent does.

```
You are setting up the LLM Wiki agent.

This agent maintains a private markdown knowledge base:
- raw sources stay immutable
- wiki pages are generated and maintained by the agent
- useful answers can be saved as durable analysis pages
- index, glossary, overview, and log keep the wiki navigable
- lint checks find contradictions, stale claims, orphan pages, and terminology drift

I will ask a few short questions so the wiki structure matches your domain.
```

---

## Step 2 — Environment Discovery

```
Run the following checks silently:
  1. Check whether the default raw root exists: raw/
  2. Check whether the default wiki root exists: wiki/
  3. Check whether wiki/index.md, wiki/overview.md, wiki/glossary.md, and wiki/log.md exist
  4. Check whether .crux/docs/llm-wiki-schema.md exists
     If missing, note that it can be generated from this agent's assets during Step 4
  5. Check whether .crux/workspace/llm-wiki/output/ exists

For each check:
  IF successful   → record result in .crux/workspace/current/scratch.md
  IF failed       → note as "missing" and surface in Step 3 if relevant
```

Do not inspect large raw sources during onboarding. Discovery should only identify
structure and obvious starter files.

---

## Step 3 — User Questions

Ask one question at a time.

```
Question order:

1. "Where should immutable source documents live?
    Default: raw/"
   default: raw/
   stores-to: MEMORY.md → raw-root

2. "Where should generated wiki pages live?
    Default: wiki/"
   default: wiki/
   stores-to: MEMORY.md → wiki-root

3. "What is this wiki primarily about?
    Examples: product research, personal knowledge, client delivery, technical writing, learning notes."
   default: project knowledge base
   stores-to: MEMORY.md → wiki-purpose

4. "Which starter page types should be enabled?
    Default: sources, concepts, products, features, personas, style, analyses.
    You can add domain-specific types such as decisions, people, companies, APIs, papers, or projects."
   default: sources, concepts, products, features, personas, style, analyses
   stores-to: MEMORY.md → wiki-page-types

5. "When a query produces a useful answer, should I ask before saving it as an analysis page?"
   default: ask-before-saving
   stores-to: MEMORY.md → query-save-policy

6. "How strict should ingest be when a source contradicts existing wiki pages?
    Options: flag-only / ask-before-update / update-with-contradiction-note"
   default: ask-before-update
   stores-to: MEMORY.md → contradiction-policy

7. "Should generated pages use Obsidian-style wikilinks?"
   default: yes
   stores-to: MEMORY.md → wikilink-style

8. "What language should wiki maintenance reports use?"
   default: user's current language
   stores-to: MEMORY.md → maintenance-language
```

---

## Step 4 — Generate Docs And Starter Structure

Generate the initial schema guidance and starter wiki files if missing.

```
Required docs for this agent:
  .crux/docs/llm-wiki-schema.md → generate from agents/llm-wiki/assets/llm-wiki-schema.template.md if missing

Required workspace paths:
  .crux/workspace/llm-wiki/output/
  .crux/workspace/llm-wiki/output/lint-reports/
  .crux/workspace/llm-wiki/output/ingest-reports/

Required wiki paths under {wiki-root}:
  index.md
  overview.md
  glossary.md
  log.md
  sources/
  concepts/
  analyses/

Optional wiki paths based on enabled page types:
  products/
  features/
  personas/
  style/
  decisions/
  people/
  companies/
  projects/
  papers/
  apis/
```

Use `llm-wiki-bootstrap` for initial creation. Preserve existing files unless the
user explicitly approves replacement.

---

## Step 5 — Review & Confirm

Present a summary of what was discovered and configured.

```
Onboarding summary for LLM Wiki:

  - raw root
  - wiki root
  - wiki purpose
  - enabled page types
  - query save policy
  - contradiction policy
  - wikilink style
  - maintenance language
  - existing starter files found or missing

Does this look correct?
  → Yes: finalise onboarding
  → No:  return to the relevant step
```

---

## Step 6 — Finalise

```
1. Write collected durable facts to .crux/workspace/llm-wiki/MEMORY.md
2. Update .crux/workspace/MANIFEST.md:
     add or update agent row → llm-wiki / pending-onboard → onboarded
3. Write event to .crux/bus/broadcast.jsonl:
     type: agent.onboarded
     from: llm-wiki
4. Notify user:
   "LLM Wiki is ready.
    You can now ask @llm-wiki to bootstrap the wiki, ingest a source,
    answer from the wiki, save an analysis page, or lint the wiki."
```

---

## Re-Onboarding

Re-run onboarding when:
- the raw root or wiki root changes
- the wiki moves to a new domain
- page types or schema conventions change materially
- the user wants stricter provenance, contradiction, or writeback rules

Re-onboarding must preserve existing raw sources and wiki pages unless the user
explicitly requests a migration or overwrite.
