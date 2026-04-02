# CI Workflow Examples

Production-ready CI workflow templates for common ecosystems. Each
example includes all best practices from the skill: parallel jobs,
concurrency control, path filtering, timeouts, caching, matrix testing,
test reporting, and commit message validation.

## Gradle (Java/Kotlin)

```yaml
name: CI

on:
  push:
    branches: [main]
    paths-ignore: ["*.md", "docs/**", "LICENSE"]
  pull_request:
    branches: [main]

permissions:
  contents: read
  checks: write
  pull-requests: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  commit-lint:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: 21
          distribution: temurin
      - uses: gradle/actions/setup-gradle@v4
      - run: ./gradlew detekt
      - run: ./gradlew ktlintCheck

  test:
    runs-on: ${{ matrix.os }}
    timeout-minutes: 20
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest]
        java-version: ["17", "21"]
        include:
          - os: ubuntu-latest
            java-version: "21"
            coverage: true
    name: "Test (${{ matrix.os }}, Java ${{ matrix.java-version }})"
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: ${{ matrix.java-version }}
          distribution: temurin
      - uses: gradle/actions/setup-gradle@v4
      - run: ./gradlew test

      - name: Publish test report
        if: always()
        uses: dorny/test-reporter@v1
        with:
          name: "Tests (${{ matrix.os }}, Java ${{ matrix.java-version }})"
          path: "**/build/test-results/**/*.xml"
          reporter: java-junit

      - name: Generate coverage
        if: matrix.coverage
        run: ./gradlew jacocoTestReport

      - name: Write summary
        if: always()
        run: |
          echo "## Test Results — ${{ matrix.os }}, Java ${{ matrix.java-version }}" >> $GITHUB_STEP_SUMMARY

  build:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: 21
          distribution: temurin
      - uses: gradle/actions/setup-gradle@v4
      - run: ./gradlew build -x test

  markdown:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v4
      - uses: DavidAnson/markdownlint-cli2-action@v20
```

## Python (UV)

```yaml
name: CI

on:
  push:
    branches: [main]
    paths-ignore: ["*.md", "docs/**", "LICENSE"]
  pull_request:
    branches: [main]

permissions:
  contents: read
  checks: write
  pull-requests: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  commit-lint:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v6
      - run: uv sync --group dev
      - run: uv run ruff check .
      - run: uv run ruff format --check .
      - run: uv run mypy src

  test:
    runs-on: ${{ matrix.os }}
    timeout-minutes: 15
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest]
        python-version: ["3.12", "3.13"]
        include:
          - os: ubuntu-latest
            python-version: "3.13"
            coverage: true
    name: "Test (${{ matrix.os }}, Python ${{ matrix.python-version }})"
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v6
      - run: uv python install ${{ matrix.python-version }}
      - run: uv sync --group dev --python ${{ matrix.python-version }}
      - run: uv run pytest --junit-xml=test-results.xml

      - name: Publish test report
        if: always()
        uses: dorny/test-reporter@v1
        with:
          name: "Tests (${{ matrix.os }}, Python ${{ matrix.python-version }})"
          path: test-results.xml
          reporter: java-junit

      - name: Coverage
        if: matrix.coverage
        run: uv run pytest --cov=src --cov-report=xml

  markdown:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v4
      - uses: DavidAnson/markdownlint-cli2-action@v20
```

## Node.js

```yaml
name: CI

on:
  push:
    branches: [main]
    paths-ignore: ["*.md", "docs/**", "LICENSE"]
  pull_request:
    branches: [main]

permissions:
  contents: read
  checks: write
  pull-requests: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  commit-lint:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run lint
      - run: npx tsc --noEmit

  test:
    runs-on: ${{ matrix.os }}
    timeout-minutes: 15
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest]
        node-version: ["20", "22"]
        include:
          - os: ubuntu-latest
            node-version: "22"
            coverage: true
    name: "Test (${{ matrix.os }}, Node ${{ matrix.node-version }})"
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: npm
      - run: npm ci
      - run: npm test

      - name: Publish test report
        if: always()
        uses: dorny/test-reporter@v1
        with:
          name: "Tests (${{ matrix.os }}, Node ${{ matrix.node-version }})"
          path: test-results.xml
          reporter: jest-junit

      - name: Coverage
        if: matrix.coverage
        run: npm run test:coverage

  build:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run build
```

## Go

```yaml
name: CI

on:
  push:
    branches: [main]
    paths-ignore: ["*.md", "docs/**", "LICENSE"]
  pull_request:
    branches: [main]

permissions:
  contents: read
  checks: write
  pull-requests: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  commit-lint:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - run: go vet ./...
      - uses: golangci/golangci-lint-action@v6
        with:
          version: latest

  test:
    runs-on: ${{ matrix.os }}
    timeout-minutes: 15
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    name: "Test (${{ matrix.os }})"
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - run: go test -v -race -coverprofile=coverage.out ./...

      - name: Write summary
        if: always()
        run: |
          echo "## Go Test Results — ${{ matrix.os }}" >> $GITHUB_STEP_SUMMARY

  build:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - run: go build ./...
```

## Rust

```yaml
name: CI

on:
  push:
    branches: [main]
    paths-ignore: ["*.md", "docs/**", "LICENSE"]
  pull_request:
    branches: [main]

permissions:
  contents: read
  checks: write
  pull-requests: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  commit-lint:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with:
          components: clippy, rustfmt
      - uses: Swatinem/rust-cache@v2
      - run: cargo fmt --check
      - run: cargo clippy -- -D warnings

  test:
    runs-on: ${{ matrix.os }}
    timeout-minutes: 20
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    name: "Test (${{ matrix.os }})"
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: Swatinem/rust-cache@v2
      - run: cargo test

  build:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: Swatinem/rust-cache@v2
      - run: cargo build --release
```

## .NET

```yaml
name: CI

on:
  push:
    branches: [main]
    paths-ignore: ["*.md", "docs/**", "LICENSE"]
  pull_request:
    branches: [main]

permissions:
  contents: read
  checks: write
  pull-requests: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  commit-lint:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  test:
    runs-on: ${{ matrix.os }}
    timeout-minutes: 15
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest]
    name: "Test (${{ matrix.os }})"
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: 9.x
      - run: dotnet restore
      - run: dotnet build --no-restore
      - run: dotnet test --no-build --logger "trx;LogFileName=test-results.trx"

      - name: Publish test report
        if: always()
        uses: dorny/test-reporter@v1
        with:
          name: "Tests (${{ matrix.os }})"
          path: "**/test-results.trx"
          reporter: dotnet-trx

  build:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: 9.x
      - run: dotnet restore
      - run: dotnet build -c Release --no-restore
      - run: dotnet pack -c Release --no-build -o dist/
```
