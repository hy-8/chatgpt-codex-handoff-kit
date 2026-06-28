# ChatGPT Test Prompt

Use CodexPro.

Call `server_config` first, then `codexpro_self_test`.
If self-test fails, stop and report the failed checks.
Then call `open_current_workspace` with `include_tree=false`.

Confirm that the active workspace is:

```text
E:\aiproduct\chatgpt+codex
```

After that, inspect `README.md`, `AGENTS.md`, and `.ai-bridge/current-plan.md`.
Write a short handoff plan into `.ai-bridge/current-plan.md` for Codex to add a tiny demo file named `demo-result.md` that proves the handoff worked.
Do not directly edit `demo-result.md`; only write the plan.
