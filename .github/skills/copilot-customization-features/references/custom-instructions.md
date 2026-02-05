# Custom Instructions

## Overview

- **Purpose:** Define workspace-wide rules, standards, and conventions.
- **When to use:** Use for guidance that should apply to every chat request in the workspace.
- **File location:**
  - Path: `.github/copilot-instructions.md`
  - Fixed filename with no variation
- **Selection/activation:** Automatically applied to all chat requests in the workspace.

## Frontmatter

None. Do not use YAML frontmatter.

## Body Layout

Use headings, imperative rules, and examples. Keep concise—link to detailed docs rather than embedding full content.

### Core Principles

- **Minimal by default:** Only include what's relevant to every task
- **Link, don't embed:** Reference docs instead of copying content
- **Keep current:** Update when practices change

## Examples

````markdown
# React Component Standards

## Naming

- Use PascalCase for component names
- Match file names to component names

## Hooks

- DO NOT call hooks conditionally
- Extract complex hook logic into custom hooks

## Example

```tsx
export const UserProfile = ({ userId }) => {
  const [user, setUser] = useState(null);
  // ...
};
```
````

## Anti-patterns

- Using both copilot-instructions.md AND AGENTS.md (choose one)
- Kitchen sink approach (including everything instead of what matters most)
- Duplicating README or other docs instead of linking to them
- Adding obvious instructions already enforced by linters/formatters

## Validation Checklist

- Stored at `.github/copilot-instructions.md` (workspace root)
- No YAML frontmatter
- Rules are specific and testable
- Do NOT use both copilot-instructions.md AND AGENTS.md (choose one)
