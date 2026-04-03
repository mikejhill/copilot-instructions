# Python Standards and Patterns

## Core Principles

1. OOP first for full projects
2. Strict typing on all signatures
3. Guard clauses at method entry
4. Fail fast on invalid preconditions
5. Parameterize everything that changes

## Module Header Requirement

Every `.py` module MUST start with:

```python
"""Module-level docstring describing purpose."""
from __future__ import annotations
```

The `from __future__ import annotations` import enables postponed evaluation of annotations (PEP 563), allowing forward references and modern type syntax.

## Full Project Directory Layout

```text
project-name/
├── .python-version               # Python version pin for uv (e.g., 3.12)
├── pyproject.toml
├── uv.lock                       # Lock file (always committed)
├── README.md
├── src/
│   ├── package_name/
│   │   ├── __init__.py
│   │   ├── __main__.py       # Entry point
│   │   ├── cli.py            # Argument parsing
│   │   ├── core.py           # Primary business logic
│   │   ├── models.py         # Dataclasses / data models
│   │   └── exceptions.py     # Custom exception hierarchy
│   └── second_package/       # Additional packages (multi-module)
│       ├── __init__.py
│       └── module.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py           # Shared fixtures
│   ├── test_core.py
│   └── test_models.py
└── .venv/                    # Managed by uv (gitignored)
```

Do NOT include `main.py` at the project root. Use `uv run <entry-point>` for development and `uv tool install .` for global installation.

Multi-module projects place each package as a sibling under `src/`. Each package has its own `__init__.py`.

## Object-Oriented Design

### Standard OOP Pattern

All business logic belongs in classes. Module-level code is limited to imports, constants, and class/function definitions.

```python
"""Core processing logic."""
from __future__ import annotations

import logging
from dataclasses import dataclass
from pathlib import Path

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class ProcessorConfig:
    """Immutable configuration for Processor."""

    input_path: Path
    max_retries: int = 3


class Processor:
    """Processes items under a configured path."""

    def __init__(self, config: ProcessorConfig) -> None:
        self._config = config
        self._validate()

    def _validate(self) -> None:
        """Guard clause: validate preconditions."""
        if not self._config.input_path.exists():
            raise FileNotFoundError(...)

    def run(self) -> list[Path]:
        """Execute the processing pipeline."""
        ...
```

See [templates.md](templates.md) → `core.py` for the complete implementation including all methods.

### Key OOP Rules

- All business logic belongs in classes.
- Use private methods (underscore prefix) for internal logic.
- Use `@dataclass(frozen=True)` for immutable configuration and data transfer objects.
- Use regular classes for stateful processing logic.
- Use `@property` for computed attributes; avoid public attributes on processing classes.
- Use abstract base classes (`abc.ABC`, `@abstractmethod`) for interfaces when polymorphism is needed.
- Import symbols from their defining module. Type checkers reject implicit re-exports (e.g., import `ScanConfig` from `models`, not from `core` which happens to import it).

### Minimizing Non-OOP Code

The only code outside classes:

- `__main__.py`: argument parsing, logging setup, class instantiation, `main()` call
- Module-level: imports, constants, `logger = logging.getLogger(__name__)`
- `conftest.py`: pytest fixtures (functions by convention)

## Typing Rules

### Required Practices

- `from __future__ import annotations` in every module
- Type annotations on all function/method parameters and return types
- Use built-in generics: `list[str]`, `dict[str, int]`, `tuple[int, ...]`, `set[str]`
- Use `| None` instead of `Optional[str]`
- Use `TypeAlias` for complex type expressions
- Use `Protocol` for structural subtyping when duck-typing is needed
- Use `@overload` for functions with multiple distinct signatures

### Forbidden Practices

- `Any` type unless interfacing with untyped third-party code
- Untyped function signatures
- `# type: ignore` without a specific error code (e.g., `# type: ignore[attr-defined]`)
- `cast()` without a code comment justifying it

### Example Type Patterns

```python
from __future__ import annotations

from collections.abc import Callable, Iterator, Sequence
from typing import TypeAlias

# Type aliases for complex types
PathFilter: TypeAlias = Callable[[Path], bool]
ItemMap: TypeAlias = dict[str, list[Path]]

# Union with None
def find_item(name: str) -> Path | None: ...

# Generic collections
def process_batch(items: Sequence[Path], filters: list[PathFilter]) -> ItemMap: ...

# Iterator return
def iter_files(root: Path) -> Iterator[Path]: ...
```

## Argument Parsing

### Standard Pattern

Argument parsing lives in a dedicated `cli.py` module, separated from business logic. Use `argparse` from the standard library.

