import * as path from "node:path";
import type { CruxFs } from "./fs.ts";
import { asList, asString, parseFrontmatter } from "./frontmatter.ts";
import { ancestors, isUnder, normalizePath } from "./paths.ts";

/**
 * Who am I? — the resolution step of skills/crux-team/SKILL.md, in code.
 *
 *   1. Company: walk up to .crux/COMPANY.md; else a .crux/company marker →
 *      registry; else a registered company with a team that owns cwd.
 *   2. Team: longest `owns` prefix; else a single `also` match; else the
 *      coordinator team when cwd is the company root.
 *   3. Project: nearest ancestor with .crux/ that is not framework home.
 */

export interface Team {
	id: string;
	roles: string[];
	skills: string[];
	/** Absolute, normalised. */
	owns: string[];
	/** Absolute, normalised. */
	also: string[];
	file: string;
}

export interface CompanyContext {
	kind: "company";
	companyId: string;
	companyRoot: string;
	coordinatorId: string;
	teams: Team[];
	/** Undefined when no team owns cwd (the skill says: ask). */
	team?: Team;
	teamVia?: "owns" | "also" | "root";
	/** How the company was found. */
	via: "walk-up" | "marker" | "registry";
	cruxDir: string;
	workspaceDir: string;
}

export interface ProjectContext {
	kind: "project";
	projectRoot: string;
	cruxDir: string;
	workspaceDir: string;
}

export type CruxContext = CompanyContext | ProjectContext;

export interface ResolveOptions {
	frameworkHome: string;
	fs: CruxFs;
}

export function resolveCrux(cwd: string, opts: ResolveOptions): CruxContext | undefined {
	const dir = normalizePath(cwd);
	const frameworkHome = normalizePath(opts.frameworkHome);
	const { fs } = opts;

	let companyRoot: string | undefined;
	let via: CompanyContext["via"] | undefined;

	for (const a of ancestors(dir)) {
		if (fs.exists(`${a}/.crux/COMPANY.md`)) {
			companyRoot = a;
			via = "walk-up";
			break;
		}
	}
	if (!companyRoot) {
		const registry = readRegistry(frameworkHome, fs);
		for (const a of ancestors(dir)) {
			const marker = `${a}/.crux/company`;
			if (fs.exists(marker) && !fs.isDirectory(marker)) {
				const id = fs.readFile(marker).trim();
				if (registry[id] && fs.exists(`${registry[id]}/.crux/COMPANY.md`)) {
					companyRoot = registry[id];
					via = "marker";
				}
				break;
			}
		}
		if (!companyRoot) {
			for (const root of Object.values(registry)) {
				if (!fs.exists(`${root}/.crux/COMPANY.md`)) continue;
				const teams = loadTeams(root, fs);
				if (teamForDir(teams, dir)) {
					companyRoot = root;
					via = "registry";
					break;
				}
			}
		}
	}

	if (companyRoot && via) {
		const company = parseFrontmatter(fs.readFile(`${companyRoot}/.crux/COMPANY.md`)).data;
		const teams = loadTeams(companyRoot, fs);
		const coordinatorId = asString(company.coordinator) || "coordinator";
		const hit = teamForDir(teams, dir);
		let team = hit?.team;
		let teamVia: CompanyContext["teamVia"] = hit?.via;
		if (!team && dir === companyRoot) {
			team = teams.find((t) => t.id === coordinatorId);
			teamVia = team ? "root" : undefined;
		}
		return {
			kind: "company",
			companyId: asString(company.id) || path.basename(companyRoot),
			companyRoot,
			coordinatorId,
			teams,
			team,
			teamVia,
			via,
			cruxDir: `${companyRoot}/.crux`,
			workspaceDir: `${companyRoot}/.crux/workspace`,
		};
	}

	for (const a of ancestors(dir)) {
		const crux = `${a}/.crux`;
		if (crux === frameworkHome) continue;
		if (fs.isDirectory(crux)) {
			return { kind: "project", projectRoot: a, cruxDir: crux, workspaceDir: `${crux}/workspace` };
		}
	}
	return undefined;
}

/** `[id]\nroot = "…"` blocks of companies.toml → { id: root }. */
export function parseRegistry(text: string): Record<string, string> {
	const out: Record<string, string> = {};
	let current: string | undefined;
	for (const line of text.split(/\r?\n/)) {
		const section = line.match(/^\s*\[\s*([^\]]+?)\s*\]/);
		if (section) {
			current = section[1];
			continue;
		}
		const root = line.match(/^\s*root\s*=\s*"([^"]*)"/);
		if (current && root) out[current] = normalizePath(root[1]);
	}
	return out;
}

export function readRegistry(frameworkHome: string, fs: CruxFs): Record<string, string> {
	const file = `${frameworkHome}/companies.toml`;
	return fs.exists(file) ? parseRegistry(fs.readFile(file)) : {};
}

export function loadTeams(companyRoot: string, fs: CruxFs): Team[] {
	const teamsDir = `${companyRoot}/.crux/teams`;
	if (!fs.isDirectory(teamsDir)) return [];
	const teams: Team[] = [];
	for (const name of fs.readDir(teamsDir).sort()) {
		const file = `${teamsDir}/${name}/TEAM.md`;
		if (!fs.exists(file)) continue;
		const { data } = parseFrontmatter(fs.readFile(file));
		const abs = (p: string) => normalizePath(path.isAbsolute(p) ? p : path.join(companyRoot, p));
		teams.push({
			id: asString(data.id) || name,
			roles: asList(data.roles),
			skills: asList(data.skills),
			owns: asList(data.owns).map(abs),
			also: asList(data.also).map(abs),
			file,
		});
	}
	return teams;
}

/** Longest `owns` prefix wins; otherwise exactly one `also` match. */
export function teamForDir(teams: Team[], dir: string): { team: Team; via: "owns" | "also"; path: string } | undefined {
	let best: { team: Team; via: "owns" | "also"; path: string } | undefined;
	const alsoHits: { team: Team; via: "also"; path: string }[] = [];
	for (const team of teams) {
		for (const owned of team.owns) {
			if (isUnder(dir, owned) && (!best || owned.length > best.path.length)) {
				best = { team, via: "owns", path: owned };
			}
		}
		for (const shared of team.also) {
			if (isUnder(dir, shared)) alsoHits.push({ team, via: "also", path: shared });
		}
	}
	if (best) return best;
	if (alsoHits.length === 1) return alsoHits[0];
	return undefined;
}

/** The team that owns a file or directory, by longest `owns` prefix. */
export function ownerOf(teams: Team[], target: string): Team | undefined {
	let best: { team: Team; len: number } | undefined;
	for (const team of teams) {
		for (const owned of team.owns) {
			if (isUnder(target, owned) && (!best || owned.length > best.len)) best = { team, len: owned.length };
		}
	}
	return best?.team;
}

export function qualifiedTeamId(ctx: CompanyContext): string | undefined {
	return ctx.team ? `${ctx.companyId}/${ctx.team.id}` : undefined;
}
