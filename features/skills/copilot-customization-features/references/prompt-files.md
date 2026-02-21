# Prompt Files

## Overview

- **Purpose:** Provide explicit, reusable prompts for repeatable tasks.
- **When to use:** Use when the task should be invoked explicitly and run consistently.
- **File location:**
  - Directory: `.github/prompts/`
  - File naming: `<name>.prompt.md` where `<name>` is descriptive and task-focused
  - Examples: `generate-api-route.prompt.md`, `review-security.prompt.md`, `scaffold-component.prompt.md`
  - Must use lowercase and hyphens
- **Selection/activation:** Prompt files are run explicitly by the user:
  - **Chat:** Type `/` and select prompt from list
  - **Command Palette:** Run `Chat: Run Prompt...`
  - **Editor:** Open prompt file and click the play button

## Frontmatter

```yaml
---
name: "generate-api-route" # Optional: Defaults to filename
description: "Generate an Express route..." # Optional: Shown in prompt picker
argument-hint: "Enter method and path..." # Optional: Hint text in chat input
agent: "agent" # Optional: ask, edit, agent, or custom agent name
tools: ["search", "fetch"] # Optional: Tool aliases, MCP servers, extensions
model: "Claude Sonnet 4" # Optional: Overrides user's selected model
---
```

All fields are optional:

- `name`: Prompt name shown after typing `/` in chat (defaults to filename if omitted)
- `description`: Brief explanation of what the prompt does (shown in prompt picker)
- `argument-hint`: User-friendly hint text shown in chat input to guide usage (e.g., "Enter feature name", "Specify file path")
- `agent`: Which agent runs the prompt (`ask`, `edit`, `agent`, or custom agent name)
- `tools`: List of tools available when running this prompt (built-in aliases, MCP servers, extension tools)
- `model`: Specific AI model to use (overrides user's selected model)

## Body Layout

Input → Output → Steps → Example. Use variables like `${selection}` or `${input:variable}` when needed.

## Examples

```markdown
---
name: generate-api-route
description: Generate an Express route with validation, error handling, and JSDoc.
argument-hint: Enter HTTP method and path (e.g., POST /users)
---

# Generate Express API Route

## Input

- HTTP method
- Route path
- Business logic summary

## Output

A TypeScript Express route with validation and error handling.

## Steps

1. Validate inputs
2. Implement handler
3. Add error handling
4. Add JSDoc

## Example

Input: POST /users with name and email
Output: Route handler with validation and database insert
```

## Anti-patterns

- Multi-task prompts trying to do too much ("create and test and deploy")
- Vague descriptions that don't help users understand when to use the prompt
- Including many tools when the task only needs search or file access

## Validation Checklist

- Stored in `.github/prompts/` folder
- File naming: `*.prompt.md`
- All frontmatter fields are optional
- Uses variables (`${selection}`, `${input:var}`) or tools only when required
