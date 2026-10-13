import { describe, expect, it } from "vitest";
import { measureBaseContext } from "../src/crux/budget.ts";
import { memoryFs } from "../src/crux/fs.ts";
import { parseInbox, pendingInbox } from "../src/crux/inbox.ts";
import { agentStatus, isOnboarded, parseManifestAgents } from "../src/crux/manifest.ts";
import { listAnswered, listRequests, parseRequest } from "../src/crux/requests.ts";
import { appendTodo, emptyTodo, parseTodos, todoStatus } from "../src/crux/todo.ts";
import { ulid } from "../src/crux/ulid.ts";
import { buildDelegateArgs, buildDelegateSystemPrompt, foldJsonLines } from "../src/delegate.ts";

const MANIFEST = `# Crux Manifest

## Agents

| Role ID | Tier | Status | Docs | Last Session |
|---|---|---|---|---|
| \`kubernetes-admin\` | infra | onboarded | ✓ | 01J |
| \`postgresql-admin\` | infra | pending-onboard | ✗ | — |
| \`b9/mail:linux-admin\` | ops | onboarded | ✓ | — |

## Skills

| Skill | Owner |
|---|---|
| \`x\` | \`y\` |
`;

describe("manifest", () => {
	it("parses the Agents table only", () => {
		expect(parseManifestAgents(MANIFEST).map((a) => a.id)).toEqual(["kubernetes-admin", "postgresql-admin", "b9/mail:linux-admin"]);
	});
	it("answers onboarding by role, optionally scoped to a team", () => {
		const agents = parseManifestAgents(MANIFEST);
		expect(isOnboarded(agents, "kubernetes-admin")).toBe(true);
		expect(isOnboarded(agents, "postgresql-admin")).toBe(false);
		expect(isOnboarded(agents, "nope")).toBe(false);
		expect(agentStatus(agents, "linux-admin", "b9/mail")).toBe("onboarded");
		expect(agentStatus(agents, "linux-admin")).toBeUndefined();
	});
});

const TODO = `# TODO

---

## Task Records

## T-A
- title: first
- status: in_progress
- owner: kubernetes-admin
- evidence_refs:
  - a.md
  - b.md

## T-B
- title: second
- status: done

---

## Rules

1. x
`;

describe("todo", () => {
	it("parses records with evidence refs", () => {
		const records = parseTodos(TODO);
		expect(records.map((r) => r.id)).toEqual(["T-A", "T-B"]);
		expect(records[0].evidence_refs).toEqual(["a.md", "b.md"]);
		expect(todoStatus(TODO, "T-B")).toBe("done");
		expect(todoStatus(TODO, "T-C")).toBeUndefined();
	});
	it("appends before the Rules block and round-trips", () => {
		const next = appendTodo(TODO, { id: "T-C", fields: { title: "third", status: "todo" }, evidence_refs: ["c.md"] });
		expect(next.indexOf("## T-C")).toBeGreaterThan(next.indexOf("## T-B"));
		expect(next.indexOf("## T-C")).toBeLessThan(next.indexOf("## Rules"));
		expect(todoStatus(next, "T-C")).toBe("todo");
		expect(parseTodos(next).find((r) => r.id === "T-C")?.evidence_refs).toEqual(["c.md"]);
	});
	it("keeps a multi-line task on one field line", () => {
		const next = appendTodo(TODO, { id: "T-M", fields: { acceptance_criteria: "line one\n\nline two", status: "todo" }, evidence_refs: [] });
		expect(next).toContain("- acceptance_criteria: line one line two\n- status: todo");
		expect(todoStatus(next, "T-M")).toBe("todo");
	});
	it("appends to a fresh file", () => {
		const next = appendTodo(emptyTodo("x", "2026-10-13"), { id: "T-1", fields: { status: "todo" }, evidence_refs: [] });
		expect(todoStatus(next, "T-1")).toBe("todo");
	});
});

const INBOX = `# Crux Inbox

## Pending Approvals

<!-- Example:
- id: APR-000
  status: pending
-->

- id: APR-001
  requested_by: kubernetes-admin
  status: pending
  summary: Apply NetworkPolicy
- id: APR-002
  status: approved
  summary: old

---

## Blocked Questions

*(none)*

---

## Operator Handoffs

- id: H-001
  requested_by: linux-admin
  summary: rotate cert

---

## Resolved

- id: APR-000
  status: approved
`;

