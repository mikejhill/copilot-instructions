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
- **Selection/activation:** Skills are auto-selected when the user request matches the frontmatter `description`. **CRITICAL:** Only `name` and `description` are used for discovery—the description is the ONLY text that determines whether the skill loads. Make it comprehensive and specific.

## Folder Structure

```
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
---
```

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
2. **Instructions** (<5000 tokens): Loads SKILL.md body when relevant
3. **Resources**: Additional files load only when referenced

## Description Examples

- "Use when generating REST APIs from OpenAPI specs with validation and error handling."
- "Use when writing PowerShell scripts that require registry modifications and idempotent checks."
- "Use when creating React components that must follow MUI v5 patterns."

## Examples

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

## Anti-patterns

- Vague descriptions that don't enable discovery (e.g., "A helpful skill")
- Monolithic SKILL.md with everything in one file instead of using reference files
- Name mismatch between folder name and frontmatter `name` field
- Missing step-by-step procedures (descriptions without actionable guidance)

## Validation Checklist

- Stored in `.github/skills/<name>/SKILL.md`
- Folder name must match `name` field in frontmatter
- `name` and `description` in frontmatter are required and specific
- Keep SKILL.md under 500 lines; use reference files for lengthy content
- File references should be one level deep from SKILL.md
- Body includes what skill accomplishes, when to use, procedures, and examples
