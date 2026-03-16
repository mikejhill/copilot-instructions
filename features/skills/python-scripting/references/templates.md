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

[project.optional-dependencies]
dev = [
    "mypy>=1.10",
    "pytest>=8.0",
    "ruff>=0.7",
]

[project.scripts]
package-name = "package_name.__main__:main"

[tool.ruff]
target-version = "py312"
line-length = 88
src = ["src", "tests"]

[tool.ruff.lint]
select = ["E", "W", "F", "I", "N", "UP", "B", "SIM", "RUF", "D", "ANN", "PT", "RET", "ARG"]
# TCH excluded: moving stdlib imports to TYPE_CHECKING blocks reduces readability.
ignore = ["D100", "D104", "D107"]

[tool.ruff.lint.pydocstyle]
convention = "google"

[tool.ruff.lint.isort]
known-first-party = ["package_name"]

[tool.mypy]
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true

[tool.pytest.ini_options]
testpaths = ["tests"]
```

### main.py

```python
#!/usr/bin/env python3
"""CLI wrapper for running the application from the project root.

This convenience script adds src/ to the Python path and delegates to the
package entry point. Equivalent to running:
    python -m package_name
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "src"))

from package_name.__main__ import main  # noqa: E402

if __name__ == "__main__":
    main()
```

**Guidelines:**

- Replace `package_name` with the actual package name.
- This file stays minimal: path setup and delegation only. No business logic.
- This file can be skipped if not useful, such as for non-CLI projects.
- The shebang line enables direct execution on Unix (`./main.py`).
- The `# noqa: E402` comment suppresses the "module-level import not at top of file" lint violation caused by the required `sys.path` insert before the import.
- Users can alternatively run `python -m package_name` from within `src/` or after installing the package.

### src/package_name/\_\_init\_\_.py

```python
"""Package-name: short description."""
from __future__ import annotations
```

### src/package_name/\_\_main\_\_.py

```python
"""Application entry point."""
from __future__ import annotations

import logging

from package_name.cli import parse_args
from package_name.core import Processor, ProcessorConfig


def main() -> None:
    """Parse arguments, configure logging, and run the application."""
    args = parse_args()
    logging.basicConfig(
        level=args.log_level,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S",
    )
    config = ProcessorConfig(input_path=args.input_path, max_retries=args.max_retries)
    processor = Processor(config)
    processor.run()


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
            if self._should_process(item):
                processed.append(item)
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


@pytest.fixture
def empty_dir(tmp_path: Path) -> Path:
    """Create an empty temporary directory."""
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

## One-Off Template

```python
from pathlib import Path
sorted(Path(path).rglob("*"), key=lambda f: f.stat().st_size, reverse=True)[:5]
```
