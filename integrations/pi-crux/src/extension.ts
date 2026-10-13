/**
 * pi-crux — Crux rules enforced inside Pi.
 *
 * Boot      resolve company/team or project at session start; disabled when
 *           neither exists.
 * Budget    estimate the base context (README "Context Loading Order") and
 *           warn above 8000 tokens; shown in the footer status.
 * Guard     block write/edit (and obvious bash writes) outside the coordinator
 *           write scope and, in a company, outside the team's owned paths.
 * Delegate  crux_delegate tool: open a TODO record for a role, run it in a
 *           separate pi process, report the record's final status.
 * Inbox     /crux-inbox: the team's request board and, for the coordinator,
 *           the pending items of workspace/inbox.md.
 */
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { BASE_CONTEXT_BUDGET, type BudgetReport, baseContextFiles, formatTokens, measureBaseContext } from "./crux/budget.ts";
import { nodeFs } from "./crux/fs.ts";
import { checkToolCall, type GuardContext } from "./crux/guard.ts";
import { pendingInbox } from "./crux/inbox.ts";
import { isOnboarded, parseManifestAgents } from "./crux/manifest.ts";
import { normalizePath } from "./crux/paths.ts";
import { listAnswered, listRequests } from "./crux/requests.ts";
import { type CruxContext, qualifiedTeamId, resolveCrux } from "./crux/resolve.ts";
import { appendTodo, emptyTodo, todoStatus } from "./crux/todo.ts";
import { ulid } from "./crux/ulid.ts";
import { buildDelegateArgs, buildDelegateSystemPrompt, runPi, writeTempPrompt } from "./delegate.ts";

const ROLE_PROMPT = /^Take the Crux role `([a-z0-9-]+)`/;
const COORDINATOR_PROMPT = /^Act as the Crux coordinator/;

interface State {
	enabled: boolean;
	frameworkHome: string;
	crux?: CruxContext;
	role: string;
	budget?: BudgetReport;
}

