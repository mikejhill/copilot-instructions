# TypeScript Templates

Copy-paste-ready skeletons for each use case. Replace `project-name` and
placeholder descriptions before use.

## Shared Configuration

These files are identical across all use cases.

### biome.json

```json
{
  "$schema": "https://biomejs.dev/schemas/2.0.0/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "correctness": {
        "noUnusedImports": "error",
        "noUnusedVariables": "error",
        "useExhaustiveDependencies": "warn"
      },
      "style": {
        "noDefaultExport": "error",
        "useConst": "error",
        "noNonNullAssertion": "warn"
      },
      "suspicious": {
        "noExplicitAny": "error"
      }
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "files": {
    "ignore": ["dist/", "node_modules/", "*.json"]
  }
}
```

### .node-version

```text
22
```

### src/errors.ts

```typescript
/**
 * Base error class for all application errors.
 *
 * @remarks
 * Extend this class to create specific error types.
 * All application errors carry a machine-readable `code` property.
 */
abstract class AppError extends Error {
  abstract readonly code: string;

  constructor(message: string, options?: ErrorOptions) {
    super(message, options);
    this.name = this.constructor.name;
  }
}

/**
 * Thrown when input validation fails.
 */
class ValidationError extends AppError {
  readonly code = "VALIDATION_ERROR";
  readonly field: string;

  constructor(field: string, message: string, options?: ErrorOptions) {
    super(`Validation failed for '${field}': ${message}`, options);
    this.field = field;
  }
}

/**
 * Thrown when a requested resource does not exist.
 */
class NotFoundError extends AppError {
  readonly code = "NOT_FOUND";
  readonly resource: string;
  readonly identifier: string;

  constructor(resource: string, identifier: string) {
    super(`${resource} not found: ${identifier}`);
    this.resource = resource;
    this.identifier = identifier;
  }
}

export { AppError, NotFoundError, ValidationError };
```

### src/types.ts

```typescript
/**
 * Structured logger interface.
 *
 * @remarks
 * Implement this interface to provide application-wide logging.
 * Each method accepts a message and optional structured data.
 */
interface Logger {
  debug(message: string, data?: Record<string, unknown>): void;
  info(message: string, data?: Record<string, unknown>): void;
  warn(message: string, data?: Record<string, unknown>): void;
  error(message: string, error?: Error, data?: Record<string, unknown>): void;
}

export type { Logger };
```

### tests/setup.ts

```typescript
// Global test setup for Vitest
// Add shared mocks, custom matchers, or environment setup here
```

---

## Browser Frontend

### package.json (Browser)

```json
{
  "name": "project-name",
  "version": "0.1.0",
  "description": "Short description of the project.",
  "type": "module",
  "engines": {
    "node": ">=22"
  },
  "packageManager": "pnpm@10.12.1",
  "scripts": {
    "dev": "vite",
    "build": "tsc --noEmit && vite build",
    "preview": "vite preview",
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "@biomejs/biome": "^2.0.0",
    "typescript": "~5.8.0",
    "vite": "^6.0.0",
    "vitest": "^3.0.0"
  }
}
```

### tsconfig.json (Browser)

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "verbatimModuleSyntax": true,
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

### tsconfig.node.json (Browser)

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "forceConsistentCasingInFileNames": true,
    "verbatimModuleSyntax": true,
    "skipLibCheck": true
  },
  "include": ["vite.config.ts"]
}
```

### vite.config.ts (Browser)

```typescript
/// <reference types="vitest/config" />
import { defineConfig } from "vite";

export default defineConfig({
  build: {
    target: "es2022",
    outDir: "dist",
    sourcemap: true,
  },
  test: {
    globals: false,
    environment: "jsdom",
    setupFiles: ["./tests/setup.ts"],
    include: ["tests/**/*.test.ts"],
    coverage: {
      provider: "v8",
      include: ["src/**/*.ts"],
      exclude: ["src/main.ts", "src/**/*.d.ts"],
    },
  },
});
```

### index.html (Browser)

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Project Name</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.ts"></script>
  </body>
</html>
```

### src/config.ts (Browser)

```typescript
interface AppConfig {
  readonly apiBaseUrl: string;
  readonly timeout: number;
  readonly logLevel: "debug" | "info" | "warn" | "error";
}

const DEFAULT_CONFIG: AppConfig = {
  apiBaseUrl: "/api",
  timeout: 5000,
  logLevel: "info",
} as const;

/**
 * Loads application configuration from environment variables with defaults.
 */
function loadConfig(overrides?: Partial<AppConfig>): AppConfig {
  return { ...DEFAULT_CONFIG, ...overrides };
}

export { DEFAULT_CONFIG, loadConfig };
export type { AppConfig };
```

### src/main.ts (Browser)

