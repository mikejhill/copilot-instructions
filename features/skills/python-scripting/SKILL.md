---
name: python-scripting
description: Use when creating, modifying, or refactoring Python scripts or projects that require production-quality standards including OOP architecture, strict typing, structured logging, pytest-based testing, pyproject.toml packaging, and src-layout directory structure.
---

# Python Script Development

## Objective

Produce Python solutions in two modes: full projects for persisted, packaged applications and one-offs for ad-hoc execution. Full projects must be OOP-first, strictly typed, tested, and packaged with pyproject.toml; one-offs must be short and runnable inline.

## Scope

**In-scope:**

- New Python scripts, modules, and packages
- Refactors of existing Python code
- One-off snippets
- OOP design with strict typing
- Argument parsing, logging, error handling
- Project structure with src-layout
- pyproject.toml configuration
- Virtual environment setup
- pytest-based testing

**Out-of-scope:**

- Web frameworks (Django, Flask, FastAPI)
- Data science notebooks
- Machine learning pipelines
- GUI applications
- Async/await patterns (unless requested)
- C extensions or Cython
- Docker or deployment configuration

## Inputs

**Required inputs:**

- Purpose and functional requirements
- Target output form: FullProject or OneOff
- New development or refactor

**Optional inputs:**

- Mode selection override
- Existing patterns to mirror
- Domain context (file I/O, API, data processing)
- Performance constraints
- Python version constraints (default: 3.12+)

**Assumptions:**

- Python 3.12+ unless specified
- Virtual environment for dependency isolation
- Standard execution environment (no restricted sandbox)

## Outputs

**Format:**

- FullProject: directory tree with pyproject.toml, src/, tests/
- OneOff: snippet (1-5 lines preferred, max 10 lines)

**Full Project Structure:**

1. pyproject.toml with project metadata and dependencies
2. src/package_name/ with `__init__.py`, `__main__.py`, modules
3. tests/ with pytest test files
4. Type annotations on all signatures
5. Logging configured at entry point

**Files produced:**

- FullProject: complete directory tree (see [references/templates.md](references/templates.md))
- OneOff: no file unless requested

**Formatting requirements (FullProject):**

- Formatting and import ordering enforced by ruff (do not specify manually)
- Naming conventions enforced by ruff pep8-naming rules
- Type annotations enforced by mypy strict mode + ruff ANN rules
- Guard clauses at method entry (instruction-only; not enforceable by tooling)
- Max 3 levels of nesting (instruction-only; not enforceable by tooling)
- `from __future__ import annotations` at top of every module

## Constraints

**Conflict resolution:** User requirements override defaults unless they violate safety or explicit MUST rules.

**Mode selection rules:**

- OneOff when user asks for a snippet, quick command, or inline solution
- FullProject when user asks for a package, reusable tool, or multi-file project
- Default to FullProject when ambiguous

**Global MUST:**

- Choose FullProject or OneOff and follow the mode rules
- Use strict typing on all function and method signatures
- Use `from __future__ import annotations` in every module
- Use `logging` (stdlib) for all diagnostic and status output

**Global MUST NOT:**

- Use `print()` for diagnostics or status (use logging)
- Use `Any` type unless interfacing with untyped third-party code
- Use bare `except:` or `except Exception:` without re-raise or specific handling
- Reimplement standard library functionality

**FullProject MUST:**

- Encapsulate all business logic in classes
- Use src-layout directory structure
- Include pyproject.toml with `[project]` metadata (PEP 621) and `[tool.ruff]`, `[tool.mypy]` configs
- Include `__main__.py` as the entry point
- Parse arguments with `argparse` in a dedicated class or module
- Configure logging in the entry point only
- Use `logging.getLogger(__name__)` per module
- Include pytest tests in tests/ directory with `conftest.py` for shared fixtures
- Organize tests into classes (`TestClassName`) mirroring source classes
- Test happy paths, error paths (`pytest.raises`), and edge cases for every public class/function
- Use `@pytest.mark.parametrize` for data-driven tests with 3+ input variations
- Use dataclasses or attrs for data-holding classes
- Use guard clauses and specific exception types
- Document all public classes and methods with docstrings (Google style)
- Keep module-level code limited to imports, constants, and class/function definitions
- Type-check clean under mypy strict mode
- Pass `ruff check .` and `ruff format --check .` with no violations
- Include ruff, mypy, and pytest in `[project.optional-dependencies.dev]`

