---
name: llm-wiki-query
description: >
  Answers questions from the compiled LLM Wiki and optionally saves useful
  answers as durable analysis pages. Use when: the user asks a question about
  accumulated wiki knowledge, wants synthesis with citations to wiki pages, or
  asks to save an answer back into the wiki.
license: MIT
compatibility: opencode
metadata:
  owner: llm-wiki
  type: read-write
  approval: "No for answers; Yes before saving analysis unless auto-save is configured"
---

# llm-wiki-query

**Owner**: `llm-wiki`
**Type**: `read-write`
**Approval**: `No for answers; Yes before saving analysis unless auto-save is configured`

---

## What I Do

Reads the wiki index first, selects relevant pages, answers from compiled wiki
knowledge, and can write the answer back as an `analyses/` page so it persists
beyond the chat.

---

## When to Use Me

- User asks a question about the wiki's accumulated knowledge
- User wants synthesis across multiple sources or pages
- User asks for a comparison, gap analysis, outline, brief, or decision note from the wiki
- User says to save or file the answer into the wiki

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/llm-wiki/MEMORY.md

Loads during execution (lazy):
  .crux/docs/llm-wiki-schema.md if output format or save policy is unclear
  {wiki-root}/index.md
  {wiki-root}/glossary.md if terminology matters
  relevant pages selected from index.md
  {wiki-root}/log.md when saving or recent context matters

Estimated token cost: ~700 tokens + relevant pages
Unloaded after: answer delivered and optional analysis saved
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `question` | user | Yes |
| `output-format` | user | No — default: concise answer |
| `save-answer` | user / MEMORY.md | No — default: ask-before-saving |
| `wiki-root` | MEMORY.md / user | No — default: `wiki/` |

---

## Steps

```
1. Read wiki-root/index.md
   Identify candidate pages relevant to the question.

2. Read relevant pages
   Keep scope narrow.
   Prefer compiled wiki pages over raw sources.

3. Check glossary if terms or naming matter

4. Synthesize answer
   Distinguish:
     - source-supported facts
     - wiki synthesis
     - uncertainty or gaps
   Cite wiki pages using wikilinks or file paths.

5. Determine whether to save
   IF user explicitly asked to save → write analysis page.
   IF query-save-policy is ask-before-saving → ask before writing.
   IF query-save-policy is auto-save-useful-answers → save when answer has durable value.

6. If saving:
   Write wiki-root/analyses/{analysis-slug}.md
   Update wiki-root/index.md
   Append query entry to wiki-root/log.md

7. Return answer and, if saved, the target analysis path.
```

---

## Output

**Writes to**: optional `{wiki-root}/analyses/{analysis-slug}.md`, `{wiki-root}/index.md`, `{wiki-root}/log.md`
**Format**: `markdown`

### Analysis page format

```markdown
---
title: "{Analysis Title}"
type: analysis
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: []
tags: []
status: current
---

One-line summary.

## Question

{original question}

## Answer

{synthesis}

## Pages Consulted

- [[page-name]]

## Evidence And Uncertainty

- ...

## Related Pages

- [[page-name]]
```

### Log entry format

```markdown
## [YYYY-MM-DD] query | {Question Summary}

Pages consulted: ...
Output filed: yes/no — {analysis path or reason}
```

---

## Approval Gate

```
Before saving an analysis page when policy is ask-before-saving:

1. Show the proposed analysis title and target path
2. Summarize pages consulted
3. Ask for explicit approval
4. On approval → write analysis, update index, append log
5. On rejection → answer only, no wiki write
```

---

## Error Handling

| Condition | Action |
|---|---|
| `index.md` missing | Recommend llm-wiki-bootstrap before query |
| No relevant pages found | Answer with coverage gap and suggest raw-source ingest |
| User asks for unsupported certainty | State uncertainty and source limitations |
| Save path already exists | Ask before overwrite or choose a unique slug |
| Unexpected failure | Stop. Write error to bus. Notify user. |