export default function cruxExtension(pi: ExtensionAPI) {
	const state: State = {
		enabled: false,
		frameworkHome: normalizePath(process.env.CRUX_HOME ?? path.join(os.homedir(), ".crux")),
		role: "coordinator",
	};

	const guard = (): GuardContext => ({ role: state.role, frameworkHome: state.frameworkHome, crux: state.crux });

	/** Default role for a session: the team's primary role; the coordinator at a root. */
	const defaultRole = (): string => {
		const c = state.crux;
		if (c?.kind === "company" && c.team && c.team.id !== c.coordinatorId) return c.team.roles[0] ?? c.team.id;
		return "coordinator";
	};

	const refreshBudget = () => {
		if (!state.crux) return;
		const role = state.role === "coordinator" ? "coordinator" : state.role;
		const files = baseContextFiles(state.crux, role, state.frameworkHome);
		state.budget = measureBaseContext(files, nodeFs);
	};

	const statusLine = (): string => {
		const c = state.crux;
		const who = c?.kind === "company" ? (qualifiedTeamId(c) ?? `${c.companyId}/?`) : `project:${state.role}`;
		const b = state.budget;
		const budget = b ? ` · base ${formatTokens(b.total)}/${formatTokens(b.budget)}${b.over ? " OVER" : ""}` : "";
		return `crux ${who}${budget}`;
	};

	const showStatus = (ctx: ExtensionContext) => {
		if (!ctx.hasUI) return;
		ctx.ui.setStatus("crux", state.enabled ? statusLine() : undefined);
	};

	const warnBudget = (ctx: ExtensionContext) => {
		const b = state.budget;
		if (!b?.over || !ctx.hasUI) return;
		const biggest = [...b.files].sort((x, y) => y.tokens - x.tokens)[0];
		ctx.ui.notify(
			`Crux base context ≈${b.total} tokens exceeds the ${BASE_CONTEXT_BUDGET} budget (largest: ${path.basename(biggest.path)} ≈${biggest.tokens}). Trim MEMORY/TODO or move detail to docs/.`,
			"warning",
		);
	};

	/** The block appended to the system prompt once Crux is resolved. */
	const contextBlock = (): string => {
		const c = state.crux;
		if (!c) return "";
		const lines = ["## Crux", ""];
		if (c.kind === "company") {
			lines.push(`Company: ${c.companyId} (${c.companyRoot}).`);
			if (c.team) {
				lines.push(`You are team ${c.companyId}/${c.team.id} (roles: ${c.team.roles.join(", ") || "—"}).`);
				lines.push(`Owned paths: ${c.team.owns.join(", ") || "—"}. Shared (also): ${c.team.also.join(", ") || "—"}.`);
				lines.push(`Inbox: ${c.cruxDir}/requests/${c.team.id}/. Workspace: ${c.workspaceDir}/${c.team.id}/.`);
			} else {
				lines.push("No team owns this directory. Ask the operator which team to act as before writing.");
			}
			lines.push(`Protocol: ${state.frameworkHome}/skills/crux-team/SKILL.md.`);
		} else {
			lines.push(`Project: ${c.projectRoot}. Active role: ${state.role}.`);
			lines.push(`Protocol: ${state.frameworkHome}/skills/crux-coordinator/SKILL.md.`);
		}
		lines.push(
			"",
			"Writes outside your scope are blocked by pi-crux; the block reason says who owns the path.",
			"Use crux_delegate to hand a task to a role; use a request file to reach another team.",
		);
		return lines.join("\n");
	};

	// ---- Boot ---------------------------------------------------------------
	pi.on("session_start", async (_event, ctx) => {
		state.crux = resolveCrux(ctx.cwd, { frameworkHome: state.frameworkHome, fs: nodeFs });
		state.enabled = state.crux !== undefined;
		state.role = process.env.CRUX_ROLE ?? defaultRole();
		if (!state.enabled) {
			if (ctx.hasUI) ctx.ui.setStatus("crux", undefined);
			return;
		}
		refreshBudget();
		showStatus(ctx);
		warnBudget(ctx);
	});

	pi.on("before_agent_start", async (event, ctx) => {
		if (!state.enabled) return undefined;
		// Pi ≥ 1.2 also fires this for extension-triggered (custom message) runs,
		// which carry no prompt. Every run gets the Crux block; only user prompts
		// can switch the role.
		const messageType = (event as { messageType?: string }).messageType;
		const prompt = !messageType || messageType === "user" ? ((event as { prompt?: string }).prompt ?? "") : "";
		const role = prompt.match(ROLE_PROMPT)?.[1];
		if (role) state.role = role;
		else if (COORDINATOR_PROMPT.test(prompt)) state.role = "coordinator";
		refreshBudget();
		showStatus(ctx);
		return { systemPrompt: `${event.systemPrompt}\n\n${contextBlock()}` };
	});

	// ---- Guard --------------------------------------------------------------
	pi.on("tool_call", async (event, ctx) => {
		if (!state.enabled) return undefined;
		const decision = checkToolCall(event.toolName, event.input as Record<string, unknown>, ctx.cwd, guard());
		if (decision.allowed) return undefined;
		if (ctx.hasUI) ctx.ui.notify(`crux blocked ${event.toolName} → ${decision.path}`, "warning");
		return { block: true, reason: `[crux:${decision.rule}] ${decision.reason} (${decision.path})` };
	});

	// ---- Delegate -----------------------------------------------------------
	// A delegated child never delegates again: no recursion, one task per process.
	if (!process.env.CRUX_DELEGATED_TASK) pi.registerTool({
		name: "crux_delegate",
		label: "Crux delegate",
		description:
			"Delegate a task to a Crux role. Opens a task record in the role's TODO.md, runs the role in a separate pi process with its own context, and reports the record's final status. Complete only when the record reads done.",
		promptSnippet: "crux_delegate(role, task) — hand work to an onboarded Crux role",
		parameters: Type.Object({
			role: Type.String({ description: "Role id, e.g. kubernetes-admin" }),
			task: Type.String({ description: "What the role must do, with its acceptance criterion" }),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const c = state.crux;
			if (!c) throw new Error("Not in a Crux project or company.");
			const { role, task } = params;

			if (c.kind === "company" && c.team && c.team.id !== c.coordinatorId && !c.team.roles.includes(role)) {
				throw new Error(
					`Role ${role} is not one of team ${c.team.id}'s roles (${c.team.roles.join(", ")}). Work for another team is a request in ${c.cruxDir}/requests/<owner>/, not a delegation.`,
				);
			}
			const manifestFile = `${c.workspaceDir}/MANIFEST.md`;
			const agents = fs.existsSync(manifestFile) ? parseManifestAgents(fs.readFileSync(manifestFile, "utf8")) : [];
			const onboardedHint = (list: typeof agents) => {
				const ids = list.filter((a) => a.status === "onboarded").map((a) => a.id);
				return ids.length > 0 ? ` Onboarded roles: ${ids.join(", ")}.` : " No role is onboarded yet.";
			};
			if (role === "coordinator") {
				throw new Error(`The coordinator does not delegate to itself; pick a domain role.${onboardedHint(agents)}`);
			}
			if (!fs.existsSync(`${state.frameworkHome}/agents/${role}/AGENT.md`)) {
				throw new Error(`Unknown role ${role}: no ${state.frameworkHome}/agents/${role}/AGENT.md.${onboardedHint(agents)}`);
			}
			const team = c.kind === "company" ? qualifiedTeamId(c) : undefined;
			if (!isOnboarded(agents, role, team)) {
				throw new Error(`Role ${role} is not onboarded in ${manifestFile}; run its onboarding first.${onboardedHint(agents)}`);
			}

			const scope = c.kind === "company" && c.team ? c.team.id : role;
			const todoFile = `${c.workspaceDir}/${scope}/TODO.md`;
			const taskId = `T-${ulid()}`;
			const today = new Date().toISOString().slice(0, 10);
			fs.mkdirSync(path.dirname(todoFile), { recursive: true });
			const existing = fs.existsSync(todoFile) ? fs.readFileSync(todoFile, "utf8") : emptyTodo(scope, today);
			fs.writeFileSync(
				todoFile,
				appendTodo(existing, {
					id: taskId,
					fields: {
						title: task.split("\n")[0].slice(0, 120),
						status: "todo",
						owner: role,
						created_by: state.role,
						created_at: today,
						updated_at: today,
						acceptance_criteria: task,
						next_step: "start",
					},
					evidence_refs: [],
				}),
			);

			const promptFile = writeTempPrompt(
				path.join(os.tmpdir(), "pi-crux"),
				taskId,
				buildDelegateSystemPrompt({ role, taskId, frameworkHome: state.frameworkHome, crux: c }),
			);
			const args = buildDelegateArgs({ task: `${task}\n\nTask record: ${taskId} in ${todoFile}`, systemPromptFile: promptFile });
			const run = await runPi(args, {
				cwd: ctx.cwd,
				env: { CRUX_ROLE: role, CRUX_HOME: state.frameworkHome, CRUX_DELEGATED_TASK: taskId },
				signal,
			});
			fs.rmSync(promptFile, { force: true });

			const status = fs.existsSync(todoFile) ? (todoStatus(fs.readFileSync(todoFile, "utf8"), taskId) ?? "todo") : "todo";
			const completed = status === "done";
			const summary = [
				`Task ${taskId} for ${role}: status=${status}${completed ? "" : " — NOT complete"}.`,
				run.exitCode !== 0 ? `pi exited ${run.exitCode}${run.errorMessage ? `: ${run.errorMessage}` : ""}` : "",
				run.turns === 0 ? `No assistant output. stderr: ${run.stderr.trim().slice(0, 500)}` : run.output,
			]
				.filter(Boolean)
				.join("\n\n");
			return {
				content: [{ type: "text", text: summary }],
				details: { taskId, role, status, completed, exitCode: run.exitCode, turns: run.turns },
			};
		},
	});

	// ---- Inbox --------------------------------------------------------------
	pi.registerCommand("crux-inbox", {
		description: "Show the Crux request board for this team and pending operator decisions",
		handler: async (_args, ctx) => {
			const c = state.crux;
			const lines: string[] = [];
			if (!c) {
				lines.push("Not in a Crux project or company.");
			} else {
				if (c.kind === "company" && c.team) {
					const inbox = listRequests(`${c.cruxDir}/requests/${c.team.id}`, nodeFs);
					lines.push(`Board inbox ${c.companyId}/${c.team.id}: ${inbox.length === 0 ? "empty" : ""}`);
					for (const r of inbox) lines.push(`  [${r.status}] ${r.opened} ${r.title || path.basename(r.file)}  ← ${r.from}`);
					const answered = listAnswered(`${c.cruxDir}/requests`, `${c.companyId}/${c.team.id}`, nodeFs);
					if (answered.length > 0) {
						lines.push("Sent, answered, not picked up:");
						for (const r of answered) lines.push(`  [${r.status}] ${r.title || path.basename(r.file)}  → ${r.to}`);
					}
				}
				const isCoordinator = c.kind === "company" ? c.team?.id === c.coordinatorId : state.role === "coordinator";
				const inboxFile = `${c.workspaceDir}/inbox.md`;
				if (isCoordinator && fs.existsSync(inboxFile)) {
					const items = pendingInbox(fs.readFileSync(inboxFile, "utf8"));
					lines.push(`Decision inbox (${inboxFile}): ${items.length === 0 ? "nothing pending" : ""}`);
					for (const i of items) lines.push(`  ${i.id} ${i.section}: ${i.fields.summary ?? ""} (from ${i.fields.requested_by ?? "?"})`);
				}
				if (lines.length === 0) {
					lines.push(`No inbox for role ${state.role} here: the board belongs to teams, the decision inbox to the coordinator.`);
				}
			}
			if (ctx.hasUI) {
				ctx.ui.setWidget("crux-inbox", lines);
				ctx.ui.notify(lines[0], "info");
			} else {
				console.log(lines.join("\n"));
			}
		},
	});
}
