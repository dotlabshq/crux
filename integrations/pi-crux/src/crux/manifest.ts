/**
 * MANIFEST.md readers. The Agents table:
 *
 *   | Role ID | Tier | Status | Docs | Last Session |
 *   |---|---|---|---|---|
 *   | `kubernetes-admin` | infra | onboarded | ✓ | 01J… |
 *
 * In a company the first column may be qualified: `base9/mail:linux-admin`.
 */
export interface ManifestAgent {
	id: string;
	tier: string;
	status: string;
}

export function parseManifestAgents(text: string): ManifestAgent[] {
	const section = sectionLines(text, "Agents");
	const agents: ManifestAgent[] = [];
	for (const line of section) {
		if (!line.startsWith("|")) continue;
		const cells = line
			.split("|")
			.slice(1, -1)
			.map((c) => c.trim().replace(/^`|`$/g, ""));
		if (cells.length < 3) continue;
		if (cells[0] === "Role ID" || /^-+$/.test(cells[0])) continue;
		if (cells[0].startsWith("{{")) continue;
		agents.push({ id: cells[0], tier: cells[1], status: cells[2] });
	}
	return agents;
}

/** Status of `role`, optionally scoped to a qualified team id (`company/team`). */
export function agentStatus(agents: ManifestAgent[], role: string, team?: string): string | undefined {
	const candidates = team ? [`${team}:${role}`, `${team}/${role}`, role] : [role];
	for (const id of candidates) {
		const hit = agents.find((a) => a.id === id);
		if (hit) return hit.status;
	}
	return undefined;
}

export function isOnboarded(agents: ManifestAgent[], role: string, team?: string): boolean {
	return agentStatus(agents, role, team) === "onboarded";
}

/** Lines between `## <heading>` and the next `## ` heading. */
export function sectionLines(text: string, heading: string): string[] {
	const lines = text.split(/\r?\n/);
	const out: string[] = [];
	let inside = false;
	for (const line of lines) {
		if (/^##\s/.test(line)) {
			if (inside) break;
			inside = line.replace(/^##\s+/, "").trim() === heading;
			continue;
		}
		if (inside) out.push(line);
	}
	return out;
}