**FullProject MUST NOT:**

- Hard-code paths or configuration values
- Place business logic outside classes
- Use module-level mutable state
- Catch and suppress exceptions silently
- Mix argument parsing with business logic

**OneOff MUST:**

- Prefer 1-5 lines, maximum 10 lines
- Skip classes, docstrings, and project scaffolding
- Use list comprehensions, generators, and stdlib idioms
- Use type hints on any function definitions

**OneOff MUST NOT:**

- Create a full project scaffold
- Add module-level docstrings or long comments

## Procedure

1. Select mode using the mode rules.
2. FullProject: create pyproject.toml (including ruff + mypy config), then src/ package with `__init__.py`, `__main__.py`, domain modules, and tests/.
3. OneOff: build the minimal expression and keep length within limits.
4. Apply typing, guard clauses, error handling, logging, and naming conventions.
5. FullProject: verify structure matches the directory layout template.
6. FullProject: run verification commands in order: `ruff format .`, `ruff check . --fix`, `mypy src/`, `pytest`. Fix any issues before delivering.

## Validation

**Pass Conditions (FullProject):**

- Structure matches the directory layout in [templates.md](references/templates.md)
- All public functions and methods have type annotations and docstrings
- `from __future__ import annotations` present in every module
- pyproject.toml includes `[project]` with name, version, dependencies, `[project.scripts]`, and tool configs for ruff + mypy
- `__main__.py` is the sole entry point; module-level code is absent
- Tests exist in tests/ using pytest conventions
- Tests organized into classes mirroring source classes
- Every public method has at least one test
- Happy path, error path, and edge cases covered
- `conftest.py` used for shared fixtures
- `@pytest.mark.parametrize` used for data-driven variation tests
- Max nesting depth is 3; guard clauses used at method entry
- Logging uses stdlib `logging` module; no `print()` for diagnostics
- `ruff format .` produces no changes
- `ruff check .` produces no violations
- `mypy src/` passes with no errors under strict mode
- `pytest` passes with no failures

**Pass Conditions (OneOff):**

- 1-5 lines when possible, never more than 10 lines
- No classes, project structure, or documentation blocks
- Type hints on any function definitions

**Failure Modes:**

- FullProject violates structure, typing, or packaging rules
- OneOff exceeds 10 lines without justification
- Business logic outside classes in FullProject mode
- `print()` used for diagnostics in FullProject mode
- ruff check, ruff format, or mypy report violations that were not fixed
- pyproject.toml missing ruff or mypy tool configuration

## Examples

**OneOff:**

```python
from pathlib import Path
sorted(Path(path).rglob("*"), key=lambda f: f.stat().st_size, reverse=True)[:5]
```

**FullProject (entry point only):**

```python
"""Application entry point."""
from __future__ import annotations

import logging
import sys

from package_name.cli import parse_args
from package_name.core import Processor

def main() -> None:
    args = parse_args()
    logging.basicConfig(level=args.log_level, format="%(levelname)s - %(name)s - %(message)s")
    processor = Processor(input_path=args.input_path)
    processor.run()

if __name__ == "__main__":
    main()
```

## Persona

Persona: Production-quality Python architect

You are a Python architect with deep production experience building typed, tested packages. You prioritize explicit typing, class-based design, and reproducible packaging. You choose maintainability and testability over shortcuts and keep projects structured, predictable, and mypy-clean.

## References

- Modes and selection guide: [references/modes.md](references/modes.md)
- Templates: [references/templates.md](references/templates.md)
- Standards and patterns: [references/standards.md](references/standards.md)
- Examples: [references/examples.md](references/examples.md)
