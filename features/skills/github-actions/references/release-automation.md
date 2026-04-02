# Release Automation Reference

Complete release workflow patterns for the GitHub Actions skill.
This reference provides the full workflow template and
ecosystem-specific publishing snippets.

## Complete Release Workflow Template

This template implements the full release sequence. Adapt it to your
ecosystem by replacing the validation, build, and publish steps.

### Language-Agnostic Core

```yaml
name: Release

on:
  workflow_dispatch:
    inputs:
      force-patch:
        description: "Force a patch bump when no feat/fix commits exist"
        type: boolean
        default: false

permissions:
  contents: write

concurrency:
  group: release
  cancel-in-progress: false

jobs:
  release:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Determine next version
        id: version
        uses: go-semantic-release/action@v1
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          allow-initial-development-versions: true
          force-bump-patch-version: ${{ inputs.force-patch }}
          dry: true

      - name: Require version bump
        if: steps.version.outputs.version == ''
        run: |
          echo "::error::No releasable commits found. Add feat:/fix: commits or use force-patch."
          exit 1

      # ── Validation ──────────────────────────────────────────
      # INSERT: ecosystem-specific lint + test steps here.
      # These MUST pass before any release artifacts are created.
      # ────────────────────────────────────────────────────────

      - name: Update CHANGELOG.md
        env:
          VERSION: ${{ steps.version.outputs.version }}
        run: |
          DATE=$(date -u +%Y-%m-%d)
          sed -i "s/^## \[Unreleased\]$/## [Unreleased]\n\n## [$VERSION] - $DATE/" CHANGELOG.md

      # ── Build ───────────────────────────────────────────────
      # INSERT: ecosystem-specific build steps here.
      # ────────────────────────────────────────────────────────

      - name: Commit CHANGELOG and push tag
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
          name: "v${{ steps.version.outputs.version }}"
          generate_release_notes: true
          files: |
            dist/*

      # ── Publish ─────────────────────────────────────────────
      # INSERT: ecosystem-specific publish steps here,
      # or use a separate job (see OIDC patterns below).
      # ────────────────────────────────────────────────────────
```

## Ecosystem-Specific Snippets

Replace the placeholder sections in the template above with the
appropriate snippets for your ecosystem.

### Python (UV + PyPI via OIDC)

```yaml
      # ── Validation ──
      - uses: astral-sh/setup-uv@v6
      - run: uv sync --group dev
      - run: uv run ruff check .
      - run: uv run ruff format --check .
      - run: uv run mypy src
      - run: uv run pytest

      # ── Build ──
      - run: uv build
        env:
          SETUPTOOLS_SCM_PRETEND_VERSION: ${{ steps.version.outputs.version }}

      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/
```

PyPI publishing uses OIDC trusted publishers and runs as a separate
job so permissions are scoped:

```yaml
  pypi:
    needs: release
    runs-on: ubuntu-latest
    timeout-minutes: 10
    environment: pypi
    permissions:
      id-token: write
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/
      - uses: pypa/gh-action-pypi-publish@release/v1
```

### Node.js (npm)

```yaml
      # ── Validation ──
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
          registry-url: https://registry.npmjs.org
      - run: npm ci
      - run: npm run lint
      - run: npm test

      # ── Build ──
      - run: npm version "${{ steps.version.outputs.version }}" --no-git-tag-version
      - run: npm run build
      - run: npm pack
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: "*.tgz"

      # ── Publish ──
      - run: npm publish --provenance --access public
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

For OIDC-based npm publishing, add `id-token: write` to permissions
and use `--provenance` which automatically generates build provenance.

### Gradle (Java/Kotlin)

```yaml
      # ── Validation ──
      - uses: actions/setup-java@v4
        with:
          java-version: 21
          distribution: temurin
      - uses: gradle/actions/setup-gradle@v4
      - run: ./gradlew check

      # ── Build ──
      - run: ./gradlew build -Pversion="${{ steps.version.outputs.version }}"
      - uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: build/libs/
```

For Maven Central publishing:

```yaml
      # ── Publish (Maven Central) ──
      - run: ./gradlew publish -Pversion="${{ steps.version.outputs.version }}"
        env:
          MAVEN_USERNAME: ${{ secrets.MAVEN_USERNAME }}
          MAVEN_PASSWORD: ${{ secrets.MAVEN_PASSWORD }}
          SIGNING_KEY: ${{ secrets.SIGNING_KEY }}
          SIGNING_PASSWORD: ${{ secrets.SIGNING_PASSWORD }}
