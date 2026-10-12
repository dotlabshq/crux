import { matchesGlob, normalizePath } from "./paths.ts";
import { type CruxContext, ownerOf } from "./resolve.ts";
import { type RuleScope, type RuleVars, WRITE_RULES, type WriteRule, expandPatterns } from "./rules.ts";

export interface GuardContext {
	/** Active Crux role: "coordinator" or a role id. */
	role: string;
	frameworkHome: string;
	crux?: CruxContext;
}

export interface Decision {
	allowed: boolean;
	path?: string;
	rule?: string;
	reason?: string;
}

/** Which rule scopes apply to this session. */
export function activeScopes(g: GuardContext): RuleScope[] {
	const scopes: RuleScope[] = ["always"];
	const c = g.crux;
	if (c?.kind === "company") {
		if (c.team?.id === c.coordinatorId) scopes.push("coordinator");
		else if (c.team) scopes.push("team");
	} else if (g.role === "coordinator") {
		scopes.push("coordinator");
	}
	return scopes;
}

export function ruleVars(g: GuardContext): RuleVars {
	const c = g.crux;
	const vars: RuleVars = { frameworkHome: normalizePath(g.frameworkHome) };
	if (c) {
		vars.crux = c.cruxDir;
		vars.workspace = c.workspaceDir;
	}
	if (c?.kind === "company") {
		vars.companyRoot = c.companyRoot;
		if (c.team) {
			vars.team = c.team.id;
			vars.owns = c.team.owns;
			vars.also = c.team.also;
		}
	}
	return vars;
}

/** Decide one write target against WRITE_RULES. */
export function checkWrite(target: string, g: GuardContext, rules: WriteRule[] = WRITE_RULES): Decision {
	const path = normalizePath(target);
	const scopes = activeScopes(g);
	const vars = ruleVars(g);
	for (const rule of rules) {
		if (!scopes.includes(rule.scope)) continue;
		if (!expandPatterns(rule.patterns, vars).some((p) => matchesGlob(path, p))) continue;
		if (rule.effect === "allow") return { allowed: true, path, rule: rule.id };
		return { allowed: false, path, rule: rule.id, reason: fillReason(rule.reason, path, g) };
	}
	return { allowed: true, path };
}

function fillReason(reason: string, path: string, g: GuardContext): string {
	const owner = g.crux?.kind === "company" ? ownerOf(g.crux.teams, path)?.id : undefined;
	return reason.replace(/\{owner\}/g, owner ?? "another team");
}

/**
 * Paths a tool call would write. `write`/`edit` are exact; `bash` is a
 * best-effort scan of the command text for redirects and file-mutating
 * commands — it cannot see what a script or a program writes.
 */
export function writeTargets(toolName: string, input: Record<string, unknown>, cwd: string): string[] {
	if (toolName === "write" || toolName === "edit") {
		const p = input.path ?? input.file_path;
		return typeof p === "string" ? [normalizePath(p, cwd)] : [];
	}
	if (toolName === "bash" || toolName === "powershell") {
		const command = typeof input.command === "string" ? input.command : "";
		return bashWriteTargets(command).map((p) => normalizePath(p, cwd));
	}
	return [];
}

const BASH_PATTERNS: RegExp[] = [
	/(?:^|[\s;&|(])>{1,2}\s*([^\s;&|)]+)/g, // > file, >> file
	/\btee\s+(?:-[a-z]+\s+)*([^\s;&|]+)/g,
	/\bsed\s+(?:-[a-zE]+\s+)*-i\S*\s+(?:(?:''|"")\s+)?(?:-e\s+)?(?:'[^']*'|"[^"]*"|\S+)\s+([^\s;&|]+)/g, // sed -i[.bak] [''] script file
	/\b(?:cp|mv)\s+(?:-\S+\s+)*\S+\s+([^\s;&|]+)/g,
	/\b(?:rm|rmdir|touch|mkdir|truncate|chmod|chown)\s+(?:-\S+\s+)*((?:[^\s;&|]+\s*)+)/g,
];

export function bashWriteTargets(command: string): string[] {
	const targets = new Set<string>();
	for (const re of BASH_PATTERNS) {
		re.lastIndex = 0;
		for (const m of command.matchAll(re)) {
			for (const raw of m[1].split(/\s+/)) {
				const p = raw.replace(/^['"]|['"]$/g, "");
				if (p && !p.startsWith("-") && p !== "/dev/null" && !/^&\d/.test(p)) targets.add(p);
			}
		}
	}
	return [...targets];
}

/** Decide a whole tool call: the first denied target blocks it. */
export function checkToolCall(toolName: string, input: Record<string, unknown>, cwd: string, g: GuardContext): Decision {
	for (const target of writeTargets(toolName, input, cwd)) {
		const d = checkWrite(target, g);
		if (!d.allowed) return d;
	}
	return { allowed: true };
}
