Use CodexPro.

Call `server_config` first, then `codexpro_self_test`.
If self-test fails, stop and report the failed checks.
Then call `open_current_workspace` with `include_tree=false`.

Confirm that the active workspace is:

```text
E:\aiproduct\chatgpt+codex
```

After that, inspect `AGENTS.md` and `.ai-bridge/current-plan.md`.

For the task I give you next, inspect the relevant files and write a clear handoff plan into:

```text
.ai-bridge/current-plan.md
```

Do not directly edit source files unless I explicitly ask you to leave handoff mode.
Only write the plan for Codex to execute.
