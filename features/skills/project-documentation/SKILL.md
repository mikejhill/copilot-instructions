---
name: project-documentation
description: "Use when creating, organizing, or reviewing project documentation in Markdown. Covers file naming conventions, root vs docs/ placement, docs/ subdirectory structure, and content structure within Markdown files."
---

# Project Documentation Skill

## Overview

All project documentation uses Markdown. This skill defines file naming rules, where documentation files belong, how to organize the `docs/` directory, and how to structure content within each file.

## File Naming

Two naming rules apply to all Markdown files in a project:

1. **Fixed uppercase names**: A small set of standard project-entry documents use fixed uppercase names. These are the only Markdown files allowed at the repository root.
    - `README.md`
    - `CHANGELOG.md`
    - `CONTRIBUTING.md`
    - `SECURITY.md`
    - `CODE_OF_CONDUCT.md`

2. **Lowercase-kebab-case**: All other Markdown files use lowercase-kebab-case (e.g., `getting-started.md`, `error-handling.md`, `release-process.md`).

Exceptions:

- `index.md` is allowed when required by documentation tooling.
- `README.md` is allowed in subdirectories when ecosystem conventions require it (e.g., package-level READMEs in monorepos).

## File Placement

### Root Level

Only the fixed uppercase Markdown files listed above belong at the repository root. Do not place any other documentation files at root.

- **README.md** (required): Project overview, getting started, basic usage, and navigation to deeper documentation.
- **CHANGELOG.md** (optional): Version history and release notes.
- **CONTRIBUTING.md** (optional): Contribution guidelines, code style, PR process. May alternatively live in `docs/`.
- **SECURITY.md** (optional): Security policy and vulnerability reporting.
- **CODE_OF_CONDUCT.md** (optional): Community conduct expectations.

### docs/ Directory

All other project documentation lives under `docs/`. Organize files into topic-based subdirectories rather than placing them flat in `docs/`.

## docs/ Subdirectories

Use these standard subdirectories within `docs/`:

| Directory               | Purpose                                                   |
| ----------------------- | --------------------------------------------------------- |
| `docs/guides/`          | How-to guides, tutorials, getting-started walkthroughs    |
| `docs/api/`             | API reference documentation                               |
| `docs/architecture/`    | System design, component diagrams, high-level overview    |
| `docs/decisions/`       | Architecture decision records (ADRs) and design rationale |
| `docs/examples/`        | Sample code and usage patterns                            |
| `docs/troubleshooting/` | Common issues and solutions                               |

Create additional subdirectories when a project's documentation does not fit these categories. Name them in lowercase-kebab-case.

## Content Structure

Every Markdown documentation file follows this general structure:

### 1. Title

Start with a single `# Heading` that names the document's subject. One `#` heading per file.

### 2. Overview

A brief paragraph (2-4 sentences) immediately after the title stating what this document covers and who it is for. The reader decides whether to continue based on this paragraph.

### 3. Body

Organize the body with `##` and `###` headings. Apply these rules:

- **One topic per section.** Each `##` section covers a single concept, procedure, or reference item.
- **Use lists over prose.** Bullet points and numbered lists are easier to scan than paragraphs.
- **Use numbered lists for sequential steps.** When order matters (procedures, setup instructions), number the steps.
- **Use code blocks with language identifiers.** Fence code with triple backticks and specify the language (e.g., ` ```bash `, ` ```typescript `). Always use backticks, never tildes. When a code block contains inner triple-backtick fences, use four backticks for the outer fence.
- **Use tables for structured comparisons.** When presenting options, configurations, or field definitions, use Markdown tables.
- **Link to related docs.** Use relative links to other documentation files rather than duplicating content.

### 4. Examples

Include at least one concrete example when the document describes a procedure, configuration, or API. Place examples inline within the relevant section or in a dedicated `## Examples` section at the end.

## Constraints

**MUST:**

- Use Markdown for all project documentation.
- Apply the fixed uppercase / lowercase-kebab-case naming split described above.
- Place only the fixed uppercase files at the repository root; all others under `docs/`.
- Start every documentation file with a single `#` heading.
- Include an overview paragraph after the title.

**MUST NOT:**

- Use spaces, mixed case, or snake_case in non-standard Markdown file names.
- Place ad hoc documentation files at the repository root.
- Scatter documentation across multiple directories without a centralized `docs/` location.
- Use multiple `#` headings in a single file.

**MAY:**

- Nest subdirectories within `docs/` beyond the standard set (e.g., `docs/guides/advanced/`).
- Use `index.md` within documentation subdirectories when required by tooling.
- Place `CONTRIBUTING.md` in `docs/` instead of root if preferred.
