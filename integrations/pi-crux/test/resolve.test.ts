import { describe, expect, it } from "vitest";
import { memoryFs } from "../src/crux/fs.ts";
import { parseFrontmatter } from "../src/crux/frontmatter.ts";
import { ownerOf, parseRegistry, resolveCrux, teamForDir } from "../src/crux/resolve.ts";

const HOME = "/u/.crux";

function company() {
	return memoryFs({
		[`${HOME}/companies.toml`]: `[b9]\nroot = "/ws/b9/company"\n\n[other]\nroot = "/ws/other"\n`,
		"/ws/b9/company/.crux/COMPANY.md": "---\nid: b9\nname: base9\ncoordinator: coordinator\n---\nx\n",
		"/ws/b9/company/.crux/teams/coordinator/TEAM.md": "---\nid: coordinator\nroles: []\nowns:\n  - .\nalso: []\n---\n",
		"/ws/b9/company/.crux/teams/mail/TEAM.md":
			"---\nid: mail\nroles:\n  - linux-admin\n  - platform-engineer\nowns:\n  - ../maticmail\nalso:\n  - ../nixscale/README.md\n---\n",
		"/ws/b9/company/.crux/teams/app/TEAM.md": "---\nid: app\nroles: [backend-developer]\nowns:\n  - /ws/b9/nixscale\n---\n",
		"/ws/b9/maticmail/docs/a.md": "",
		"/ws/b9/nixscale/apps/api/x.ts": "",
		"/ws/b9/nixscale/README.md": "",
		"/ws/elsewhere/.crux/company": "b9\n",
		"/ws/elsewhere/src/x": "",
		"/ws/proj/.crux/workspace/TODO.md": "",
		"/ws/proj/src/x": "",
		"/u/.crux/agents/x/AGENT.md": "",
		"/u/src/x": "",
	});
}

describe("resolveCrux", () => {
	it("walks up to COMPANY.md and picks the coordinator at the root", () => {
		const ctx = resolveCrux("/ws/b9/company/.crux/teams", { frameworkHome: HOME, fs: company() });
		expect(ctx?.kind).toBe("company");
		if (ctx?.kind !== "company") return;
		expect(ctx.via).toBe("walk-up");
		expect(ctx.companyId).toBe("b9");
		expect(ctx.team?.id).toBe("coordinator");
		expect(ctx.teamVia).toBe("owns");
	});

	it("finds a sibling code repository through the registry (owns: ../repo)", () => {
		const ctx = resolveCrux("/ws/b9/maticmail/docs", { frameworkHome: HOME, fs: company() });
		expect(ctx?.kind).toBe("company");
		if (ctx?.kind !== "company") return;
		expect(ctx.via).toBe("registry");
		expect(ctx.team?.id).toBe("mail");
		expect(ctx.team?.owns).toEqual(["/ws/b9/maticmail"]);
	});

	it("longest owns prefix wins over the coordinator's '.' and absolute paths work", () => {
		const ctx = resolveCrux("/ws/b9/nixscale/apps/api", { frameworkHome: HOME, fs: company() });
		expect(ctx?.kind === "company" && ctx.team?.id).toBe("app");
	});

	it("resolves a .crux/company marker through the registry", () => {
		const ctx = resolveCrux("/ws/elsewhere/src", { frameworkHome: HOME, fs: company() });
		expect(ctx?.kind === "company" && ctx.via).toBe("marker");
		expect(ctx?.kind === "company" && ctx.team).toBeUndefined();
	});

	it("falls back to a project .crux/", () => {
		const ctx = resolveCrux("/ws/proj/src", { frameworkHome: HOME, fs: company() });
		expect(ctx).toEqual({
			kind: "project",
			projectRoot: "/ws/proj",
			cruxDir: "/ws/proj/.crux",
			workspaceDir: "/ws/proj/.crux/workspace",
		});
	});

	it("never treats framework home as a project .crux/", () => {
		expect(resolveCrux("/u/src", { frameworkHome: HOME, fs: company() })).toBeUndefined();
	});
});

describe("teamForDir / ownerOf", () => {
	const teams = [
		{ id: "a", roles: [], skills: [], owns: ["/r"], also: [], file: "" },
		{ id: "b", roles: [], skills: [], owns: ["/r/sub"], also: ["/r/README.md"], file: "" },
	];
	it("prefers the deeper owner", () => {
		expect(teamForDir(teams, "/r/sub/x")?.team.id).toBe("b");
		expect(teamForDir(teams, "/r/x")?.team.id).toBe("a");
		expect(ownerOf(teams, "/r/sub/deep/file")?.id).toBe("b");
	});
	it("uses a single also match only when nothing owns the path", () => {
		const only = [{ id: "b", roles: [], skills: [], owns: ["/elsewhere"], also: ["/r/README.md"], file: "" }];
		expect(teamForDir(only, "/r/README.md")?.via).toBe("also");
		expect(teamForDir(only, "/r")).toBeUndefined();
	});
});

describe("parsers", () => {
	it("reads companies.toml", () => {
		expect(parseRegistry('[a]\nroot = "/x/a"\n[b-c]\nroot = "/y/"\n')).toEqual({ a: "/x/a", "b-c": "/y" });
	});
	it("reads folded, inline-list and block-list frontmatter", () => {
		const { data, body } = parseFrontmatter(
			"---\nname: x\ndescription: >\n  one\n  two\nroles: [a, b]\nowns:\n  - p # comment\n  - q\nmode: subagent # c\n---\nbody\n",
		);
		expect(data).toEqual({ name: "x", description: "one two", roles: ["a", "b"], owns: ["p", "q"], mode: "subagent" });
		expect(body).toBe("body\n");
	});
});
