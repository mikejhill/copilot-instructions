---
name: Git Commit Conventions
description: Use when writing git commit messages, performing git commits, or working with git history.
---

# Git Commit Conventions

## Commit Message Template

```text
<TYPE>: <SUBJECT (LIMIT 50 CHARS)>

<BODY - optional but recommended (WRAP AT 72 CHARS)>

<FOOTER - if applicable (WRAP AT 72 CHARS)>
```

## Fields

- `<TYPE>`: feat | fix | docs | style | refactor | test | chore | ci
- `<SUBJECT>`: 50 characters or less, imperative mood, lowercase first letter, no period
- `<BODY>`: Wrapped at 72 characters, explain what and why (not how)
- `<FOOTER>`: References like "Closes #123" or "Related-To: TICKET-456"

## Rules

1. **Type** must be one of the allowed values (feat, fix, docs, style, refactor, test, chore, ci)
2. **Subject** must be 50 characters or less, start with a lowercase letter, use imperative mood (e.g., "add feature" not "Added feature"), and have no trailing period
3. **Body** must wrap at 72 characters if included; explains what changed and why (not how)
4. **Footer** must include ticket/issue references when applicable

## Examples

### Minimal (subject only)

```text
feat: add user authentication module
```

### With body

```text
fix: resolve race condition in cache handler

The previous implementation didn't lock the cache during updates,
causing intermittent data corruption when multiple requests occurred
simultaneously. Added mutex locking around cache write operations.
```

### With footer

```text
docs: update API documentation for endpoints

Added missing parameter descriptions and response examples for the
user management endpoints. Updated error code reference table.

Related-To: DOCS-456
```

### Full example

```text
refactor: extract validation logic into separate module

Moved all input validation functions from controllers into a dedicated
validation module to improve reusability and testability. Updated all
imports and added unit tests for validation functions.

Closes #789
Related-To: REFACTOR-123
```
