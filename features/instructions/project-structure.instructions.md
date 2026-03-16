---
name: Project Structure
description: Use when organizing project files and directories to follow established conventions. Defines the purpose and usage of standard directories and files.
---

# Project Structure Standards

Maintain consistent directory organization: separate documentation, configuration, temporary work, and source code into designated directories following language/framework conventions.

## Rules

**MUST:**

- Place configuration files at the project root or in a dedicated `config/` directory
- Place documentation in `docs/` with `README.md` at root level (see project-documentation skill)
- Use `.tmp/` exclusively for temporary agent/developer artifacts (see temp-storage instructions)
- Place GitHub workflows, issue templates, and Copilot customization in `.github/`
- Keep `.gitignore` and standard dot-files at root level
- Designate source and test directories following language/framework conventions
- Include `.tmp/` in `.gitignore` — never commit temporary files

**MUST NOT:**

- Place temporary or work-in-progress files in the root directory
- Store configuration inside source or test directories unless language conventions require it
- Place source and test files at root without clear directory separation

**MAY:**

- Add top-level directories for domain concerns (e.g., `scripts/`, `examples/`, `benchmarks/`)
- Place source at root if language conventions dictate (e.g., Python, Ruby, PHP)
- Colocate tests with source if language conventions prefer (e.g., Go, Rust, JavaScript)

## Standard Directories

| Directory | Purpose |
|-----------|---------|
| `README.md` | Project overview, setup, basic usage |
| `LICENSE` | License file (use SPDX identifier) |
| `.gitignore` | Exclusions: `.tmp/`, build artifacts, `.env` files |
| `.github/` | Workflows, issue templates, `copilot-instructions.md`, PR templates |
| `.tmp/` | Temporary agent/developer workspace (never committed) |
| `docs/` | All documentation beyond root-level files |
| Source dir | Language-specific: `src/`, `lib/`, `cmd/`, `internal/`, `pkg/`, or root |
| Test dir | Language-specific: `tests/`, `spec/`, colocated `*_test.*`, or `src/test/` |
| Config files | Root-level: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, etc. |

## Example: Python

```
project/
├── .github/
│   ├── workflows/
│   ├── ISSUE_TEMPLATE/
│   └── copilot-instructions.md
├── .tmp/
├── docs/
├── src/
│   └── mypackage/
│       ├── __init__.py
│       └── core.py
├── tests/
│   └── test_core.py
├── .gitignore
├── README.md
└── pyproject.toml
```

Adapt directory names to match your language's conventions (e.g., Go uses `cmd/`+`internal/`+`pkg/`, Ruby uses `lib/`+`spec/`, Java uses `src/main/`+`src/test/`).
