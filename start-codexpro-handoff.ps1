$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $Root
$Cloudflared = Join-Path $env:USERPROFILE ".codexpro\bin\cloudflared.exe"

if (-not (Test-Path -LiteralPath $Cloudflared)) {
  throw "cloudflared.exe was not found at $Cloudflared. Install it with winget install --id Cloudflare.cloudflared, then copy it to that path."
}

Write-Host "Starting CodexPro handoff mode for:"
Write-Host "  $Root"
Write-Host ""
Write-Host "When the Server URL appears, paste it into ChatGPT Settings -> Apps -> Advanced settings -> Create app."
Write-Host "Authentication: None / No Authentication."
Write-Host ""

codexpro start `
  --root "$Root" `
  --mode handoff `
  --bash safe `
  --port 8788 `
  --tunnel cloudflare `
  --cloudflared "$Cloudflared" `
  --no-install-cloudflared `
  --tool-mode standard `
  --copy-url `
  --save-config
