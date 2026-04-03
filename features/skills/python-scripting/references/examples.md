# Python Examples

## One-Off: Find Largest Files

**Scenario:** Find the five largest files under a path

```python
from pathlib import Path
sorted(Path(path).rglob("*"), key=lambda f: f.stat().st_size, reverse=True)[:5]  # path: str | Path
```

## One-Off: Filter and Transform

**Scenario:** Extract unique email domains from a list

```python
domains = sorted({email.split("@")[1] for email in emails if "@" in email})  # emails: list[str]
```

## One-Off: File Content Search

**Scenario:** Find all Python files containing a pattern

```python
from pathlib import Path
[f for f in Path(".").rglob("*.py") if "TODO" in f.read_text(encoding="utf-8")]
```

## Full Project (Skeleton)

Use the full project skeleton in [templates.md](templates.md) as the baseline. Place business logic in classes under `src/package_name/`, tests under `tests/`, and configure packaging in `pyproject.toml`.

## Full Project (Refactor Example)

### Before (Procedural)

```python
import os
import json

path = "/data/config"
results = []
for filename in os.listdir(path):
    if filename.endswith(".json"):
        filepath = os.path.join(path, filename)
        with open(filepath) as f:
            data = json.load(f)
        if data.get("enabled"):
            print(f"Found: {filename}")
            results.append(data)
print(f"Total: {len(results)}")
```

**Rules applied in this refactor:**

- Hardcoded `"/data/config"` → `ScannerConfig.search_path` (parameterize everything)
- `os.listdir` + `os.path.join` → `Path.glob()` (prefer pathlib)
- `print()` for status → `logger.info()` / `logger.debug()` (structured logging)
- Bare dict data → `ScanResult` frozen dataclass (typed data models)
- Procedural loop → `ConfigScanner` class with `_validate()` guard (OOP + guard clauses)
- No error handling → `try/except` with `logger.warning()` for bad files (fail gracefully)

### After (Refactored)

#### src/config_scanner/core.py

```python
"""Configuration file scanner."""
from __future__ import annotations

import json
import logging
from dataclasses import dataclass
from pathlib import Path

from config_scanner.exceptions import ConfigurationError

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class ScannerConfig:
    """Immutable scanner configuration."""

    search_path: Path
    pattern: str = "*.json"
    required_field: str = "enabled"


@dataclass(frozen=True)
class ScanResult:
    """Result of scanning a single config file."""

    path: Path
    data: dict[str, object]


class ConfigScanner:
    """Scans a directory for enabled configuration files."""

    def __init__(self, config: ScannerConfig) -> None:
        self._config = config
        self._validate()

    def _validate(self) -> None:
        """Guard clause: validate preconditions."""
        if not self._config.search_path.is_dir():
            raise ConfigurationError(
                f"Search path is not a directory: {self._config.search_path}"
            )

    def scan(self) -> list[ScanResult]:
        """Scan for enabled configuration files."""
        logger.info("Scanning %s for %s", self._config.search_path, self._config.pattern)
        results: list[ScanResult] = []

        for path in self._config.search_path.glob(self._config.pattern):
            result = self._process_file(path)
            if result is not None:
                results.append(result)

        logger.info("Found %d enabled configurations", len(results))
        return results

    def _process_file(self, path: Path) -> ScanResult | None:
        """Load and evaluate a single configuration file."""
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            logger.warning("Skipping unreadable file: %s", path)
            return None

        if not data.get(self._config.required_field):
            return None

        logger.debug("Found enabled config: %s", path.name)
        return ScanResult(path=path, data=data)
```

#### src/config_scanner/cli.py

```python
"""CLI for config scanner."""
from __future__ import annotations

import argparse
import logging
from pathlib import Path


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description="Scan for enabled config files.")
    parser.add_argument("search_path", type=Path, help="Directory to scan.")
    parser.add_argument(
        "--pattern", default="*.json", help="Glob pattern (default: %(default)s)."
    )
    parser.add_argument(
        "--field", default="enabled", help="Required field (default: %(default)s)."
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity (default: %(default)s).",
    )

    args = parser.parse_args(argv)

    if not args.search_path.is_dir():
        parser.error(f"Not a directory: {args.search_path}")

    args.log_level = getattr(logging, args.log_level)
    return args
```

#### src/config_scanner/exceptions.py

```python
"""Config scanner exception hierarchy."""
from __future__ import annotations


class AppError(Exception):
    """Base exception for config scanner."""


class ConfigurationError(AppError):
    """Raised when scanner configuration is invalid."""
```

#### src/config_scanner/\_\_main\_\_.py

```python
"""Entry point for config scanner."""
from __future__ import annotations

import logging
import sys

from config_scanner.cli import parse_args
from config_scanner.core import ConfigScanner, ScannerConfig
from config_scanner.exceptions import AppError

logger = logging.getLogger(__name__)


def main() -> None:
    """Parse arguments, configure logging, and run the scanner."""
    args = parse_args()
    logging.basicConfig(
        level=args.log_level,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S",
    )
    config = ScannerConfig(
        search_path=args.search_path,
        pattern=args.pattern,
        required_field=args.field,
    )
    try:
        scanner = ConfigScanner(config)
        results = scanner.scan()
    except AppError as exc:
        logger.error("%s", exc)
        sys.exit(1)

    for result in results:
        print(result.path.name)  # Program output (user-requested data)


if __name__ == "__main__":
    main()
```

#### tests/test_core.py

```python
"""Tests for config scanner core logic."""
from __future__ import annotations

import json
from pathlib import Path

import pytest

from config_scanner.core import ConfigScanner, ScannerConfig
from config_scanner.exceptions import ConfigurationError


@pytest.fixture
def config_dir(tmp_path: Path) -> Path:
    """Create a directory with sample config files."""
    (tmp_path / "enabled.json").write_text(json.dumps({"enabled": True, "name": "a"}))
    (tmp_path / "disabled.json").write_text(json.dumps({"enabled": False, "name": "b"}))
    (tmp_path / "no_field.json").write_text(json.dumps({"name": "c"}))
    (tmp_path / "invalid.json").write_text("not json")
    return tmp_path


class TestConfigScanner:
    """Tests for ConfigScanner."""

    def test_finds_enabled_configs(self, config_dir: Path) -> None:
        config = ScannerConfig(search_path=config_dir)
        scanner = ConfigScanner(config)
        results = scanner.scan()
        assert len(results) == 1
        assert results[0].path.name == "enabled.json"

    def test_raises_on_invalid_path(self, tmp_path: Path) -> None:
        config = ScannerConfig(search_path=tmp_path / "nonexistent")
        with pytest.raises(ConfigurationError):
            ConfigScanner(config)

    def test_skips_invalid_json(self, config_dir: Path) -> None:
        config = ScannerConfig(search_path=config_dir)
        scanner = ConfigScanner(config)
        results = scanner.scan()
        names = [r.path.name for r in results]
        assert "invalid.json" not in names

    def test_custom_pattern(self, tmp_path: Path) -> None:
        (tmp_path / "config.yaml").write_text("not scanned")
        (tmp_path / "config.json").write_text(json.dumps({"enabled": True}))
        config = ScannerConfig(search_path=tmp_path, pattern="*.json")
        scanner = ConfigScanner(config)
        results = scanner.scan()
        assert len(results) == 1
```
