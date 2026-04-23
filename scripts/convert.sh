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
      echo "Usage: $0 [--tool opencode|claude-code|cursor|all] [--dry-run]"
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
  awk "/^---/{p++} p==1 && /^${key}:/{gsub(/^${key}:[[:space:]]*/,\"\"); print; exit}" "$file" \
    | tr -d '"' | xargs
}

# ---------------------------------------------------------------------------
# Auto-detect tools
# ---------------------------------------------------------------------------
detect_tools() {
  local detected=()
  [[ -d ".opencode" ]]          && detected+=("opencode")
  [[ -d ".claude" ]] || command -v claude &>/dev/null && detected+=("claude-code")
  [[ -d ".cursor" ]]            && detected+=("cursor")
  echo "${detected[@]:-}"
}

if [[ "$TOOL" == "auto" ]]; then
  _detected=$(detect_tools)
  if [[ -z "$_detected" ]]; then
    warn "No tools detected. Specify --tool opencode|claude-code|cursor|all"
    exit 0
  fi
  read -ra TOOLS <<< "$_detected"
  info "Auto-detected: ${TOOLS[*]}"
elif [[ "$TOOL" == "all" ]]; then
  TOOLS=("opencode" "claude-code" "cursor")
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
# Dispatch
# ===========================================================================
CONVERTED=0
for tool in "${TOOLS[@]}"; do
  case "$tool" in
    opencode)    convert_opencode;    CONVERTED=$((CONVERTED+1)) ;;
    claude-code) convert_claude_code; CONVERTED=$((CONVERTED+1)) ;;
    cursor)      convert_cursor;      CONVERTED=$((CONVERTED+1)) ;;
    *) warn "Unknown tool: $tool (supported: opencode, claude-code, cursor)" ;;
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