describe("inbox", () => {
	it("reads items, skipping comments, none markers and Resolved", () => {
		expect(parseInbox(INBOX).map((i) => i.id)).toEqual(["APR-001", "APR-002", "H-001"]);
		expect(pendingInbox(INBOX).map((i) => i.id)).toEqual(["APR-001", "H-001"]);
		expect(parseInbox(INBOX)[0].fields.summary).toBe("Apply NetworkPolicy");
	});
});

describe("requests", () => {
	const fs = memoryFs({
		"/c/.crux/requests/mail/2026-10-13-smtp.md": "---\nid: 01\nfrom: b9/app\nto: b9/mail\ntype: task\nstatus: open\nopened: 2026-10-13\n---\n\n# SMTP sender for invites\n",
		"/c/.crux/requests/mail/.gitkeep": "",
		"/c/.crux/requests/app/2026-10-01-old.md": "---\nid: 02\nfrom: b9/mail\nto: b9/app\nstatus: done\nopened: 2026-10-01\nclosed: 2026-10-02\n---\n# answered\n",
	});
	it("lists an inbox oldest first and parses the title", () => {
		const inbox = listRequests("/c/.crux/requests/mail", fs);
		expect(inbox).toHaveLength(1);
		expect(inbox[0]).toMatchObject({ id: "01", from: "b9/app", status: "open", title: "SMTP sender for invites" });
		expect(listRequests("/c/.crux/requests/none", fs)).toEqual([]);
	});
	it("finds answered requests this team sent", () => {
		expect(listAnswered("/c/.crux/requests", "b9/mail", fs).map((r) => r.id)).toEqual(["02"]);
		expect(listAnswered("/c/.crux/requests", "b9/app", fs)).toEqual([]);
	});
	it("defaults type and status", () => {
		expect(parseRequest("f", "---\nid: x\n---\n")).toMatchObject({ type: "task", status: "open" });
	});
});

describe("budget", () => {
	it("sums estimated tokens and flags the limit", () => {
		const fs = memoryFs({ "/a": "x".repeat(4000), "/b": "y".repeat(400) });
		const r = measureBaseContext(["/a", "/b", "/missing"], fs, 1000);
		expect(r.total).toBe(1100);
		expect(r.over).toBe(true);
		expect(r.files[2]).toMatchObject({ missing: true, tokens: 0 });
		expect(measureBaseContext(["/b"], fs).over).toBe(false);
	});
});

describe("delegate", () => {
	it("builds a json print-mode invocation without context files", () => {
		expect(buildDelegateArgs({ task: "do x", systemPromptFile: "/tmp/p.md", model: "m", tools: ["read", "bash"] })).toEqual([
			"--mode",
			"json",
			"-p",
			"--no-session",
			"--no-context-files",
			"--model",
			"m",
			"--tools",
			"read,bash",
			"--append-system-prompt",
			"/tmp/p.md",
			"Task: do x",
		]);
	});
	it("writes the load order and task record into the system prompt", () => {
		const prompt = buildDelegateSystemPrompt({
			role: "kubernetes-admin",
			taskId: "T-1",
			frameworkHome: "/u/.crux",
			crux: { kind: "project", projectRoot: "/p", cruxDir: "/p/.crux", workspaceDir: "/p/.crux/workspace" },
		});
		expect(prompt).toContain("3. /u/.crux/agents/kubernetes-admin/AGENT.md");
		expect(prompt).toContain("## T-1");
		expect(prompt).toContain("/p/.crux/workspace/kubernetes-admin/TODO.md");
	});
	it("folds the final assistant message out of a JSON event stream", () => {
		const r = foldJsonLines([
			JSON.stringify({ type: "message_start" }),
			JSON.stringify({ type: "message_end", message: { role: "user", content: [{ type: "text", text: "task" }] } }),
			JSON.stringify({ type: "message_end", message: { role: "assistant", content: [{ type: "text", text: "first" }], stopReason: "toolUse" } }),
			"not json",
			JSON.stringify({ type: "message_end", message: { role: "assistant", content: [{ type: "text", text: "final" }], stopReason: "stop" } }),
		]);
		expect(r).toEqual({ output: "final", stopReason: "stop", errorMessage: undefined, turns: 2 });
	});
	it("ulid is 26 chars and time-sortable", () => {
		const a = ulid(1000);
		const b = ulid(2000);
		expect(a).toHaveLength(26);
		expect(a.slice(0, 10) < b.slice(0, 10)).toBe(true);
	});
});
