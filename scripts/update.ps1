[CmdletBinding()]
param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = 'Stop'

# -Force overwrites framework-home agents and skills. companies.toml and local/
# are protected by install.ps1 and never touched.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installScript = Join-Path $scriptDir 'install.ps1'

if (-not (Test-Path $installScript)) {
  Write-Host "  ⚠ install.ps1 not found at $installScript" -ForegroundColor Yellow
  exit 1
}

Write-Host ''
Write-Host 'Crux update' -ForegroundColor Cyan
Write-Host 'Pulling latest agents and skills from remote...'
Write-Host ''

& $installScript -Force @RemainingArgs
