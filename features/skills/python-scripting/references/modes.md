# Python Scripting Modes

## Mode Selection Rules

Use these rules when the user does not explicitly choose a mode:

- OneOff: User asks for a snippet, quick command, inline solution, or REPL expression.
- FullProject: User asks for a package, reusable tool, CLI application, or multi-file project.
- Default: If ambiguous, use FullProject.

## Mode Summary

| Mode        | When to Use                    | Output          | Core Expectations                                           |
| ----------- | ------------------------------ | --------------- | ----------------------------------------------------------- |
| FullProject | Persisted, packaged automation | Directory tree  | OOP, strict typing, pyproject.toml, tests, logging          |
| OneOff      | Ad-hoc, immediate execution    | Inline snippet  | Short, stdlib-first, idiomatic, type hints on any functions |

## OneOff Guardrails

- 1-5 lines preferred, max 10 lines
- No classes, docstrings, or project scaffolding
- Use list comprehensions, generators, pathlib, and stdlib idioms
- Type hints on any function definitions
- No imports beyond stdlib unless the user's context already includes the dependency

## FullProject Guardrails

- src-layout directory structure with pyproject.toml
- All business logic in classes
- Strict typing on all signatures (`from __future__ import annotations`)
- Guard clauses at method entry
- Specific exception types; no bare `except:`
- Logging via stdlib `logging`; no `print()` for diagnostics
- pytest tests in tests/ directory
- Entry point in `__main__.py` calling a `main()` function
- pyproject.toml includes `[tool.ruff]` and `[tool.mypy]` configuration
- After generation: run `ruff format .`, `ruff check . --fix`, `mypy src/`, `pytest`
