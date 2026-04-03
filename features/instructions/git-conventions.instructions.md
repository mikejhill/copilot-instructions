---
name: Git Commit Conventions
description: Commit message format and pre-commit validation rules.
---

# Git Commit Conventions

All commits follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## Format

```text
<type>: <subject>

<body>

<footer>
```

- **type**: `feat` | `fix` | `docs` | `style` | `refactor` | `test` | `chore` | `ci`
- **subject**: ≤50 chars, imperative mood, lowercase, no period
- **body** (optional): wrap at 72 chars, explain what and why
- **footer** (optional): `Closes #N`, `Related-To: TICKET-N`

## Pre-commit Validation

When committing `.md` files, run markdown linting first:

```bash
npx markdownlint-cli2
```

## Repository-local Git Hooks

If a repo contains `.githooks/`, activate with:

```bash
git config core.hooksPath .githooks
```

One-time per clone. Sets repo-local config to use checked-in hooks.
