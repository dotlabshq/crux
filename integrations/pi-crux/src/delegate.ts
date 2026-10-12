import { type ChildProcess, spawn } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import type { CruxContext } from "./crux/resolve.ts";

/**
 * Delegation: run a role in its own `pi` process (JSON print mode, no
 * session) and read the final assistant message from the event stream —
 * the pattern of Pi's examples/extensions/subagent.
 */

export interface DelegateArgsOptions {
	task: string;
	systemPromptFile: string;
	model?: string;
	tools?: string[];
}

/** Argument vector for the child pi; pure so it can be tested. */
export function buildDelegateArgs(o: DelegateArgsOptions): string[] {
	const args = ["--mode", "json", "-p", "--no-session", "--no-context-files"];
	if (o.model) args.push("--model", o.model);
	if (o.tools && o.tools.length > 0) args.push("--tools", o.tools.join(","));
	args.push("--append-system-prompt", o.systemPromptFile);
	args.push(`Task: ${o.task}`);
	return args;
}

export interface DelegatePromptOptions {
	role: string;
	taskId: string;
	frameworkHome: string;
	crux: CruxContext;
}

/** The role's load order, as the Pi prompt templates state it. */
export function buildDelegateSystemPrompt(o: DelegatePromptOptions): string {
	const c = o.crux;
	const scope = c.kind === "company" && c.team ? c.team.id : o.role;
	const lines = [
		`You are the Crux role \`${o.role}\`, delegated task ${o.taskId} by the coordinator.`,
		"",
		"Load these before working, in this order; skip files that do not exist:",
		`1. ${c.cruxDir}/CONSTITUTION.md`,
		`2. ${c.cruxDir}/SOUL.md`,
		`3. ${o.frameworkHome}/agents/${o.role}/AGENT.md`,
		`4. ${o.frameworkHome}/agents/${o.role}/SOUL.md`,
		`5. ${c.workspaceDir}/${scope}/MEMORY.md`,
		`6. ${c.workspaceDir}/${scope}/TODO.md`,
		`7. ${c.workspaceDir}/${scope}/NOTES.md`,
		"",
		`Your task record is \`## ${o.taskId}\` in ${c.workspaceDir}/${scope}/TODO.md.`,
		"Set its status to in_progress when you start, and to done, waiting or blocked",
		"when you stop; the delegation only counts as complete when it reads done.",
		"Persist durable facts to MEMORY.md. Stay inside this role's domain and approval",
		"gates; hand off anything another role or team owns.",
	];
	if (c.kind === "company") {
		lines.push("", `Company: ${c.companyId} (${c.companyRoot}). Team: ${c.team?.id ?? "unresolved"}.`);
		lines.push(`Teams, ownership and the request board: ${o.frameworkHome}/skills/crux-team/SKILL.md.`);
	}
	return lines.join("\n");
}

export interface DelegateRun {
	exitCode: number;
	output: string;
	stopReason?: string;
	errorMessage?: string;
	turns: number;
	stderr: string;
}

/** Fold a JSON-lines event stream into the final assistant text. Pure. */
export function foldJsonLines(lines: string[]): Omit<DelegateRun, "exitCode" | "stderr"> {
	let output = "";
	let stopReason: string | undefined;
	let errorMessage: string | undefined;
	let turns = 0;
	for (const line of lines) {
		if (!line.trim()) continue;
		let event: any;
		try {
			event = JSON.parse(line);
		} catch {
			continue;
		}
		if (event.type !== "message_end" || event.message?.role !== "assistant") continue;
		turns++;
		const text = (event.message.content ?? [])
			.filter((p: any) => p.type === "text")
			.map((p: any) => p.text)
			.join("");
		if (text) output = text;
		if (event.message.stopReason) stopReason = event.message.stopReason;
		if (event.message.errorMessage) errorMessage = event.message.errorMessage;
	}
	return { output, stopReason, errorMessage, turns };
}

/** How to start pi: the running entrypoint when known, else `pi` on PATH. */
export function piInvocation(args: string[]): { command: string; args: string[] } {
	const script = process.argv[1];
	if (script && fs.existsSync(script) && !script.startsWith("/$bunfs/")) {
		return { command: process.execPath, args: [script, ...args] };
	}
	return { command: "pi", args };
}

export interface RunOptions {
	cwd: string;
	env: Record<string, string>;
	signal?: AbortSignal;
	spawnImpl?: typeof spawn;
}

export function runPi(args: string[], o: RunOptions): Promise<DelegateRun> {
	const { command, args: full } = piInvocation(args);
	const spawner = o.spawnImpl ?? spawn;
	return new Promise((resolve) => {
		const proc: ChildProcess = spawner(command, full, {
			cwd: o.cwd,
			env: { ...process.env, ...o.env },
			shell: false,
			stdio: ["ignore", "pipe", "pipe"],
		});
		const lines: string[] = [];
		let buffer = "";
		let stderr = "";
		proc.stdout?.on("data", (d) => {
			buffer += d.toString();
			const parts = buffer.split("\n");
			buffer = parts.pop() ?? "";
			lines.push(...parts);
		});
		proc.stderr?.on("data", (d) => {
			stderr += d.toString();
		});
		const finish = (code: number) => {
			if (buffer.trim()) lines.push(buffer);
			resolve({ exitCode: code, stderr, ...foldJsonLines(lines) });
		};
		proc.on("close", (code) => finish(code ?? 0));
		proc.on("error", (err) => {
			stderr += String(err);
			finish(1);
		});
		if (o.signal) {
			const kill = () => {
				proc.kill("SIGTERM");
				setTimeout(() => {
					if (!proc.killed) proc.kill("SIGKILL");
				}, 5000);
			};
			if (o.signal.aborted) kill();
			else o.signal.addEventListener("abort", kill, { once: true });
		}
	});
}

export function writeTempPrompt(dir: string, taskId: string, text: string): string {
	fs.mkdirSync(dir, { recursive: true });
	const file = path.join(dir, `crux-delegate-${taskId}.md`);
	fs.writeFileSync(file, text, "utf8");
	return file;
}
