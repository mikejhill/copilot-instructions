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

## Decision Flow

Use this flow to quickly choose the right feature type:

| Requirement                                            | Feature Type                                          |
| ------------------------------------------------------ | ----------------------------------------------------- |
| Should this apply to every request in the workspace?   | Custom instructions or AGENTS.md                      |
| Should this apply only to specific files/folders?      | Instructions files (with `applyTo`)                   |
| Should this load on-demand when relevant?              | Instructions files (with `description`), Agent Skills |
| Is this a single focused task with inputs?             | Prompt files                                          |
| Does this need bundled assets (scripts/templates)?     | Agent Skills                                          |
| Does this need tool restrictions or context isolation? | Custom agents                                         |
| Is this a multi-stage workflow with handoffs?          | Custom agents                                         |

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

## Custom Instructions

### Overview

- **Purpose:** Define workspace-wide rules, standards, and conventions.
- **When to use:** Use for guidance that should apply to every chat request in the workspace.
- **File location:**
  - Path: `.github/copilot-instructions.md`
  - Fixed filename with no variation
- **Selection/activation:** Automatically applied to all chat requests in the workspace.

### Frontmatter

None. Do not use YAML frontmatter.

### Body Layout

Use headings, imperative rules, and examples. Keep concise—link to detailed docs rather than embedding full content.

#### Core Principles

- **Minimal by default:** Only include what's relevant to every task
- **Link, don't embed:** Reference docs instead of copying content
- **Keep current:** Update when practices change

### Examples

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

### Anti-patterns

- Using both copilot-instructions.md AND AGENTS.md (choose one)
- Kitchen sink approach (including everything instead of what matters most)
- Duplicating README or other docs instead of linking to them
- Adding obvious instructions already enforced by linters/formatters

## Instructions Files

### Overview

- **Purpose:** Define scoped instructions for specific files, languages, or folders.
- **When to use:** Use when rules should apply only to matching files or tasks.
- **File location:**
  - Directory: `.github/instructions/`
  - File naming: `<name>.instructions.md` where `<name>` is descriptive and domain-specific
  - Examples: `python-standards.instructions.md`, `api-guidelines.instructions.md`, `react-patterns.instructions.md`
  - Must use lowercase and hyphens
- **Selection/activation:** Three modes:
  - **On-demand** (`description`): Agent detects task relevance (task-based: migrations, refactoring, API work)
  - **Explicit** (`applyTo`): Files matching glob in context (file-based: language standards, framework rules)
  - **Manual**: User attaches via "Add Context" (ad-hoc attachment)
  - Note: `applyTo` triggers when creating or modifying matching files, not for read-only operations

### Frontmatter

```yaml
---
name: "Display Name" # Optional: Defaults to filename
description: "Use when..." # Optional: Enables on-demand semantic activation
applyTo: "**/*.py" # Optional: Glob pattern for explicit file matching
---
```

All fields are optional:

- `name`: Display name shown in UI when file is attached or referenced (defaults to filename if omitted).
- `description`: Enables on-demand semantic activation when request matches. Use "Use when..." pattern for clarity.
  - Can be combined with `applyTo` for dual activation: pattern-based AND semantic.
  - When used alone (without `applyTo`), enables pure semantic matching.
  - Include trigger scenarios and key technologies for better discovery.
- `applyTo`: Glob pattern(s) for explicit auto-application to matching files.
  - Single pattern: `"**/*.py"`
  - Multiple patterns (OR logic): `["src/**", "lib/**"]` or `["**/*.ts", "**/*.tsx"]`

### Body Layout

Use short, testable rules.

### Examples

#### Pattern-based

```markdown
---
applyTo: "**/*.py"
---

# Python Standards

- Use type hints for all public functions
- Prefer pathlib over os.path
```

#### Semantic On-demand

```markdown
---
name: API Guidelines
description: Use when designing or implementing REST APIs to ensure consistent error handling and versioning.
---

# API Standards

- All endpoints must return structured error responses
- Use semantic versioning in URL paths (/v1/, /v2/)
- Include rate limit headers in responses
```

### Anti-patterns

- Vague descriptions that don't enable discovery (e.g., "Helpful coding tips")
- Overly broad `applyTo` patterns (e.g., `"**"`) with content only relevant to specific files
- Duplicating documentation instead of linking
- Mixing multiple concerns in one file (testing + API design + styling)

## AGENTS.md

### Overview

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

### Frontmatter

None. Do not use YAML frontmatter.

### Body Layout

Keep rules concise and agent-agnostic.

**AGENTS.md hierarchy:** For monorepos, the closest AGENTS.md in the directory tree takes precedence, allowing folder-specific overrides.

### Examples

