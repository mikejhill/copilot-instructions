---
name: copilot-customization-features
description: Use when authoring GitHub Copilot customization artifacts in VS Code to select the correct feature type and format it correctly (custom instructions, AGENTS.md, agent skills, prompt files, and custom agents).
---

# Skill Instructions

Use the same structure for each feature type: Purpose, When to use, Selection/activation, File location, Required metadata, Body layout, Example, Reference.

## Cheatsheet

| Feature             | Use when                         | Selection/activation                       | File location                            |
| ------------------- | -------------------------------- | ------------------------------------------ | ---------------------------------------- |
| Custom instructions | Always-on coding standards       | Auto-applied                               | .github/copilot-instructions.md          |
| Instructions files  | File- or task-specific rules     | Auto-applied by `applyTo` or manual attach | .github/instructions/\*.instructions.md  |
| AGENTS.md           | Global agent instructions        | Auto-applied (optional)                    | AGENTS.md (workspace root or subfolders) |
| Agent Skills        | On-demand capabilities           | Auto-loaded by `description` match         | .github/skills/skill-name/SKILL.md       |
| Prompt files        | Explicit, repeatable tasks       | Run by user                                | .github/prompts/prompt-name.prompt.md    |
| Custom agents       | Role-specific tools+instructions | Selected by user                           | .github/agents/agent-name.agent.md       |

## Global rules

**Naming:**

- Use lowercase, hyphen-separated names for variable-name features (skills, prompts, agents).
- Avoid generic names (e.g., "testing", "instructions", "standards").
- Use descriptive, action-oriented names that indicate purpose or capability (e.g., `jest-test-generation`, `generate-api-route`, `code-reviewer`).
- Fixed-name features (custom instructions, AGENTS.md) have specific filenames; no variation needed.

**Other rules:**

- For Agent Skills, the `description` is the only text used for automatic activation. It must state capability and when to use it.
- For Prompt Files and Custom Agents, the `description` is UI metadata; make it specific and task-focused.
- For Custom Instructions and AGENTS.md, do not use YAML frontmatter.
- Include one concrete example per feature type.

For detailed guidance on phrasing rules, constraints, and instructions, reference the [writing-ai-instructions](../writing-ai-instructions/SKILL.md) skill.

## Custom instructions (.github/copilot-instructions.md)

**Reference:** [Custom instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)

**Purpose:** Define workspace-wide rules, standards, and conventions.

**When to use:** Use for guidance that should apply to every chat request in the workspace.

**Naming & File location:**

- File path: `.github/copilot-instructions.md`.
- Filename is fixed with no variation.

**Selection/activation:** Automatically applied to all chat requests in the workspace.

**Metadata:** None. Do not use YAML frontmatter.

**Body layout:** Use headings, imperative rules, and examples.

**Example:**

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

## Instructions Files

**Reference:** [Custom instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)

**Purpose:** Define scoped instructions for specific files, languages, or folders.

**When to use:** Use when rules should apply only to matching files or tasks.

**Naming & File location:**

- File path: `.github/instructions/<name>.instructions.md`.
- File names: Use descriptive, domain-specific names (e.g., `python-standards`, `api-guidelines`, `react-patterns`).
  - Files must end with `.instructions.md` and use lowercase and hyphens.
  - Example: `python-standards.instructions.md`.

**Selection/activation:**

- Auto-applied when `applyTo` matches the file being edited.
- If `applyTo` is omitted, the file is not auto-applied and must be manually attached to a chat request.

**Metadata (optional):**

```yaml
---
name: Python instructions
description: Python coding standards for services.
applyTo: "**/*.py"
---
```

- All fields are optional.
- `applyTo`: Glob pattern for auto-applying to matching files. If omitted, file must be manually attached.

**Body layout:** Use short, testable rules.

**Example:**

```markdown
---
applyTo: "**/*.py"
---

# Python Standards

- Use type hints for all public functions
- Prefer pathlib over os.path
```

## AGENTS.md

**Reference:** [Custom instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)

