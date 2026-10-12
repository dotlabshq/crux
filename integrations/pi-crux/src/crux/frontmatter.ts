/**
 * Frontmatter parser for the subset of YAML Crux files use:
 *   key: value
 *   key: [a, b]
 *   key:
 *     - a
 *     - b
 *   key: >      (folded block, joined with spaces)
 * Comments after `#` are stripped from values. No nested maps.
 */
export type FrontmatterValue = string | string[];

export interface Frontmatter {
	data: Record<string, FrontmatterValue>;
	body: string;
}

export function parseFrontmatter(text: string): Frontmatter {
	const lines = text.split(/\r?\n/);
	if (lines[0] !== "---") return { data: {}, body: text };

	const data: Record<string, FrontmatterValue> = {};
	let i = 1;
	let currentList: string[] | undefined;
	let currentBlock: { key: string; parts: string[] } | undefined;

	for (; i < lines.length; i++) {
		const line = lines[i];
		if (line === "---") {
			i++;
			break;
		}
		if (currentBlock) {
			if (/^\s+\S/.test(line)) {
				currentBlock.parts.push(line.trim());
				continue;
			}
			data[currentBlock.key] = currentBlock.parts.join(" ");
			currentBlock = undefined;
		}
		const item = line.match(/^\s+-\s*(.*?)\s*$/);
		if (item && currentList) {
			const value = stripComment(item[1]);
			if (value !== "") currentList.push(value);
			continue;
		}
		currentList = undefined;
		const kv = line.match(/^([A-Za-z0-9_-]+)\s*:\s*(.*)$/);
		if (!kv) continue;
		const key = kv[1];
		const raw = stripComment(kv[2]);
		if (raw === ">" || raw === "|") {
			currentBlock = { key, parts: [] };
		} else if (raw.startsWith("[")) {
			data[key] = raw
				.replace(/^\[|\]$/g, "")
				.split(",")
				.map((s) => unquote(s.trim()))
				.filter((s) => s !== "");
		} else if (raw === "") {
			currentList = [];
			data[key] = currentList;
		} else {
			data[key] = unquote(raw);
		}
	}
	if (currentBlock) data[currentBlock.key] = currentBlock.parts.join(" ");
	return { data, body: lines.slice(i).join("\n") };
}

export function asString(value: FrontmatterValue | undefined): string {
	if (value === undefined) return "";
	return Array.isArray(value) ? value.join(", ") : value;
}

export function asList(value: FrontmatterValue | undefined): string[] {
	if (value === undefined || value === "") return [];
	return Array.isArray(value) ? value : [value];
}

function stripComment(value: string): string {
	// A `#` preceded by whitespace starts a comment; `#` inside quotes is kept.
	const quoted = value.startsWith('"') || value.startsWith("'");
	if (quoted) return value;
	return value.replace(/\s+#.*$/, "").trim();
}

function unquote(value: string): string {
	if (value.length >= 2 && ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'")))) {
		return value.slice(1, -1);
	}
	return value;
}
