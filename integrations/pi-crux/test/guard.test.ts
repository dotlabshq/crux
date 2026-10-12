import { describe, expect, it } from "vitest";
import { activeScopes, bashWriteTargets, checkToolCall, checkWrite, type GuardContext } from "../src/crux/guard.ts";
import { globToRegExp } from "../src/crux/paths.ts";
import type { CompanyContext, ProjectContext } from "../src/crux/resolve.ts";
import { expandPatterns } from "../src/crux/rules.ts";

const HOME = "/u/.crux";

const project: ProjectContext = {
	kind: "project",
	projectRoot: "/p",
	cruxDir: "/p/.crux",
	workspaceDir: "/p/.crux/workspace",
};

const teams = [
	{ id: "coordinator", roles: [], skills: [], owns: ["/ws/company"], also: [], file: "" },
	{ id: "mail", roles: ["linux-admin"], skills: [], owns: ["/ws/maticmail"], also: ["/ws/nixscale/README.md"], file: "" },
	{ id: "app", roles: ["backend-developer"], skills: [], owns: ["/ws/nixscale"], also: [], file: "" },
];

function companyAs(teamId: string): CompanyContext {
	return {
		kind: "company",
		companyId: "b9",
		companyRoot: "/ws/company",
		coordinatorId: "coordinator",
		teams,
		team: teams.find((t) => t.id === teamId),
		via: "walk-up",
		cruxDir: "/ws/company/.crux",
		workspaceDir: "/ws/company/.crux/workspace",
	};
}

const coordinator: GuardContext = { role: "coordinator", frameworkHome: HOME, crux: project };
const agent: GuardContext = { role: "kubernetes-admin", frameworkHome: HOME, crux: project };
const mail: GuardContext = { role: "linux-admin", frameworkHome: HOME, crux: companyAs("mail") };
const companyCoordinator: GuardContext = { role: "coordinator", frameworkHome: HOME, crux: companyAs("coordinator") };

describe("glob", () => {
	it("matches ** across segments and * within one", () => {
		expect(globToRegExp("/a/**").test("/a/b/c")).toBe(true);
		expect(globToRegExp("/a/**").test("/a")).toBe(false);
		expect(globToRegExp("/w/*/TODO.md").test("/w/x/TODO.md")).toBe(true);
		expect(globToRegExp("/w/*/TODO.md").test("/w/x/y/TODO.md")).toBe(false);
		expect(globToRegExp("/a.b").test("/aXb")).toBe(false);
	});
});

describe("scopes and patterns", () => {
	it("picks scopes from role and team", () => {
		expect(activeScopes(coordinator)).toEqual(["always", "coordinator"]);
		expect(activeScopes(agent)).toEqual(["always"]);
		expect(activeScopes(mail)).toEqual(["always", "team"]);
		expect(activeScopes(companyCoordinator)).toEqual(["always", "coordinator"]);
	});
	it("fans {owns}/{also} out and drops patterns with unresolved placeholders", () => {
		expect(expandPatterns(["{owns}/**", "{companyRoot}/AGENTS.md", "{crux}/x"], { frameworkHome: HOME, owns: ["/a", "/b"], crux: "/c" })).toEqual([
			"/a/**",
			"/b/**",
			"/c/x",
		]);
	});
});

describe("coordinator write scope (project)", () => {
	it.each([
		["/p/.crux/workspace/MANIFEST.md", true],
		["/p/.crux/workspace/TODO.md", true],
		["/p/.crux/workspace/inbox.md", true],
		["/p/.crux/workspace/kubernetes-admin/TODO.md", true],
		["/p/.crux/workspace/sessions/01/scratch.md", true],
		["/p/.crux/bus/broadcast.jsonl", true],
		["/p/.crux/workspace/kubernetes-admin/MEMORY.md", false],
		["/p/.crux/workspace/kubernetes-admin/NOTES.md", false],
		["/p/.crux/workspace/kubernetes-admin/output/report.md", false],
		["/p/.crux/docs/cluster.md", false],
		["/p/.crux/decisions/x.md", false],
		["/p/src/main.ts", false],
		["/u/.crux/agents/x/AGENT.md", false],
	])("%s allowed=%s", (path, allowed) => {
		expect(checkWrite(path, coordinator).allowed).toBe(allowed);
	});
	it("names the rule and a delegation hint", () => {
		const d = checkWrite("/p/.crux/docs/cluster.md", coordinator);
		expect(d.rule).toBe("coordinator-no-domain-state");
		expect(d.reason).toContain("crux_delegate");
	});
});

