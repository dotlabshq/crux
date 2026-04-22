#!/usr/bin/env bash
# Requires bash 3.2+ (macOS default)
# =============================================================================
# Crux — install.sh
# Downloads the Crux framework skeleton into the current project
# and converts agent definitions for the specified AI tool.
#
# Quick start:
#   curl -fsSL https://raw.githubusercontent.com/dotlabshq/crux/main/scripts/install.sh | bash
#
# With options:
#   curl -fsSL .../install.sh | bash -s -- \
#     --agents kubernetes-admin,postgresql-admin \
#     --tool opencode \
#     --project "My Platform"
#
# Local usage:
#   ./scripts/install.sh --agents kubernetes-admin --tool opencode
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()    { echo -e "  ${GREEN}✓${RESET} $*"; }
info()  { echo -e "  ${CYAN}→${RESET} $*"; }
warn()  { echo -e "  ${YELLOW}⚠${RESET} $*"; }
err()   { echo -e "  ${RED}✗${RESET} $*" >&2; }
hdr()   { echo -e "\n${BOLD}${BLUE}$*${RESET}"; }
step()  { echo -e "\n${BOLD}$*${RESET}"; }

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
REPO="dotlabshq/crux"
BRANCH="main"
AGENTS_ARG=""
TOOL="auto"
PROJECT_NAME=""
CRUX_DIR=".crux"
DRY_RUN=false
FORCE=false

REPO_RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
REPO_ARCHIVE="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agents)       AGENTS_ARG="$2";    shift 2 ;;
    --tool)         TOOL="$2";          shift 2 ;;
    --project)      PROJECT_NAME="$2";  shift 2 ;;
    --branch)       BRANCH="$2";        shift 2
                    REPO_RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
                    REPO_ARCHIVE="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" ;;
    --repo)         REPO="$2";          shift 2
                    REPO_RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
                    REPO_ARCHIVE="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" ;;
    --dry-run)      DRY_RUN=true;       shift ;;
    --force)        FORCE=true;         shift ;;
    --help|-h)
      cat <<HELP
Usage: install.sh [options]

Options:
  --agents <list>   Comma-separated agent IDs to include
                    e.g. kubernetes-admin,postgresql-admin
                    Defaults to all available agents
  --tool <name>     Target AI tool: opencode | claude-code | cursor | all
                    Default: auto-detect
  --project <name>  Project name (used during workspace initialisation)
  --branch <name>   GitHub branch to download from (default: main)
  --dry-run         Preview without writing files
  --force           Overwrite existing .crux/ files

Examples:
  # Minimal
  curl -fsSL ${REPO_RAW}/scripts/install.sh | bash

  # With agents and tool
  curl -fsSL ${REPO_RAW}/scripts/install.sh | bash -s -- \\
    --agents kubernetes-admin,postgresql-admin \\
    --tool opencode \\
    --project "My Platform"
HELP
      exit 0 ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
echo ""
echo -e "${BOLD}${BLUE}┌─────────────────────────────────┐${RESET}"
echo -e "${BOLD}${BLUE}│  Crux — workspace installer     │${RESET}"
echo -e "${BOLD}${BLUE}└─────────────────────────────────┘${RESET}"
echo ""
[[ -n "$PROJECT_NAME" ]] && echo -e "  Project:  ${CYAN}${PROJECT_NAME}${RESET}"
echo -e "  Repo:     ${CYAN}${REPO}@${BRANCH}${RESET}"
echo -e "  Tool:     ${CYAN}${TOOL}${RESET}"
[[ -n "$AGENTS_ARG" ]]   && echo -e "  Agents:   ${CYAN}${AGENTS_ARG}${RESET}"
$DRY_RUN && echo -e "  ${YELLOW}Mode:     dry-run${RESET}"

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------
step "Checking prerequisites..."

DOWNLOADER=""
if command -v curl &>/dev/null; then
  DOWNLOADER="curl"
  ok "curl found"
elif command -v wget &>/dev/null; then
  DOWNLOADER="wget"
  ok "wget found"
else
  err "curl or wget required."
  exit 1
fi

if ! command -v tar &>/dev/null; then
  err "tar required."
  exit 1
fi
ok "tar found"

# ---------------------------------------------------------------------------
# Download helpers
# ---------------------------------------------------------------------------
download() {
  local url="$1" dest="$2"
  if [[ "$DOWNLOADER" == "curl" ]]; then
    curl -fsSL "$url" -o "$dest"
  else
    wget -qO "$dest" "$url"
  fi
}

download_stdout() {
  local url="$1"
  if [[ "$DOWNLOADER" == "curl" ]]; then
    curl -fsSL "$url"
  else
    wget -qO- "$url"
  fi
}