```python
def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse and validate command-line arguments."""
    parser = argparse.ArgumentParser(...)
    parser.add_argument("input_path", type=Path, ...)
    parser.add_argument("--max-retries", type=int, default=3, ...)
    parser.add_argument("--log-level", choices=[...], default="INFO", ...)

    args = parser.parse_args(argv)

    if not args.input_path.exists():
        parser.error(f"Input path does not exist: {args.input_path}")

    args.log_level = getattr(logging, args.log_level)
    return args
```

See [templates.md](templates.md) → `cli.py` for the complete implementation.

### Argument Rules

- Define all arguments in `cli.py` using `argparse`
- Accept `argv: list[str] | None = None` parameter for testability
- Use `type=Path` for path arguments
- Use `choices=` for enumerated values
- Use `default=` with `%(default)s` in help text
- Perform post-parse validation with `parser.error()` for user-facing errors
- Return `argparse.Namespace`; convert to typed domain objects (`ProcessorConfig`, etc.) in `__main__.py` immediately — `Namespace` attributes are untyped at the type-checker level

## Logging

### Configuration

Configure logging once in `__main__.py`:

```python
logging.basicConfig(
    level=args.log_level,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
)
```

### Per-Module Logger

Every module creates its own logger at module level:

```python
logger = logging.getLogger(__name__)
```

### Logging Rules

- Use `logging.getLogger(__name__)` per module
- Configure logging only in `__main__.py`
- Use `logger.debug()` for diagnostics
- Use `logger.info()` for status and progress
- Use `logger.warning()` for recoverable issues
- Use `logger.error()` for failures that do not halt execution
- Use `logger.exception()` inside except blocks (includes traceback)
- Use lazy formatting: `logger.info("Processing %s", path)` not f-strings
- MUST NOT use `print()` for diagnostics or status

### Performance

Avoid expensive computation in log calls. Guard heavy logging behind level checks:

```python
if logger.isEnabledFor(logging.DEBUG):
    details = compute_expensive_diagnostics(items)
    logger.debug("Diagnostics: %s", details)
```

## Guard Clauses and Error Handling

### Guard Clause Pattern

Validate preconditions at the start of every public method:

```python
def process(self, items: list[Path]) -> list[Path]:
    """Process a list of paths."""
    if not items:
        raise ValueError("Items list must not be empty")
    if any(not item.exists() for item in items):
        missing = [i for i in items if not i.exists()]
        raise FileNotFoundError(f"Missing items: {missing}")
    # ... proceed with logic
```

**Defense-in-depth validation**: CLI validation (`parser.error()`) catches user errors early with friendly messages. Domain validation (guard clauses in constructors and methods) protects invariants for non-CLI callers (tests, library consumers). Both layers are intentional — do not remove one because the other exists.

### Exception Rules

- Use specific exception types: `ValueError`, `FileNotFoundError`, `TypeError`, `RuntimeError`
- Define custom exceptions in `exceptions.py` for domain-specific errors
- Never use bare `except:` or `except Exception:` without re-raise
- Include context in error messages: state what failed, what was expected, and what was found (e.g., `"Expected 'version' key in config, found keys: ['name', 'description']"`)
- Use `raise ... from err` to preserve exception chains

### Custom Exception Pattern

```python
"""Project-specific exception hierarchy."""
from __future__ import annotations


class AppError(Exception):
    """Base exception for the application."""


class ConfigurationError(AppError):
    """Raised when configuration is invalid or missing."""


class ProcessingError(AppError):
    """Raised when item processing fails."""

    def __init__(self, item: str, reason: str) -> None:
        super().__init__(f"Failed to process '{item}': {reason}")
        self.item = item
        self.reason = reason
```

## Enums and Constants

Use `Enum` for fixed sets of related values instead of string constants or magic numbers:

```python
from enum import Enum


class Severity(Enum):
    """Log severity levels."""

    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"
```

Rules:

- Use `Enum` for categories, statuses, severity levels, and other bounded value sets
- Use `UPPER_SNAKE_CASE` for enum members
- Add a class docstring
- Reference enum members by name (`Severity.ERROR`) not by value

## Optional Parameters

Use `| None` with a default of `None` for optional filtering or configuration:

```python
def filter_entries(
    self, severity: Severity | None = None
) -> list[LogEntry]:
    """Filter entries by severity. Returns all entries when severity is None."""
    if severity is None:
        return list(self._entries)
    return [e for e in self._entries if e.severity == severity]
```

Check `is None` explicitly rather than relying on truthiness.

## Naming Conventions

