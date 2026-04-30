# Project Agent Instructions

Relacionado: [[MAPA_PROYECTO]] · [[PLAN_MINIJUEGOS_AI]]

- After creating or modifying any `.md` file in this repository, sync Markdown notes to the Obsidian mirror:
  `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Sync-MarkdownToObsidian.ps1`
- The Obsidian mirror target is `D:\test\agent-files-game`.
- Preserve repository-relative paths so Obsidian links stay stable.
- Codex native hooks are configured in `.codex/hooks.json` to run the sync automatically after `apply_patch` edits Markdown files.
- If only specific Markdown files changed, pass them with `-Path`, for example:
  `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Sync-MarkdownToObsidian.ps1 -Path .\PLAN_MINIJUEGOS_AI.md`
