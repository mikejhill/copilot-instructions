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

## License

[MIT](LICENSE)