| Element           | Convention         | Examples                              |
| ----------------- | ------------------ | ------------------------------------- |
| Modules           | snake_case         | `file_processor.py`, `data_models.py` |
| Packages          | snake_case         | `my_package`, `data_pipeline`         |
| Classes           | PascalCase         | `FileProcessor`, `DataModel`          |
| Functions/Methods | snake_case         | `process_items()`, `validate_input()` |
| Variables         | snake_case         | `input_path`, `retry_count`           |
| Constants         | UPPER_SNAKE_CASE   | `MAX_RETRIES`, `DEFAULT_TIMEOUT`      |
| Private members   | Leading underscore | `_validate()`, `_cache`               |
| Type aliases      | PascalCase         | `PathFilter`, `ItemMap`               |

### Public API Surface

For packages intended for external import, define `__all__` in `__init__.py` to control the public API surface:

```python
__all__ = ["Processor", "ProcessorConfig"]
```

This makes the importable interface explicit and prevents internal symbols from leaking.

## Nesting and Extraction

- Max 3 levels of nesting.
- Extract deeper logic into private methods.
- Use early returns (guard clauses) to reduce nesting.

### When to Extract a Private Method

Extract a private method when:

1. Logic repeats across two or more methods
2. Nesting depth exceeds 2 levels inside a method
3. A method exceeds ~20 lines
4. A logical step has a clear name (readability extraction)

## Testing Standards

### Directory Structure

```text
tests/
├── __init__.py
├── conftest.py           # Shared fixtures
├── test_core.py          # Tests for core module
├── test_cli.py           # Tests for CLI parsing
└── test_models.py        # Tests for data models
```

### Test Rules

- Use pytest as the test framework
- Name test files `test_<module>.py`
- Name test functions `test_<behavior_or_scenario>`
- Group related tests into classes (`TestClassName`) that mirror the class under test
- Use fixtures in `conftest.py` for shared setup (see below)
- Use `@pytest.mark.parametrize` for data-driven tests (see below)
- Use `tmp_path` fixture for filesystem tests
- Test argument parsing by passing `argv` lists to `parse_args()`
- Assert specific exception types with `pytest.raises(ExceptionType)`
- One assertion per test when practical; group only closely related assertions

### conftest.py and Fixtures

Place shared fixtures in `tests/conftest.py`. Fixtures replace repetitive setup code across test files.

```python
"""Shared test fixtures."""
from __future__ import annotations

from pathlib import Path

import pytest


@pytest.fixture
def sample_dir(tmp_path: Path) -> Path:
    """Create a temporary directory with sample files."""
    (tmp_path / "file1.txt").write_text("content")
    (tmp_path / "file2.txt").write_text("content")
    (tmp_path / "subdir").mkdir()
    return tmp_path
```

Rules for fixtures:

- Define fixtures that create test data or configure state
- Use `tmp_path` (built-in) for any filesystem operations
- Return the created resource for test methods to use
- Keep fixtures focused: one fixture per concern

### Parametrize

Use `@pytest.mark.parametrize` when the same test logic applies to multiple inputs:

```python
@pytest.mark.parametrize(
    ("severity", "expected_count"),
    [
        ("DEBUG", 1),
        ("INFO", 2),
        ("ERROR", 3),
    ],
)
def test_filter_by_severity(
    self, tmp_path: Path, severity: str, expected_count: int
) -> None:
    # test body using severity and expected_count
    ...
```

Use parametrize when:

- Testing the same behavior with 3+ different input values
- Testing boundary conditions (0, 1, max)
- Testing each enum member or category value

### Test Coverage Expectations

Every public class and function must have tests covering:

1. **Happy path**: Normal operation with valid inputs
2. **Error path**: Invalid inputs, missing files, bad config (`pytest.raises`)
3. **Edge cases**: Empty inputs, boundary values, None arguments

```python
class TestProcessor:
    """Tests for Processor class."""

    # Happy path
    def test_run_returns_files(self, sample_dir: Path) -> None: ...

    # Error path
    def test_raises_on_missing_path(self, tmp_path: Path) -> None:
        with pytest.raises(FileNotFoundError):
            ...

    # Edge case via parametrize
    @pytest.mark.parametrize("count", [0, 1, 5])
    def test_processes_variable_file_counts(self, tmp_path: Path, count: int) -> None: ...
```

### Test Example

See [templates.md](templates.md) → `test_core.py` for the complete test implementation demonstrating all coverage patterns.

## Tooling and Verification

