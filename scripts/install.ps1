[CmdletBinding()]
param(
  [string]$Agents = '',
  [ValidateSet('auto', 'opencode', 'claude-code', 'cursor', 'codex', 'all')]
  [string]$Tool = 'auto',
  [string]$Project = '',
  [string]$Branch = 'main',
  [string]$Repo = 'dotlabshq/crux',
  [switch]$DryRun,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Write-Ok($Message) { Write-Host "  ✓ $Message" -ForegroundColor Green }
function Write-Info($Message) { Write-Host "  → $Message" -ForegroundColor Cyan }
function Write-Warn($Message) { Write-Host "  ⚠ $Message" -ForegroundColor Yellow }
function Write-Err($Message) { Write-Host "  ✗ $Message" -ForegroundColor Red }
function Write-Step($Message) { Write-Host "`n$Message" -ForegroundColor White }

$script:InstalledCount = 0
$script:SkippedCount = 0

function Install-File([string]$SourcePath, [string]$DestPath) {
  if (-not (Test-Path $SourcePath)) {
    Write-Warn "Not found in archive: $SourcePath"
    return
  }

  if ((Test-Path $DestPath) -and -not $Force) {
    Write-Info "Exists, skipping (--Force to overwrite): $DestPath"
    $script:SkippedCount++
    return
  }

  if ($DryRun) {
    Write-Info "[dry-run] would install: $DestPath"
  } else {
    $parent = Split-Path -Parent $DestPath
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    Copy-Item -LiteralPath $SourcePath -Destination $DestPath -Force
    Write-Ok $DestPath
  }
  $script:InstalledCount++
}

function Install-Tree([string]$SourceRoot, [string]$DestRoot) {
  if (-not (Test-Path $SourceRoot)) {
    Write-Warn "Not found in archive: $SourceRoot"
    return
  }

  foreach ($file in (Get-ChildItem -Path $SourceRoot -Recurse -File | Sort-Object FullName)) {
    $relative = $file.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
    $dest = Join-Path $DestRoot $relative
    Install-File $file.FullName $dest
  }
}

$repoArchive = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"

Write-Host ''
Write-Host '┌─────────────────────────────────┐' -ForegroundColor Blue
Write-Host '│  Crux — workspace installer     │' -ForegroundColor Blue
Write-Host '└─────────────────────────────────┘' -ForegroundColor Blue
Write-Host ''
if ($Project) { Write-Host "  Project:  $Project" -ForegroundColor Cyan }
Write-Host "  Repo:     $Repo@$Branch" -ForegroundColor Cyan
Write-Host "  Tool:     $Tool" -ForegroundColor Cyan
if ($Agents) { Write-Host "  Agents:   $Agents" -ForegroundColor Cyan }
if ($DryRun) { Write-Host '  Mode:     dry-run' -ForegroundColor Yellow }

Write-Step 'Checking prerequisites...'
try {
  $null = Get-Command Invoke-WebRequest -ErrorAction Stop
  $null = Get-Command Expand-Archive -ErrorAction Stop
  Write-Ok 'PowerShell download/extract commands available'
} catch {
  Write-Err 'Invoke-WebRequest and Expand-Archive are required.'
  exit 1
}

Write-Step 'Downloading Crux framework...'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("crux-install-" + [guid]::NewGuid().ToString('N'))
$archivePath = Join-Path $tempRoot 'crux.zip'
$extractRoot = Join-Path $tempRoot 'extracted'
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

try {
  Write-Info "Fetching archive from $Repo@$Branch..."
  Invoke-WebRequest -Uri $repoArchive -OutFile $archivePath
  Expand-Archive -LiteralPath $archivePath -DestinationPath $extractRoot -Force
  Write-Ok 'Downloaded'

  $archiveSourceDir = Get-ChildItem -Path $extractRoot -Directory | Select-Object -First 1
  if (-not $archiveSourceDir) {
    throw 'Could not locate extracted Crux archive root.'
  }
  $archiveSource = $archiveSourceDir.FullName

  Install-File (Join-Path $archiveSource 'COORDINATOR.md') '.\.crux\COORDINATOR.md'
  Install-File (Join-Path $archiveSource 'AGENTS.md') '.\.crux\AGENTS.md'
  Install-Tree (Join-Path $archiveSource 'bus') '.\.crux\bus'
  Install-Tree (Join-Path $archiveSource 'templates') '.\.crux\templates'
  Install-Tree (Join-Path $archiveSource 'workflows') '.\.crux\workflows'

  Write-Ok "$script:InstalledCount framework files installed, $script:SkippedCount skipped"

  Write-Step 'Installing agents...'
  if ($Agents) {
    $agentList = $Agents.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  } else {
    $agentList = Get-ChildItem -Path (Join-Path $archiveSource 'agents') -Recurse -Filter AGENT.md |
      ForEach-Object { Split-Path -Leaf $_.DirectoryName } |
      Sort-Object -Unique
  }

  foreach ($role in $agentList) {
    $sourceAgentDir = Join-Path $archiveSource "agents/$role"
    $sourceAgentFile = Join-Path $sourceAgentDir 'AGENT.md'
    $destAgentDir = Join-Path '.\.crux\agents' $role
    $destAgentFile = Join-Path $destAgentDir 'AGENT.md'

    if (-not (Test-Path $sourceAgentFile)) {
      Write-Warn "Agent not found in Crux framework: $role"
      Write-Warn "  To create a custom agent: copy .crux/templates/AGENT.template.md -> .crux/agents/$role/AGENT.md"
      continue
    }

    if ((Test-Path $destAgentFile) -and -not $Force) {
      Write-Info "Agent exists, skipping: $role (--Force to overwrite)"
      continue
    }

    if ($DryRun) {
      Write-Info "[dry-run] would install agent: $role"
    } else {
      Write-Info "Installing agent directory: $role"
    }

    Install-Tree $sourceAgentDir $destAgentDir
  }

  Write-Step 'Installing skills...'
  foreach ($role in $agentList) {
    $agentFile = Join-Path '.\.crux\agents' "$role\AGENT.md"
    if (-not (Test-Path $agentFile)) { continue }

    $skillLines = Select-String -Path $agentFile -Pattern '^\| `' | ForEach-Object { $_.Line }
    foreach ($line in $skillLines) {
      if ($line -match '`\s*([^`]+)\s*`') {
        $skillName = $matches[1].Trim()
        $sourceSkillDir = Join-Path $archiveSource "skills/$skillName"
        $sourceSkillFile = Join-Path $sourceSkillDir 'SKILL.md'
        $destSkillDir = Join-Path '.\.crux\skills' $skillName
        $destSkillFile = Join-Path $destSkillDir 'SKILL.md'

        if (-not (Test-Path $sourceSkillFile)) { continue }
        if ((Test-Path $destSkillFile) -and -not $Force) { continue }

        if ($DryRun) {
          Write-Info "[dry-run] would install skill: $skillName"
        } else {
          Write-Info "Installing skill directory: $skillName"
        }

        Install-Tree $sourceSkillDir $destSkillDir
      }
    }
  }

  Write-Step 'Creating directory structure...'
  foreach ($dir in @('.\.crux')) {
    if ($DryRun) {
      Write-Info "[dry-run] would create: $dir"
    } else {
      New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
  }
  Write-Ok 'Directories ready'

  Write-Step 'Updating .gitignore...'
  $gitignoreEntries = @('.crux/workspace/')
  if (Test-Path '.gitignore') {
    $gitignoreContent = Get-Content '.gitignore'
    foreach ($entry in $gitignoreEntries) {
      if ($gitignoreContent -contains $entry) {
        Write-Info "Already in .gitignore: $entry"
      } elseif ($DryRun) {
        Write-Info "[dry-run] would add to .gitignore: $entry"
      } else {
        Add-Content -LiteralPath '.gitignore' -Value $entry
        Write-Ok "Added to .gitignore: $entry"
      }
    }
  } elseif ($DryRun) {
    Write-Info '[dry-run] would create .gitignore'
  } else {
    Set-Content -LiteralPath '.gitignore' -Value $gitignoreEntries -Encoding utf8
    Write-Ok 'Created .gitignore'
  }

  Write-Step 'Installing helper scripts...'
  foreach ($scriptName in @('convert.sh', 'install.sh', 'update.sh', 'convert.ps1', 'install.ps1', 'update.ps1')) {
    $scriptSource = Join-Path $archiveSource "scripts/$scriptName"
    $scriptDest = Join-Path '.\scripts' $scriptName
    if (-not (Test-Path $scriptSource)) { continue }

    if ((Test-Path $scriptDest) -and -not $Force) {
      Write-Info "Exists, skipping (--Force to overwrite): scripts/$scriptName"
    } elseif ($DryRun) {
      Write-Info "[dry-run] would install: scripts/$scriptName"
    } else {
      New-Item -ItemType Directory -Force -Path '.\scripts' | Out-Null
      Copy-Item -LiteralPath $scriptSource -Destination $scriptDest -Force
      Write-Ok "scripts/$scriptName"
    }
  }

  Write-Step 'Converting agent definitions to tool format...'
  $convertScript = '.\scripts\convert.ps1'
  if ($DryRun) {
    Write-Info "[dry-run] would run: powershell -File $convertScript -Tool $Tool"
  } else {
    & $convertScript -Tool $Tool
  }

  Write-Host ''
  Write-Host '┌─────────────────────────────────────────────┐' -ForegroundColor Green
  Write-Host '│  Crux installed successfully                │' -ForegroundColor Green
  Write-Host '└─────────────────────────────────────────────┘' -ForegroundColor Green
  Write-Host ''
  Write-Host '  Next steps:' -ForegroundColor White
  Write-Host ''
  Write-Host '  1. Start your AI tool in this project directory'
  if ($agentList.Count -gt 0) {
    Write-Host '  2. The coordinator will run workspace initialisation on first boot'
    Write-Host '     and ask a few questions to set up your workspace'
    Write-Host '  3. Activate an agent:'
    foreach ($role in $agentList) {
      Write-Host "       @$role" -ForegroundColor Cyan
    }
  } else {
    Write-Host '  2. The coordinator boots automatically and runs workspace initialisation'
  }
  Write-Host ''
  Write-Host '  When you update agents or skills:' -ForegroundColor White
  Write-Host '    .\scripts\convert.ps1' -ForegroundColor Cyan
  Write-Host ''
}
finally {
  if (Test-Path $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}