describe("domain role (project)", () => {
	it("may write project files and its own state, never framework home", () => {
		expect(checkWrite("/p/src/main.ts", agent).allowed).toBe(true);
		expect(checkWrite("/p/.crux/workspace/kubernetes-admin/MEMORY.md", agent).allowed).toBe(true);
		expect(checkWrite("/u/.crux/skills/x/SKILL.md", agent).rule).toBe("framework-home-read-only");
	});
});

describe("team ownership (company)", () => {
	it.each([
		["/ws/maticmail/docs/dns.md", true],
		["/ws/maticmail", true],
		["/ws/nixscale/README.md", true],
		["/ws/company/.crux/requests/app/2026-10-13-smtp.md", true],
		["/ws/company/.crux/requests/mail/2026-10-13-x.md", true],
		["/ws/company/.crux/workspace/mail/MEMORY.md", true],
		["/ws/nixscale/apps/api/mail.ts", false],
		["/ws/company/.crux/teams/mail/TEAM.md", false],
		["/ws/company/.crux/workspace/app/TODO.md", false],
		["/ws/company/AGENTS.md", false],
	])("mail → %s allowed=%s", (path, allowed) => {
		expect(checkWrite(path, mail).allowed).toBe(allowed);
	});
	it("tells the team who owns the path", () => {
		expect(checkWrite("/ws/nixscale/apps/api/mail.ts", mail).reason).toContain("app owns it");
		expect(checkWrite("/ws/nixscale/apps/api/mail.ts", mail).reason).toContain("requests/app/");
	});
	it("coordinator team keeps the board and teams but not domain repos", () => {
		expect(checkWrite("/ws/company/.crux/teams/qa/TEAM.md", companyCoordinator).allowed).toBe(true);
		expect(checkWrite("/ws/company/AGENTS.md", companyCoordinator).allowed).toBe(true);
		expect(checkWrite("/ws/company/.crux/workspace/inbox.md", companyCoordinator).allowed).toBe(true);
		expect(checkWrite("/ws/maticmail/x", companyCoordinator).allowed).toBe(false);
		expect(checkWrite("/ws/company/.crux/decisions/d.md", companyCoordinator).allowed).toBe(false);
	});
});

describe("tool calls", () => {
	it("reads write/edit paths relative to cwd", () => {
		expect(checkToolCall("write", { path: ".crux/docs/x.md", content: "" }, "/p", coordinator).allowed).toBe(false);
		expect(checkToolCall("edit", { path: "/p/.crux/workspace/TODO.md", edits: [] }, "/p", coordinator).allowed).toBe(true);
		expect(checkToolCall("read", { path: "/u/.crux/agents/x/AGENT.md" }, "/p", coordinator).allowed).toBe(true);
	});
	it("extracts obvious bash write targets", () => {
		expect(bashWriteTargets("echo hi > out.txt && cat a >> /tmp/log; ls 2>/dev/null")).toEqual(["out.txt", "/tmp/log"]);
		expect(bashWriteTargets("sed -i '' 's/a/b/' docs/x.md")).toEqual(["docs/x.md"]);
		expect(bashWriteTargets("cp -r src dest/ ; mv a.md b.md; rm -rf build dist")).toEqual(["dest/", "b.md", "build", "dist"]);
		expect(bashWriteTargets("echo hi | tee -a notes.md")).toEqual(["notes.md"]);
		expect(bashWriteTargets("git status")).toEqual([]);
	});
	it("blocks a bash redirect into a forbidden path", () => {
		const d = checkToolCall("bash", { command: "echo x > .crux/docs/gen.md" }, "/p", coordinator);
		expect(d.allowed).toBe(false);
		expect(d.path).toBe("/p/.crux/docs/gen.md");
	});
});