```markdown
# Agent-wide Instructions

- Do not modify files without confirmation
- Prefer reading existing code before proposing changes
```

## Agent Skills

### Overview

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

#### Folder Structure

```
.github/skills/<skill-name>/
├── SKILL.md           # Required (name must match folder)
├── scripts/           # Executable code
├── references/        # Docs loaded as needed
└── assets/            # Templates, boilerplate
```

### Frontmatter

```yaml
---
name: skill-name # Required: Lowercase alphanumeric + hyphens, must match folder name
description: "Use when..." # Required: State capability and when to use. Drives auto-activation.
---
```

#### Description Field

This is the ONLY text used for skill activation. Include:

- What the skill does (capabilities)
- When to use it (trigger scenarios)
- Key technologies or patterns involved
- Be specific to avoid false matches

### Body Layout

What the skill accomplishes, step-by-step procedures, and examples.

#### Bundled Assets

Skills can include additional files in the same directory:

- Scripts, templates, checklists, or reference data
- Reference using relative paths: `[template](./template.js)` or `[checklist](./checklist.md)`
- Keep main SKILL.md file under 500 lines; move lengthy content to separate files
- Keep file references one level deep from SKILL.md for optimal loading
- Organize with clear file naming (e.g., `scripts/test.js`, `references/api-spec.md`, `assets/template.ts`)

#### Progressive Loading

Skills load in stages to optimize token usage:

1. **Discovery** (~100 tokens): Agent reads `name` and `description`
2. **Instructions** (<5000 tokens): Loads SKILL.md body when relevant
3. **Resources**: Additional files load only when referenced

#### Description Examples

- "Use when generating REST APIs from OpenAPI specs with validation and error handling."
- "Use when writing PowerShell scripts that require registry modifications and idempotent checks."
- "Use when creating React components that must follow MUI v5 patterns."

### Examples

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

### Anti-patterns

- Vague descriptions that don't enable discovery (e.g., "A helpful skill")
- Monolithic SKILL.md with everything in one file instead of using reference files
- Name mismatch between folder name and frontmatter `name` field
- Missing step-by-step procedures (descriptions without actionable guidance)

## Prompt Files

### Overview

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

### Frontmatter

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

### Body Layout

Input → Output → Steps → Example. Use variables like `${selection}` or `${input:variable}` when needed.

### Examples

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

### Anti-patterns

- Multi-task prompts trying to do too much ("create and test and deploy")
- Vague descriptions that don't help users understand when to use the prompt
- Including many tools when the task only needs search or file access

## Custom Agents

### Overview

- **Purpose:** Define specialist assistants with explicit scope, tools, and constraints.
- **When to use:** Use for role-specific workflows (planning, research, front-end, etc.).
- **File location:**
  - Directory: `.github/agents/`
  - File naming: `<name>.agent.md` where `<name>` is descriptive and role-focused
  - Examples: `code-reviewer.agent.md`, `planner.agent.md`, `api-designer.agent.md`
  - Names must clearly indicate the agent's specialized function
  - Must use lowercase and hyphens
- **Selection/activation:** Three modes:
  - **Explicit selection:** User selects the agent from the agent picker in chat
  - **Subagent invocation:** Agents can be automatically invoked via the `runSubagent` tool when `infer: true` (default) and the agent's `description` matches the task
  - **Handoffs:** Agents can trigger workflow transitions to other agents via handoff buttons

### Frontmatter

```yaml
---
name: "Planner" # Optional: Defaults to filename
description: "Generate implementation plans" # Optional: Used for picker and subagent discovery
argument-hint: "feature=..." # Optional: Hint text in chat input
tools: ["search", "web"] # Optional: Defaults to all user-enabled tools
model: "Claude Sonnet 4" # Optional: Overrides user's selected model
agents: ["Agent1", "Agent2"] # Optional: Restrict allowed subagents (omit=all, []=none)
infer: "all" # Optional: "all"|true, "user"|false, "agent", "hidden"
handoffs: # Optional: Workflow transitions
  - label: "Implement Plan"
    agent: "agent"
    prompt: "Implement the plan..."
    send: false
---
```

All fields are optional:

- `name`: Display name shown in agent picker (defaults to filename if omitted).
- `description`: Brief explanation of agent's purpose. Used for subagent discovery when `infer` allows.
- `argument-hint`: User-friendly hint text shown in chat input (e.g., "feature=...").
- `tools`: List of available tools for this agent. If omitted, all user-enabled tools are available.
  - Use `[]` for no tools (conversational only)
  - Common patterns: `["read", "search"]` (read-only), `["read", "edit", "search"]` (no terminal)
