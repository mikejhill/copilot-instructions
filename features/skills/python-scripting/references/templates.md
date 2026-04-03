# Python Templates

## Full Project Skeleton

### pyproject.toml

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "package-name"
version = "0.1.0"
description = "Short description of the project."
requires-python = ">=3.12"
dependencies = []

[dependency-groups]
dev = [
    "pytest>=8.0",
    "ruff>=0.7",
    "ty>=0.0.1",
]

[project.scripts]
package-name = "package_name.__main__:main"

[tool.ruff]
target-version = "py312"
line-length = 88
src = ["src", "tests"]

[tool.ruff.lint]
select = ["E", "W", "F", "I", "N", "UP", "B", "SIM", "RUF", "D", "ANN", "PT", "RET", "ARG", "FA"]
# TCH excluded: moving stdlib imports to TYPE_CHECKING blocks reduces readability.
ignore = ["D100", "D104", "D107"]

[tool.ruff.lint.pydocstyle]
convention = "google"

[tool.ruff.lint.isort]
known-first-party = ["package_name"]

[tool.ty.environment]
python-version = "3.12"

[tool.pytest.ini_options]
testpaths = ["tests"]
```

### main.py — REMOVED

Do NOT create a `main.py` wrapper at the project root. With uv managing the project:

- **Development:** `uv run package-name` (uses `[project.scripts]` entry point)
- **Direct module execution:** `uv run python -m package_name`
- **Global install:** `uv tool install .` places the entry point on `PATH`

The `main.py` pattern (inserting `src/` into `sys.path`) is unnecessary when uv handles the virtual environment and editable installs.

### src/package_name/\_\_init\_\_.py

```python
"""Package-name: short description."""
from __future__ import annotations
```

For libraries intended for external consumption, add a `py.typed` marker file (PEP 561) at `src/package_name/py.typed` (empty file) so downstream type checkers can see the package's type information.

### src/package_name/\_\_main\_\_.py

```python
"""Application entry point."""
from __future__ import annotations

import logging
import sys

from package_name.cli import parse_args
from package_name.core import Processor, ProcessorConfig
from package_name.exceptions import AppError

logger = logging.getLogger(__name__)


def main() -> None:
    """Parse arguments, configure logging, and run the application."""
    args = parse_args()
    logging.basicConfig(
        level=args.log_level,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S",
    )
    config = ProcessorConfig(input_path=args.input_path, max_retries=args.max_retries)
    try:
        processor = Processor(config)
        processor.run()
    except AppError as exc:
        logger.error("%s", exc)
        sys.exit(1)


if __name__ == "__main__":
    main()
```

### src/package_name/cli.py

```python
"""Command-line interface definition."""
from __future__ import annotations

