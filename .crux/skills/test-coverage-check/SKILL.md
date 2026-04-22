---
name: test-coverage-check
description: >
  Runs the project test suite and collects coverage metrics. Identifies
  uncovered packages, files, and functions. Highlights coverage regressions
  relative to a threshold or previous run. Read-only analysis — does not
  modify tests or source code.
  Use when: user asks about coverage, before a major refactor, or after
  adding new backend logic.
license: MIT
compatibility: opencode
metadata:
  owner: backend-developer
  type: read-only
  approval: "No"
---

# test-coverage-check

**Owner**: `backend-developer`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Detects the project's language and test runner, executes the test suite with
coverage enabled, and produces a prioritised coverage report. Flags packages
or modules below a configurable threshold and highlights recently-modified
files that lack test coverage.

---

## When to Use Me

- User asks: "what's the test coverage?", "are tests passing?", "coverage report"
- Before a major refactor — establish baseline
- After implementing a feature — verify new code is covered
- Onboarding Step 3 (backend-developer)

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/backend-developer/MEMORY.md
    Fields needed:
      language         (go | node | python | ruby | rust | unknown)
      test-runner      (go test | jest | pytest | rspec | cargo test | unknown)
      test-command     (optional override — if user has a custom test script)
      coverage-threshold  (optional — minimum % below which to flag, default 80)

Estimated token cost: ~400 tokens
Unloaded after: report delivered
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| threshold | user or MEMORY.md | No — default 80% |
| target-path | user | No — runs full suite if omitted |
| changed-only | user | No — if true, focuses report on recently changed files |

---

## Steps

```
1. Detect language and test runner
   IF MEMORY.md has language + test-runner → use those
   ELSE detect:
     go.mod present          → Go,     go test
     package.json present    → Node,   jest / vitest / mocha
     requirements.txt or
       pyproject.toml        → Python, pytest
     Gemfile present         → Ruby,   rspec / minitest
     Cargo.toml present      → Rust,   cargo test
   IF cannot detect → ask user: "What language and test runner does this project use?"

2. Run tests with coverage

   Go:
     go test ./... -coverprofile=.crux/workspace/backend-developer/coverage.out \
       -covermode=atomic 2>&1
     go tool cover -func=.crux/workspace/backend-developer/coverage.out

   Node (Jest):
     npx jest --coverage --coverageReporters=text-summary --coverageReporters=json \
       --coverageDirectory=.crux/workspace/backend-developer/coverage 2>&1

   Python (pytest):
     python -m pytest --cov={target-path} --cov-report=term-missing \
       --cov-report=json:.crux/workspace/backend-developer/coverage.json 2>&1

   Rust:
     cargo test 2>&1  (note: tarpaulin required for line coverage)
     IF tarpaulin available: cargo tarpaulin --out Json \
       --output-dir .crux/workspace/backend-developer/ 2>&1

   IF test-command set in MEMORY.md → use that instead

3. Parse results
   Extract:
     - Overall coverage %
     - Per-package/module coverage %
     - Test pass/fail counts
     - Any test failures (stop and report failures before coverage)

4. IF tests failed
   Stop coverage analysis.
   Report:
     "{n} tests failed. Resolve test failures before reviewing coverage.
      Failing tests: {list}"

5. Identify coverage gaps
   Packages/files below threshold:
     Sort ascending by coverage %
     Flag: {pkg} — {coverage}% (threshold: {threshold}%)

   IF changed-only:
     git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -E '\.(go|ts|js|py|rb|rs)$'
     For each changed file: show coverage %
     FLAG: changed file with 0% coverage → HIGH priority

6. Compile results
   HIGH   — 0% coverage on changed files, or critical packages uncovered
   MEDIUM — below threshold
   LOW    — above threshold but notable gaps

7. Report inline
```

---

## Output

Delivered inline. Format:

```
## Test Coverage — {DATE}

Language:    {language}
Test runner: {test-runner}
Threshold:   {threshold}%

### Summary

Tests:    {n} passed, {n} failed, {n} skipped
Overall:  {pct}%  ← {OK | BELOW THRESHOLD}

### Packages Below Threshold

| Package / Module | Coverage | Gap |
|---|---|---|
| {pkg} | {pct}% | {threshold - pct}pp below threshold |

### Recently Changed Files (coverage)

| File | Coverage | Status |
|---|---|---|
| {file} | {pct}% | {OK | NO COVERAGE} |

### Recommendations

{1. Add tests for: {top uncovered packages}}
{2. Newly changed files with no coverage: {list}}
{3. Consider adding integration tests for: {list}}
```

---

## Error Handling

| Condition | Action |
|---|---|
| Language/runner not detected | Ask user before proceeding. |
| Test command not found (jest, pytest, etc.) | Notify: "{runner} not found. Run `npm install` or check PATH." |
| Tests fail | Stop. Report failures. Do not proceed to coverage analysis. |
| Coverage output not parseable | Show raw output, note parse failure. |
| Workspace output dir not writable | Write coverage files to /tmp/crux-coverage/. Notify user. |
| go tool cover not found | Run `go test` output parsing only (no per-function breakdown). |
