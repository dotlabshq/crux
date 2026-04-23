#!/usr/bin/env bash
# Requires bash 3.2+ (macOS default)
# =============================================================================
# Crux — install.sh
# Downloads the Crux framework source, maps it into `.crux/` in the current
# project, and converts agent definitions for the specified AI tool.
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
# Helpers
# ---------------------------------------------------------------------------
install_file() {
  local src="$1"
  local dest="$2"

  if [[ ! -f "$src" ]]; then
    warn "Not found in archive: ${src#$EXTRACTED/}"
    return
  fi

  if [[ -f "$dest" ]] && ! $FORCE; then
    info "Exists, skipping (--force to overwrite): ${dest#./}"
    SKIPPED=$((SKIPPED+1))
    return
  fi

  if $DRY_RUN; then
    info "[dry-run] would install: ${dest#./}"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    ok "${dest#./}"
  fi
  INSTALLED=$((INSTALLED+1))
}

install_tree() {
  local src_root="$1"
  local dest_root="$2"

  if [[ ! -d "$src_root" ]]; then
    warn "Not found in archive: ${src_root#$EXTRACTED/}"
    return
  fi

  while IFS= read -r src_file; do
    local rel dest
    rel="${src_file#$src_root/}"
    dest="$dest_root/$rel"
    install_file "$src_file" "$dest"
  done < <(find "$src_root" -type f | sort)
}

# ---------------------------------------------------------------------------
# Step 1: Download framework source
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

INSTALLED=0
SKIPPED=0

install_file "$EXTRACTED/COORDINATOR.md" "./.crux/COORDINATOR.md"
install_file "$EXTRACTED/AGENTS.md" "./.crux/AGENTS.md"
install_tree "$EXTRACTED/bus" "./.crux/bus"
install_tree "$EXTRACTED/templates" "./.crux/templates"
install_tree "$EXTRACTED/workflows" "./.crux/workflows"

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
    find "$EXTRACTED/agents" -name "AGENT.md" 2>/dev/null \
    | while IFS= read -r f; do basename "$(dirname "$f")"; done \
    | sort
  )
fi

for role in "${AGENT_LIST[@]}"; do
  role=$(echo "$role" | xargs)  # trim whitespace
  src_agent_dir="$EXTRACTED/agents/${role}"
  dest_agent_dir=".crux/agents/${role}"
  src_agent="$src_agent_dir/AGENT.md"
  dest_agent="$dest_agent_dir/AGENT.md"

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
    info "Installing agent directory: ${role}"
  fi

  install_tree "$src_agent_dir" "$dest_agent_dir"
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
    src_skill_dir="$EXTRACTED/skills/${skill_name}"
    src_skill="$src_skill_dir/SKILL.md"
    dest_skill_dir=".crux/skills/${skill_name}"
    dest_skill="$dest_skill_dir/SKILL.md"

    if [[ ! -f "$src_skill" ]]; then
      continue  # Custom or future skill — not bundled
    fi

    if [[ -f "$dest_skill" ]] && ! $FORCE; then
      continue  # Already installed
    fi

    if $DRY_RUN; then
      info "[dry-run] would install skill: ${skill_name}"
    else
      info "Installing skill directory: ${skill_name}"
    fi

    install_tree "$src_skill_dir" "$dest_skill_dir"
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
  ".crux"
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

# Install all scripts from archive (convert.sh, install.sh, update.sh)
for _script in convert.sh install.sh update.sh; do
  _src="$EXTRACTED/scripts/${_script}"
  _dest="./scripts/${_script}"
  [[ ! -f "$_src" ]] && continue
  if [[ -f "$_dest" ]] && ! $FORCE; then
    info "Exists, skipping (--force to overwrite): scripts/${_script}"
  elif $DRY_RUN; then
    info "[dry-run] would install: scripts/${_script}"
  else
    mkdir -p "./scripts"
    cp "$_src" "$_dest"
    chmod +x "$_dest"
    ok "scripts/${_script}"
  fi
done

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
  echo -e "  2. The coordinator will run workspace initialisation on first boot"
  echo -e "     and ask a few questions to set up your workspace"
  echo -e "  3. Activate an agent:"
  for role in "${AGENT_LIST[@]}"; do
    echo -e "       ${CYAN}@${role}${RESET}"
  done
else
  echo -e "  2. The coordinator boots automatically and runs workspace initialisation"
fi
echo ""
echo -e "  ${BOLD}When you update agents or skills:${RESET}"
echo -e "    ${CYAN}./scripts/convert.sh${RESET}"
echo ""
