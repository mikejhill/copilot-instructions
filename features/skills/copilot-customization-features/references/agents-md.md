# AGENTS.md

AGENTS.md provides tool-agnostic instructions for all agents in the workspace, designed to work across GitHub Copilot, Claude Code, and other AI assistants. Use this reference to create and configure AGENTS.md files.

## Overview

- **Purpose:** Provide custom instructions intended for all agents in the workspace. Intended to be tool-agnostic (GitHub Copilot, Claude Code, etc.).
- **When to use:** Use when multiple agents share the same baseline rules and constraints.
- **File location:**
  - Path: `AGENTS.md` (workspace root) or nested in subfolders (experimental)
  - Examples: `AGENTS.md`, `src/AGENTS.md`
  - Fixed filename with no variation
- **Selection/activation:**
  - Automatically applied to all chat requests
  - When multiple `AGENTS.md` files exist, only the closest to the active file is used
  - For monorepos, this allows folder-specific overrides
- **Important:** Use either `copilot-instructions.md` OR `AGENTS.md`, not both. Choose based on whether the workspace is GitHub Copilot-specific (copilot-instructions.md) or tool-agnostic (AGENTS.md).

## Frontmatter

None. Do not use YAML frontmatter.

## Body Layout

Keep rules concise and agent-agnostic.

**AGENTS.md hierarchy:** For monorepos, the closest AGENTS.md in the directory tree takes precedence, allowing folder-specific overrides.

## Examples

```markdown
# Agent-wide Instructions

- Do not modify files without confirmation
- Prefer reading existing code before proposing changes
```

## Validation Checklist

- Stored at workspace root as `AGENTS.md` and/or optional nested files in subfolders
- Contains agent-wide instructions for all files (not a discoverable registry)
