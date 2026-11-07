# =============================================================================
# Crux — company.ps1
# Creates and extends a Crux company: a git repository of teams that own
# paths and exchange requests. Protocol: skills/crux-team/SKILL.md.
#
# Usage:
#   company.ps1 init <id> [-Root <dir>] [-Name <name>] [-Description <text>]
#   company.ps1 team add <id> -Role <r1,r2> -Owns <p1,p2>
#                         [-Also <p1,p2>] [-Skills <s1,s2>]
#                         [-Company <id> | -Root <dir>]
#   company.ps1 list
#   company.ps1 resolve [<dir>]     which company and team own <dir> (default: cwd)
#
# Common options: -DryRun
# =============================================================================
[CmdletBinding()]
param(
  [Parameter(Position = 0)][string]$Command = '',
  [Parameter(Position = 1)][string]$Arg1 = '',
  [Parameter(Position = 2)][string]$Arg2 = '',
  [string]$Root = '',
  [string]$Name = '',
  [string]$Description = '',
  [string]$Role = '',
  [string]$Owns = '',
  [string]$Also = '',
  [string]$Skills = '',
  [string]$Company = '',
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$FrameworkHome = if ($env:CRUX_HOME) { $env:CRUX_HOME } else { Join-Path $HOME '.crux' }
$Registry = Join-Path $FrameworkHome 'companies.toml'
$Templates = Join-Path (Split-Path -Parent $PSScriptRoot) 'templates'
if (-not (Test-Path $Templates)) { $Templates = Join-Path $FrameworkHome 'templates' }
$Today = Get-Date -Format 'yyyy-MM-dd'

function Write-Ok($Message) { Write-Host "  ✓ $Message" -ForegroundColor Green }
function Write-Info($Message) { Write-Host "  → $Message" -ForegroundColor Cyan }
function Write-Warn($Message) { Write-Host "  ⚠ $Message" -ForegroundColor Yellow }
function Stop-WithError($Message) { Write-Host "  ✗ $Message" -ForegroundColor Red; exit 1 }

function Test-ValidId([string]$Id) { return $Id -cmatch '^[a-z0-9]+(-[a-z0-9]+)*$' }

function Split-Csv([string]$Value) {
  if (-not $Value) { return @() }
  return @($Value -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

function Write-NewFile([string]$Dest, [string]$Content) {
  if (Test-Path $Dest) { Write-Info "Exists, keeping: $Dest"; return }
  if ($DryRun) { Write-Info "[dry-run] would create: $Dest"; return }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Dest) | Out-Null
  Set-Content -LiteralPath $Dest -Value $Content -Encoding utf8
  Write-Ok $Dest
}

function New-BoardDir([string]$Dir) {
  if ($DryRun) { Write-Info "[dry-run] would create: $Dir/"; return }
  New-Item -ItemType Directory -Force -Path $Dir | Out-Null
  if (-not (Get-ChildItem -Force -LiteralPath $Dir)) { New-Item -ItemType File -Path (Join-Path $Dir '.gitkeep') | Out-Null }
}

function Get-Template([string]$File) {
  $path = Join-Path $Templates $File
  if (-not (Test-Path $path)) { Stop-WithError "Template missing: $path (run install.ps1 or update.ps1)" }
  return (Get-Content -Raw -LiteralPath $path).TrimEnd()
}

function Get-TemplateBody([string]$File) {
  $lines = (Get-Template $File) -split "`r?`n"
  $count = 0
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -eq '---') { $count++; if ($count -eq 2) { return ($lines[($i + 1)..($lines.Count - 1)] -join "`n") } }
  }
  return ''
}

# ---------------------------------------------------------------------------
# Registry
# ---------------------------------------------------------------------------
function Get-Registry {
  $map = [ordered]@{}
  if (-not (Test-Path $Registry)) { return $map }
  $current = ''
  foreach ($line in Get-Content -LiteralPath $Registry) {
    if ($line -match '^\s*\[\s*([^\]]+?)\s*\]') { $current = $Matches[1]; continue }
    if ($current -and $line -match '^\s*root\s*=\s*"([^"]*)"') { $map[$current] = $Matches[1] }
  }
  return $map
}

