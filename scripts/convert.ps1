[CmdletBinding()]
param(
  [ValidateSet('auto', 'opencode', 'claude-code', 'cursor', 'codex', 'all')]
  [string]$Tool = 'auto',
  [Alias('crux')]
  [string]$Source = 'auto',
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function Write-Ok($Message) { Write-Host "  ✓ $Message" -ForegroundColor Green }
function Write-Info($Message) { Write-Host "  → $Message" -ForegroundColor Cyan }
function Write-Warn($Message) { Write-Host "  ⚠ $Message" -ForegroundColor Yellow }
function Write-Err($Message) { Write-Host "  ✗ $Message" -ForegroundColor Red }
function Write-Hdr($Message) { Write-Host "`n$Message" -ForegroundColor Blue }

function Get-CodexHome {
  if ($env:CODEX_HOME) { return $env:CODEX_HOME }
  return Join-Path $HOME '.codex'
}

function Get-ProjectSlug([string]$Path) {
  $name = Split-Path $Path -Leaf
  $slug = ($name.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
  if ([string]::IsNullOrWhiteSpace($slug)) { return 'crux' }
  return $slug
}

function Get-FrontmatterValue([string]$Key, [string]$FilePath) {
  $lines = Get-Content -LiteralPath $FilePath
  $inFrontmatter = $false
  $frontmatterCount = 0
  for ($index = 0; $index -lt $lines.Count; $index++) {
    $line = $lines[$index]
    if ($line -eq '---') {
      $frontmatterCount++
      if ($frontmatterCount -eq 1) { $inFrontmatter = $true; continue }
      break
    }
    if (-not $inFrontmatter) { continue }
    if ($line -match "^$([regex]::Escape($Key)):\s*(.*)$") {
      $value = $matches[1]
      if ($value -eq '>' -or $value -eq '|') {
        $buffer = New-Object System.Collections.Generic.List[string]
        for ($inner = $index + 1; $inner -lt $lines.Count; $inner++) {
          $nextLine = $lines[$inner]
          if ($nextLine -eq '---') { break }
          if ($nextLine -match '^\S') { break }
          $trimmed = $nextLine.Trim()
          if ($trimmed) { [void]$buffer.Add($trimmed) }
        }
        return ($buffer -join ' ')
      }
      return $value.Trim('"').Trim()
    }
  }
  return ''
}

function Write-File([string]$Path, [string]$Content) {
  if ($DryRun) {
    Write-Info "[dry-run] would write: $Path"
    return
  }

  $parent = Split-Path -Parent $Path
  if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
  [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
  Write-Ok $Path
}

function Copy-File([string]$SourcePath, [string]$DestPath) {
  if ($DryRun) {
    Write-Info "[dry-run] would copy: $SourcePath -> $DestPath"
    return
  }

  $parent = Split-Path -Parent $DestPath
  if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
  Copy-Item -LiteralPath $SourcePath -Destination $DestPath -Force
  Write-Ok $DestPath
}

function Detect-Tools {
  $detected = New-Object System.Collections.Generic.List[string]
  if (Test-Path '.opencode') { [void]$detected.Add('opencode') }
  if (Test-Path '.claude') { [void]$detected.Add('claude-code') }
  if (Test-Path '.cursor') { [void]$detected.Add('cursor') }
  if (Test-Path (Get-CodexHome)) { [void]$detected.Add('codex') }
  return $detected
}

if ($Source -eq 'auto') {
  if ((Test-Path 'COORDINATOR.md') -and (Test-Path 'agents') -and (Test-Path 'skills')) {
    $Source = '.'
  } elseif ((Test-Path '.crux/COORDINATOR.md') -and (Test-Path '.crux/agents') -and (Test-Path '.crux/skills')) {
    $Source = '.crux'
  } else {
    Write-Err 'No Crux source found. Run from the framework repo root or a project containing .crux/.'
    exit 1
  }
}

$sourceAbs = (Resolve-Path $Source).Path
if ((Split-Path $sourceAbs -Leaf) -eq '.crux') {
  $rootDir = Split-Path -Parent $sourceAbs
} else {
  $rootDir = $sourceAbs
}
$workspaceDir = Join-Path $rootDir '.crux/workspace'
$projectSlug = Get-ProjectSlug $rootDir
$coordinator = Join-Path $sourceAbs 'COORDINATOR.md'
$agentsDir = Join-Path $sourceAbs 'agents'
$skillsDir = Join-Path $sourceAbs 'skills'

if (-not (Test-Path $coordinator)) {
  Write-Err "$coordinator not found."
  exit 1
}

if ($Tool -eq 'auto') {
  $tools = Detect-Tools
  if ($tools.Count -eq 0) {
    Write-Warn 'No tools detected. Specify -Tool opencode|claude-code|cursor|codex|all'
    exit 0
  }
  Write-Info ("Auto-detected: {0}" -f ($tools -join ', '))
} elseif ($Tool -eq 'all') {
  $tools = @('opencode', 'claude-code', 'cursor', 'codex')
} else {
  $tools = @($Tool)
}

$agentFiles = Get-ChildItem -Path $agentsDir -Recurse -Filter AGENT.md | Sort-Object FullName
$skillFiles = Get-ChildItem -Path $skillsDir -Recurse -Filter SKILL.md | Sort-Object FullName

Write-Host "`nCrux convert"
Write-Host "Source:  $Source/"
Write-Host "Agents:  $($agentFiles.Count)"
Write-Host "Skills:  $($skillFiles.Count)"
Write-Host "Tools:   $($tools -join ', ')"
if ($DryRun) { Write-Host "Mode:    dry-run" -ForegroundColor Yellow }

function Convert-Opencode {
  Write-Hdr 'opencode'
  $agentOut = '.opencode/agent'
  $skillOut = '.opencode/skills'

  Copy-File $coordinator (Join-Path $agentOut 'crux-coordinator.md')

  foreach ($agentFile in $agentFiles) {
    $role = Split-Path -Leaf (Split-Path -Parent $agentFile.FullName)
    Copy-File $agentFile.FullName (Join-Path $agentOut "$role.md")
  }

  foreach ($skillFile in $skillFiles) {
    $name = Split-Path -Leaf (Split-Path -Parent $skillFile.FullName)
    Copy-File $skillFile.FullName (Join-Path (Join-Path $skillOut $name) 'SKILL.md')
  }
}

function Convert-ClaudeCode {
  Write-Hdr 'claude-code'

  foreach ($agentFile in $agentFiles) {
    $role = Split-Path -Leaf (Split-Path -Parent $agentFile.FullName)
    Copy-File $agentFile.FullName (Join-Path '.claude/agents' "$role.md")
  }

  $claudeMd = @"
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
"@

  if ((Test-Path 'CLAUDE.md') -and (Select-String -Path 'CLAUDE.md' -Pattern 'crux/COORDINATOR.md' -Quiet)) {
    Write-Warn 'CLAUDE.md already contains Crux instructions — skipping'
  } elseif (Test-Path 'CLAUDE.md') {
    if ($DryRun) {
      Write-Info '[dry-run] would append Crux section to CLAUDE.md'
    } else {
      Add-Content -LiteralPath 'CLAUDE.md' -Value "`n`n---`n`n$claudeMd"
      Write-Ok 'CLAUDE.md (appended)'
    }
  } else {
    Write-File 'CLAUDE.md' $claudeMd
  }
}

function Convert-Cursor {
  Write-Hdr 'cursor'
  $lines = New-Object System.Collections.Generic.List[string]
  [void]$lines.Add('# Crux — Agent Workspace Rules')
  [void]$lines.Add('')
  [void]$lines.Add('This project uses the Crux multi-agent framework. Read `.crux/COORDINATOR.md` on startup.')
  [void]$lines.Add('')
  [void]$lines.Add('## Active Agents')
  [void]$lines.Add('')

  foreach ($agentFile in $agentFiles) {
    $role = Split-Path -Leaf (Split-Path -Parent $agentFile.FullName)
    $description = Get-FrontmatterValue 'description' $agentFile.FullName
    [void]$lines.Add("- **`$role`** — $description")
  }

  [void]$lines.Add('')
  [void]$lines.Add('## Rules')
  [void]$lines.Add('')
  [void]$lines.Add('- Always read `.crux/COORDINATOR.md` before starting any task')
  [void]$lines.Add('- Load `.crux/workspace/MANIFEST.md` to understand current system state')
  [void]$lines.Add('- Agent definitions are in `.crux/agents/{role}/AGENT.md`')
  [void]$lines.Add('- Do not modify `.crux/agents/` files during a session')
  [void]$lines.Add('- Follow approval gates defined in each agent''s AGENT.md')

  Write-File '.cursor/rules/crux.mdc' (($lines -join "`n") + "`n")
}

function New-CodexCoordinatorSkill {
  @"
---
name: crux-$projectSlug-coordinator
description: Use when this workspace should be handled through the Crux coordinator so it can route work to the appropriate project agent.
---

# Crux Coordinator

Use this skill when the user wants to work through the Crux coordinator for the $projectSlug workspace, or when a request should be routed across multiple project agents instead of handled as a single generic coding task.

## Workspace Source Of Truth

Read these in order:
1. $sourceAbs/COORDINATOR.md
2. $rootDir/AGENTS.md
3. $rootDir/COORDINATOR.md if it exists outside installed .crux/
4. $workspaceDir/MANIFEST.md if it exists
5. $workspaceDir/TODO.md if it exists
6. $workspaceDir/inbox.md if it exists

## How To Operate

- Treat Crux markdown files as the authority for routing, approvals, and task continuity.
- Before delegating or continuing work, check coordinator task state in $workspaceDir/TODO.md when available.
- Prefer resuming an open task over creating duplicate work.
- When a specialist role is clearly a better fit, load that role's AGENT.md and, if present, SOUL.md, MEMORY.md, TODO.md, and NOTES.md before continuing.
- Load a role-owned Crux skill from $sourceAbs/skills/{skill-name}/SKILL.md only when the request actually needs that skill.
- Follow approval gates and escalation rules defined by the coordinator and selected agent.
"@
}

function New-CodexAgentSkill([string]$Role, [string]$DisplayName, [string]$Description) {
  @"
---
name: crux-$projectSlug-$Role
description: Use when the user explicitly wants the $DisplayName role from the $projectSlug Crux workspace, or when the task clearly matches this role's domain. $Description
---

# $DisplayName

This Codex skill is a wrapper around the Crux agent at $sourceAbs/agents/$Role/AGENT.md.

## Load Order

Read these sources before answering in this role:
1. $sourceAbs/agents/$Role/AGENT.md
2. $sourceAbs/agents/$Role/SOUL.md if present
3. $workspaceDir/$Role/MEMORY.md if present
4. $workspaceDir/$Role/TODO.md if present
5. $workspaceDir/$Role/NOTES.md if present
6. $workspaceDir/MANIFEST.md if broader project state is relevant
7. Any role-owned Crux skill from $sourceAbs/skills/{skill-name}/SKILL.md only when needed

## Operating Rules

- Stay inside this role's domain, boundaries, and escalation rules.
- Reuse open tasks from $workspaceDir/$Role/TODO.md before starting new parallel work.
- Treat TODO.md as task state, NOTES.md as support context, and MEMORY.md as durable facts.
- If the role's AGENT.md says another agent should own part of the work, hand off instead of improvising across boundaries.
- Use project-local Crux skills directly from the workspace source tree instead of inventing a second copy.
"@
}

function Convert-Codex {
  Write-Hdr 'codex'
  $skillRoot = Join-Path (Get-CodexHome) "skills/crux/$projectSlug"
  Write-File (Join-Path $skillRoot 'agents/coordinator/SKILL.md') (New-CodexCoordinatorSkill)

  foreach ($agentFile in $agentFiles) {
    $role = Split-Path -Leaf (Split-Path -Parent $agentFile.FullName)
    $displayName = Get-FrontmatterValue 'name' $agentFile.FullName
    $description = Get-FrontmatterValue 'description' $agentFile.FullName
    Write-File (Join-Path $skillRoot "agents/$role/SKILL.md") (New-CodexAgentSkill -Role $role -DisplayName $displayName -Description $description)
  }
}

$converted = 0
foreach ($toolName in $tools) {
  switch ($toolName) {
    'opencode' { Convert-Opencode; $converted++ }
    'claude-code' { Convert-ClaudeCode; $converted++ }
    'cursor' { Convert-Cursor; $converted++ }
    'codex' { Convert-Codex; $converted++ }
    default { Write-Warn "Unknown tool: $toolName (supported: opencode, claude-code, cursor, codex)" }
  }
}

Write-Host ''
if ($converted -gt 0) {
  Write-Host "Done. $converted tool(s) converted." -ForegroundColor Green
  Write-Host 'Re-run after editing any agents/ or skills/ source file,'
  Write-Host 'or installed .crux/agents/ / .crux/skills/ in a user project.'
} else {
  Write-Warn 'Nothing converted.'
}
