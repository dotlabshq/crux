import { sectionLines } from "./manifest.ts";

/**
 * workspace/inbox.md — the human decision surface. Items are `- id:` blocks
 * under Pending Approvals, Blocked Questions and Operator Handoffs;
 * `*(none)*` and HTML comments are not items.
 */
export const INBOX_SECTIONS = ["Pending Approvals", "Blocked Questions", "Operator Handoffs"] as const;

export interface InboxItem {
	section: (typeof INBOX_SECTIONS)[number];
	id: string;
	fields: Record<string, string>;
}

export function parseInbox(text: string): InboxItem[] {
	const items: InboxItem[] = [];
	for (const section of INBOX_SECTIONS) {
		let current: InboxItem | undefined;
		for (const line of stripComments(sectionLines(text, section))) {
			const start = line.match(/^-\s*id\s*:\s*(\S+)/);
			if (start) {
				current = { section, id: start[1], fields: {} };
				items.push(current);
				continue;
			}
			const field = line.match(/^\s+([a-z_]+)\s*:\s*(.*?)\s*$/);
			if (field && current) current.fields[field[1]] = field[2];
			else if (!/^\s/.test(line)) current = undefined;
		}
	}
	return items;
}

export function pendingInbox(text: string): InboxItem[] {
	return parseInbox(text).filter((i) => (i.fields.status ?? "pending") === "pending");
}

function stripComments(lines: string[]): string[] {
	const out: string[] = [];
	let inComment = false;
	for (const line of lines) {
		if (inComment) {
			if (line.includes("-->")) inComment = false;
			continue;
		}
		if (line.trim().startsWith("<!--")) {
			if (!line.includes("-->")) inComment = true;
			continue;
		}
		out.push(line);
	}
	return out;
}
