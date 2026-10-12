#!/usr/bin/env node
// Smoke test without a model: load the extension the way Pi does (jiti) and drive its
// handlers with a fake ExtensionAPI. Usage: node test/smoke.mjs <project-dir>   (CRUX_HOME set)
import { createJiti } from "jiti";
const jiti = createJiti(import.meta.url);
const mod = await jiti.import(new URL("../src/extension.ts", import.meta.url).pathname);
const ext = mod.default;
const handlers = {}; const tools = {}; const commands = {};
const notes = [];
const pi = {
  on: (ev, h) => { (handlers[ev] ??= []).push(h); return () => {}; },
  registerTool: (t) => { tools[t.name] = t; },
  registerCommand: (n, o) => { commands[n] = o; },
};
ext(pi);
const status = {};
const ctx = { cwd: process.argv[2], hasUI: true, mode: "tui",
  ui: { setStatus: (k, v) => { status[k] = v; }, notify: (m, t) => notes.push(`${t}: ${m}`), setWidget: (k, v) => { status[k] = v; } } };
const fire = async (ev, e) => { let r; for (const h of handlers[ev] ?? []) r = (await h(e, ctx)) ?? r; return r; };
await fire("session_start", { type: "session_start", reason: "startup" });
console.log("status:", status.crux);
const b = await fire("before_agent_start", { type: "before_agent_start", prompt: "Act as the Crux coordinator for this workspace.", systemPrompt: "BASE", systemPromptOptions: {} });
console.log("system prompt tail:", b?.systemPrompt?.split("\n").slice(-4).join(" | "));
const attempt = async (toolName, input) => {
  const r = await fire("tool_call", { type: "tool_call", toolName, toolCallId: "1", input });
  console.log(`${toolName} ${JSON.stringify(input).slice(0, 70)} →`, r ? `BLOCKED ${r.reason}` : "allowed");
};
await attempt("write", { path: ".crux/docs/cluster.md", content: "x" });
await attempt("edit", { path: ".crux/workspace/kubernetes-admin/MEMORY.md", edits: [] });
await attempt("bash", { command: "echo hi > src/app.ts" });
await attempt("write", { path: ".crux/workspace/TODO.md", content: "x" });
await attempt("write", { path: ".crux/workspace/kubernetes-admin/TODO.md", content: "x" });
await attempt("write", { path: process.env.CRUX_HOME + "/agents/kubernetes-admin/AGENT.md", content: "x" });
await fire("before_agent_start", { type: "before_agent_start", prompt: "Take the Crux role `kubernetes-admin` (x) for this workspace.", systemPrompt: "BASE", systemPromptOptions: {} });
console.log("status after /kubernetes-admin:", status.crux);
await attempt("write", { path: ".crux/docs/cluster.md", content: "x" });
await attempt("write", { path: process.env.CRUX_HOME + "/skills/x/SKILL.md", content: "x" });
await commands["crux-inbox"].handler("", ctx);
console.log("inbox widget:", status["crux-inbox"]);
console.log("tools:", Object.keys(tools), "commands:", Object.keys(commands));
console.log("notifications:", notes);
