# Copilot Instructions

[![Markdown Lint](https://github.com/mikejhill/copilot-instructions/actions/workflows/markdown-lint.yml/badge.svg?branch=main)](https://github.com/mikejhill/copilot-instructions/actions/workflows/markdown-lint.yml)

A curated collection of GitHub Copilot customization features for VS Code, including custom instructions, agent skills, prompt files, and custom agents. These files define coding standards, reusable workflows, and specialized tools to tailor AI assistant behavior.

## Structure

| Directory                | Contents                                               |
| ------------------------ | ------------------------------------------------------ |
| `features/instructions/` | Scoped instruction files for standards and conventions |
| `features/skills/`       | On-demand agent skills with bundled references         |
| `features/prompts/`      | Explicit, repeatable prompt files                      |
| `features/agents/`       | Custom agent definitions                               |
| `features/hooks/`        | Agent lifecycle hooks                                  |
| `features/resources/`    | Reference documentation and guides                     |

## Usage

You can activate these features in VS Code using either approach:

1. Copy the `features/` directory contents into your project's `.github/` directory.
2. Clone this repository and add the feature subdirectories to your VS Code settings.

- `chat.agentFilesLocations`
- `chat.instructionsFilesLocations`
- `chat.promptFilesLocations`
- `chat.hookFilesLocations`
- `chat.agentSkillsLocations`

See the [copilot-customization-features skill](features/skills/copilot-customization-features/SKILL.md) for detailed documentation on each feature type.

## Codex Integration

The skills under `features/skills/` are already stored in the same folder-oriented format that Codex expects: one directory per skill with a `SKILL.md` entry point and any bundled `references/`, `scripts/`, or `assets/`.

To make these skills available to both Codex desktop and Codex CLI without introducing a second copy to maintain, use the sync script in [`scripts/sync-codex-skills.ps1`](scripts/sync-codex-skills.ps1). It creates directory junctions in your Codex user skills directory that point back to this repository.

This keeps the repository as the single source of truth:

- Edit skills only in `features/skills/`
- Re-run the sync script after adding, renaming, or removing skills
- Codex and Codex CLI both read the linked skills from `~/.codex/skills/`

### Setup

```powershell
pwsh -File .\scripts\sync-codex-skills.ps1
```

If you have removed skills from the repository and want to remove their previously-created Codex links as well:

```powershell
pwsh -File .\scripts\sync-codex-skills.ps1 -Prune
```

### Notes

- The script uses `$env:CODEX_HOME` when it is set; otherwise it targets `~/.codex`.
- Existing non-junction folders in the Codex skills directory are left untouched and reported as skipped.
- On Windows, directory junctions avoid content duplication and fit well with a repo-managed workflow.

## License

[MIT](LICENSE)
