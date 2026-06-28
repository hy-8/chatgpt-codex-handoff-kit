$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$escapedRoot = [WildcardPattern]::Escape($Root)

$processes = Get-CimInstance Win32_Process | Where-Object {
  ($_.CommandLine -like "*codexpro*start*--root*$escapedRoot*") -or
  ($_.CommandLine -like "*cloudflared.exe*tunnel*--url*127.0.0.1:8788*")
}

if (-not $processes) {
  Write-Host "No CodexPro handoff processes found for $Root"
  exit 0
}

foreach ($process in $processes) {
  Write-Host "Stopping $($process.Name) PID $($process.ProcessId)"
  Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
}

Write-Host "Stopped CodexPro handoff processes for $Root"