# ---------------------------------------------------------------------------
# Step 1: Download .crux/ skeleton
# ---------------------------------------------------------------------------
step "Downloading Crux framework..."

TMPDIR_WORK=$(mktemp -d)
trap 'rm -rf "$TMPDIR_WORK"' EXIT

ARCHIVE="$TMPDIR_WORK/crux.tar.gz"
EXTRACTED="$TMPDIR_WORK/extracted"

info "Fetching archive from ${REPO}@${BRANCH}..."
download "$REPO_ARCHIVE" "$ARCHIVE"
mkdir -p "$EXTRACTED"
tar xzf "$ARCHIVE" --strip-components=1 -C "$EXTRACTED"
ok "Downloaded"

# Files to install from framework (not user-specific files like agents/)
FRAMEWORK_FILES=(
  ".crux/COORDINATOR.md"
  ".crux/AGENTS.md"
  "README.md"
  ".crux/bus/protocol.md"
  ".crux/templates/CONSTITUTION.template.md"
  ".crux/templates/SOUL.template.md"
  ".crux/templates/MANIFEST.template.md"
  ".crux/templates/INBOX.template.md"
  ".crux/templates/MEMORY.template.md"
  ".crux/templates/NOTES.template.md"
  ".crux/templates/AGENT.template.md"
  ".crux/templates/SKILL.template.md"
  ".crux/templates/WORKFLOW.template.md"
  ".crux/templates/DECISION.template.md"
  ".crux/templates/onboarding.template.md"
  ".crux/templates/decisions/TENANT-NAMING-CONVENTIONS.template.md"
  ".crux/templates/skills/example-skill/SKILL.md"
)

INSTALLED=0
SKIPPED=0

for rel in "${FRAMEWORK_FILES[@]}"; do
  src="$EXTRACTED/$rel"
  dest="./$rel"

  if [[ ! -f "$src" ]]; then
    warn "Not found in archive: $rel"
    continue
  fi

  if [[ -f "$dest" ]] && ! $FORCE; then
    info "Exists, skipping (--force to overwrite): $rel"
    SKIPPED=$((SKIPPED+1))
    continue
  fi

  if $DRY_RUN; then
    info "[dry-run] would install: $rel"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    ok "$rel"
  fi
  INSTALLED=$((INSTALLED+1))
done

ok "${INSTALLED} framework files installed, ${SKIPPED} skipped"

# ---------------------------------------------------------------------------
# Step 2: Install requested agents
# ---------------------------------------------------------------------------
step "Installing agents..."

if [[ -n "$AGENTS_ARG" ]]; then
  IFS=',' read -ra AGENT_LIST <<< "$AGENTS_ARG"
else
  # Install all available agents from the archive
  AGENT_LIST=()
  while IFS= read -r role; do
    AGENT_LIST+=("$role")
  done < <(
    find "$EXTRACTED/.crux/agents" -name "AGENT.md" 2>/dev/null \
    | while IFS= read -r f; do basename "$(dirname "$f")"; done \
    | sort
  )
fi

for role in "${AGENT_LIST[@]}"; do
  role=$(echo "$role" | xargs)  # trim whitespace
  src_agent="$EXTRACTED/.crux/agents/${role}/AGENT.md"
  src_onboarding="$EXTRACTED/.crux/agents/${role}/onboarding.md"
  dest_agent=".crux/agents/${role}/AGENT.md"
  dest_onboarding=".crux/agents/${role}/onboarding.md"

  if [[ ! -f "$src_agent" ]]; then
    warn "Agent not found in Crux framework: ${role}"
    warn "  To create a custom agent: copy .crux/templates/AGENT.template.md → .crux/agents/${role}/AGENT.md"
    continue
  fi

  if [[ -f "$dest_agent" ]] && ! $FORCE; then
    info "Agent exists, skipping: ${role} (--force to overwrite)"
    continue
  fi

  if $DRY_RUN; then
    info "[dry-run] would install agent: ${role}"
  else
    mkdir -p ".crux/agents/${role}"
    cp "$src_agent" "$dest_agent"
    ok "Agent: ${role}"
    if [[ -f "$src_onboarding" ]]; then
      cp "$src_onboarding" "$dest_onboarding"
      ok "  onboarding.md"
    fi
  fi
done

# ---------------------------------------------------------------------------
# Step 3: Install skills bundled with requested agents
# ---------------------------------------------------------------------------
step "Installing skills..."

