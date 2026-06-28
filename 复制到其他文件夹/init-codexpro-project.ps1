$ErrorActionPreference = "Stop"

$Root = if ($env:INIT_ROOT) {
  $env:INIT_ROOT.TrimEnd("\", "/")
} else {
  Split-Path -Parent $MyInvocation.MyCommand.Path
}
Set-Location -LiteralPath $Root

function Write-IfMissing {
  param(
    [Parameter(Mandatory = $true)][string]$RelativePath,
    [Parameter(Mandatory = $true)][string]$Content
  )

  $fullPath = Join-Path $Root $RelativePath
  $parent = Split-Path -Parent $fullPath
  if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }

  if (Test-Path -LiteralPath $fullPath) {
    if ([System.IO.Path]::GetExtension($fullPath).Equals(".bat", [System.StringComparison]::OrdinalIgnoreCase)) {
      $bytes = [System.IO.File]::ReadAllBytes($fullPath)
      if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $fullPath
        [System.IO.File]::WriteAllText($fullPath, $text, [System.Text.Encoding]::ASCII)
        Write-Host "Fixed BOM: $RelativePath"
        return
      }
    }
    Write-Host "Keep existing: $RelativePath"
    return
  }

  $text = $Content.TrimStart("`r", "`n")
  if ([System.IO.Path]::GetExtension($fullPath).Equals(".bat", [System.StringComparison]::OrdinalIgnoreCase)) {
    [System.IO.File]::WriteAllText($fullPath, $text, [System.Text.Encoding]::ASCII)
  } else {
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($fullPath, $text, $utf8NoBom)
  }
  Write-Host "Created: $RelativePath"
}

New-Item -ItemType Directory -Force -Path (Join-Path $Root ".ai-bridge") | Out-Null

Write-IfMissing ".ai-bridge\current-plan.md" @'
# Current Plan

Status: waiting for ChatGPT handoff.

Ask ChatGPT, through CodexPro, to inspect this workspace and write a concrete implementation plan here. Codex can then execute this plan locally.
'@

Write-IfMissing ".ai-bridge\agent-status.md" @'
# Agent Status

No handoff plan has been executed yet.

Update this file after running a plan with:

- changes made
- files touched
- verification commands
- results
- blockers or follow-up questions
'@

Write-IfMissing ".ai-bridge\decisions.md" @'
# Decisions

- Use CodexPro handoff mode so ChatGPT writes plans without directly editing source files.
- Use safe bash mode for focused verification commands.
- Use Cloudflare quick tunnel for simple first-time testing.
'@

Write-IfMissing ".ai-bridge\open-questions.md" @'
# Open Questions

- If this project uses CodexPro often, decide whether to replace quick tunnels with a stable ngrok or Cloudflare named tunnel URL.
'@

$ChatGptStartPrompt = @'
Use CodexPro.

Call `server_config` first, then `codexpro_self_test`.
If self-test fails, stop and report the failed checks.
Then call `open_current_workspace` with `include_tree=false`.

Confirm that the active workspace is:

```text
__WORKSPACE_ROOT__
```

After that, inspect `AGENTS.md` and `.ai-bridge/current-plan.md`.

For the task I give you next, inspect the relevant files and write a clear handoff plan into:

```text
.ai-bridge/current-plan.md
```

Do not directly edit source files unless I explicitly ask you to leave handoff mode.
Only write the plan for Codex to execute.
'@

$ChatGptStartPrompt = $ChatGptStartPrompt.Replace("__WORKSPACE_ROOT__", $Root)
Write-IfMissing ".ai-bridge\chatgpt-start-prompt.md" $ChatGptStartPrompt

Write-IfMissing ".ai-bridge\.gitignore" @'
execution-log.jsonl
implementation-diff.patch
watch-handoff-state.json
codexpro-*.log
codexpro-port.txt
'@

Write-IfMissing "AGENTS.md" @'
# Workspace Instructions

This project uses CodexPro handoff files for ChatGPT and Codex collaboration.

- Keep edits scoped to the user's requested task.
- Prefer writing execution plans to `.ai-bridge/current-plan.md` when using handoff mode.
- Do not add secrets, account tokens, or tunnel URLs to tracked files.
- Record local execution notes in `.ai-bridge/agent-status.md` when a plan is executed.
- Use focused verification commands and summarize results clearly.
'@

$Manual = @'
# CodexPro Handoff 操作手册

这个项目已经准备好用 CodexPro 连接 ChatGPT 网页端和本地 Codex。

## 第一次初始化

1. 把 `init-codexpro-project.bat` 和 `init-codexpro-project.ps1` 复制到新项目根目录。
2. 双击 `init-codexpro-project.bat`。
3. 它会在当前项目生成 `.ai-bridge`、`AGENTS.md`、启动脚本和停止脚本。

## 每次开始使用

1. 双击当前项目里的 `start-codexpro-handoff.bat`。
2. 等终端显示 `CodexPro ready`。
3. 复制出来的 Server URL 会自动进入剪贴板。
4. 打开 ChatGPT 网页端。
5. 进入 `Settings -> Apps -> Advanced settings`。
6. 创建或更新 CodexPro App。
7. Server URL 粘贴剪贴板里的地址。
8. Authentication 选择 `None / No Authentication`。
9. 勾选风险确认，然后保存。

## 给 ChatGPT 的启动提示词

1. 打开当前项目里的：

```text
.ai-bridge\chatgpt-start-prompt.md
```

2. 复制里面的全部内容。
3. 在 ChatGPT 新对话里选择刚才创建的 CodexPro App。
4. 把提示词发给 ChatGPT。
5. 确认 ChatGPT 调用了 `server_config`、`codexpro_self_test` 和 `open_current_workspace`。
6. 确认它识别到的 workspace 是：

