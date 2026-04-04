# Intent

Codify Python scripting standards for CLI tools and automation scripts
using the Astral toolchain.

## Goals

1. Every rule enforceable by tooling or verifiable by inspection
2. Two modes only: OneOff (single-file) and FullProject (packaged)
3. Astral-focused toolchain: uv for packaging, Ruff for linting/formatting,
   ty for type checking
4. Templates are copy-paste ready with no placeholders requiring judgment
5. Frozen dataclasses for all domain models — no mutable state

## Log

- 2026-03-15: Created skill targeting Python CLI tools and automation scripts
- 2026-04-03: Standardized toolchain on uv, Ruff, and ty replacing pip,
  flake8, and mypy
- 2026-04-03: Refined via tribunal (2 iterations, severity 78 → 25) — added
  FA rule, error handling patterns, reduced standards.md duplication
- 2026-04-03 [agent]: Fixed constructor mismatch between SKILL.md example and
  templates.md; added exceptions.py to refactor example; added Namespace typing
  guidance