```

For JetBrains Marketplace publishing:

```yaml
      # ── Publish (JetBrains Marketplace) ──
      - run: ./gradlew publishPlugin -Pversion="${{ steps.version.outputs.version }}"
        env:
          PUBLISH_TOKEN: ${{ secrets.JETBRAINS_TOKEN }}
```

### Go

```yaml
      # ── Validation ──
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - run: go vet ./...
      - run: go test ./...

      # ── Build ──
      - name: Build binaries
        env:
          VERSION: ${{ steps.version.outputs.version }}
        run: |
          GOOS=linux   GOARCH=amd64 go build -ldflags "-X main.version=$VERSION" -o dist/app-linux-amd64 .
          GOOS=darwin  GOARCH=arm64 go build -ldflags "-X main.version=$VERSION" -o dist/app-darwin-arm64 .
          GOOS=windows GOARCH=amd64 go build -ldflags "-X main.version=$VERSION" -o dist/app-windows-amd64.exe .
```

Go modules are published automatically via git tags — no registry
push step is needed. The tag push in the core template is sufficient.

### Rust (crates.io)

```yaml
      # ── Validation ──
      - uses: dtolnay/rust-toolchain@stable
      - uses: Swatinem/rust-cache@v2
      - run: cargo clippy -- -D warnings
      - run: cargo test

      # ── Build ──
      - name: Set version
        run: |
          sed -i "s/^version = .*/version = \"${{ steps.version.outputs.version }}\"/" Cargo.toml
      - run: cargo build --release
      - uses: actions/upload-artifact@v4
        with:
          name: release-binary
          path: target/release/

      # ── Publish ──
      - run: cargo publish
        env:
          CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
```

### .NET (NuGet)

```yaml
      # ── Validation ──
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: 9.x
      - run: dotnet restore
      - run: dotnet build --no-restore
      - run: dotnet test --no-build

      # ── Build ──
      - run: >-
          dotnet pack -c Release
          -p:PackageVersion=${{ steps.version.outputs.version }}
          -o dist/

      # ── Publish ──
      - run: >-
          dotnet nuget push dist/*.nupkg
          --api-key ${{ secrets.NUGET_API_KEY }}
          --source https://api.nuget.org/v3/index.json
```

### Docker

```yaml
      # ── Build and Publish ──
      - uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - uses: docker/build-push-action@v6
        with:
          push: true
          tags: |
            ${{ github.repository }}:v${{ steps.version.outputs.version }}
            ${{ github.repository }}:latest
```

For multi-platform images, add `platforms: linux/amd64,linux/arm64`.

## Deployment Patterns

### Environment-Gated Deployments

For projects that deploy to infrastructure (not just publish packages),
use GitHub environments with protection rules:

```yaml
  deploy-staging:
    needs: release
    runs-on: ubuntu-latest
    timeout-minutes: 15
    environment: staging
    steps:
      - name: Deploy to staging
        run: echo "Deploy to staging..."

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    timeout-minutes: 15
    environment:
      name: production
      url: https://example.com
    steps:
      - name: Deploy to production
        run: echo "Deploy to production..."
```

Configure each environment in repository settings:

- **staging** — No restrictions (auto-deploys after release)
- **production** — Required reviewers, wait timer, deployment branch
  restrictions (`main` only)

### Multi-Registry Publishing

Some projects publish to multiple registries (e.g., npm + GitHub
Packages, or PyPI + GitHub Packages). Use separate jobs for each, all
depending on the `release` job:

```yaml
  npm:
    needs: release
    # ... npm publish steps

  github-packages:
    needs: release
    # ... GitHub Packages publish steps
```

## Tag Protection Setup

Configure repository rulesets (Settings → Rules → Rulesets):

1. Create a new ruleset targeting **tags** matching `v*`
2. Under "Bypass list", add only the **GitHub Actions** actor
3. Enable **Restrict creations** and **Restrict deletions**
4. This ensures only the release workflow can create or delete version
   tags

## CHANGELOG.md Template

New projects should start with this file:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
```

## Dependabot Configuration

Keep action versions current automatically:

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    commit-message:
      prefix: "ci"
```

This ensures action version updates are proposed as PRs with
conventional commit messages (`ci(deps): bump actions/checkout from
v4.1.0 to v4.2.0`).