```text
__WORKSPACE_ROOT__
```

## 日常协作方式

1. 你把任务告诉 ChatGPT。
2. ChatGPT 通过 CodexPro 读取当前项目。
3. ChatGPT 把执行计划写入：

```text
.ai-bridge\current-plan.md
```

4. 回到 Codex，让 Codex 读取并执行这个计划。
5. Codex 执行后，把状态写入：

```text
.ai-bridge\agent-status.md
```

6. 需要复查时，再让 ChatGPT 读取状态和改动。

## 每次结束使用

双击当前项目里的：

```text
stop-codexpro-handoff.bat
```

## 注意事项

- 每个项目都应该在自己的项目根目录启动 CodexPro。
- `.ai-bridge` 是 ChatGPT 和 Codex 的交接区。
- `current-plan.md` 是 ChatGPT 写给 Codex 的计划。
- `agent-status.md` 是 Codex 执行后的状态记录。
- 不要把 tunnel token、账号密钥、`.env` 内容发给别人。
- 使用 Cloudflare quick tunnel 时，每次重启 URL 都会变化，需要更新 ChatGPT App 的 Server URL。
'@

$Manual = $Manual.Replace("__WORKSPACE_ROOT__", $Root)
Write-IfMissing "操作手册.md" $Manual

Write-IfMissing "start-codexpro-handoff.ps1" @'
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $Root

if (-not (Get-Command codexpro -ErrorAction SilentlyContinue)) {
  Write-Host "codexpro is not installed. Installing with npm..."
  npm install -g codexpro
}

function Test-PortAvailable {
  param([int]$Port)
  try {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse("127.0.0.1"), $Port)
    $listener.Start()
    $listener.Stop()
    return $true
  } catch {
    return $false
  }
}

$Port = $null
foreach ($candidate in 8788..8799) {
  if (Test-PortAvailable $candidate) {
    $Port = $candidate
    break
  }
}

if (-not $Port) {
  throw "No free CodexPro port found in 8788-8799."
}

$BridgeDir = Join-Path $Root ".ai-bridge"
New-Item -ItemType Directory -Force -Path $BridgeDir | Out-Null
Set-Content -LiteralPath (Join-Path $BridgeDir "codexpro-port.txt") -Value $Port -Encoding ASCII

$Cloudflared = Join-Path $env:USERPROFILE ".codexpro\bin\cloudflared.exe"
if (-not (Test-Path -LiteralPath $Cloudflared)) {
  $WingetCloudflared = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages\Cloudflare.cloudflared_Microsoft.Winget.Source_8wekyb3d8bbwe\cloudflared.exe"
  if (Test-Path -LiteralPath $WingetCloudflared) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Cloudflared) | Out-Null
    Copy-Item -LiteralPath $WingetCloudflared -Destination $Cloudflared -Force
  }
}

if (-not (Test-Path -LiteralPath $Cloudflared)) {
  throw "cloudflared.exe was not found. Run: winget install --id Cloudflare.cloudflared --source winget"
}

Write-Host "Starting CodexPro handoff mode for:"
Write-Host "  $Root"
Write-Host ""
Write-Host "Local port: $Port"
Write-Host "When the Server URL appears, paste it into ChatGPT Settings -> Apps -> Advanced settings -> Create app."
Write-Host "Authentication: None / No Authentication."
Write-Host ""

codexpro start `
  --root "$Root" `
  --mode handoff `
  --bash safe `
  --port $Port `
  --tunnel cloudflare `
  --cloudflared "$Cloudflared" `
  --no-install-cloudflared `
  --tool-mode standard `
  --copy-url
'@

Write-IfMissing "start-codexpro-handoff.bat" @'
@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-codexpro-handoff.ps1"
pause
'@

Write-IfMissing "stop-codexpro-handoff.ps1" @'
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$PortFile = Join-Path $Root ".ai-bridge\codexpro-port.txt"
$Port = $null
if (Test-Path -LiteralPath $PortFile) {
  $rawPort = (Get-Content -Raw -LiteralPath $PortFile).Trim()
  if ($rawPort -match "^\d+$") {
    $Port = [int]$rawPort
  }
}

$processes = Get-CimInstance Win32_Process | Where-Object {
  $cmd = $_.CommandLine
  if (-not $cmd) { return $false }
  (($cmd.Contains("codexpro") -and $cmd.Contains("start") -and $cmd.Contains($Root)) -or
   ($Port -and $cmd.Contains("cloudflared") -and $cmd.Contains("127.0.0.1:$Port")))
}

if ($Port) {
  $listeners = Get-NetTCPConnection -LocalAddress 127.0.0.1 -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
  foreach ($listener in $listeners) {
    $processes += Get-CimInstance Win32_Process -Filter "ProcessId=$($listener.OwningProcess)" -ErrorAction SilentlyContinue
  }
}

$processes = $processes | Where-Object { $_ } | Sort-Object ProcessId -Unique

if (-not $processes) {
  Write-Host "No CodexPro handoff processes found for $Root"
  exit 0
}

foreach ($process in $processes) {
  Write-Host "Stopping $($process.Name) PID $($process.ProcessId)"
  Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
}

Write-Host "Stopped CodexPro handoff processes for $Root"
'@

Write-IfMissing "stop-codexpro-handoff.bat" @'
@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0stop-codexpro-handoff.ps1"
pause
'@

Write-Host ""
Write-Host "Done."
Write-Host "Next: double-click start-codexpro-handoff.bat in this project folder."
Write-Host "After CodexPro starts, paste the copied Server URL into ChatGPT Apps Developer Mode."
