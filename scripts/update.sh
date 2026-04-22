#!/usr/bin/env bash
# Requires bash 3.2+ (macOS default)
# =============================================================================
# Crux — update.sh
# Pulls the latest agent, skill, and framework files from the Crux repo
# and re-runs convert.sh to sync tool-specific locations.
#
# Usage:
#   ./scripts/update.sh                          # update all agents and framework
#   ./scripts/update.sh --agents kubernetes-admin,postgresql-admin
#   ./scripts/update.sh --tool opencode
#   ./scripts/update.sh --dry-run
#
# Note: --force is passed to install.sh automatically.
#       Local changes to .crux/agents/ or .crux/skills/ will be overwritten.
# =============================================================================
set -euo pipefail

CYAN='\033[0;36m'; BOLD='\033[1m'; YELLOW='\033[1;33m'; RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"

if [[ ! -f "$INSTALL_SCRIPT" ]]; then
  echo -e "  ${YELLOW}⚠${RESET} install.sh not found at $INSTALL_SCRIPT"
  exit 1
fi

echo ""
echo -e "${BOLD}${CYAN}Crux update${RESET}"
echo -e "Pulling latest agents and skills from remote..."
echo ""

exec bash "$INSTALL_SCRIPT" --force "$@"
