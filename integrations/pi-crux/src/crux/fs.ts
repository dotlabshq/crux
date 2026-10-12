import * as nfs from "node:fs";

/**
 * Minimal filesystem view used by every pure Crux module, so tests can run
 * against an in-memory tree and the extension against node:fs.
 */
export interface CruxFs {
	exists(path: string): boolean;
	isDirectory(path: string): boolean;
	readFile(path: string): string;
	readDir(path: string): string[];
}

export const nodeFs: CruxFs = {
	exists: (p) => nfs.existsSync(p),
	isDirectory: (p) => {
		try {
			return nfs.statSync(p).isDirectory();
		} catch {
			return false;
		}
	},
	readFile: (p) => nfs.readFileSync(p, "utf8"),
	readDir: (p) => nfs.readdirSync(p),
};

/** In-memory tree for tests: keys are absolute file paths, values their text. */
export function memoryFs(files: Record<string, string>): CruxFs {
	const dirs = new Set<string>();
	for (const file of Object.keys(files)) {
		let dir = file;
		while (dir.includes("/")) {
			dir = dir.slice(0, dir.lastIndexOf("/")) || "/";
			dirs.add(dir);
			if (dir === "/") break;
		}
	}
	return {
		exists: (p) => p in files || dirs.has(p),
		isDirectory: (p) => dirs.has(p),
		readFile: (p) => {
			if (!(p in files)) throw new Error(`ENOENT: ${p}`);
			return files[p];
		},
		readDir: (p) => {
			const prefix = p === "/" ? "/" : `${p}/`;
			const names = new Set<string>();
			for (const key of [...Object.keys(files), ...dirs]) {
				if (key.startsWith(prefix) && key !== p) {
					names.add(key.slice(prefix.length).split("/")[0]);
				}
			}
			return [...names].sort();
		},
	};
}
