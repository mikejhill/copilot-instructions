# TypeScript Templates

## Full Project Skeleton (Browser Frontend)

### package.json

```json
{
  "name": "project-name",
  "version": "0.1.0",
  "description": "Short description of the project.",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc --noEmit && vite build",
    "preview": "vite preview",
    "lint": "eslint . && prettier --check .",
    "lint:fix": "eslint . --fix && prettier --write .",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "@eslint/js": "^9.0.0",
    "eslint": "^9.0.0",
    "globals": "^16.0.0",
    "prettier": "^3.0.0",
    "typescript": "~5.8.0",
    "typescript-eslint": "^8.0.0",
    "vite": "^6.0.0",
    "vitest": "^3.0.0"
  }
}
```

### tsconfig.json

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

### tsconfig.node.json

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
  "include": ["vite.config.ts", "eslint.config.ts"]
}
```

### vite.config.ts

```typescript
import { defineConfig } from "vite";

export default defineConfig({
  build: {
    target: "es2022",
    outDir: "dist",
    sourcemap: true,
  },
});
```

### eslint.config.ts

```typescript
import eslint from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.strictTypeChecked,
  ...tseslint.configs.stylisticTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      "@typescript-eslint/no-unused-vars": [
        "error",
        { argsIgnorePattern: "^_" },
      ],
      "@typescript-eslint/explicit-function-return-type": "error",
      "@typescript-eslint/explicit-member-accessibility": [
        "error",
        { accessibility: "no-public" },
      ],
      "@typescript-eslint/no-floating-promises": "error",
      "@typescript-eslint/no-misused-promises": "error",
      "@typescript-eslint/prefer-readonly": "error",
      "@typescript-eslint/strict-boolean-expressions": "error",
    },
  },
  {
    ignores: ["dist/", "node_modules/"],
  },
);
```

### .prettierrc

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2
}
```

### index.html

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

### src/config.ts

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

### src/main.ts

```typescript
import { loadConfig } from "./config.ts";

function bootstrap(): void {
  const config = loadConfig();
  // Application initialization
  const app = document.querySelector<HTMLDivElement>("#app");
  if (!app) {
    throw new Error("Root element #app not found");
  }
  app.textContent = `Running with API: ${config.apiBaseUrl}`;
}

bootstrap();
```

### tests/setup.ts

```typescript
// Global test setup for Vitest
// Add shared mocks, custom matchers, or environment setup here
```

---

## Full Project Skeleton (Node.js Application)

### package.json (Node.js)

```json
{
  "name": "project-name",
  "version": "0.1.0",
  "description": "Short description of the project.",
  "type": "module",
  "scripts": {
    "dev": "vite-node --watch src/main.ts",
    "build": "tsc",
    "start": "node dist/main.js",
    "lint": "eslint . && prettier --check .",
    "lint:fix": "eslint . --fix && prettier --write .",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "@eslint/js": "^9.0.0",
    "@types/node": "^22.0.0",
    "eslint": "^9.0.0",
    "globals": "^16.0.0",
    "prettier": "^3.0.0",
    "typescript": "~5.8.0",
    "typescript-eslint": "^8.0.0",
    "vite-node": "^3.0.0",
    "vitest": "^3.0.0"
  }
}
```

### tsconfig.json (Node.js)

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

### src/cli.ts (Node.js CLI Projects)

```typescript
import { parseArgs } from "node:util";
import { ValidationError } from "./errors.ts";

interface CliOptions {
  readonly inputPath: string;
  readonly maxRetries: number;
  readonly logLevel: "debug" | "info" | "warn" | "error";
  readonly verbose: boolean;
}

/**
 * Parses and validates command-line arguments.
 *
 * @param args - Raw argument array. Defaults to `process.argv.slice(2)`.
 * @returns Validated CLI options.
 * @throws {@link ValidationError} If required arguments are missing or invalid.
 */
function parseCli(args: string[] = process.argv.slice(2)): CliOptions {
  const { values, positionals } = parseArgs({
    args,
    options: {
      "max-retries": { type: "string", default: "3" },
      "log-level": { type: "string", default: "info" },
      verbose: { type: "boolean", default: false },
    },
    allowPositionals: true,
    strict: true,
  });

  const inputPath = positionals[0];
  if (!inputPath) {
    throw new ValidationError(
      "inputPath",
      "Input path is required as the first positional argument",
    );
  }

  const maxRetries = Number(values["max-retries"]);
  if (!Number.isInteger(maxRetries) || maxRetries < 0) {
    throw new ValidationError("max-retries", "Must be a non-negative integer");
  }

  const logLevel = values["log-level"] as CliOptions["logLevel"];
  const validLevels = new Set(["debug", "info", "warn", "error"]);
  if (!validLevels.has(logLevel)) {
    throw new ValidationError(
      "log-level",
      `Must be one of: ${[...validLevels].join(", ")}`,
    );
  }

  return {
    inputPath,
    maxRetries,
    logLevel,
    verbose: values.verbose ?? false,
  };
}

export { parseCli };
export type { CliOptions };
```

### src/main.ts (Node.js Entry Point)

```typescript
import { parseCli } from "./cli.ts";
import { Processor, type ProcessorConfig } from "./services/processor.ts";

function main(): void {
  const options = parseCli();

  const config: ProcessorConfig = {
    inputPath: options.inputPath,
    maxRetries: options.maxRetries,
  };

  const processor = new Processor(config);
  processor.run();
}

main();
```

---

## Vitest Configuration

### vitest section in vite.config.ts (Browser)

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

### vitest section in vite.config.ts (Node.js)

```typescript
/// <reference types="vitest/config" />
import { defineConfig } from "vite";

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
    it("creates_instance_with_valid_config", () => {
      const processor = new Processor(validConfig);
      expect(processor).toBeInstanceOf(Processor);
    });

    it("rejects_empty_inputPath", () => {
      const config: ProcessorConfig = { ...validConfig, inputPath: "" };
      expect(() => new Processor(config)).toThrow(ValidationError);
    });

    it("rejects_negative_maxRetries", () => {
      const config: ProcessorConfig = { ...validConfig, maxRetries: -1 };
      expect(() => new Processor(config)).toThrow(ValidationError);
    });
  });

  describe("run", () => {
    it.each([
      { description: "single item", items: ["a"], expected: 1 },
      { description: "multiple items", items: ["a", "b", "c"], expected: 3 },
      { description: "no items", items: [], expected: 0 },
    ])("processes_$description", ({ items, expected }) => {
      const processor = new Processor(validConfig);
      const result = processor.run(items);
      expect(result.count, `Expected ${expected} processed items`).toBe(
        expected,
      );
    });
  });
});
```