**Purpose:** Provide custom instructions intended for all agents in the workspace. Intended to be tool-agnostic (GitHub Copilot, Claude Code, etc.).

**When to use:** Use when multiple agents share the same baseline rules and constraints.

**Naming & File location:**

- File path: `AGENTS.md` (workspace root) or nested `AGENTS.md` files in subfolders (experimental).
- Filename is fixed with no variation.
- Example: `AGENTS.md` or `src/AGENTS.md`.

**Selection/activation:**

- Automatically applied to all chat requests.
- When multiple `AGENTS.md` files exist (workspace root and subfolders), only the closest `AGENTS.md` to the active file is used.

**Metadata:** None. Do not use YAML frontmatter.

**Body layout:** Keep rules concise and agent-agnostic.

**Example:**

```markdown
# Agent-wide Instructions

- Do not modify files without confirmation
- Prefer reading existing code before proposing changes
```

## Agent Skills

**Reference:** [Agent skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)

**Purpose:** Provide specialized, reusable capabilities with optional scripts and resources.

**When to use:** Use for task-specific workflows that should load on demand.

**Naming & File location:**

- File path: `.github/skills/<name>/SKILL.md`.
- Skill names: Use descriptive, capability-focused names in lowercase with hyphens (e.g., `jest-test-generation`, `api-scaffolding`, `security-audit`).
  - Avoid generic names like "testing" or "utilities".
  - Folder name becomes the skill identifier.
  - Example: `.github/skills/jest-test-generation/SKILL.md`.

**Selection/activation:** Skills are auto-selected when the user request matches the frontmatter `description`. **CRITICAL:** Only `name` and `description` are used for discovery - the description is the ONLY text that determines whether the skill loads. Make it comprehensive and specific.

**Metadata (required):**

```yaml
---
name: skill-name
description: State capability and when to use it. This drives auto-activation.
---
```

**Description field:** This is the ONLY text used for skill activation. Include:

- What the skill does (capabilities)
- When to use it (trigger scenarios)
- Key technologies or patterns involved
- Be specific to avoid false matches

**Body layout:** What the skill accomplishes, step-by-step procedures, and examples. Reference files using relative paths, for example `[template](./template.js)`.

**Description examples:**

- "Use when generating REST APIs from OpenAPI specs with validation and error handling."
- "Use when writing PowerShell scripts that require registry modifications and idempotent checks."
- "Use when creating React components that must follow MUI v5 patterns."

**Example:**

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

## Prompt Files

