/**
 * TODO.md records (templates/TODO.template.md):
 *
 *   ## T-01J…
 *   - title: …
 *   - status: todo | in_progress | waiting | blocked | done | canceled
 *   - owner: role
 *   - evidence_refs:
 *     - path
 */
export const TODO_STATUSES = ["todo", "in_progress", "waiting", "blocked", "done", "canceled"] as const;
export type TodoStatus = (typeof TODO_STATUSES)[number];

export interface TodoRecord {
	id: string;
	fields: Record<string, string>;
	evidence_refs: string[];
}

export function parseTodos(text: string): TodoRecord[] {
	const records: TodoRecord[] = [];
	let current: TodoRecord | undefined;
	let inRefs = false;
	for (const line of text.split(/\r?\n/)) {
		const heading = line.match(/^##\s+(T-\S+)\s*$/);
		if (heading) {
			current = { id: heading[1], fields: {}, evidence_refs: [] };
			records.push(current);
			inRefs = false;
			continue;
		}
		if (/^##?\s/.test(line) || line.trim() === "---") {
			current = undefined;
			inRefs = false;
			continue;
		}
		if (!current) continue;
		const ref = line.match(/^\s{2,}-\s*(.+?)\s*$/);
		if (ref && inRefs) {
			current.evidence_refs.push(ref[1]);
			continue;
		}
		const field = line.match(/^-\s*([a-z_]+)\s*:\s*(.*?)\s*$/);
		if (field) {
			inRefs = field[1] === "evidence_refs";
			if (!inRefs) current.fields[field[1]] = field[2];
		}
	}
	return records;
}

export function todoStatus(text: string, id: string): string | undefined {
	return parseTodos(text).find((r) => r.id === id)?.fields.status;
}

/** A field value on one line: the format is one `- key: value` line per field. */
export function oneLine(value: string): string {
	return value.replace(/\s*\r?\n\s*/g, " ").trim();
}

export function formatTodo(record: TodoRecord): string {
	const lines = [`## ${record.id}`];
	for (const [key, value] of Object.entries(record.fields)) lines.push(`- ${key}: ${oneLine(value)}`);
	if (record.evidence_refs.length > 0) {
		lines.push("- evidence_refs:");
		for (const ref of record.evidence_refs) lines.push(`  - ${ref}`);
	}
	return lines.join("\n");
}

/** Insert a record before the trailing `## Rules` block, or append. */
export function appendTodo(text: string, record: TodoRecord): string {
	const block = `${formatTodo(record)}\n`;
	const marker = text.search(/\n---\n\n## Rules\b/);
	if (marker >= 0) {
		const before = text.slice(0, marker).replace(/\s*$/, "");
		return `${before}\n\n${block}${text.slice(marker)}`;
	}
	const trimmed = text.replace(/\s*$/, "");
	return trimmed ? `${trimmed}\n\n${block}` : block;
}

/** Fresh TODO.md body when the role has none yet. */
export function emptyTodo(scope: string, date: string): string {
	return [
		"# TODO",
		"",
		`> Canonical task state for \`${scope}\`. Created ${date} by pi-crux.`,
		"",
		"---",
		"",
		"## Task Records",
		"",
	].join("\n");
}
