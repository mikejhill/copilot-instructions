# Node.js CLI Patterns

Patterns for building Node.js command-line tools in TypeScript, with emphasis
on agent skill CLIs. These patterns produce testable, composable CLIs that
follow Unix conventions.

## Entry Point Architecture

Separate the entry point (`main.ts`) from argument parsing (`cli.ts`) and
business logic (service classes). This mirrors the Python pattern of
`__main__.py` → `cli.py` → domain modules.

### main.ts — Bootstrap and Error Boundary

`main.ts` is the only file with top-level side effects. It wires dependencies,
calls the CLI parser, invokes the application, and handles fatal errors.

```typescript
#!/usr/bin/env node

import { parseCli } from "./cli.ts";
import { Processor } from "./services/processor.ts";
import { AppError } from "./errors.ts";

async function main(argv: string[]): Promise<number> {
  const options = parseCli(argv);

  const processor = new Processor(options);
  const result = await processor.run();

  process.stdout.write(JSON.stringify(result, null, 2) + "\n");
  return 0;
}

main(process.argv.slice(2))
  .then((code) => {
    process.exitCode = code;
  })
  .catch((error: unknown) => {
    if (error instanceof AppError) {
      console.error(`Error: ${error.message}`);
      process.exitCode = 1;
    } else {
      console.error("Unexpected error:", error);
      process.exitCode = 2;
    }
  });
```

**Rules:**

- Set `process.exitCode` instead of calling `process.exit()` — this allows
  async cleanup (open handles, flush buffers) to complete.
- The `main` function accepts `argv` as a parameter for testability.
- The `.catch` block is the single top-level error boundary.

### cli.ts — Argument Parsing

`cli.ts` exports a pure function that parses arguments and returns a typed
options object. It has no side effects and no imports of business logic.

```typescript
import { parseArgs } from "node:util";
import { readFileSync } from "node:fs";
import { ValidationError } from "./errors.ts";

interface CliOptions {
  readonly inputPath: string;
  readonly outputFormat: "json" | "text";
  readonly verbose: boolean;
}

function parseCli(argv: string[]): CliOptions {
  const { values } = parseArgs({
    args: argv,
    options: {
      input: { type: "string", short: "i" },
      format: { type: "string", short: "f", default: "json" },
      verbose: { type: "boolean", short: "v", default: false },
      version: { type: "boolean" },
      help: { type: "boolean", short: "h" },
    },
    strict: true,
  });

  if (values.help) {
    printUsage();
    process.exit(0);
  }

  if (values.version) {
    printVersion();
    process.exit(0);
  }

  if (!values.input) {
    throw new ValidationError("input", "--input is required");
  }

  const format = values.format as string;
  if (format !== "json" && format !== "text") {
    throw new ValidationError("format", `invalid format: ${format}`);
  }

  return {
    inputPath: values.input,
    outputFormat: format,
    verbose: values.verbose ?? false,
  };
}

function printUsage(): void {
  console.error(`Usage: my-tool --input <path> [--format json|text] [--verbose]

Options:
  -i, --input <path>    Input file path (required)
  -f, --format <type>   Output format: json or text (default: json)
  -v, --verbose         Enable verbose output
      --version         Print version and exit
  -h, --help            Print this help and exit`);
}

function printVersion(): void {
  const pkg = JSON.parse(
    readFileSync(new URL("../package.json", import.meta.url), "utf-8"),
  ) as { version: string };
  console.error(pkg.version);
}

export { parseCli };
export type { CliOptions };
```

**Rules:**

- Use `node:util parseArgs` for zero-dependency argument parsing. This is
  the standard library equivalent of Python's `argparse`.
- The `parseCli` function accepts an `argv` array parameter (not
  `process.argv`) so tests can call it directly.
- Return a fully typed, readonly options object — no loose strings.
- Validate immediately after parsing — this is the first validation layer.
- `--help` and `--version` are the only cases where `process.exit()` is
  acceptable (they are informational exits, not errors).
- Print help and version to stderr (stdout is reserved for program output).

## Two-Layer Validation

Validate input at two levels:

1. **CLI layer** (`cli.ts`): Argument presence, type, and format. Catches
   missing or malformed arguments before business logic runs.
2. **Domain layer** (service constructors and methods): Business rule
   validation. Catches semantic errors (invalid combinations, out-of-range
   values, missing resources).

```typescript
// Layer 1: CLI validation (cli.ts)
if (!values.input) {
  throw new ValidationError("input", "--input is required");
}

// Layer 2: Domain validation (service constructor)
class Processor {
  constructor(private readonly options: ProcessorOptions) {
    if (!existsSync(options.inputPath)) {
      throw new ValidationError("inputPath", `file not found: ${options.inputPath}`);
    }
  }
}
```

The CLI layer validates syntax; the domain layer validates semantics. This
separation keeps business logic testable without requiring CLI argument
strings in tests.

## Version Reporting

Read the version from `package.json` at runtime. Do not duplicate the version
string in source code.