function Add-RegistryEntry([string]$Id, [string]$CompanyRoot) {
  $map = Get-Registry
  if ($map.Contains($Id)) {
    if ($map[$Id] -ne $CompanyRoot) { Stop-WithError "Registry already maps '$Id' to $($map[$Id])" }
    Write-Info "Registry already has $Id → $CompanyRoot"
    return
  }
  if ($DryRun) { Write-Info "[dry-run] would register $Id → $CompanyRoot in $Registry"; return }
  New-Item -ItemType Directory -Force -Path $FrameworkHome | Out-Null
  $prefix = if ((Test-Path $Registry) -and (Get-Item $Registry).Length -gt 0) { "`n" } else { '' }
  Add-Content -LiteralPath $Registry -Value "$prefix[$Id]`nroot = `"$CompanyRoot`"" -Encoding utf8
  Write-Ok "Registered $Id → $CompanyRoot in $Registry"
}

# ---------------------------------------------------------------------------
# Company root discovery and frontmatter
# ---------------------------------------------------------------------------
function Find-CompanyRoot {
  $dir = (Get-Location).ProviderPath
  while ($dir) {
    if (Test-Path (Join-Path $dir '.crux/COMPANY.md')) { return $dir }
    $parent = Split-Path -Parent $dir
    if ($parent -eq $dir) { break }
    $dir = $parent
  }
  if (Test-Path '.crux/company') {
    $id = (Get-Content -Raw '.crux/company').Trim()
    $map = Get-Registry
    if ($map.Contains($id)) { return $map[$id] }
  }
  return ''
}

function Get-FrontmatterLines([string]$File) {
  $lines = Get-Content -LiteralPath $File
  if ($lines.Count -eq 0 -or $lines[0] -ne '---') { return @() }
  $out = @()
  for ($i = 1; $i -lt $lines.Count; $i++) { if ($lines[$i] -eq '---') { break }; $out += $lines[$i] }
  return $out
}

function Get-FrontmatterValue([string]$File, [string]$Key) {
  foreach ($line in Get-FrontmatterLines $File) {
    if ($line -match "^$Key\s*:\s*(.*?)\s*(#.*)?$") { return $Matches[1] }
  }
  return ''
}

function Get-FrontmatterList([string]$File, [string]$Key) {
  $items = @(); $inList = $false
  foreach ($line in Get-FrontmatterLines $File) {
    if ($line -match "^$Key\s*:\s*(.*?)\s*(#.*)?$") {
      $rest = $Matches[1]
      if ($rest.StartsWith('[')) { return Split-Csv ($rest.Trim('[', ']')) }
      $inList = $true; continue
    }
    if ($inList -and $line -match '^\s+-\s*(.*?)\s*(#.*)?$') { $items += $Matches[1]; continue }
    if ($inList -and $line -match '^\S') { break }
  }
  return $items
}

function Get-NormalPath([string]$Path, [string]$CompanyRoot) {
  $p = $Path
  if ($p -eq $CompanyRoot) { $p = '.' }
  elseif ($p.StartsWith("$CompanyRoot/") -or $p.StartsWith("$CompanyRoot\")) { $p = $p.Substring($CompanyRoot.Length + 1) }
  $p = $p -replace '\\', '/'
  if ($p.StartsWith('./')) { $p = $p.Substring(2) }
  $p = $p.TrimEnd('/')
  if (-not $p) { $p = '.' }
  return $p
}

function Format-YamlList([string]$Key, [string[]]$Items) {
  if (-not $Items -or $Items.Count -eq 0) { return "${Key}: []" }
  return "${Key}:`n" + (($Items | ForEach-Object { "  - $_" }) -join "`n")
}

# ---------------------------------------------------------------------------
# init
# ---------------------------------------------------------------------------
function Invoke-Init([string]$Id) {
  if (-not $Id) { Stop-WithError 'Company id required: company.ps1 init <id>' }
  if (-not (Test-ValidId $Id)) { Stop-WithError "Invalid id '$Id' (lowercase letters, digits, hyphens)" }
  $companyRoot = if ($Root) { $Root } else { '.' }
  if (-not (Test-Path $companyRoot)) { Stop-WithError "Root does not exist: $companyRoot" }
  $companyRoot = (Resolve-Path $companyRoot).ProviderPath
  $displayName = if ($Name) { $Name } else { $Id }
  $sentence = if ($Description) { $Description } else { '{{One sentence on what the company is.}}' }

  $companyFile = Join-Path $companyRoot '.crux/COMPANY.md'
  if (Test-Path $companyFile) {
    $existing = Get-FrontmatterValue $companyFile 'id'
    if ($existing -ne $Id) { Stop-WithError "$companyRoot is already company '$existing'" }
  }

  Write-Host "`nCrux company init  $Id → $companyRoot`n" -ForegroundColor White

  $company = (Get-Template 'COMPANY.template.md').Replace('{{COMPANY_ID}}', $Id).Replace('{{COMPANY_NAME}}', $displayName).Replace('{{DATE}}', $Today).Replace('{{One sentence on what the company is.}}', $sentence)
  Write-NewFile $companyFile $company
  Write-NewFile (Join-Path $companyRoot '.crux/CONSTITUTION.md') (Get-Template 'CONSTITUTION.company.template.md')
  Write-NewFile (Join-Path $companyRoot '.crux/SOUL.md') (Get-Template 'SOUL.template.md')

  foreach ($d in @('decisions', 'docs', 'summaries', 'requests/coordinator')) {
    New-BoardDir (Join-Path $companyRoot ".crux/$d")
  }

  $body = (Get-TemplateBody 'TEAM.template.md').Replace('{{TEAM_ID}}', 'coordinator')
  Write-NewFile (Join-Path $companyRoot '.crux/teams/coordinator/TEAM.md') @"
---
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
$body
"@

  $agentsFile = Join-Path $companyRoot 'AGENTS.md'
  $agents = (Get-Template 'AGENTS.company.template.md').Replace('{{COMPANY_ID}}', $Id)
  if (Test-Path $agentsFile) {
    if (Select-String -LiteralPath $agentsFile -Pattern 'Crux Company Bootstrap' -Quiet) {
      Write-Info 'AGENTS.md already contains the company bootstrap'
    } elseif ($DryRun) {
      Write-Info "[dry-run] would prepend company bootstrap to $agentsFile"
    } else {
      $existingAgents = Get-Content -Raw -LiteralPath $agentsFile
      Set-Content -LiteralPath $agentsFile -Value ("$agents`n`n---`n`n" + $existingAgents) -Encoding utf8
      Write-Ok "$agentsFile (prepended company bootstrap)"
    }
  } else {
    Write-NewFile $agentsFile $agents
  }

  $gitignore = Join-Path $companyRoot '.gitignore'
  if ((Test-Path $gitignore) -and (Select-String -LiteralPath $gitignore -Pattern '^\.crux/workspace/$' -Quiet)) {
    Write-Info '.gitignore already ignores .crux/workspace/'
  } elseif ($DryRun) {
    Write-Info "[dry-run] would add .crux/workspace/ to $gitignore"
  } else {
    Add-Content -LiteralPath $gitignore -Value '.crux/workspace/' -Encoding utf8
    Write-Ok "${gitignore}: .crux/workspace/"
  }

  Add-RegistryEntry $Id $companyRoot

  Write-Host ''
  Write-Info 'Next: add teams with  company.ps1 team add <id> -Role <role> -Owns <path>'
  if (-not (Test-Path (Join-Path $companyRoot '.git'))) { Write-Warn "$companyRoot is not a git repository yet; the board is meant to be committed" }
}

# ---------------------------------------------------------------------------
# team add
# ---------------------------------------------------------------------------
function Invoke-TeamAdd([string]$Id) {
  if (-not $Id) { Stop-WithError 'Team id required: company.ps1 team add <id> -Role … -Owns …' }
  if (-not (Test-ValidId $Id)) { Stop-WithError "Invalid team id '$Id'" }
  if (-not $Role) { Stop-WithError '-Role is required' }
  if (-not $Owns) { Stop-WithError '-Owns is required' }

  $companyRoot = ''
  if ($Company) {
    $map = Get-Registry
    if (-not $map.Contains($Company)) { Stop-WithError "Company '$Company' is not in $Registry" }
    $companyRoot = $map[$Company]
  } elseif ($Root) {
    $companyRoot = $Root
  } else {
    $companyRoot = Find-CompanyRoot
  }
  if (-not $companyRoot -or -not (Test-Path (Join-Path $companyRoot '.crux/COMPANY.md'))) {
    Stop-WithError 'No Crux company found (use -Company or -Root, or run company.ps1 init)'
  }
  $companyRoot = (Resolve-Path $companyRoot).ProviderPath

  $teamFile = Join-Path $companyRoot ".crux/teams/$Id/TEAM.md"
  if (Test-Path $teamFile) { Stop-WithError "Team '$Id' already exists: $teamFile" }

  $roles = Split-Csv $Role
  foreach ($r in $roles) {
    if (-not (Test-Path (Join-Path $FrameworkHome "agents/$r/AGENT.md"))) { Write-Warn "Role not installed in framework home: $r" }
  }

  $others = @(Get-ChildItem -Path (Join-Path $companyRoot '.crux/teams') -Filter 'TEAM.md' -Recurse -ErrorAction SilentlyContinue)
  $owned = @()
  foreach ($p in Split-Csv $Owns) {
    $np = Get-NormalPath $p $companyRoot
    if (-not [System.IO.Path]::IsPathRooted($np) -and -not (Test-Path (Join-Path $companyRoot $np))) { Write-Warn "Owned path does not exist yet: $np" }
    if ([System.IO.Path]::IsPathRooted($np)) { Write-Warn "Owned path outside the company root: $np" }
    foreach ($other in $others) {
      $otherId = Split-Path -Leaf (Split-Path -Parent $other.FullName)
      foreach ($op in Get-FrontmatterList $other.FullName 'owns') {
        if ((Get-NormalPath $op $companyRoot) -eq $np) { Stop-WithError "'$np' is already owned by team '$otherId'" }
      }
    }
    $owned += $np
  }
  $alsoList = @(Split-Csv $Also | ForEach-Object { Get-NormalPath $_ $companyRoot })

  $body = (Get-TemplateBody 'TEAM.template.md').Replace('{{TEAM_ID}}', $Id)
  $frontmatter = @(
    "id: $Id",
    (Format-YamlList 'roles' $roles),
    (Format-YamlList 'skills' (Split-Csv $Skills)),
    (Format-YamlList 'owns' $owned),
    (Format-YamlList 'also' $alsoList)
  ) -join "`n"
  Write-NewFile $teamFile "---`n$frontmatter`n---`n$body"
  New-BoardDir (Join-Path $companyRoot ".crux/requests/$Id")

  $cid = Get-FrontmatterValue (Join-Path $companyRoot '.crux/COMPANY.md') 'id'
  Write-Host ''
  Write-Info "Team $cid/$Id created. Fill in its paragraph in $teamFile and commit at $companyRoot."
}

