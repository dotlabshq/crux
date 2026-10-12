/**
 * Write-scope rules, as data. One structure, so a later version can read
 * the same rules from markdown (README "Coordinator write scope",
 * skills/crux-team "Ownership") instead of this file.
 *
 * Evaluation: the first rule whose scope applies and whose pattern matches
 * decides. Sessions with no applicable deny rule may write anywhere except
 * framework home.
 *
 * Placeholders expand against the session:
 *   {frameworkHome}  $HOME/.crux
 *   {crux}           .crux of the project or company
 *   {workspace}      {crux}/workspace
 *   {companyRoot}    company root (company sessions only)
 *   {team}           team id (team sessions only)
 *   {owns} {also}    one pattern per owned / shared path
 */
export type RuleScope = "always" | "coordinator" | "team";

export interface WriteRule {
	id: string;
	scope: RuleScope;
	effect: "allow" | "deny";
	patterns: string[];
	/** `{owner}` is replaced with the owning team, when known. */
	reason: string;
	source: string;
}

export const WRITE_RULES: WriteRule[] = [
	{
		id: "framework-home-read-only",
		scope: "always",
		effect: "deny",
		patterns: ["{frameworkHome}", "{frameworkHome}/**"],
		reason: "Framework home is read-only during project work; project facts belong in .crux/.",
		source: "skills/crux-coordinator/SKILL.md § Path Model",
	},
	{
		id: "coordinator-control-plane",
		scope: "coordinator",
		effect: "allow",
		patterns: [
			"{workspace}/MANIFEST.md",
			"{workspace}/TODO.md",
			"{workspace}/inbox.md",
			"{workspace}/MEMORY.md",
			"{workspace}/sessions/**",
			"{workspace}/coordinator/**",
			"{workspace}/*/TODO.md",
			"{crux}/bus/**",
		],
		reason: "",
		source: "README § Task State Model — coordinator may write",
	},
	{
		id: "coordinator-company-root",
		scope: "coordinator",
		effect: "allow",
		patterns: ["{companyRoot}/AGENTS.md", "{crux}/teams/**", "{crux}/requests/**", "{crux}/COMPANY.md"],
		reason: "",
		source: "skills/crux-team/SKILL.md § Coordinator Team",
	},
	{
		id: "coordinator-no-domain-state",
		scope: "coordinator",
		effect: "deny",
		patterns: [
			"{workspace}/*/MEMORY.md",
			"{workspace}/*/NOTES.md",
			"{workspace}/*/output/**",
			"{crux}/docs/**",
			"{crux}/summaries/**",
			"{crux}/decisions/**",
		],
		reason: "The coordinator does not write domain state; delegate this with crux_delegate to the owning role.",
		source: "README § Task State Model — coordinator must not write",
	},
	{
		id: "coordinator-no-domain-files",
		scope: "coordinator",
		effect: "deny",
		patterns: ["**"],
		reason: "Domain-owned project file; the coordinator delegates (crux_delegate) or opens a request to the owning team.",
		source: "README § Task State Model — coordinator must not write",
	},
	{
		id: "team-owned-paths",
		scope: "team",
		effect: "allow",
		patterns: ["{owns}", "{owns}/**", "{also}", "{also}/**", "{crux}/requests/**", "{workspace}/{team}/**"],
		reason: "",
		source: "skills/crux-team/SKILL.md § Ownership rules 2 and 5",
	},
	{
		id: "team-not-owned",
		scope: "team",
		effect: "deny",
		patterns: ["**"],
		reason: "Not owned by this team ({owner} owns it): open a request in .crux/requests/{owner}/ instead of editing.",
		source: "skills/crux-team/SKILL.md § Ownership rule 3",
	},
];

export interface RuleVars {
	frameworkHome: string;
	crux?: string;
	workspace?: string;
	companyRoot?: string;
	team?: string;
	owns?: string[];
	also?: string[];
}

/** Expand placeholders; `{owns}`/`{also}` fan out to one pattern per path. */
export function expandPatterns(patterns: string[], vars: RuleVars): string[] {
	const out: string[] = [];
	for (const pattern of patterns) {
		const lists: [string, string[] | undefined][] = [
			["{owns}", vars.owns],
			["{also}", vars.also],
		];
		const fanned = lists.find(([ph]) => pattern.includes(ph));
		if (fanned) {
			for (const p of fanned[1] ?? []) out.push(substitute(pattern.replace(fanned[0], p), vars));
			continue;
		}
		const expanded = substitute(pattern, vars);
		if (!expanded.includes("{")) out.push(expanded);
	}
	return out;
}

function substitute(pattern: string, vars: RuleVars): string {
	return pattern
		.replace("{frameworkHome}", vars.frameworkHome)
		.replace("{crux}", vars.crux ?? "{crux}")
		.replace("{workspace}", vars.workspace ?? "{workspace}")
		.replace("{companyRoot}", vars.companyRoot ?? "{companyRoot}")
		.replace("{team}", vars.team ?? "{team}");
}
