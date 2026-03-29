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

| Directory    | Purpose                                                                    |
| ------------ | -------------------------------------------------------------------------- |
| `README.md`  | Project overview, setup, basic usage                                       |
| `LICENSE`    | License file (use SPDX identifier)                                         |
| `.gitignore` | Exclusions: `.tmp/`, build artifacts, `.env` files                         |
| `.github/`   | Workflows, issue templates, `copilot-instructions.md`, PR templates        |
| `.tmp/`      | Temporary agent/developer workspace (never committed)                      |
| `docs/`      | All documentation beyond root-level files                                  |
| Source dir   | Language-specific: `src/`, `lib/`, `cmd/`, `internal/`, `pkg/`, or root    |
| Test dir     | Language-specific: `tests/`, `spec/`, colocated `*_test.*`, or `src/test/` |
| Config files | Root-level: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, etc. |

## Example: Python

```
project/
├── .github/
│   ├── workflows/
│   ├── ISSUE_TEMPLATE/
│   └── copilot-instructions.md
├── .python-version
├── .tmp/
├── docs/
├── src/
│   └── mypackage/
│       ├── __init__.py
│       └── core.py
├── tests/
│   └── test_core.py
├── .gitignore
├── pyproject.toml
├── README.md
└── uv.lock
```

### Python Project Rules

**Build tooling:** All Python projects use [uv](https://docs.astral.sh/uv/) as the project manager. The only exception is throwaway one-off scripts with no build system.

**Required root files:**

| File               | Purpose                                                         |
| ------------------ | --------------------------------------------------------------- |
| `pyproject.toml`   | Project metadata, dependencies, dependency groups, tool configs |
| `.python-version`  | Pin the Python version for uv (e.g., `3.12`)                   |
| `uv.lock`          | Lock file — always committed to version control                 |

**Forbidden root files:**

| File          | Reason                                                                     |
| ------------- | -------------------------------------------------------------------------- |
| `main.py`     | Unnecessary with uv. Use `uv run <command>` or `[project.scripts]` entry points instead. |
| `setup.py`    | Replaced by `pyproject.toml`                                               |
| `setup.cfg`   | Replaced by `pyproject.toml`                                               |
| `Pipfile`     | Replaced by uv                                                             |
| `Pipfile.lock`| Replaced by `uv.lock`                                                      |
| `requirements.txt` | Replaced by `pyproject.toml` `[project.dependencies]` and `[dependency-groups]` |

**Virtual environment:** uv manages `.venv/` automatically via `uv sync`. Never create or activate virtual environments manually.

**Dependency groups (not optional-dependencies):** Dev tools belong in `[dependency-groups]` (PEP 735), not `[project.optional-dependencies]`:

```toml
[dependency-groups]
dev = [
    "mypy>=1.10",
    "pytest>=8.0",
    "ruff>=0.7",
]
```

**Running commands:** Always use `uv run` to execute project commands in the managed environment:

```bash
uv run pytest
uv run ruff check .
uv run mypy src/
uv run <entry-point-name>
```

**Installing as a global tool:** Use `uv tool install` for global CLI tool installation:

```bash
uv tool install .                # Install from local project
uv tool install package-name     # Install from PyPI
```

Adapt directory names to match your language's conventions (e.g., Go uses `cmd/`+`internal/`+`pkg/`, Ruby uses `lib/`+`spec/`, Java uses `src/main/`+`src/test/`).