# Find skills referenced by installed agents
for role in "${AGENT_LIST[@]}"; do
  agent_file=".crux/agents/${role}/AGENT.md"
  [[ ! -f "$agent_file" ]] && continue

  # Extract skill names from the Skills table
  while IFS= read -r skill_name; do
    skill_name=$(echo "$skill_name" | xargs)
    src_skill="$EXTRACTED/.crux/skills/${skill_name}/SKILL.md"
    dest_skill=".crux/skills/${skill_name}/SKILL.md"

    if [[ ! -f "$src_skill" ]]; then
      continue  # Custom or future skill — not bundled
    fi

    if [[ -f "$dest_skill" ]] && ! $FORCE; then
      continue  # Already installed
    fi

    if $DRY_RUN; then
      info "[dry-run] would install skill: ${skill_name}"
    else
      mkdir -p ".crux/skills/${skill_name}"
      cp "$src_skill" "$dest_skill"
      ok "Skill: ${skill_name}"
    fi
  done < <(
    awk '/## V\. Skills/,/^---/' "$agent_file" \
    | grep '^\| `' \
    | sed 's/.*`\([^`]*\)`.*/\1/'
  )
done

# ---------------------------------------------------------------------------
# Step 4: Create empty required directories
# ---------------------------------------------------------------------------
step "Creating directory structure..."

DIRS=(
  ".crux/agents"
  ".crux/decisions"
  ".crux/docs"
  ".crux/summaries"
  ".crux/workflows"
  ".crux/skills"
  ".crux/bus"
)

for d in "${DIRS[@]}"; do
  if $DRY_RUN; then
    info "[dry-run] would create: $d"
  else
    mkdir -p "$d"
  fi
done
ok "Directories ready"

# ---------------------------------------------------------------------------
# Step 5: .gitignore
# ---------------------------------------------------------------------------
step "Updating .gitignore..."

GITIGNORE_ENTRIES=(
  ".crux/workspace/"
)

if [[ -f ".gitignore" ]]; then
  for entry in "${GITIGNORE_ENTRIES[@]}"; do
    if grep -qxF "$entry" ".gitignore" 2>/dev/null; then
      info "Already in .gitignore: $entry"
    elif $DRY_RUN; then
      info "[dry-run] would add to .gitignore: $entry"
    else
      echo "$entry" >> ".gitignore"
      ok "Added to .gitignore: $entry"
    fi
  done
else
  if $DRY_RUN; then
    info "[dry-run] would create .gitignore"
  else
    printf '%s\n' "${GITIGNORE_ENTRIES[@]}" > ".gitignore"
    ok "Created .gitignore"
  fi
fi

# ---------------------------------------------------------------------------
# Step 6: Download and run convert.sh
# ---------------------------------------------------------------------------
step "Converting agent definitions to tool format..."

CONVERT_SCRIPT="./scripts/convert.sh"

# If running via curl (no local scripts/), download convert.sh
if [[ ! -f "$CONVERT_SCRIPT" ]]; then
  info "Downloading convert.sh..."
  if $DRY_RUN; then
    info "[dry-run] would download and run convert.sh"
  else
    mkdir -p "./scripts"
    cp "$EXTRACTED/scripts/convert.sh" "$CONVERT_SCRIPT"
    chmod +x "$CONVERT_SCRIPT"
    ok "scripts/convert.sh installed"
  fi
fi

CONVERT_ARGS=("--tool" "$TOOL")
$DRY_RUN && CONVERT_ARGS+=("--dry-run")

if $DRY_RUN; then
  info "[dry-run] would run: $CONVERT_SCRIPT ${CONVERT_ARGS[*]}"
else
  chmod +x "$CONVERT_SCRIPT"
  "$CONVERT_SCRIPT" "${CONVERT_ARGS[@]}"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo -e "${BOLD}${GREEN}┌─────────────────────────────────────────────┐${RESET}"
echo -e "${BOLD}${GREEN}│  Crux installed successfully                │${RESET}"
echo -e "${BOLD}${GREEN}└─────────────────────────────────────────────┘${RESET}"
echo ""
echo -e "  ${BOLD}Next steps:${RESET}"
echo ""
echo -e "  1. Start your AI tool in this project directory"
if [[ ${#AGENT_LIST[@]} -gt 0 ]]; then
  echo -e "  2. The coordinator will run installation on first boot"
  echo -e "     and ask a few questions to set up your workspace"
  echo -e "  3. Activate an agent:"
  for role in "${AGENT_LIST[@]}"; do
    echo -e "       ${CYAN}@${role}${RESET}"
  done
else
  echo -e "  2. The coordinator boots automatically and runs workspace installation"
fi
echo ""
echo -e "  ${BOLD}When you update agents or skills:${RESET}"
echo -e "    ${CYAN}./scripts/convert.sh${RESET}"
echo ""
