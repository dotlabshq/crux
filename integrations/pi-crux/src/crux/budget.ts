import type { CruxFs } from "./fs.ts";
import type { CruxContext } from "./resolve.ts";

/** README "Context Loading Order": hard limit before execution begins. */
export const BASE_CONTEXT_BUDGET = 8000;

/** Rough: four characters per token, rounded up. */
export function estimateTokens(text: string): number {
	return Math.ceil(text.length / 4);
}

/**
 * The files every agent loads "always" (README steps 1–5), for a role.
 * In a company the per-role workspace is the team's workspace.
 */
export function baseContextFiles(ctx: CruxContext, role: string, frameworkHome: string): string[] {
	const scope = ctx.kind === "company" && ctx.team ? ctx.team.id : role;
	return [
		`${ctx.cruxDir}/CONSTITUTION.md`,
		`${ctx.cruxDir}/SOUL.md`,
		`${frameworkHome}/agents/${role}/AGENT.md`,
		`${ctx.workspaceDir}/${scope}/MEMORY.md`,
		`${ctx.workspaceDir}/${scope}/TODO.md`,
	];
}

export interface BudgetReport {
	files: { path: string; tokens: number; missing: boolean }[];
	total: number;
	budget: number;
	over: boolean;
}

export function measureBaseContext(files: string[], fs: CruxFs, budget = BASE_CONTEXT_BUDGET): BudgetReport {
	const rows = files.map((path) => {
		const missing = !fs.exists(path);
		return { path, missing, tokens: missing ? 0 : estimateTokens(fs.readFile(path)) };
	});
	const total = rows.reduce((n, r) => n + r.tokens, 0);
	return { files: rows, total, budget, over: total > budget };
}

export function formatTokens(n: number): string {
	return n >= 1000 ? `${(n / 1000).toFixed(1)}k` : String(n);
}