```typescript
import { readFileSync } from "node:fs";

function getVersion(): string {
  const pkg = JSON.parse(
    readFileSync(new URL("../package.json", import.meta.url), "utf-8"),
  ) as { version: string };
  return pkg.version;
}
```

Use `import.meta.url` to resolve `package.json` relative to the source file,
which works correctly whether running via `tsx` (development) or compiled
output (production).

## Configuration Loading

For CLIs that need persistent configuration (API keys, preferences), follow
the `~/.config/copilot-skills/<name>/` convention from the
`skill-cli-development` skill.

```typescript
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

interface ToolConfig {
  readonly apiKey?: string;
  readonly defaultFormat: "json" | "text";
}

const CONFIG_DIR = join(homedir(), ".config", "copilot-skills", "my-tool");
const CONFIG_FILE = join(CONFIG_DIR, "config.json");

function loadConfig(): ToolConfig {
  if (!existsSync(CONFIG_FILE)) {
    return { defaultFormat: "json" };
  }
  return JSON.parse(readFileSync(CONFIG_FILE, "utf-8")) as ToolConfig;
}

function saveConfig(config: ToolConfig): void {
  mkdirSync(CONFIG_DIR, { recursive: true });
  writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2) + "\n");
}
```

## Process Exit Codes

| Code | Meaning | Usage |
| --- | --- | --- |
| 0 | Success | Normal completion |
| 1 | User error | Invalid arguments, validation failure, bad input |
| 2 | Runtime error | Unexpected exception, service unavailable |

Map these in the top-level error boundary:

```typescript
main(process.argv.slice(2))
  .then((code) => {
    process.exitCode = code;
  })
  .catch((error: unknown) => {
    if (error instanceof ValidationError) {
      console.error(`Error: ${error.message}`);
      process.exitCode = 1;
    } else if (error instanceof AppError) {
      console.error(`Error [${error.code}]: ${error.message}`);
      process.exitCode = 1;
    } else {
      console.error("Unexpected error:", error);
      process.exitCode = 2;
    }
  });
```

## Package.json for CLI Projects

CLI projects include a `bin` field that maps the command name to the compiled
entry point:

```json
{
  "name": "my-tool",
  "version": "1.0.0",
  "type": "module",
  "bin": {
    "my-tool": "dist/main.js"
  },
  "engines": {
    "node": ">=22"
  },
  "packageManager": "pnpm@10.12.1",
  "scripts": {
    "build": "tsc",
    "dev": "tsx src/main.ts",
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "test": "vitest run",
    "test:watch": "vitest"
  }
}
```

**Rules:**

- `"type": "module"` is required for ESM.
- `bin` points to `dist/main.js` (compiled output), not `src/main.ts`.
- `engines` constrains the Node.js version.
- `packageManager` is set by Corepack (`corepack use pnpm@latest`).
- The `dev` script uses `tsx` for direct TypeScript execution.
- The `build` script uses `tsc` (no bundler needed for Node.js CLIs).

## Testing CLI Tools

### Testing Argument Parsing

Because `parseCli` accepts an `argv` array, test it directly:

```typescript
import { describe, expect, it } from "vitest";
import { parseCli } from "../src/cli.ts";
import { ValidationError } from "../src/errors.ts";

describe("parseCli", () => {
  it("parses required and optional arguments", () => {
    const options = parseCli(["--input", "data.json", "--format", "text"]);
    expect(options).toEqual({
      inputPath: "data.json",
      outputFormat: "text",
      verbose: false,
    });
  });

  it("uses default values for optional arguments", () => {
    const options = parseCli(["--input", "data.json"]);
    expect(options.outputFormat).toBe("json");
    expect(options.verbose).toBe(false);
  });

  it("throws ValidationError for missing required argument", () => {
    expect(() => parseCli([])).toThrow(ValidationError);
  });

  it("throws ValidationError for invalid format", () => {
    expect(() => parseCli(["--input", "x", "--format", "xml"])).toThrow(
      ValidationError,
    );
  });
});
```

### Testing the Main Function

Test the `main` function by capturing its return value and checking stdout
output:

```typescript
import { describe, expect, it, vi } from "vitest";

describe("main", () => {
  it("returns exit code 0 on success", async () => {
    const writeSpy = vi.spyOn(process.stdout, "write").mockReturnValue(true);

    const code = await main(["--input", "test-fixture.json"]);

    expect(code).toBe(0);
    expect(writeSpy).toHaveBeenCalled();
    writeSpy.mockRestore();
  });
});
```

### Integration Testing

For full CLI integration tests, run the compiled binary as a subprocess:

```typescript
import { execFileSync } from "node:child_process";
import { describe, expect, it } from "vitest";

describe("CLI integration", () => {
  it("exits 0 and produces JSON output", () => {
    const result = execFileSync("node", ["dist/main.js", "--input", "fixture.json"], {
      encoding: "utf-8",
    });
    const parsed = JSON.parse(result) as Record<string, unknown>;
    expect(parsed).toHaveProperty("count");
  });

  it("exits 1 for missing required argument", () => {
    expect(() => {
      execFileSync("node", ["dist/main.js"], { encoding: "utf-8" });
    }).toThrow();
  });
});
```
