# ChatGPT + Codex Handoff Kit

一个给 Windows 用户准备的 CodexPro 交接模板：让 ChatGPT 网页端通过 CodexPro 读取本地项目、写入计划，再交给 Codex 在本地执行。  
本仓库是基于原开源项目 [rebel0789/codexpro](https://github.com/rebel0789/codexpro) 的使用流程整理和本地脚本封装，不是 CodexPro 官方仓库或官方发布版。  
适合不想每次手动搭 `.ai-bridge`、启动脚本、提示词和操作说明的人，复制两份初始化文件即可快速接入新项目。

## 快捷使用

1. 从 `复制到其他文件夹` 复制 `init-codexpro-project.bat` 和 `init-codexpro-project.ps1` 到任意新项目根目录。
2. 双击 `init-codexpro-project.bat`，它会自动生成 `.ai-bridge`、`AGENTS.md`、`操作手册.md`、启动/停止脚本和 ChatGPT 启动提示词。
3. 双击新项目里的 `start-codexpro-handoff.bat`，把自动复制的 Server URL 粘贴到 ChatGPT Apps Developer Mode。
4. 打开 `.ai-bridge\chatgpt-start-prompt.md`，复制给 ChatGPT；结束时双击 `stop-codexpro-handoff.bat`。

## 工作流

```text
ChatGPT Web -> CodexPro MCP -> .ai-bridge/current-plan.md -> Codex 本地执行
```

详细步骤见 `操作手册.md`。