import argparse
import logging
from pathlib import Path


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse and validate command-line arguments.

    Args:
        argv: Argument list. Defaults to sys.argv[1:] when None.

    Returns:
        Parsed argument namespace.
    """
    parser = argparse.ArgumentParser(
        description="Process items under a given path.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "input_path",
        type=Path,
        help="Path to the input directory.",
    )
    parser.add_argument(
        "--max-retries",
        type=int,
        default=3,
        help="Maximum retry attempts (default: %(default)s).",
    )
    parser.add_argument(
        "--log-level",
        type=str,
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity (default: %(default)s).",
    )

    args = parser.parse_args(argv)

    if not args.input_path.exists():
        parser.error(f"Input path does not exist: {args.input_path}")

    args.log_level = getattr(logging, args.log_level)
    return args
```

### src/package_name/core.py

```python
"""Core processing logic."""
from __future__ import annotations

import logging
from dataclasses import dataclass
from pathlib import Path

from package_name.exceptions import ProcessingError

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
            raise FileNotFoundError(
                f"Input path does not exist: {self._config.input_path}"
            )

    def run(self) -> list[Path]:
        """Execute the processing pipeline."""
        logger.info("Processing %s", self._config.input_path)
        items = self._discover_items()
        results = self._process_items(items)
        logger.info("Processed %d items", len(results))
        return results

    def _discover_items(self) -> list[Path]:
        """Find all items to process."""
        return list(self._config.input_path.iterdir())

    def _process_items(self, items: list[Path]) -> list[Path]:
        """Apply processing logic to each item."""
        processed: list[Path] = []
        for item in items:
            try:
                if self._should_process(item):
                    processed.append(item)
            except OSError as err:
                raise ProcessingError(
                    item=str(item), reason=str(err)
                ) from err
        return processed

    def _should_process(self, item: Path) -> bool:
        """Determine whether an item qualifies for processing."""
        return item.is_file()
```

### src/package_name/models.py

```python
"""Data models for the application."""
from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path


class Status(Enum):
    """Processing status categories."""

    PENDING = "pending"
    SUCCESS = "success"
    FAILED = "failed"


@dataclass(frozen=True)
class ProcessingResult:
    """Result of processing a single item."""

    source: Path
    status: Status
    message: str = ""


@dataclass
class ProcessingSummary:
    """Aggregated results of a processing run."""

    total: int = 0
    succeeded: int = 0
    failed: int = 0
    results: list[ProcessingResult] = field(default_factory=list)

    def add(self, result: ProcessingResult) -> None:
        """Record a processing result."""
        self.total += 1
        if result.status == Status.SUCCESS:
            self.succeeded += 1
        else:
            self.failed += 1
        self.results.append(result)
```

### src/package_name/exceptions.py

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

### tests/\_\_init\_\_.py

```python
"""Test package."""
from __future__ import annotations
```

### tests/conftest.py

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

Fixture guidelines:

- One fixture per test concern (data setup, configuration, file system state)
- Use `tmp_path` for any filesystem operations
- Return the created resource so tests can reference it
- Place domain-specific fixtures here; keep test-local fixtures in the test file

### tests/test_core.py

```python
"""Tests for core processing logic."""
from __future__ import annotations

from pathlib import Path

import pytest

from package_name.core import Processor, ProcessorConfig


class TestProcessor:
    """Tests for Processor class."""

    def test_run_returns_files(self, sample_dir: Path) -> None:
        config = ProcessorConfig(input_path=sample_dir)
        processor = Processor(config)
        result = processor.run()
        assert len(result) == 2

    def test_raises_on_missing_path(self, tmp_path: Path) -> None:
        config = ProcessorConfig(input_path=tmp_path / "nonexistent")
        with pytest.raises(FileNotFoundError):
            Processor(config)

    @pytest.mark.parametrize("count", [0, 1, 5])
    def test_processes_variable_file_counts(
        self, tmp_path: Path, count: int
    ) -> None:
        for i in range(count):
            (tmp_path / f"file{i}.txt").write_text("data")
        config = ProcessorConfig(input_path=tmp_path)
        processor = Processor(config)
        result = processor.run()
        assert len(result) == count
```

### tests/test_cli.py

```python
"""Tests for CLI argument parsing."""
from __future__ import annotations

from pathlib import Path

import pytest

from package_name.cli import parse_args


class TestParseArgs:
    """Tests for parse_args function."""

    def test_parses_required_path(self, tmp_path: Path) -> None:
        args = parse_args([str(tmp_path)])
        assert args.input_path == tmp_path

    def test_default_max_retries(self, tmp_path: Path) -> None:
        args = parse_args([str(tmp_path)])
        assert args.max_retries == 3

    def test_custom_max_retries(self, tmp_path: Path) -> None:
        args = parse_args([str(tmp_path), "--max-retries", "5"])
        assert args.max_retries == 5

    def test_rejects_missing_path(self) -> None:
        with pytest.raises(SystemExit):
            parse_args(["/nonexistent/path"])
```

### .gitignore

```text
__pycache__/
*.py[cod]
*.egg-info/
dist/
build/
.venv/
```

## One-Off Template

```python
from pathlib import Path
sorted(Path(path).rglob("*"), key=lambda f: f.stat().st_size, reverse=True)[:5]
```

## README Installation Section Template

Python project README files should include installation instructions using uv. Use this pattern:

```markdown
## Installation

### Global install

Install as a global tool using [uv](https://docs.astral.sh/uv/):

\```bash
uv tool install .
\```

### Development

Clone the repository and sync the environment:

\```bash
uv sync
\```

Run the application:

\```bash
uv run <entry-point-name>
\```

Run tests and checks:

\```bash
uv run pytest
uv run ruff check .
uv run ty check
\```
```

**Guidelines:**

- Always link to [uv documentation](https://docs.astral.sh/uv/) on first mention.
- Use `uv tool install .` for global CLI tool installation, not `pip install` or `pipx install`.
- Use `uv sync` for development setup, not `pip install -e ".[dev]"`.
- Use `uv run` for all command execution, not bare `pytest`, `ruff`, etc.
- Do not document custom installer scripts, `main.py` wrappers, or `PYTHONPATH` manipulation.
