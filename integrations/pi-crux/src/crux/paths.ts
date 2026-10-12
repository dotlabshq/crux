import * as path from "node:path";

/** Normalise to an absolute, forward-slash path with no trailing slash. */
export function normalizePath(p: string, cwd?: string): string {
	let abs = path.isAbsolute(p) ? p : path.resolve(cwd ?? process.cwd(), p);
	abs = path.normalize(abs).replace(/\\/g, "/");
	if (abs.length > 1 && abs.endsWith("/")) abs = abs.slice(0, -1);
	return abs;
}

/** Whether `p` is `root` or lies below it. Both must be normalised. */
export function isUnder(p: string, root: string): boolean {
	return p === root || p.startsWith(root === "/" ? "/" : `${root}/`);
}

/** cwd, its parent, … up to the filesystem root. */
export function ancestors(p: string): string[] {
	const out: string[] = [];
	let dir = normalizePath(p);
	for (;;) {
		out.push(dir);
		const parent = path.dirname(dir);
		if (parent === dir) break;
		dir = parent;
	}
	return out;
}

/**
 * Glob → RegExp. `**` matches across separators, `*` within one segment.
 * Patterns are matched against whole normalised paths.
 */
export function globToRegExp(glob: string): RegExp {
	let re = "";
	for (let i = 0; i < glob.length; i++) {
		const c = glob[i];
		if (c === "*") {
			if (glob[i + 1] === "*") {
				re += ".*";
				i++;
				if (glob[i + 1] === "/") i++;
			} else {
				re += "[^/]*";
			}
		} else if ("\\^$.|?+()[]{}".includes(c)) {
			re += `\\${c}`;
		} else {
			re += c;
		}
	}
	return new RegExp(`^${re}$`);
}

export function matchesGlob(p: string, glob: string): boolean {
	return globToRegExp(glob).test(p);
}
