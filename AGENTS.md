# Agent Instructions — copilot-instructions

This repository is a portable collection of GitHub Copilot (and compatible AI assistant) customization features. Its purpose is to define coding standards, reusable workflows, and specialized tools that can be applied to any workspace on any machine.

## Repository Role

This repository is a **feature library**, not a project workspace. It stores customization features for use in *other* workspaces. It is not the target of those features itself.

## Feature Placement

All features belong under `features/`. Never create features in `.github/` within this repository.

| Feature type        | Directory                             | File pattern                          |
| ------------------- | ------------------------------------- | ------------------------------------- |
| Agent skills        | `features/skills/<name>/`             | `SKILL.md` (required)                 |
| Instructions files  | `features/instructions/`              | `<name>.instructions.md`              |
| Prompt files        | `features/prompts/`                   | `<name>.prompt.md`                    |
| Custom agents       | `features/agents/`                    | `<name>.agent.md`                     |
| Agent hooks         | `features/hooks/`                     | `<name>.json`                         |
| Reference resources | `features/resources/`                 | `<name>.md`                           |

Do not place any feature files in `.github/`. The `.github/` directory in this repository is reserved for CI workflows only.

## How Features Are Consumed

Features in `features/` are not active in this repository. They are made available to other workspaces through one of these methods:

- **VS Code settings** — Point `chat.agentSkillsLocations`, `chat.instructionsFilesLocations`, `chat.promptFilesLocations`, `chat.hookFilesLocations`, or `chat.agentFilesLocations` at the relevant `features/` subdirectory.
- **Symlinks** — Create symlinks in `~/.copilot/` (or equivalent tool config directory) pointing to subdirectories within `features/`.
- **Copy** — Copy the contents of `features/` subdirectories into `~/.copilot/` or a project's `.github/` directory on the target machine.
- **Codex sync** — Run `scripts/sync-codex-skills.ps1` to create directory junctions from `~/.codex/skills/` into `features/skills/`.

## Creating New Features

When adding a new feature to this repository:

1. Identify the correct feature type and target subdirectory from the table above.
2. Create the file or folder in `features/`, not anywhere else.
3. Follow the naming conventions: lowercase, hyphen-separated for variable-name features (skills, prompts, agents, instructions).
4. Invoke the `copilot-features` skill for detailed implementation guidance on any feature type.
5. Run the markdown linter before committing: `npx markdownlint-cli2`.

## Constraints

- Place all new features in `features/` subdirectories.
- Do not create `.github/skills/`, `.github/instructions/`, `.github/prompts/`, `.github/agents/`, or `.github/hooks/` in this repository.
- Do not add workspace-specific configuration (project settings, environment files, secrets) to this repository.
- Do not duplicate a rule across multiple feature files. Each rule belongs in exactly one place.
