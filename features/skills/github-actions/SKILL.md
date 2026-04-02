---
name: github-actions
description: "Use when creating, modifying, or refactoring GitHub Actions workflows for any project. Covers CI/CD pipeline design, GitOps-based releases with automated tagging and changelog generation, Conventional Commits enforcement, multi-environment matrix builds, performance optimization (caching, parallelism), test result presentation, and trusted action selection."
---

# GitHub Actions Skill

## Overview

This skill defines standards for GitHub Actions workflows across any
releasable project, regardless of language or framework. It produces CI
pipelines, release automation, and deployment workflows that are fast,
secure, and maintainable.

Three practices are **mandatory** and non-negotiable. Every workflow
produced by this skill enforces them.

## Required Practices

### 1. Conventional Commits

All commits MUST follow the
[Conventional Commits](https://www.conventionalcommits.org/v1.0.0/)
specification.

- Format: `type(scope): description` (scope is optional)
- Standard types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`,
  `test`, `build`, `ci`, `chore`, `revert`
- Breaking changes: append `!` after type/scope OR include
  `BREAKING CHANGE:` in the commit footer
- Version bump mapping: `fix` → PATCH, `feat` → MINOR,
  breaking change → MAJOR
- CI MUST validate commit messages on pull requests
- When using squash-merge, the PR title serves as the merge commit
  message and MUST follow conventional commit format

### 2. GitOps Tag-Driven Releases

Git tags are the **sole source of truth** for releases. Tags and
releases are tightly coupled.

- Version tags use the format `vMAJOR.MINOR.PATCH` (e.g., `v1.2.3`)
- Pre-release tags use a suffix: `v1.2.3-rc.1`, `v1.2.3-beta.1`
- Tags MUST be created exclusively by the release workflow — never
  pushed manually by developers
- Configure repository rulesets to protect tag patterns matching `v*`
  and restrict creation to the GitHub Actions actor
- One tag = one release = one set of published artifacts. This coupling
  is absolute.

### 3. Keep a Changelog

Every project MUST maintain a `CHANGELOG.md` file following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

- The `## [Unreleased]` section accumulates changes between releases
- During release, the workflow promotes `[Unreleased]` entries into a
  new versioned section with a date
- Use these categories: Added, Changed, Deprecated, Removed, Fixed,
  Security
- Developers write entries under `[Unreleased]`; the release workflow
  handles promotion. Never manually edit versioned sections.
- `CHANGELOG.md` is the human-curated record for developers. GitHub
  Release notes are the auto-generated record for consumers. Maintain
  both.

## Workflow Architecture

Every project MUST have at minimum these workflows:

| Workflow    | File           | Trigger                    | Purpose                              |
| ----------- | -------------- | -------------------------- | ------------------------------------ |
| **CI**      | `ci.yml`       | `push` and `pull_request`  | Validate code, run tests, check build |
| **Release** | `release.yml`  | `workflow_dispatch` manual | Version, tag, release, publish       |

Optional workflows:

| Workflow   | File          | Trigger                                | Purpose                            |
| ---------- | ------------- | -------------------------------------- | ---------------------------------- |
| **Deploy** | `deploy.yml`  | `release` event or `workflow_dispatch` | Promote a release to an environment |

### Separation of Concerns

- **CI** validates that code is correct and mergeable. It runs on every
  push and pull request. It NEVER publishes anything.
- **Release** ships code. It runs on demand via `workflow_dispatch`. It
  determines the version, creates the tag, builds artifacts, and
  publishes to registries.
- **Deploy** promotes a release to an environment. It is optional and
  only needed when deployment is separate from publishing.

Do not mix these responsibilities. CI does not release. Release does not
deploy (unless publishing IS the deployment).

## CI Workflow Design

### Scaffold

```yaml
name: CI

on:
  push:
    branches: [main]
    paths-ignore:
      - "*.md"
      - "docs/**"
      - "LICENSE"
  pull_request:
    branches: [main]

permissions:
  contents: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
```

### Jobs

Run these jobs in parallel (no `needs` unless a true dependency exists):

1. **Commit lint** (PR only) — Validate the PR title follows
   Conventional Commits
2. **Lint** — Static analysis, formatting, type checking
3. **Test** — Unit and integration tests (matrix for OS/versions if
   applicable)
4. **Build** — Verify artifacts can be produced (do NOT publish)

Optional: **Markdown lint**, **Security audit**

### Commit Message Validation

For squash-merge repositories (the most common strategy with
Conventional Commits), validate the PR title:

```yaml
commit-lint:
  if: github.event_name == 'pull_request'
  runs-on: ubuntu-latest
  permissions:
    pull-requests: read
  steps:
    - uses: amannn/action-semantic-pull-request@v5
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

For merge-commit or rebase-merge repositories, validate individual
commit messages using `commitlint`.

### PR vs Default Branch Deviations

| Concern                      | Pull Request              | Default Branch Push         |
| ---------------------------- | ------------------------- | --------------------------- |
| Commit message validation    | YES — validate PR title   | SKIP — validated at PR time |
| Full test matrix             | YES                       | YES                         |
| Build artifacts              | Verify build succeeds     | Verify build succeeds       |
| Code coverage                | Enforce minimum threshold | Record and report           |
| Publish / deploy             | NEVER                     | NEVER                       |

See [CI Workflow Examples](./references/ci-workflow-examples.md) for
complete, production-ready templates for each ecosystem.

## Release Process

The release workflow is the **only** mechanism for shipping. It uses
`workflow_dispatch` so a human decides when to release but automation
handles the execution.

### Inputs

```yaml
on:
  workflow_dispatch:
    inputs:
      force-patch:
        description: "Force a patch bump when no feat/fix commits exist"
        type: boolean
        default: false
```

### Sequence

Execute these steps strictly in order. If any step fails, the workflow
halts — no partial releases.

1. **Checkout** — `fetch-depth: 0` for full git history (required for
   commit analysis)
2. **Determine version** — Analyze conventional commits since the last
   tag; compute the next semantic version via dry-run
3. **Guard** — Abort with a clear error if no releasable commits exist
   and `force-patch` is false
4. **Validate** — Run the full lint and test suite. The release MUST
   NOT proceed if validation fails.
5. **Update CHANGELOG.md** — Promote `[Unreleased]` entries to a new
   versioned section
6. **Commit** — Commit the CHANGELOG update using the bot identity
7. **Build** — Produce release artifacts
8. **Tag and push** — Create the version tag and push both the commit
   and tag
9. **GitHub Release** — Create a GitHub Release with artifacts attached
   and release notes generated
10. **Publish** — Push to package registries (npm, PyPI, Maven Central,
    crates.io, NuGet, etc.)

See [Release Automation Reference](./references/release-automation.md)
for the complete workflow template with full YAML.

### Version Determination

| Tool                              | Best For                                          |
| --------------------------------- | ------------------------------------------------- |
| `go-semantic-release/action@v1`   | Language-agnostic projects (no runtime dependency) |
| `semantic-release` (npm package)  | Node.js projects (rich plugin ecosystem)          |
| Custom script                     | Full control over version logic                   |

Run in **dry-run mode** first. Use the computed version for CHANGELOG,
build, and tag steps.

### CHANGELOG Automation

```yaml
- name: Update CHANGELOG.md
  env:
    VERSION: ${{ steps.version.outputs.version }}
  run: |
    DATE=$(date -u +%Y-%m-%d)
    sed -i "s/^## \[Unreleased\]$/## [Unreleased]\n\n## [$VERSION] - $DATE/" CHANGELOG.md
```

This inserts a versioned section header below `[Unreleased]`. Existing
unreleased entries become the content of the new version. The
`[Unreleased]` section resets to empty.

### Tag and GitHub Release

```yaml
- name: Commit and tag
  env:
    VERSION: ${{ steps.version.outputs.version }}
  run: |
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git add CHANGELOG.md
    git commit -m "chore(release): v$VERSION"
    git tag "v$VERSION"
    git push origin HEAD "v$VERSION"

- name: Create GitHub Release
  uses: softprops/action-gh-release@v2
  with:
    tag_name: "v${{ steps.version.outputs.version }}"
    generate_release_notes: true
    files: dist/*
```

## Performance Optimization

### Caching

Use setup actions with built-in caching. Avoid manual `actions/cache`
unless no setup action covers your ecosystem.

| Ecosystem       | Setup Action                       | Caching                            |
| --------------- | ---------------------------------- | ---------------------------------- |
| Gradle          | `gradle/actions/setup-gradle@v4`   | Automatic                          |
| Maven           | `actions/setup-java@v4`            | `cache: maven`                     |
| Python (uv)     | `astral-sh/setup-uv@v6`           | Automatic                          |
| Python (pip)    | `actions/setup-python@v5`          | `cache: pip`                       |
| Node.js         | `actions/setup-node@v4`            | `cache: npm` (or `pnpm`, `yarn`)  |
| Go              | `actions/setup-go@v5`              | Automatic                          |
| Rust            | `Swatinem/rust-cache@v2`           | Automatic                          |
| .NET            | `actions/setup-dotnet@v4`          | Use `actions/cache` for NuGet      |

### Parallelism

- Jobs without `needs` run concurrently. Exploit this by splitting
  lint, test, and build into separate jobs.
- Add `needs` only when a job requires another's output.
- Use matrix strategies to parallelize across OS and runtime versions.

### Concurrency Control

- CI workflows: `cancel-in-progress: true` — newer pushes supersede
  stale runs.
- Release workflows: `cancel-in-progress: false` — never cancel an
  in-progress release.

### Conditional Execution

- Use `paths-ignore` to skip CI for documentation-only changes.
- Use `if` conditions for expensive steps that apply only to specific
  matrix entries.
- Collect code coverage on ONE matrix combination only (typically the
  latest runtime version on `ubuntu-latest`).
- Use `if: always()` on reporting steps so they execute even when
  earlier steps fail.

### Timeouts

Set `timeout-minutes` on every job. Use 2–3× the expected duration.

## Multi-Environment Testing

```yaml
strategy:
  fail-fast: false
  matrix:
    os: [ubuntu-latest, windows-latest]
    version: ["17", "21"]
    exclude:
      - os: windows-latest
        version: "17"
    include:
      - os: ubuntu-latest
        version: "21"
        coverage: true
```

- Set `fail-fast: false` so all matrix jobs run to completion.
- Include only OS/version combinations the project actually supports.
- Use `exclude` to skip unnecessary combinations.
- Use `include` to attach flags (like `coverage: true`) to a single
  combination.
- Name jobs descriptively:
  `name: "Test (${{ matrix.os }}, v${{ matrix.version }})"`.

## Presentation

### Job Summaries

Write Markdown to `$GITHUB_STEP_SUMMARY` for rich output on the
workflow run page:

```yaml
- name: Report results
  if: always()
  run: |
    echo "## Test Results :test_tube:" >> $GITHUB_STEP_SUMMARY
    echo "" >> $GITHUB_STEP_SUMMARY
    echo "| Suite | Passed | Failed | Skipped |" >> $GITHUB_STEP_SUMMARY
    echo "|-------|--------|--------|---------|" >> $GITHUB_STEP_SUMMARY
```

### Test Reporters

Render test results as GitHub checks with file-level annotations:

```yaml
- name: Publish test results
  uses: dorny/test-reporter@v1
  if: always()
  with:
    name: "Tests (${{ matrix.os }})"
    path: "**/TEST-*.xml"
    reporter: java-junit
```

Supported reporters: `java-junit`, `dotnet-trx`, `dart-json`,
`mocha-json`, `jest-junit`.

### Build Scans (Gradle)

Use `gradle/actions/setup-gradle@v4` which links build scans in
workflow output automatically. Add `--scan` to Gradle commands for
public build scan URLs.

### Annotations

Use workflow commands to surface issues inline on files:

```yaml
echo "::error file=src/auth.ts,line=15::Unvalidated input"
echo "::warning::Coverage below 80%"
```

## Security

### Permissions

Declare explicit permissions in every workflow. Never rely on repository
defaults. Start from zero and add only what each workflow requires.

- CI: `contents: read` (minimum for checkout)
- Release: `contents: write` (push tags, create releases)
- OIDC publishing: add `id-token: write`
- PR interactions: add `pull-requests: write`

### Authentication

- Prefer OIDC trusted publishing for registries that support it (PyPI,
  npm).
- Use GitHub environment protection rules with required reviewers for
  production deployments.
- Store third-party credentials as encrypted repository or environment
  secrets. Never log them.

### Action Pinning

Pin to major version tags for readability, or full commit SHAs for
maximum security in release workflows:

```yaml
uses: actions/checkout@v4                                              # Major tag
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4 SHA
```

Configure Dependabot to keep action versions current. See
[Release Automation Reference](./references/release-automation.md) for
the Dependabot configuration.

## Trusted Actions

### Selection Criteria

Only use actions that meet ALL of these requirements:

- Published by GitHub (`actions/*`), a verified creator, or a
  recognized open-source organization
- Actively maintained — updated within the past 12 months
- Widely adopted — significant community usage and stars
- Open source — auditable code

### Curated List

| Purpose          | Action                                          |
| ---------------- | ----------------------------------------------- |
| Checkout         | `actions/checkout@v4`                           |
| Artifacts        | `actions/upload-artifact@v4`                    |
| Artifacts        | `actions/download-artifact@v4`                  |
| Cache            | `actions/cache@v4`                              |
| Java             | `actions/setup-java@v4`                         |
| Node.js          | `actions/setup-node@v4`                         |
| Python           | `actions/setup-python@v5`                       |
| Go               | `actions/setup-go@v5`                           |
| .NET             | `actions/setup-dotnet@v4`                       |
| Gradle           | `gradle/actions/setup-gradle@v4`                |
| UV (Python)      | `astral-sh/setup-uv@v6`                         |
| Rust toolchain   | `dtolnay/rust-toolchain@stable`                 |
| Rust cache       | `Swatinem/rust-cache@v2`                        |
| Go lint          | `golangci/golangci-lint-action@v6`              |
| GitHub Release   | `softprops/action-gh-release@v2`                |
| Docker build     | `docker/build-push-action@v6`                   |
| Docker login     | `docker/login-action@v3`                        |
| PyPI publish     | `pypa/gh-action-pypi-publish@release/v1`        |
| Test reporter    | `dorny/test-reporter@v1`                        |
| PR title lint    | `amannn/action-semantic-pull-request@v5`        |
| Semantic release | `go-semantic-release/action@v1`                 |
| Markdown lint    | `DavidAnson/markdownlint-cli2-action@v20`       |

**Avoid** actions with fewer than 100 stars, no updates in 12+ months,
unknown publishers, excessive permission requirements, or functionality
already covered by official `actions/*` actions.

## Anti-patterns

- **Manual tags** — Developers pushing tags bypasses the release
  workflow and violates GitOps
- **Tag-triggered releases** — Creates a chicken-and-egg problem; use
  `workflow_dispatch` instead
- **Publishing without validation** — The release workflow MUST run
  tests before publishing
- **Default permissions** — Repository defaults grant `write-all`;
  always declare explicit minimal permissions
- **Unbounded workflows** — Missing timeouts, concurrency groups, and
  path filters waste CI minutes
- **Untrusted actions** — Low-star, unmaintained actions are a
  supply-chain risk
- **Manual CHANGELOG edits for releases** — Automate the version
  section promotion in the release workflow
- **Mixing CI and release** — CI validates; release ships. Separate
  workflows, separate triggers, separate concerns.

## Related Files

- `references/release-automation.md`: Complete annotated release
  workflow template with CHANGELOG automation, version determination,
  ecosystem-specific publishing patterns, deployment gating, and tag
  protection setup.
- `references/ci-workflow-examples.md`: Production-ready CI workflow
  templates for Gradle, Python, Node.js, Go, Rust, and .NET with all
  best practices applied.

## Example

**Input:** "Create CI and release workflows for a Python project using
UV"

**Output:**

1. `.github/workflows/ci.yml` — Commit lint (PR only), ruff check +
   format, mypy, pytest matrix (ubuntu + windows, Python 3.12 + 3.13),
   markdownlint, concurrency control, path filters
2. `.github/workflows/release.yml` — `go-semantic-release` version
   determination, CHANGELOG promotion, `uv build`, tag push, GitHub
   Release, PyPI publish via OIDC