**Reference:** [Prompt files](https://code.visualstudio.com/docs/copilot/customization/prompt-files)

**Purpose:** Provide explicit, reusable prompts for repeatable tasks.

**When to use:** Use when the task should be invoked explicitly and run consistently.

**Naming & File location:**

- File path: `.github/prompts/<name>.prompt.md`.
- File names: Use descriptive, task-focused names in lowercase with hyphens (e.g., `generate-api-route`, `review-security`, `scaffold-component`).
  - Files must end with `.prompt.md`.
  - Example: `generate-api-route.prompt.md`.

**Selection/activation:** Prompt files are run explicitly by the user. Prompt name is available after typing `/` in chat.

**Metadata (optional):**

```yaml
---
name: generate-api-route
description: Generate an Express route with validation, error handling, and JSDoc.
argument-hint: Enter method and path (e.g., POST /users)
agent: agent
tools: ["search", "fetch"]
model: Claude Sonnet 4
---
```

**Frontmatter fields:**

- `name`: Prompt name shown after typing `/` in chat (defaults to filename if omitted)
- `description`: Brief explanation of what the prompt does
- `argument-hint`: User-friendly hint text shown in chat input to guide usage (e.g., "Enter feature name", "Specify file path")
- `agent`: Which agent runs the prompt (`ask`, `edit`, `agent`, or custom agent name)
- `tools`: List of tools available when running this prompt
- `model`: Specific AI model to use (overrides user's selected model)

**Body layout:** Input → Output → Steps → Example. Use variables like `${selection}` or `${input:variable}` when needed.

**Example:**

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

## Custom Agents

**Reference:** [Custom agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)

**Purpose:** Define specialist assistants with explicit scope, tools, and constraints.

**When to use:** Use for role-specific workflows (planning, research, front-end, etc.).

**Naming & File location:**

- File path: `.github/agents/<name>.agent.md`.
- Agent names: Use descriptive, role-focused names in lowercase with hyphens (e.g., `code-reviewer`, `planner`, `api-designer`).
  - Names must clearly indicate the agent's specialized function.
  - Files must end with `.agent.md`.
  - Example: `code-reviewer.agent.md`.

**Selection/activation:** Agents are selected explicitly by the user. Handoffs can guide sequential workflows.

**Metadata (optional):**

```yaml
---
name: Planner
description: Generate implementation plans without editing files.
argument-hint: "feature=..."
tools: ["search", "fetch"]
model: Claude Sonnet 4
infer: true
handoffs:
  - label: Implement Plan
    agent: agent
    prompt: Implement the plan outlined above.
    send: false
---
```

- All fields are optional.
- `tools`: List of available tools for this agent (if not provided, all user-enabled tools are available)
- `model`: AI model to use
- `infer`: Enable use as subagent (default: true)
- `handoffs`: Define sequential workflow transitions with label, target agent, prompt, and send (auto-submit) flag

**Body layout:** Role → Capabilities → Tools → Constraints → Handoffs/Subagent criteria → Examples.

**Example:**

```markdown
---
name: planner
description: Generate implementation plans without modifying code.
tools: ["search", "fetch"]
handoffs:
  - label: Start Implementation
    agent: agent
    prompt: Implement the plan outlined above step by step.
    send: false
  - label: Review Plan
    agent: code-reviewer
    prompt: Review this implementation plan for potential issues.
    send: false
---

# Planner Agent

## Role

Research and generate detailed implementation plans without editing files.

## Capabilities

- Analyze requirements and existing codebase
- Create step-by-step implementation plans
- Identify dependencies and potential risks

## Tools

- search, fetch (read-only operations)

## Constraints

- DO NOT modify any files
- DO NOT run code or tests

## Handoffs

After generating a plan, users can:

- Click "Start Implementation" to switch to the default agent with the implementation prompt pre-filled
- Click "Review Plan" to switch to code-reviewer agent for plan validation

## Examples

Task: Plan a new authentication feature
Output: Detailed plan with steps, files to modify, and testing approach
Next: User clicks "Start Implementation" to begin coding
```

**How handoffs work:**

- After the agent completes its response, handoff buttons appear below the output
- Clicking a handoff button switches to the target agent and pre-fills the prompt
- If `send: true`, the prompt auto-submits; if `send: false` (recommended), user can review/edit first

## Validation Checklist

### All Features

- Name is lowercase and hyphen-separated (skills, prompts, agents)
- File path matches feature type
- Examples are included

### Custom Instructions

- Stored at `.github/copilot-instructions.md` (workspace root)
- No YAML frontmatter
- Rules are specific and testable

### Instructions Files

- Stored in `.github/instructions/` folder (workspace) or user profile
- File naming: `*.instructions.md`
- `applyTo` glob pattern enables auto-application; omit for manual attachment only

### AGENTS.md

- Stored at workspace root as `AGENTS.md`
- Optional nested files in subfolders (experimental)
- Contains agent-wide instructions (not a registry)

### Agent Skills

- Project: `.github/skills/<name>/SKILL.md`
- Personal: `~/.copilot/skills/<name>/SKILL.md`
- File naming: Skill folder name + `/SKILL.md`
- `name` and `description` in frontmatter are required and specific
- Body includes what skill accomplishes, when to use, procedures, and examples

### Prompt Files

- Workspace: `.github/prompts/` folder or user profile
- File naming: `*.prompt.md`
- All frontmatter fields are optional
- Uses variables (`${selection}`, `${input:var}`) or tools only when required

### Custom Agents

- Workspace: `.github/agents/` folder or user profile
- File naming: `*.agent.md`
- All frontmatter fields are optional
- Tools and constraints are explicit when specified
- Handoffs are defined when workflow needs staged steps
