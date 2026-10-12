import type { CruxFs } from "./fs.ts";
import { asString, parseFrontmatter } from "./frontmatter.ts";

/** One file on the board: .crux/requests/<team>/<date>-<slug>.md */
export interface RequestFile {
	file: string;
	id: string;
	from: string;
	to: string;
	type: string;
	status: string;
	opened: string;
	closed: string;
	title: string;
}

export function parseRequest(file: string, text: string): RequestFile {
	const { data, body } = parseFrontmatter(text);
	const title = body.split(/\r?\n/).find((l) => l.startsWith("# "))?.slice(2).trim() ?? "";
	return {
		file,
		id: asString(data.id),
		from: asString(data.from),
		to: asString(data.to),
		type: asString(data.type) || "task",
		status: asString(data.status) || "open",
		opened: asString(data.opened),
		closed: asString(data.closed),
		title,
	};
}

/** The requests addressed to a team, oldest first (filenames start with the date). */
export function listRequests(dir: string, fs: CruxFs): RequestFile[] {
	if (!fs.isDirectory(dir)) return [];
	return fs
		.readDir(dir)
		.filter((n) => n.endsWith(".md") && !n.startsWith("."))
		.sort()
		.map((n) => parseRequest(`${dir}/${n}`, fs.readFile(`${dir}/${n}`)));
}

/** Requests this team sent that the owner has answered and it has not picked up. */
export function listAnswered(requestsRoot: string, from: string, fs: CruxFs): RequestFile[] {
	if (!fs.isDirectory(requestsRoot)) return [];
	const out: RequestFile[] = [];
	for (const team of fs.readDir(requestsRoot)) {
		for (const r of listRequests(`${requestsRoot}/${team}`, fs)) {
			if (r.from === from && (r.status === "done" || r.status === "declined")) out.push(r);
		}
	}
	return out;
}