function Get-OwnedAbsolute([string]$Path, [string]$CompanyRoot) {
  $p = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $CompanyRoot $Path }
  if (Test-Path $p) { return (Resolve-Path $p).ProviderPath.TrimEnd('/', '\') }
  return [System.IO.Path]::GetFullPath($p).TrimEnd('/', '\')
}

function Test-UnderPath([string]$Dir, [string]$Owned) {
  return ($Dir -eq $Owned) -or $Dir.StartsWith("$Owned/") -or $Dir.StartsWith("$Owned\")
}

# Best match of $Dir among the teams of the company at $CompanyRoot:
# longest `owns` prefix, else a single `also` match.
function Find-TeamForDir([string]$CompanyRoot, [string]$Dir) {
  $best = $null; $alsoHits = @()
  foreach ($file in @(Get-ChildItem -Path (Join-Path $CompanyRoot '.crux/teams') -Filter 'TEAM.md' -Recurse -ErrorAction SilentlyContinue)) {
    $team = Split-Path -Leaf (Split-Path -Parent $file.FullName)
    foreach ($op in Get-FrontmatterList $file.FullName 'owns') {
      $ap = Get-OwnedAbsolute $op $CompanyRoot
      if ((Test-UnderPath $Dir $ap) -and (-not $best -or $ap.Length -gt $best.Path.Length)) {
        $best = [pscustomobject]@{ Team = $team; Path = $ap; Kind = 'owns' }
      }
    }
    foreach ($op in Get-FrontmatterList $file.FullName 'also') {
      $ap = Get-OwnedAbsolute $op $CompanyRoot
      if (Test-UnderPath $Dir $ap) { $alsoHits += [pscustomobject]@{ Team = $team; Path = $ap; Kind = 'also' } }
    }
  }
  if ($best) { return $best }
  if ($alsoHits.Count -eq 1) { return $alsoHits[0] }
  return $null
}

function Invoke-Resolve([string]$Target) {
  $dir = if ($Target) { $Target } else { '.' }
  if (-not (Test-Path $dir -PathType Container)) { Stop-WithError "Not a directory: $dir" }
  $dir = (Resolve-Path $dir).ProviderPath.TrimEnd('/', '\')

  $companyRoot = ''; $via = ''
  $d = $dir
  while ($d) {
    if (Test-Path (Join-Path $d '.crux/COMPANY.md')) { $companyRoot = $d; $via = 'walk-up'; break }
    $parent = Split-Path -Parent $d
    if (-not $parent -or $parent -eq $d) { break }
    $d = $parent
  }
  $map = Get-Registry
  if (-not $companyRoot -and (Test-Path (Join-Path $dir '.crux/company'))) {
    $id = (Get-Content -Raw (Join-Path $dir '.crux/company')).Trim()
    if ($map.Contains($id)) { $companyRoot = $map[$id]; $via = 'marker' }
  }
  if (-not $companyRoot) {
    foreach ($id in $map.Keys) {
      $r = $map[$id]
      if ((Test-Path (Join-Path $r '.crux/COMPANY.md')) -and (Find-TeamForDir $r $dir)) { $companyRoot = $r; $via = 'registry'; break }
    }
  }
  if (-not $companyRoot) { Write-Info "${dir}: not in a Crux company"; exit 1 }

  $companyFile = Join-Path $companyRoot '.crux/COMPANY.md'
  $cid = Get-FrontmatterValue $companyFile 'id'
  $hit = Find-TeamForDir $companyRoot $dir
  if (-not $hit -and $dir -eq $companyRoot) {
    $hit = [pscustomobject]@{ Team = (Get-FrontmatterValue $companyFile 'coordinator'); Path = $companyRoot; Kind = 'root' }
  }

  Write-Host "  Dir:      $dir"
  Write-Host "  Company:  $cid  ($companyRoot, via $via)"
  if (-not $hit) { Write-Warn 'No team owns this directory — ask, or add one with: company.ps1 team add'; exit 1 }
  Write-Host "  Team:     $cid/$($hit.Team)  ($($hit.Kind) $($hit.Path))"
  Write-Host "  Inbox:    $(Join-Path $companyRoot ".crux/requests/$($hit.Team)")/"
}

function Invoke-List {
  $map = Get-Registry
  if ($map.Count -eq 0) { Write-Info "No companies registered ($Registry missing or empty)"; return }
  foreach ($id in $map.Keys) {
    $teamsDir = Join-Path $map[$id] '.crux/teams'
    $teams = if (Test-Path $teamsDir) { (Get-ChildItem -Directory $teamsDir | ForEach-Object Name) -join ' ' } else { '(root missing or not initialised)' }
    Write-Host "  $id  $($map[$id])"
    Write-Host "      teams: $teams"
  }
}

switch ($Command) {
  'init' { Invoke-Init $Arg1 }
  'team' {
    if ($Arg1 -ne 'add') { Stop-WithError "Unknown team command: $Arg1 (expected: team add)" }
    Invoke-TeamAdd $Arg2
  }
  'list' { Invoke-List }
  'resolve' { Invoke-Resolve $Arg1 }
  default {
    Get-Content $PSCommandPath | Select-Object -Skip 4 -First 10 | ForEach-Object { $_ -replace '^# ?', '' }
    if ($Command -and $Command -notin @('help', '-h')) { exit 1 }
  }
}