Three Astral tools plus pytest enforce code quality deterministically. All are configured in pyproject.toml and run after code generation. The Astral tools (ruff, ty) are developed by [Astral](https://astral.sh/) and form a cohesive, high-performance Rust-based Python toolchain.

### Tool Stack

| Tool            | Purpose                          | Command           |
| --------------- | -------------------------------- | ----------------- |
| **ruff**        | Linting (replaces flake8, isort) | `ruff check .`    |
| **ruff format** | Formatting (replaces black)      | `ruff format .`   |
| **ty**          | Static type checking             | `ty check`        |
| **pytest**      | Test execution                   | `pytest`          |

### Enforcement Rules

- Ruff and ty configuration lives in pyproject.toml. Do not use separate config files.
- All formatting rules are enforced by `ruff format`. Do not add formatting rules to instructions; they are deterministic via tooling.
- All import ordering is enforced by `ruff check` with isort rules enabled. Do not manually sort imports.
- All type checking is enforced by `ty check`. Do not rely on instruction-only type rules.

### Verification Procedure (FullProject)

After generating or modifying code, run these commands in order:

```bash
uv run ruff format .       # Auto-fix formatting
uv run ruff check . --fix  # Auto-fix lint violations
uv run ty check            # Type check (must pass clean)
uv run pytest              # Tests (must pass)
```

If `ruff check` or `ruff format` auto-fixes issues, apply the fixes and continue. If `ty` reports errors, fix the type annotations. If `pytest` fails, fix the failing tests or code.

### ruff Configuration

```toml
[tool.ruff]
target-version = "py312"
line-length = 88
src = ["src", "tests"]

[tool.ruff.lint]
select = [
    "E",     # pycodestyle errors
    "W",     # pycodestyle warnings
    "F",     # pyflakes
    "I",     # isort
    "N",     # pep8-naming
    "UP",    # pyupgrade
    "B",     # flake8-bugbear
    "SIM",   # flake8-simplify
    "RUF",   # ruff-specific rules
    "D",     # pydocstyle
    "ANN",   # flake8-annotations
    "PT",    # flake8-pytest-style
    "RET",   # flake8-return
    "ARG",   # flake8-unused-arguments
    "FA",    # flake8-future-annotations
]
# TCH (flake8-type-checking) excluded: moving stdlib imports into TYPE_CHECKING
# blocks reduces readability for marginal import-time savings.
ignore = [
    "D100",  # Missing docstring in public module (covered by module header rule)
    "D104",  # Missing docstring in public package
    "D107",  # Missing docstring in __init__ (class docstring suffices)
]

[tool.ruff.lint.pydocstyle]
convention = "google"

[tool.ruff.lint.isort]
known-first-party = ["package_name"]
```

### ty Configuration

```toml
[tool.ty.environment]
python-version = "3.12"
```

ty auto-discovers source files from the project root and detects `src/` layout automatically. It reads `.python-version` and `project.requires-python` to infer the target Python version, so `[tool.ty.environment]` is an explicit override when needed. Use `[tool.ty.rules]` to adjust specific diagnostic severity:

```toml
[tool.ty.rules]
# Example: downgrade a specific diagnostic to warning
# possibly-unbound = "warning"
```

### What Tooling Replaces

These rules are enforced by automation and MUST NOT be duplicated in instructions:

- **Import ordering** → ruff (isort rules)
- **Line length** → ruff format (88 chars)
- **Blank lines between definitions** → ruff format
- **Trailing whitespace and newlines** → ruff format
- **Unused imports and variables** → ruff (pyflakes rules)
- **Naming conventions** → ruff (pep8-naming rules)
- **Docstring format** → ruff (pydocstyle rules with Google convention)
- **Type annotation presence** → ty + ruff (ANN rules)
- **`from __future__ import annotations`** → ruff (FA rules)

Instruction-only rules (not enforceable by tooling):

- OOP architecture and class design
- Guard clause placement
- Max nesting depth (3 levels)
- Logging pattern (`getLogger(__name__)`, lazy formatting)
- Business logic encapsulation in classes

## Packaging and Dependencies

### pyproject.toml

Use PEP 621 metadata in pyproject.toml:

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "package-name"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = []

[dependency-groups]
dev = ["pytest>=8.0", "ruff>=0.7", "ty>=0.0.1"]

[project.scripts]
package-name = "package_name.__main__:main"

# ... ruff, ty, and pytest configuration follows
```

See [templates.md](templates.md) → `pyproject.toml` for the complete configuration including all ruff, ty, and pytest settings.

### Virtual Environment

uv manages the virtual environment automatically. Do not create or activate `.venv` manually:

```bash
uv sync                  # Create .venv and install all dependencies
uv run <command>         # Run commands inside the managed environment
```

### Dependency Rules

- All dependencies declared in pyproject.toml `[project.dependencies]`
- Dev dependencies in `[dependency-groups] dev` (PEP 735), NOT `[project.optional-dependencies]`
- Pin minimum versions: `"requests>=2.31"`
- **Libraries** (packages others depend on): use minimum-version pins (`"requests>=2.31"`) to maximize compatibility
- **Applications** (deployed tools): rely on `uv.lock` for reproducibility; `uv.lock` MUST always be committed
- Use `uv sync` for development setup, not `pip install`
- Use `uv run` for all command execution, not bare tool commands
- `.venv/` directory is gitignored
