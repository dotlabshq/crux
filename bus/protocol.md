# Bus Protocol

> Defines the message schema for all inter-agent communication in Crux.
> The transport layer may change (filesystem → in-memory → Redis → NATS)
> but this schema remains stable.

---

## Message Schema

```json
{
  "id":           "<ulid>",
  "from":         "<role-id>",
  "to":           "<role-id> | broadcast",
  "mode":         "primary | hidden | remote",
  "type":         "task | result | event | error | approval-request | approval-response",
  "payload":      "<free text, markdown>",
  "context_refs": ["<file path>", "..."],
  "parent_id":    "<ulid of originating message or null>",
  "ts":           "<iso8601>"
}
```

---

## Message Types

| Type | Direction | Description |
|---|---|---|
| `task` | coordinator → agent | Assign work to an agent |
| `result` | agent → coordinator | Return completed work |
| `event` | any → broadcast | Notify all agents of a state change |
| `error` | agent → coordinator | Report a failure |
| `approval-request` | agent → coordinator | Pause and request human approval |
| `approval-response` | coordinator → agent | Relay human approval or rejection |

---

## @Mention Modes

```
primary
  Coordinator hands off directly in the same context.
  The receiving agent's full AGENT.md is loaded into the current session.
  Use for: tightly coupled tasks, small context cost.

hidden
  Task runs in the background.
  Result is returned without surfacing intermediate steps to the user.
  Use for: read-only operations, analysis, report generation.

remote
  Agent runs as a separate process:
    uv run crux --role {role-id}
  Message is written to bus/{role-id}/ and picked up by the process.
  Use for: long-running tasks, heavy context, parallel execution.
```

---

## Directory Structure

```
bus/
├── protocol.md                     ← this file
├── broadcast.jsonl                 ← all agents listen; coordinator writes
├── {from-role}/
│   └── to-{to-role}.jsonl          ← outbound from {from-role}
└── {role-id}/
    └── inbox.jsonl                 ← inbound for {role-id}
```

### File naming

- `bus/coordinator/to-kubernetes-admin.jsonl`
- `bus/kubernetes-admin/to-coordinator.jsonl`
- `bus/broadcast.jsonl`

---

## Transport Backends

Current transport is determined by the environment.
Message schema does not change between transports.

| Stage | Backend | Notes |
|---|---|---|
| Now (markdown-native) | Filesystem JSONL | Git-friendly, human-readable, debuggable |
| Single process | In-memory queue | No disk I/O, same schema |
| Multi-process | Redis Streams | `XADD` / `XREAD`, built-in replay |
| Distributed | NATS JetStream | Remote agents, guaranteed delivery |

---

## Broadcast Events

Standard events written to `bus/broadcast.jsonl`:

| Event | Written by | Meaning |
|---|---|---|
| `agent.onboarded` | coordinator | Agent completed onboarding |
| `agent.started` | coordinator | Agent session opened |
| `agent.stopped` | coordinator | Agent session closed |
| `doc.updated` | any agent | A docs/ file was created or modified |
| `approval.requested` | any agent | Human approval needed — all agents pause related tasks |
| `approval.resolved` | coordinator | Approval granted or rejected |
| `amendment.requested` | any agent | Constitution amendment requested |
| `amendment.resolved` | coordinator | Amendment approved or rejected |

---

## Rules

- Only the coordinator may write to `bus/broadcast.jsonl`
- Agents write only to their own outbound channel (`bus/{role-id}/to-{target}.jsonl`)
- No agent reads from another agent's outbound channel directly — only via coordinator
- All `approval-request` messages must block the requesting agent until resolved
- Message IDs use ULID format — sortable, unique, no coordination required