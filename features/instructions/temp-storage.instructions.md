---
name: agent-tmp-directory
description: Provides instructions on how to use the `.tmp/` directory for temporary agent storage. This should be uesd any time that a task would benefit from temporary storage, such as internal scripts, problem analysis, short-term memory, intermediate agent state, tool outputs, agent coordintaion, and more.
applyTo: "**"
---

# Agent Temporary Directory Management

Use the `.tmp/` directory liberally to store temporary artifacts in order to enable state preservation, rollback capability, debugging visibility, and clean separation between working files and final outputs.

## Purpose

The temporary directory `.tmp/` should be used to store any emphemeral files which are useful for agents. This behaves as a temporary file storage and short-term memory. This supports the following functions:

- **Reduce context bloat**: Store various intermediate session-related information to reduce context window usage and reliance.
- **Store information for future reference**: Reference data for future agent runs, such as inferred repository or research data.
- **Sharing outputs between agents and sessions**: Intermediate and detailed results from sessions and subagents.
- **Scripts and supporting files**: Files used for script execution, such as Python scripts used for analysis.
- **Script and tool outputs**: Temporary output files for later reference.
- **Reports and analyses**: Full reports and analyses which can be useful for both users and agents.

## Process

1. Create a session-specific ID: 8 random alphanumeric characters `[a-zA-Z0-9]` (e.g., `x7f3K9m2`, `B4n8pQ1w`).
2. Read context from `.tmp/` when necessary to restore state or access previous analysis.
3. Create subdirectories under `.tmp/` as needed for different artifact types.
4. Write files using naming conventions that include the session ID, timestamp, or stage number.
5. Preserve files across operations unless cleanup is required for correctness.

## Path Structure

### Directories

```
.tmp/
  ├── checkpoints/  # State checkpoints before risky operations
  ├── scripts/      # Scripts and supporting files
  ├── outputs/      # Outputs from tool calls and scripts
  ├── reports/      # Temporary reports and analyses
  ├── info/         # Inferred information
  └── other/        # All other files
```

### Files

**Session-specific files:**

- Format: `.tmp/{directory}/{session-id}-{description}.{ext}`
- Example: `.tmp/reports/x7f3K9m2-api-analysis.md`
- Use when coordination across multiple operations in a single session

**Timestamp files:**

- Format: `.tmp/{directory}/YYYYMMDD-HHMMSS-{description}.{ext}`
- Example: `.tmp/outputs/20260301-143022-eslint-results.json`
- Use for time-ordered logs or sequential operations

**Stage-based files:**

- Format: `.tmp/{directory}/{step-number}-{operation}-{filename}.{ext}`
- Example: `.tmp/reports/01-parse-input.json`, `02-transform-data.json`, `03-final-output.json`
- Use for multi-step operations where intermediate stages need to be preserved in order

**General, non-session-specific:**

- Format: `.tmp/{directory}/{description}.{ext}`
- Example: `.tmp/info/repository-structure.json`
- Use for reusable context that persists across sessions

## Example Use Cases

- **Analysis and planning**: Store search results, research findings, or architectural diagrams before committing decisions. Preserves the discovery process for debugging or user review.
- **Error-handling and recovery**: Save state checkpoints before risky operations, enabling rollback to last-known-good state if failures occur.
- **Tool integration**: Stage raw tool outputs (ESLint, TypeScript compiler, API responses) for filtering, validation, or transformation before applying changes.
- **Temporary scripts and outputs**: Store generated scripts, shell commands, or tool-generated code that needs validation before execution.
- **Agent coordination**: Use `.tmp/` as a message bus between sequential agents or multi-agent workflows, keeping handoff data organized and separate from workspace.
- **Testing and validation**: Generate test data, mock responses, or validation reports without cluttering the workspace or committing temporary test artifacts.
- **Context management**: Preserve intermediate analysis results, decision trees, or reasoning chains to reduce token usage and aid future agent runs.
- **Multi-step transformations**: Break complex operations into stages, storing intermediate results at each step for visibility, debugging, and ability to resume on failure.

## Usage

- Use `.tmp/` for all temporary files.
- Create and use these files liberally.
- Modify files freely to maintain accurate state.
- Do not commit these files. `.tmp/` should be included in `.gitignore`.
- Do not use this for permanent storage. These files will be removed periodically.
- Avoid disruptive actions to files in use by other agents. Other agents may be simultaneously operating in this directory.
- Avoid deleting files unless necessary to maintain accurate state. Leave intermediate files for future use and user debugging.