- `model`: Specific AI model to use (overrides user's selected model).
- `agents`: Restrict allowed subagents by name array. Omit for all agents, `[]` for none.
- `infer`: Control agent visibility and subagent invocation:
  - `"all"` or `true`: Available in picker AND as subagent (default)
  - `"user"` or `false`: Only in picker, not as subagent
  - `"agent"`: Only as subagent, hidden from picker
  - `"hidden"`: Not available anywhere
- `handoffs`: Define sequential workflow transitions with:
  - `label`: Button text shown to user
  - `agent`: Target agent name to switch to
  - `prompt`: Pre-filled prompt text for next agent
  - `send`: Auto-submit flag (true/false). Recommended: false for user review.

#### Tool Aliases

| Alias     | Purpose                           |
| --------- | --------------------------------- |
| `execute` | Run terminal commands             |
| `read`    | Read file contents                |
| `edit`    | Edit files                        |
| `search`  | Search files or text              |
| `agent`   | Invoke custom agents as subagents |
| `web`     | Fetch URLs and web search         |
| `todo`    | Manage task lists                 |

### Body Layout

Role → Capabilities → Tools → Constraints → Handoffs/Subagent criteria → Examples.

### Examples

```markdown
---
name: planner
description: Generate implementation plans without modifying code.
tools: ["search", "web"]
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

#### How Handoffs Work

- After the agent completes its response, handoff buttons appear below the output
- Clicking a handoff button switches to the target agent and pre-fills the prompt
- If `send: true`, the prompt auto-submits; if `send: false` (recommended), user can review/edit first

### Anti-patterns

- Swiss-army agents with too many tools trying to do everything
- Vague descriptions that don't guide delegation ("A helpful agent")
- Role confusion where description doesn't match body persona
- Circular handoffs (A → B → A) without clear progress criteria

## Selection Criteria

Use these criteria when choosing between similar feature types:

### Instructions Files vs Agent Skills

- Does this apply to _most_ work in a domain? → Instructions Files
- Does this apply to _specific_ tasks or workflows? → Agent Skills
- Example: "Always use type hints in Python" → Instructions. "Generate Jest tests with mocks" → Skill.

### Agent Skills vs Prompt Files

- Multi-step workflow with bundled assets (scripts, templates)? → Agent Skills
- Single focused task with parameterized inputs? → Prompt Files
- Example: "Security audit with checklist + scripts" → Skill. "Generate API route from method + path" → Prompt.

### Agent Skills vs Custom Agents

- Same capabilities needed for all steps? → Agent Skills
- Need context isolation (subagent returns single output)? → Custom Agents
- Need different tool restrictions per stage? → Custom Agents
- Example: "Generate tests following team standards" → Skill. "Plan feature (read-only) → Implement → Review (different tools each stage)" → Custom Agents.

### Custom Instructions vs AGENTS.md

- GitHub Copilot-specific standards? → Custom instructions
- Tool-agnostic rules for multiple AI assistants? → AGENTS.md
- Use both when needed; they complement each other.

## Validation Checklist

### All Features

- Name is lowercase and hyphen-separated (skills, prompts, agents)
- File path matches feature type
- Examples are included

### Custom Instructions

- Stored at `.github/copilot-instructions.md` (workspace root)
- No YAML frontmatter
- Rules are specific and testable
- Do NOT use both copilot-instructions.md AND AGENTS.md (choose one)

### Instructions Files

- Stored in `.github/instructions/` folder
- File naming: `*.instructions.md`
- `applyTo` enables explicit pattern-based activation
- `description` enables on-demand semantic activation (use "Use when..." pattern)
- Both can be combined for dual activation modes
- If neither is provided, file requires manual attachment

### AGENTS.md

- Stored at workspace root as `AGENTS.md` and/or optional nested files in subfolders
- Contains agent-wide instructions for all files (not a discoverable registry)

### Agent Skills

- Stored in `.github/skills/<name>/SKILL.md`
- Folder name must match `name` field in frontmatter
- `name` and `description` in frontmatter are required and specific
- Keep SKILL.md under 500 lines; use reference files for lengthy content
- File references should be one level deep from SKILL.md
- Body includes what skill accomplishes, when to use, procedures, and examples

### Prompt Files

- Stored in `.github/prompts/` folder
- File naming: `*.prompt.md`
- All frontmatter fields are optional
- Uses variables (`${selection}`, `${input:var}`) or tools only when required

### Custom Agents

- Stored in `.github/agents/` folder
- File naming: `*.agent.md`
- All frontmatter fields are optional
- Configure `infer` to control picker visibility and subagent invocation
- Use minimal tool sets appropriate to the agent's role
- Define clear constraints on what the agent should NOT do
- Handoffs are defined when workflow needs staged steps
- Avoid circular handoffs without progress criteria
