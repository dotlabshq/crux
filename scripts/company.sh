#!/usr/bin/env bash
# Requires bash 3.2+ (macOS default)
# =============================================================================
# Crux — company.sh
# Creates and extends a Crux company: a git repository of teams that own
# paths and exchange requests. Protocol: skills/crux-team/SKILL.md.
#
# Usage:
#   company.sh init <id> [--root <dir>] [--name <name>] [--description <text>]
#   company.sh team add <id> --role <r1,r2> --owns <p1,p2>
#                         [--also <p1,p2>] [--skills <s1,s2>]
#                         [--company <id> | --root <dir>]
#   company.sh list
#   company.sh resolve [<dir>]      which company and team own <dir> (default: cwd)
#
# Common options: --dry-run
# =============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET} $*"; }
info() { echo -e "  ${CYAN}→${RESET} $*"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $*"; }
err()  { echo -e "  ${RED}✗${RESET} $*" >&2; }
die()  { err "$*"; exit 1; }

FRAMEWORK_HOME="${CRUX_HOME:-$HOME/.crux}"
REGISTRY="$FRAMEWORK_HOME/companies.toml"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES="$SCRIPT_DIR/../templates"
[[ -d "$TEMPLATES" ]] || TEMPLATES="$FRAMEWORK_HOME/templates"
TODAY="$(date +%Y-%m-%d)"
DRY_RUN=false

usage() { sed -n '/^# Usage:/,/^# Common/p' "$0" | sed 's/^# \{0,1\}//'; }

valid_id() { [[ "$1" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; }

abspath() { (cd "$1" && pwd -P); }

# Write $2 to file $1 unless it exists.
write_new() {
  local dest="$1" content="$2"
  if [[ -e "$dest" ]]; then
    info "Exists, keeping: $dest"
    return
  fi
  if $DRY_RUN; then
    info "[dry-run] would create: $dest"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  printf '%s\n' "$content" > "$dest"
  ok "$dest"
}

make_dir() {
  local d="$1"
  if $DRY_RUN; then info "[dry-run] would create: $d/"; return; fi
  mkdir -p "$d"
  [[ -n "$(ls -A "$d" 2>/dev/null)" ]] || touch "$d/.gitkeep"
}

template() {
  local f="$TEMPLATES/$1"
  [[ -f "$f" ]] || die "Template missing: $f (run install.sh or update.sh)"
  cat "$f"
}

# Body of a template after its frontmatter.
template_body() {
  template "$1" | awk 'n>=2 {print; next} /^---$/ {n++}'
}

# ---------------------------------------------------------------------------
# Registry
# ---------------------------------------------------------------------------
registry_root() {
  [[ -f "$REGISTRY" ]] || return 0
  awk -v id="$1" '
    /^\[/ { cur = $0; gsub(/[][ ]/, "", cur); next }
    cur == id && $1 == "root" { sub(/^[^=]*=[ ]*"/, ""); sub(/".*$/, ""); print; exit }
  ' "$REGISTRY"
}

registry_add() {
  local id="$1" root="$2" existing
  existing="$(registry_root "$id")"
  if [[ -n "$existing" ]]; then
    [[ "$existing" == "$root" ]] || die "Registry already maps '$id' to $existing"
    info "Registry already has $id → $root"
    return
  fi
  if $DRY_RUN; then info "[dry-run] would register $id → $root in $REGISTRY"; return; fi
  mkdir -p "$FRAMEWORK_HOME"
  [[ -s "$REGISTRY" ]] && printf '\n' >> "$REGISTRY"
  printf '[%s]\nroot = "%s"\n' "$id" "$root" >> "$REGISTRY"
  ok "Registered $id → $root in $REGISTRY"
}

# ---------------------------------------------------------------------------
# Company root discovery
# ---------------------------------------------------------------------------
find_company_root() {
  local dir
  dir="$(pwd -P)"
  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/.crux/COMPANY.md" ]] && { echo "$dir"; return; }
    dir="$(dirname "$dir")"
  done
  if [[ -f ".crux/company" ]]; then
    registry_root "$(tr -d '[:space:]' < .crux/company)"
  fi
}

frontmatter_value() {
  awk -v k="$2" 'NR==1 && /^---$/ {fm=1; next} fm && /^---$/ {exit}
    fm && $1 == k":" {sub(/^[^:]*:[ ]*/, ""); sub(/[ ]*#.*$/, ""); print; exit}' "$1"
}

# List items of a frontmatter key: "key:\n  - a\n  - b" or "key: [a, b]".
frontmatter_list() {
  awk -v k="$2" '
    NR==1 && /^---$/ {fm=1; next}
    fm && /^---$/ {exit}
    !fm {next}
    $1 == k":" {
      rest = $0; sub(/^[^:]*:[ ]*/, "", rest); sub(/[ ]*#.*$/, "", rest)
      if (rest ~ /^\[/) { gsub(/[][ ]/, "", rest); n = split(rest, a, ","); for (i=1;i<=n;i++) if (a[i]!="") print a[i]; exit }
      inlist = 1; next
    }
    inlist && /^[ ]+-/ { v = $0; sub(/^[ ]+-[ ]*/, "", v); sub(/[ ]*#.*$/, "", v); print v; next }
    inlist && /^[^ ]/ { exit }
  ' "$1"
}

# Normalise an owned path relative to the company root.
norm_path() {
  local p="$1" root="$2"
  case "$p" in
    "$root") p="." ;;
    "$root"/*) p="${p#$root/}" ;;
  esac
  p="${p#./}"; p="${p%/}"
  [[ -z "$p" ]] && p="."
  echo "$p"
}

split_csv() { echo "$1" | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$' || true; }

yaml_list() {
  local key="$1" items="$2"
  if [[ -z "$items" ]]; then
    echo "$key: []"
  else
    echo "$key:"
    echo "$items" | sed 's/^/  - /'
  fi
}

# ---------------------------------------------------------------------------
# init
# ---------------------------------------------------------------------------
cmd_init() {
  local id="" root="." name="" description=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)        root="$2"; shift 2 ;;
      --name)        name="$2"; shift 2 ;;
      --description) description="$2"; shift 2 ;;
      --dry-run)     DRY_RUN=true; shift ;;
      -*)            die "Unknown option: $1" ;;
      *)             [[ -z "$id" ]] || die "Unexpected argument: $1"; id="$1"; shift ;;
    esac
  done
  [[ -n "$id" ]] || die "Company id required: company.sh init <id>"
  valid_id "$id" || die "Invalid id '$id' (lowercase letters, digits, hyphens)"
  [[ -d "$root" ]] || die "Root does not exist: $root"
  root="$(abspath "$root")"
  [[ -n "$name" ]] || name="$id"
  [[ -n "$description" ]] || description="{{One sentence on what the company is.}}"

  if [[ -f "$root/.crux/COMPANY.md" ]]; then
    local existing
    existing="$(frontmatter_value "$root/.crux/COMPANY.md" id)"
    [[ "$existing" == "$id" ]] || die "$root is already company '$existing'"
  fi

  echo -e "\n${BOLD}Crux company init${RESET}  $id → $root\n"

  local company
  company="$(template COMPANY.template.md \
    | sed -e "s|{{COMPANY_ID}}|$id|g" -e "s|{{COMPANY_NAME}}|$name|g" -e "s|{{DATE}}|$TODAY|g" \
    | awk -v d="$description" '{ if ($0 == "{{One sentence on what the company is.}}") print d; else print }')"
  write_new "$root/.crux/COMPANY.md" "$company"
  write_new "$root/.crux/CONSTITUTION.md" "$(template CONSTITUTION.company.template.md)"
  write_new "$root/.crux/SOUL.md" "$(template SOUL.template.md)"

  local d
  for d in decisions docs summaries requests/coordinator; do
    make_dir "$root/.crux/$d"
  done

  local team_body
  team_body="$(template_body TEAM.template.md | sed "s|{{TEAM_ID}}|coordinator|g")"
  write_new "$root/.crux/teams/coordinator/TEAM.md" "---
id: coordinator
roles:
  - company-coordinator
skills:
  - crux-coordinator
  - crux-team
owns:
  - .
also: []
---
$team_body"

  local agents_content
  agents_content="$(template AGENTS.company.template.md | sed "s|{{COMPANY_ID}}|$id|g")"
  if [[ -f "$root/AGENTS.md" ]]; then
    if grep -q "Crux Company Bootstrap" "$root/AGENTS.md"; then
      info "AGENTS.md already contains the company bootstrap"
    elif $DRY_RUN; then
      info "[dry-run] would prepend company bootstrap to $root/AGENTS.md"
    else
      local tmp; tmp="$(mktemp)"
      { printf '%s\n\n---\n\n' "$agents_content"; cat "$root/AGENTS.md"; } > "$tmp"
      mv "$tmp" "$root/AGENTS.md"
      ok "$root/AGENTS.md (prepended company bootstrap)"
    fi
  else
    write_new "$root/AGENTS.md" "$agents_content"
  fi

  if grep -qxF ".crux/workspace/" "$root/.gitignore" 2>/dev/null; then
    info ".gitignore already ignores .crux/workspace/"
  elif $DRY_RUN; then
    info "[dry-run] would add .crux/workspace/ to $root/.gitignore"
  else
    echo ".crux/workspace/" >> "$root/.gitignore"
    ok "$root/.gitignore: .crux/workspace/"
  fi

  registry_add "$id" "$root"

  echo ""
  info "Next: add teams with  company.sh team add <id> --role <role> --owns <path>"
  [[ -d "$root/.git" ]] || warn "$root is not a git repository yet; the board is meant to be committed"
}

# ---------------------------------------------------------------------------
# team add
# ---------------------------------------------------------------------------
cmd_team_add() {
  local id="" roles="" owns="" also="" skills="" company="" root=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --role|--roles) roles="$2"; shift 2 ;;
      --owns)         owns="$2"; shift 2 ;;
      --also)         also="$2"; shift 2 ;;
      --skills)       skills="$2"; shift 2 ;;
      --company)      company="$2"; shift 2 ;;
      --root)         root="$2"; shift 2 ;;
      --dry-run)      DRY_RUN=true; shift ;;
      -*)             die "Unknown option: $1" ;;
      *)              [[ -z "$id" ]] || die "Unexpected argument: $1"; id="$1"; shift ;;
    esac
  done
  [[ -n "$id" ]] || die "Team id required: company.sh team add <id> --role … --owns …"
  valid_id "$id" || die "Invalid team id '$id'"
  [[ -n "$roles" ]] || die "--role is required"
  [[ -n "$owns" ]]  || die "--owns is required"

  if [[ -n "$company" ]]; then
    root="$(registry_root "$company")"
    [[ -n "$root" ]] || die "Company '$company' is not in $REGISTRY"
  elif [[ -z "$root" ]]; then
    root="$(find_company_root)"
  fi
  [[ -n "$root" && -f "$root/.crux/COMPANY.md" ]] || die "No Crux company found (use --company or --root, or run company.sh init)"
  root="$(abspath "$root")"

  local team_file="$root/.crux/teams/$id/TEAM.md"
  [[ ! -f "$team_file" ]] || die "Team '$id' already exists: $team_file"

  local role
  for role in $(split_csv "$roles"); do
    [[ -f "$FRAMEWORK_HOME/agents/$role/AGENT.md" ]] || warn "Role not installed in framework home: $role"
  done

  # Normalise owned paths and check exclusivity against every other team.
  local owned="" p np other other_id op
  for p in $(split_csv "$owns"); do
    [[ "$p" == /* && "$p" != "$root" && "$p" != "$root/"* ]] && warn "Owned path outside the company root: $p"
    np="$(norm_path "$p" "$root")"
    [[ -e "$root/$np" || "$np" == /* ]] || warn "Owned path does not exist yet: $np"
    for other in "$root"/.crux/teams/*/TEAM.md; do
      [[ -f "$other" ]] || continue
      other_id="$(basename "$(dirname "$other")")"
      while IFS= read -r op; do
        [[ -n "$op" ]] || continue
        [[ "$(norm_path "$op" "$root")" == "$np" ]] && die "'$np' is already owned by team '$other_id'"
      done < <(frontmatter_list "$other" owns)
    done
    owned="${owned}${owned:+$'\n'}$np"
  done

  local also_list="" skills_list="" roles_list
  roles_list="$(split_csv "$roles")"
  for p in $(split_csv "$also"); do also_list="${also_list}${also_list:+$'\n'}$(norm_path "$p" "$root")"; done
  skills_list="$(split_csv "$skills")"

  local body
  body="$(template_body TEAM.template.md | sed "s|{{TEAM_ID}}|$id|g")"
  write_new "$team_file" "---
id: $id
$(yaml_list roles "$roles_list")
$(yaml_list skills "$skills_list")
$(yaml_list owns "$owned")
$(yaml_list also "$also_list")
---
$body"
  make_dir "$root/.crux/requests/$id"

  local cid
  cid="$(frontmatter_value "$root/.crux/COMPANY.md" id)"
  echo ""
  info "Team $cid/$id created. Fill in its paragraph in $team_file and commit at $root."
}

# Absolute form of an owned path (relative paths are against the company root).
abs_owned() {
  local p="$1" root="$2"
  [[ "$p" == /* ]] || p="$root/$p"
  if [[ -d "$p" ]]; then abspath "$p"; else echo "${p%/}"; fi
}

# Print "<team>\t<owned-abs-path>\t<kind>" for the best match of <dir> in the
# company at <root>: longest `owns` prefix, else a single `also` match.
team_for_dir() {
  local root="$1" dir="$2" f team op ap kind best="" best_len=-1 also_hits="" also_count=0
  for f in "$root"/.crux/teams/*/TEAM.md; do
    [[ -f "$f" ]] || continue
    team="$(basename "$(dirname "$f")")"
    for kind in owns also; do
      while IFS= read -r op; do
        [[ -n "$op" ]] || continue
        ap="$(abs_owned "$op" "$root")"
        [[ "$dir" == "$ap" || "$dir" == "$ap"/* ]] || continue
        if [[ "$kind" == owns ]]; then
          if (( ${#ap} > best_len )); then best="$team"$'\t'"$ap"$'\towns'; best_len=${#ap}; fi
        else
          also_hits="$team"$'\t'"$ap"$'\talso'; also_count=$((also_count+1))
        fi
      done < <(frontmatter_list "$f" "$kind")
    done
  done
  if [[ -n "$best" ]]; then echo "$best"
  elif (( also_count == 1 )); then echo "$also_hits"
  fi
}

cmd_resolve() {
  local dir="${1:-.}" root="" via="" d id r hit
  [[ -d "$dir" ]] || die "Not a directory: $dir"
  dir="$(abspath "$dir")"

  d="$dir"
  while [[ "$d" != "/" ]]; do
    [[ -f "$d/.crux/COMPANY.md" ]] && { root="$d"; via="walk-up"; break; }
    d="$(dirname "$d")"
  done
  if [[ -z "$root" && -f "$dir/.crux/company" ]]; then
    root="$(registry_root "$(tr -d '[:space:]' < "$dir/.crux/company")")"; via="marker"
  fi
  if [[ -z "$root" && -f "$REGISTRY" ]]; then
    while IFS=$'\t' read -r id r; do
      [[ -f "$r/.crux/COMPANY.md" ]] || continue
      if [[ -n "$(team_for_dir "$r" "$dir")" ]]; then root="$r"; via="registry"; break; fi
    done < <(awk '/^\[/ {id=$0; gsub(/[][ ]/, "", id)} $1=="root" {r=$0; sub(/^[^=]*=[ ]*"/, "", r); sub(/".*$/, "", r); print id "\t" r}' "$REGISTRY")
  fi
  [[ -n "$root" ]] || { info "$dir: not in a Crux company"; return 1; }

  local cid team="" owned="" kind=""
  cid="$(frontmatter_value "$root/.crux/COMPANY.md" id)"
  hit="$(team_for_dir "$root" "$dir")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r team owned kind <<< "$hit"
  elif [[ "$dir" == "$root" ]]; then
    team="$(frontmatter_value "$root/.crux/COMPANY.md" coordinator)"; owned="$root"; kind="root"
  fi

  echo -e "  Dir:      $dir"
  echo -e "  Company:  ${BOLD}$cid${RESET}  ($root, via $via)"
  if [[ -n "$team" ]]; then
    echo -e "  Team:     ${BOLD}$cid/$team${RESET}  ($kind $owned)"
    echo -e "  Inbox:    $root/.crux/requests/$team/"
  else
    warn "No team owns this directory — ask, or add one with: company.sh team add"
    return 1
  fi
}

cmd_list() {
  if [[ ! -f "$REGISTRY" ]]; then
    info "No companies registered ($REGISTRY missing)"
    return
  fi
  awk '/^\[/ {id=$0; gsub(/[][ ]/, "", id)} $1=="root" {r=$0; sub(/^[^=]*=[ ]*"/, "", r); sub(/".*$/, "", r); print id "\t" r}' "$REGISTRY" \
  | while IFS=$'\t' read -r id r; do
      local teams=""
      if [[ -d "$r/.crux/teams" ]]; then
        teams="$(ls "$r/.crux/teams" | tr '\n' ' ')"
      else
        teams="(root missing or not initialised)"
      fi
      echo -e "  ${BOLD}$id${RESET}  $r\n      teams: $teams"
    done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
[[ $# -gt 0 ]] || { usage; exit 1; }
case "$1" in
  init)   shift; cmd_init "$@" ;;
  team)
    shift
    [[ "${1:-}" == "add" ]] || die "Unknown team command: ${1:-} (expected: team add)"
    shift; cmd_team_add "$@" ;;
  list)   shift; cmd_list ;;
  resolve) shift; cmd_resolve "$@" ;;
  -h|--help|help) usage ;;
  *) die "Unknown command: $1" ;;
esac
