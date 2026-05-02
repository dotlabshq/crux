#!/usr/bin/env bash
# Requires bash 3.2+ (macOS default)
# =============================================================================
# Crux — convert.sh
# Syncs Crux agent/skill definitions → tool-specific locations.
# Run this after editing source-repo `agents/` or `skills/`, or installed
# `.crux/agents/` / `.crux/skills/` in a user project.
#
# Usage:
#   ./scripts/convert.sh                     # auto-detect tools
#   ./scripts/convert.sh --tool opencode
#   ./scripts/convert.sh --tool claude-code
#   ./scripts/convert.sh --tool cursor
#   ./scripts/convert.sh --tool codex
#   ./scripts/convert.sh --tool all
#   ./scripts/convert.sh --dry-run           # preview without writing
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET} $*"; }
info() { echo -e "  ${CYAN}→${RESET} $*"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $*"; }
err()  { echo -e "  ${RED}✗${RESET} $*" >&2; }
hdr()  { echo -e "\n${BOLD}${BLUE}$*${RESET}"; }

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------
TOOL="auto"
DRY_RUN=false
SOURCE_DIR="auto"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)    TOOL="$2"; shift 2 ;;
    --crux|--source) SOURCE_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --help|-h)
      echo "Usage: $0 [--tool opencode|claude-code|cursor|codex|all] [--dry-run]"
      exit 0 ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Validate
# ---------------------------------------------------------------------------
if [[ "$SOURCE_DIR" == "auto" ]]; then
  if [[ -f "COORDINATOR.md" && -d "agents" && -d "skills" ]]; then
    SOURCE_DIR="."
  elif [[ -f ".crux/COORDINATOR.md" && -d ".crux/agents" && -d ".crux/skills" ]]; then
    SOURCE_DIR=".crux"
  else
    err "No Crux source found. Run from the framework repo root or a project containing .crux/."
    exit 1
  fi
fi

COORDINATOR="$SOURCE_DIR/COORDINATOR.md"
AGENTS_DIR="$SOURCE_DIR/agents"
SKILLS_DIR="$SOURCE_DIR/skills"
SOURCE_ABS=$(cd "$SOURCE_DIR" && pwd)
if [[ "$(basename "$SOURCE_ABS")" == ".crux" ]]; then
  ROOT_DIR=$(cd "$(dirname "$SOURCE_ABS")" && pwd)
else
  ROOT_DIR="$SOURCE_ABS"