```typescript
import { loadConfig } from "./config.ts";

function bootstrap(): void {
  const config = loadConfig();
  const app = document.querySelector<HTMLDivElement>("#app");
  if (!app) {
    throw new Error("Root element #app not found");
  }
  app.textContent = `Running with API: ${config.apiBaseUrl}`;
}

bootstrap();
```

---

## Node.js Server

### package.json (Server)

```json
{
  "name": "project-name",
  "version": "0.1.0",
  "description": "Short description of the project.",
  "type": "module",
  "engines": {
    "node": ">=22"
  },
  "packageManager": "pnpm@10.12.1",
  "scripts": {
    "dev": "tsx --watch src/main.ts",
    "build": "tsc",
    "start": "node dist/main.js",
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "@biomejs/biome": "^2.0.0",
    "@types/node": "^22.0.0",
    "tsx": "^4.0.0",
    "typescript": "~5.8.0",
    "vitest": "^3.0.0"
  },
  "dependencies": {
    "pino": "^9.0.0"
  }
}
```

### tsconfig.json (Node.js)

Used by both Server and CLI projects.

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "nodenext",
    "lib": ["ES2022"],
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "verbatimModuleSyntax": true,
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

### vitest.config.ts (Node.js)

Used by both Server and CLI projects.

```typescript
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: false,
    environment: "node",
    setupFiles: ["./tests/setup.ts"],
    include: ["tests/**/*.test.ts"],
    coverage: {
      provider: "v8",
      include: ["src/**/*.ts"],
      exclude: ["src/main.ts", "src/cli.ts", "src/**/*.d.ts"],
    },
  },
});
```

### src/main.ts (Server)

```typescript
import pino from "pino";
import { loadConfig } from "./config.ts";
import { Processor } from "./services/processor.ts";

const logger = pino({ level: process.env["LOG_LEVEL"] ?? "info" });

async function main(): Promise<void> {
  const config = loadConfig();
  logger.info({ port: config.port }, "starting server");

  const processor = new Processor(config, logger);
  await processor.run();
}

main().catch((error: unknown) => {
  logger.fatal({ err: error }, "unhandled error");
  process.exitCode = 1;
});
```

---

## Node.js CLI

### package.json (CLI)

```json
{
  "name": "project-name",
  "version": "0.1.0",
  "description": "Short description of the tool.",
  "type": "module",
  "bin": {
    "project-name": "dist/main.js"
  },
  "engines": {
    "node": ">=22"
  },
  "packageManager": "pnpm@10.12.1",
  "scripts": {
    "dev": "tsx src/main.ts",
    "build": "tsc",
    "start": "node dist/main.js",
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "@biomejs/biome": "^2.0.0",
    "@types/node": "^22.0.0",
    "tsx": "^4.0.0",
    "typescript": "~5.8.0",
    "vitest": "^3.0.0"
  }
}
```

### src/cli.ts (CLI)

See [cli-patterns.md](cli-patterns.md) for detailed patterns. Minimal
template:

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
  console.error(`Usage: project-name --input <path> [--format json|text] [--verbose]

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

### src/main.ts (CLI)

```typescript
#!/usr/bin/env node

import { parseCli } from "./cli.ts";
import { Processor } from "./services/processor.ts";
import { AppError } from "./errors.ts";

async function main(argv: string[]): Promise<number> {
  const options = parseCli(argv);

  const processor = new Processor({
    inputPath: options.inputPath,
    outputFormat: options.outputFormat,
  });
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

---

## Test Template

### tests/services/processor.test.ts

```typescript
import { describe, expect, it } from "vitest";
import {
  Processor,
  type ProcessorConfig,
} from "../../src/services/processor.ts";
import { ValidationError } from "../../src/errors.ts";

describe("Processor", () => {
  const validConfig: ProcessorConfig = {
    inputPath: "/valid/path",
    maxRetries: 3,
  };

  describe("constructor", () => {
    it("creates instance with valid config", () => {
      const processor = new Processor(validConfig);
      expect(processor).toBeInstanceOf(Processor);
    });

    it("rejects empty inputPath", () => {
      const config: ProcessorConfig = { ...validConfig, inputPath: "" };
      expect(() => new Processor(config)).toThrow(ValidationError);
    });

    it("rejects negative maxRetries", () => {
      const config: ProcessorConfig = { ...validConfig, maxRetries: -1 };
      expect(() => new Processor(config)).toThrow(ValidationError);
    });
  });

  describe("run", () => {
    it.each([
      { description: "single item", items: ["a"], expected: 1 },
      { description: "multiple items", items: ["a", "b", "c"], expected: 3 },
      { description: "no items", items: [], expected: 0 },
    ])("processes $description", ({ items, expected }) => {
      const processor = new Processor(validConfig);
      const result = processor.run(items);
      expect(result.count, `Expected ${expected} processed items`).toBe(
        expected,
      );
    });
  });
});
```

### tests/cli.test.ts (CLI Projects)

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
