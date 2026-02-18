# Agent Skills

## Overview

- **Purpose:** Provide specialized, reusable capabilities with optional scripts and resources.
- **When to use:** Use for task-specific workflows that should load on demand.
- **File location:**
  - Directory: `.github/skills/<name>/`
  - Main file: `SKILL.md` (required, name must match folder)
  - Naming: `<name>` should be descriptive and capability-focused
  - Examples: `jest-test-generation`, `api-scaffolding`, `security-audit`
  - Avoid generic names like "testing" or "utilities"
  - Must use lowercase and hyphens
  - Folder name must match the `name` field in frontmatter
- **Selection/activation:** Skills can be activated in two ways:
  - **Automatic:** Auto-selected when user request matches the frontmatter `description`
  - **Manual:** Invoked via slash commands in chat (e.g., `/skill-name additional context`)
  - **CRITICAL:** Only `name` and `description` are used for discovery—the description is the ONLY text that determines automatic loading.
  - By default, skills appear in the slash command menu and can auto-load. Use `user-invokable` and `disable-model-invocation` frontmatter fields to control this behavior.

## Folder Structure

```text
.github/skills/<skill-name>/
├── SKILL.md           # Required (name must match folder)
├── scripts/           # Executable code
├── references/        # Docs loaded as needed
└── assets/            # Templates, boilerplate
```

## Frontmatter

```yaml
---
name: skill-name # Required: Lowercase alphanumeric + hyphens, must match folder name
description: "Use when..." # Required: State capability and when to use. Drives auto-activation.
argument-hint: "[test file] [options]" # Optional: Hint shown in chat input when invoked as a slash command
user-invokable: true # Optional: Controls if skill appears in the slash-command menu (default: true)
disable-model-invocation: false # Optional: Prevents auto-loading, requires slash-command invocation (default: false)
---
```

**Required fields:**

- `name`: Lowercase, hyphen-separated identifier matching folder name
- `description`: Drives automatic activation. State what skill does and when to use it.

**Optional fields:**

- `argument-hint`: User-friendly hint text shown in chat input when skill is invoked as a slash command (e.g., "\[test file] \[options]", "for the login page")
- `user-invokable`: Set to `false` to hide skill from the slash command menu while allowing automatic loading (default: `true`)
- `disable-model-invocation`: Set to `true` to prevent automatic loading and require explicit slash command invocation (default: `false`)

## Description Field

This is the ONLY text used for skill activation. Include:

- What the skill does (capabilities)
- When to use it (trigger scenarios)
- Key technologies or patterns involved
- Be specific to avoid false matches

## Body Layout

What the skill accomplishes, step-by-step procedures, and examples.

## Bundled Assets

Skills can include additional files in the same directory:

- Scripts, templates, checklists, or reference data
- Reference using relative paths: `[template](./template.js)` or `[checklist](./checklist.md)`
- Keep main SKILL.md file under 500 lines; move lengthy content to separate files
- Keep file references one level deep from SKILL.md for optimal loading
- Organize with clear file naming (e.g., `scripts/test.js`, `references/api-spec.md`, `assets/template.ts`)

## Progressive Loading

Skills load in stages to optimize token usage:

1. **Discovery** (~100 tokens): Agent reads `name` and `description`
2. **Instructions** (<5000 tokens, ~250 lines max): Loads SKILL.md body when relevant
3. **Resources**: Additional files load only when referenced

## Using Skills as Slash Commands

Skills are available as slash commands in chat alongside prompt files. Type `/` in chat to see all available skills.

### Invocation Methods

1. **Automatic loading:** Agent loads skill when request matches `description`
2. **Manual invocation:** Type `/skill-name` in chat, optionally followed by context (e.g., `/webapp-testing for the login page`)

### Controlling Skill Visibility and Loading

Use frontmatter fields to control how skills are accessed:

| Configuration                    | In the slash command menu? | Auto-loads? | Use Case                                            |
| -------------------------------- | -------------------------- | ----------- | --------------------------------------------------- |
| Default (both omitted)           | Yes                        | Yes         | General-purpose skills                              |
| `user-invokable: false`          | No                         | Yes         | Background knowledge skills that load when relevant |
| `disable-model-invocation: true` | Yes                        | No          | Skills you only want to run on demand               |
| Both set                         | No                         | No          | Disabled skills                                     |

**Important:** Only **one** slash command can be used at a time. You cannot use slash commands to manually select multiple skills simultaneously.

### Argument Hints

Use `argument-hint` to guide users when they invoke your skill:

```yaml
---
name: github-actions-debugging
description: Debug GitHub Actions workflow failures
argument-hint: PR #[number] or workflow name
---
```

When users type `/github-actions-debugging`, the hint "PR #\[number] or workflow name" appears in the chat input field.

## Description Examples

- "Use when generating REST APIs from OpenAPI specs with validation and error handling."
- "Use when writing PowerShell scripts that require registry modifications and idempotent checks."
- "Use when creating React components that must follow MUI v5 patterns."

## Examples

### Example 1: Auto-loading skill

```markdown
---
name: jest-test-generation
description: Use when generating Jest tests for JavaScript functions with mocking and edge case coverage.
---

# Skill Instructions

## Procedure

1. Identify inputs, outputs, and dependencies
2. Define success, edge, and error cases
3. Mock external dependencies
4. Write assertions with clear expectations
5. Add descriptive test names

## Example

Input: Function that fetches user data
Output: Tests for success, network error, and empty response
```

### Example 2: Slash-command-only skill with argument hint

```markdown
---
name: github-actions-debugging
description: Debug GitHub Actions workflow failures by analyzing logs and suggesting fixes
argument-hint: PR #[number] or workflow name
disable-model-invocation: true
---

# Skill Instructions

## Procedure

1. Retrieve workflow run logs
2. Identify failure points in the logs
3. Analyze error messages and stack traces
4. Suggest specific fixes based on common patterns
5. Provide corrected workflow YAML if needed

## Example

Input: `/github-actions-debugging PR #42`
Output: Analysis of workflow failures with suggested fixes
```

## Anti-patterns

- Vague descriptions that don't enable discovery (e.g., "A helpful skill")
- Monolithic SKILL.md with everything in one file instead of using reference files
- Name mismatch between folder name and frontmatter `name` field
- Missing step-by-step procedures (descriptions without actionable guidance)
- Setting both `user-invokable: false` and `disable-model-invocation: true` (disables skill entirely)
- Using generic `argument-hint` that doesn't help users understand what to provide

## Validation Checklist

- Stored in `.github/skills/<name>/SKILL.md`
- Folder name must match `name` field in frontmatter
- Required fields: `name` and `description` in frontmatter are specific
- Optional fields used appropriately: `argument-hint`, `user-invokable`, `disable-model-invocation`
- Keep SKILL.md under 500 lines; use reference files for lengthy content
- File references should be one level deep from SKILL.md
- Body includes what skill accomplishes, when to use, procedures, and examples
- If using visibility controls, not both set to false (which disables skill entirely)