fi
WORKSPACE_DIR="$ROOT_DIR/.crux/workspace"
PROJECT_SLUG=$(printf '%s' "$(basename "$ROOT_DIR")" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-')
PROJECT_SLUG="${PROJECT_SLUG#-}"
PROJECT_SLUG="${PROJECT_SLUG%-}"
[[ -z "$PROJECT_SLUG" ]] && PROJECT_SLUG="crux"

if [[ ! -f "$COORDINATOR" ]]; then
  err "$COORDINATOR not found."
  exit 1
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
write_file() {
  local dest="$1"
  local content="$2"
  if $DRY_RUN; then
    info "[dry-run] would write: $dest"
  else
    mkdir -p "$(dirname "$dest")"
    printf '%s' "$content" > "$dest"
    ok "$dest"
  fi
}

copy_file() {
  local src="$1"
  local dest="$2"
  if $DRY_RUN; then
    info "[dry-run] would copy: $src → $dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    ok "$dest"
  fi
}

# Extract frontmatter value: extract_fm <key> <file>
extract_fm() {
  local key="$1" file="$2"
  awk -v key="$key" '
    /^---$/ { frontmatter++; next }
    frontmatter != 1 { next }
    block {
      if ($0 ~ /^[^[:space:]]/ || $0 ~ /^---$/) {
        print value
        printed = 1
        exit
      }
      line = $0
      sub(/^[[:space:]]+/, "", line)
      if (line != "") {
        value = value (value ? " " : "") line
      }
      next
    }
    $0 ~ ("^" key ":") {
      line = $0
      sub("^" key ":[[:space:]]*", "", line)
      if (line == ">" || line == "|") {
        block = 1
        value = ""
        next
      }
      gsub(/"/, "", line)
      print line
      printed = 1
      exit
    }
    END {
      if (block && !printed) print value
    }
  ' "$file" | xargs
}

codex_root() {
  if [[ -n "${CODEX_HOME:-}" ]]; then
    printf '%s' "$CODEX_HOME"
  else
    printf '%s/.codex' "$HOME"
  fi
}

render_template() {
  local text="$1"
  shift
  while [[ $# -gt 1 ]]; do
    local key="$1"
    local value="$2"
    text="${text//${key}/${value}}"
    shift 2
  done
  printf '%s' "$text"
}

# ---------------------------------------------------------------------------
# Auto-detect tools
# ---------------------------------------------------------------------------
detect_tools() {
  local detected=()
  [[ -d ".opencode" ]]          && detected+=("opencode")
  [[ -d ".claude" ]] || command -v claude &>/dev/null && detected+=("claude-code")
  [[ -d ".cursor" ]]            && detected+=("cursor")
  [[ -d "$(codex_root)" ]]      && detected+=("codex")
  echo "${detected[@]:-}"
}

if [[ "$TOOL" == "auto" ]]; then
  _detected=$(detect_tools)
  if [[ -z "$_detected" ]]; then
    warn "No tools detected. Specify --tool opencode|claude-code|cursor|codex|all"
    exit 0
  fi
  read -ra TOOLS <<< "$_detected"
  info "Auto-detected: ${TOOLS[*]}"
elif [[ "$TOOL" == "all" ]]; then
  TOOLS=("opencode" "claude-code" "cursor" "codex")
else
  TOOLS=("$TOOL")
fi

# ---------------------------------------------------------------------------
# Collect agents and skills
# ---------------------------------------------------------------------------
AGENT_FILES=()
while IFS= read -r f; do AGENT_FILES+=("$f"); done < <(find "$AGENTS_DIR" -name "AGENT.md" 2>/dev/null | sort)
SKILL_FILES=()
while IFS= read -r f; do SKILL_FILES+=("$f"); done < <(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null | sort)

echo -e "\n${BOLD}Crux convert${RESET}"
echo -e "Source:  ${CYAN}$SOURCE_DIR/${RESET}"
echo -e "Agents:  ${#AGENT_FILES[@]}"
echo -e "Skills:  ${#SKILL_FILES[@]}"
echo -e "Tools:   ${TOOLS[*]}"
$DRY_RUN && echo -e "${YELLOW}Mode:    dry-run${RESET}"

# ===========================================================================
# OPENCODE
# ===========================================================================
convert_opencode() {
  hdr "opencode"
  local agent_out=".opencode/agent"
  local skill_out=".opencode/skills"

  # Coordinator
  copy_file "$COORDINATOR" "$agent_out/crux-coordinator.md"

  # Agents
  for agent_file in "${AGENT_FILES[@]}"; do
    local role
    role=$(basename "$(dirname "$agent_file")")
    copy_file "$agent_file" "$agent_out/${role}.md"
  done

  # Skills
  for skill_file in "${SKILL_FILES[@]}"; do
    local name
    name=$(basename "$(dirname "$skill_file")")
    copy_file "$skill_file" "$skill_out/${name}/SKILL.md"
  done
}

# ===========================================================================
# CLAUDE CODE
# ===========================================================================
convert_claude_code() {
  hdr "claude-code"

  # Per-agent files → .claude/agents/
  for agent_file in "${AGENT_FILES[@]}"; do
    local role
    role=$(basename "$(dirname "$agent_file")")
    copy_file "$agent_file" ".claude/agents/${role}.md"
  done

  # CLAUDE.md — boot instructions pointing to .crux/
  local claude_md
  claude_md=$(cat <<'CLAUDEMD'
# Crux

This project uses the Crux multi-agent workspace framework.

## Boot Instructions

On every session start:
1. Read `.crux/COORDINATOR.md` — boot sequence and routing rules
2. Read `.crux/CONSTITUTION.md` — universal rules (if it exists)
3. Read `.crux/SOUL.md` — identity and tone defaults (if it exists)
4. Read `.crux/workspace/MANIFEST.md` — current system state (if it exists)
   - If `.crux/workspace/` does not exist → run workspace initialisation as described in COORDINATOR.md
5. Surface any pending items (agents pending onboard, amendments, open sessions)

## Agents

Sub-agents are defined in `.claude/agents/`. Each handles a bounded domain.
Type `@{role-id}` to activate an agent. The coordinator routes all @mentions.

## Key Paths

| Path | Purpose |
|---|---|
| `.crux/COORDINATOR.md` | Boot + routing logic |
| `.crux/agents/{role}/AGENT.md` | Agent identity (source of truth) |
| `.crux/skills/{name}/SKILL.md` | Skill definitions |
| `.crux/workflows/{name}.md` | Multi-agent workflows |
| `.crux/decisions/` | Approved architectural decisions |
| `.crux/workspace/` | Live state — gitignored |

Do not modify `.crux/agents/` files during a session.
Do not write to `.crux/workspace/` without following COORDINATOR.md protocols.
CLAUDEMD
)

  # Append only if CLAUDE.md does not already contain Crux boot instructions
  if [[ -f "CLAUDE.md" ]] && grep -q "crux/COORDINATOR.md" "CLAUDE.md" 2>/dev/null; then
    warn "CLAUDE.md already contains Crux instructions — skipping"
  else
    if [[ -f "CLAUDE.md" ]]; then
      if $DRY_RUN; then
        info "[dry-run] would append Crux section to CLAUDE.md"
      else
        printf '\n\n---\n\n%s' "$claude_md" >> "CLAUDE.md"
        ok "CLAUDE.md (appended)"
      fi
    else
      write_file "CLAUDE.md" "$claude_md"
    fi
  fi
}

# ===========================================================================
# CURSOR
# ===========================================================================
convert_cursor() {
  hdr "cursor"

  local rules=""
  rules+="# Crux — Agent Workspace Rules\n\n"
  rules+="This project uses the Crux multi-agent framework. Read \`.crux/COORDINATOR.md\` on startup.\n\n"
  rules+="## Active Agents\n\n"

  for agent_file in "${AGENT_FILES[@]}"; do
    local role description
    role=$(basename "$(dirname "$agent_file")")
    description=$(extract_fm "description" "$agent_file" | head -1)
    rules+="- **\`${role}\`** — ${description}\n"
  done

  rules+="\n## Rules\n\n"
  rules+="- Always read \`.crux/COORDINATOR.md\` before starting any task\n"
  rules+="- Load \`.crux/workspace/MANIFEST.md\` to understand current system state\n"
  rules+="- Agent definitions are in \`.crux/agents/{role}/AGENT.md\`\n"
  rules+="- Do not modify \`.crux/agents/\` files during a session\n"
  rules+="- Follow approval gates defined in each agent's AGENT.md\n"

  write_file ".cursor/rules/crux.mdc" "$(printf '%b' "$rules")"
}

# ===========================================================================
# CODEX
# ===========================================================================
convert_codex() {
  hdr "codex"

  local codex_home skill_root coordinator_name coordinator_desc coordinator_tpl coordinator_skill
  codex_home="$(codex_root)"
  skill_root="$codex_home/skills/crux/$PROJECT_SLUG"
  coordinator_name="crux-${PROJECT_SLUG}-coordinator"
  coordinator_desc="Use when this workspace should be handled through the Crux coordinator so it can route work to the appropriate project agent."
  coordinator_tpl=$(printf '%s\n' \
    '---' \
    'name: __COORDINATOR_NAME__' \
    'description: __COORDINATOR_DESC__' \
    '---' \
    '' \
    '# Crux Coordinator' \
    '' \
    'Use this skill when the user wants to work through the Crux coordinator for the __PROJECT_SLUG__ workspace, or when a request should be routed across multiple project agents instead of handled as a single generic coding task.' \
    '' \
    '## Workspace Source Of Truth' \
    '' \
    'Read these in order:' \
    '1. __SOURCE_ABS__/COORDINATOR.md' \
    '2. __ROOT_DIR__/AGENTS.md' \
    '3. __ROOT_DIR__/COORDINATOR.md if it exists outside installed .crux/' \
    '4. __WORKSPACE_DIR__/MANIFEST.md if it exists' \
    '5. __WORKSPACE_DIR__/TODO.md if it exists' \
    '6. __WORKSPACE_DIR__/inbox.md if it exists' \
    '' \
    '## How To Operate' \
    '' \
    '- Treat Crux markdown files as the authority for routing, approvals, and task continuity.' \
    '- Before delegating or continuing work, check coordinator task state in __WORKSPACE_DIR__/TODO.md when available.' \
    '- Prefer resuming an open task over creating duplicate work.' \
    "- When a specialist role is clearly a better fit, load that role's AGENT.md and, if present, SOUL.md, MEMORY.md, TODO.md, and NOTES.md before continuing." \
    '- Load a role-owned Crux skill from __SOURCE_ABS__/skills/{skill-name}/SKILL.md only when the request actually needs that skill.' \
    '- Follow approval gates and escalation rules defined by the coordinator and selected agent.')
  coordinator_skill=$(render_template "$coordinator_tpl" \
    "__COORDINATOR_NAME__" "$coordinator_name" \
    "__COORDINATOR_DESC__" "$coordinator_desc" \
    "__PROJECT_SLUG__" "$PROJECT_SLUG" \
    "__SOURCE_ABS__" "$SOURCE_ABS" \
    "__ROOT_DIR__" "$ROOT_DIR" \
    "__WORKSPACE_DIR__" "$WORKSPACE_DIR")

  write_file "$skill_root/agents/coordinator/SKILL.md" "$coordinator_skill"

  for agent_file in "${AGENT_FILES[@]}"; do
    local role display_name description agent_tpl agent_skill
    role=$(basename "$(dirname "$agent_file")")
    display_name=$(extract_fm "name" "$agent_file")
    description=$(extract_fm "description" "$agent_file")

    agent_tpl=$(printf '%s\n' \
      '---' \
      'name: __AGENT_SKILL_NAME__' \
      'description: Use when the user explicitly wants the __DISPLAY_NAME__ role from the __PROJECT_SLUG__ Crux workspace, or when the task clearly matches this role'\''s domain. __DESCRIPTION__' \
      '---' \
      '' \
      '# __DISPLAY_NAME__' \
      '' \
      'This Codex skill is a wrapper around the Crux agent at __SOURCE_ABS__/agents/__ROLE__/AGENT.md.' \
      '' \
      '## Load Order' \
      '' \
      'Read these sources before answering in this role:' \
      '1. __SOURCE_ABS__/agents/__ROLE__/AGENT.md' \
      '2. __SOURCE_ABS__/agents/__ROLE__/SOUL.md if present' \
      '3. __WORKSPACE_DIR__/__ROLE__/MEMORY.md if present' \
      '4. __WORKSPACE_DIR__/__ROLE__/TODO.md if present' \
      '5. __WORKSPACE_DIR__/__ROLE__/NOTES.md if present' \
      '6. __WORKSPACE_DIR__/MANIFEST.md if broader project state is relevant' \
      '7. Any role-owned Crux skill from __SOURCE_ABS__/skills/{skill-name}/SKILL.md only when needed' \
      '' \
      '## Operating Rules' \
      '' \
      '- Stay inside this role'\''s domain, boundaries, and escalation rules.' \
      '- Reuse open tasks from __WORKSPACE_DIR__/__ROLE__/TODO.md before starting new parallel work.' \
      '- Treat TODO.md as task state, NOTES.md as support context, and MEMORY.md as durable facts.' \
      '- If the role'\''s AGENT.md says another agent should own part of the work, hand off instead of improvising across boundaries.' \
      '- Use project-local Crux skills directly from the workspace source tree instead of inventing a second copy.')
    agent_skill=$(render_template "$agent_tpl" \
      "__AGENT_SKILL_NAME__" "crux-${PROJECT_SLUG}-${role}" \
      "__DISPLAY_NAME__" "$display_name" \
      "__PROJECT_SLUG__" "$PROJECT_SLUG" \
      "__DESCRIPTION__" "$description" \
      "__SOURCE_ABS__" "$SOURCE_ABS" \
      "__WORKSPACE_DIR__" "$WORKSPACE_DIR" \
      "__ROLE__" "$role")

    write_file "$skill_root/agents/${role}/SKILL.md" "$agent_skill"
  done
}

# ===========================================================================
# Dispatch
# ===========================================================================
CONVERTED=0
for tool in "${TOOLS[@]}"; do
  case "$tool" in
    opencode)    convert_opencode;    CONVERTED=$((CONVERTED+1)) ;;
    claude-code) convert_claude_code; CONVERTED=$((CONVERTED+1)) ;;
    cursor)      convert_cursor;      CONVERTED=$((CONVERTED+1)) ;;
    codex)       convert_codex;       CONVERTED=$((CONVERTED+1)) ;;
    *) warn "Unknown tool: $tool (supported: opencode, claude-code, cursor, codex)" ;;
  esac
done

echo ""
if [[ $CONVERTED -gt 0 ]]; then
  echo -e "${GREEN}${BOLD}Done.${RESET} ${CONVERTED} tool(s) converted."
  echo -e "Re-run after editing any ${CYAN}agents/${RESET} or ${CYAN}skills/${RESET} source file,"
  echo -e "or installed ${CYAN}.crux/agents/${RESET} / ${CYAN}.crux/skills/${RESET} in a user project."
else
  warn "Nothing converted."
fi
