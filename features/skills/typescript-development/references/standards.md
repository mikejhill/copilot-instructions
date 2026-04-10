# TypeScript Standards and Patterns

## Core Principles

1. OOP first for full projects
2. Strict typing on all signatures
3. Guard clauses at method entry
4. Fail fast on invalid preconditions
5. Named exports only; no default exports
6. `as const` objects or union types instead of `enum`

## Full Project Directory Layout

### Browser Frontend

```text
project-name/
├── package.json            # Corepack packageManager, engines, scripts
├── tsconfig.json
├── tsconfig.node.json
├── vite.config.ts
├── biome.json
├── .node-version           # Pins Node.js runtime version
├── index.html
├── public/
│   └── favicon.svg
├── src/
│   ├── main.ts                # Entry point
│   ├── config.ts              # Typed application configuration
│   ├── errors.ts              # Custom error hierarchy
│   ├── types.ts               # Shared interfaces and type aliases
│   ├── services/
│   │   ├── api-client.ts      # HTTP client class
│   │   └── auth-service.ts    # Authentication logic
│   ├── models/
│   │   ├── user.ts            # Domain model class
│   │   └── session.ts         # Session model class
│   └── utils/
│       └── validation.ts      # Validation utility class
├── tests/
│   ├── setup.ts               # Test setup and global mocks
│   ├── services/
│   │   ├── api-client.test.ts
│   │   └── auth-service.test.ts
│   └── models/
│       ├── user.test.ts
│       └── session.test.ts
└── node_modules/              # (gitignored)
```

### Node.js Server

```text
project-name/
├── package.json            # Corepack packageManager, engines, scripts
├── tsconfig.json
├── vitest.config.ts
├── biome.json
├── .node-version           # Pins Node.js runtime version
├── src/
│   ├── main.ts                # Server bootstrap
│   ├── config.ts              # Typed configuration
│   ├── errors.ts              # Custom error hierarchy
│   ├── types.ts               # Shared interfaces and type aliases
│   ├── services/
│   │   └── processor.ts       # Business logic class
│   ├── models/
│   │   └── result.ts          # Domain model class
│   └── utils/
│       └── file-system.ts     # File system utility class
├── tests/
│   ├── setup.ts
│   ├── services/
│   │   └── processor.test.ts
│   └── models/
│       └── result.test.ts
└── node_modules/              # (gitignored)
```

### Node.js CLI

```text
project-name/
├── package.json            # Corepack packageManager, engines, bin field
├── tsconfig.json
├── vitest.config.ts
├── biome.json
├── .node-version           # Pins Node.js runtime version
├── src/
│   ├── main.ts                # Entry point (bootstrap + error boundary)
│   ├── cli.ts                 # Argument parsing (testable)
│   ├── config.ts              # Typed configuration
│   ├── errors.ts              # Custom error hierarchy
│   ├── types.ts               # Shared interfaces and type aliases
│   ├── services/
│   │   └── processor.ts       # Core business logic
│   └── utils/
│       └── validation.ts      # Input validation utility
├── tests/
│   ├── cli.test.ts            # Argument parsing tests
│   ├── services/
│   │   └── processor.test.ts
│   └── utils/
│       └── validation.test.ts
└── node_modules/              # (gitignored)
```

## Naming Conventions

| Element              | Convention   | Examples                                         |
| -------------------- | ------------ | ------------------------------------------------ |
| Files and folders    | kebab-case   | `api-client.ts`, `auth-service.ts`, `models/`    |
| Classes              | PascalCase   | `ApiClient`, `AuthService`, `UserRepository`     |
| Interfaces           | PascalCase   | `HttpClient`, `UserData`, `ServiceConfig`        |
| Type aliases         | PascalCase   | `UserId`, `RequestHandler`, `ValidationResult`   |
| Constants (module)   | UPPER_SNAKE  | `MAX_RETRIES`, `DEFAULT_TIMEOUT`, `API_VERSION`  |
| Variables            | camelCase    | `userCount`, `isValid`, `retryDelay`             |
| Functions/methods    | camelCase    | `fetchUser()`, `validateInput()`, `parseToken()` |
| Private members      | `private` kw | `private readonly _cache: Map<string, Item>`     |
| Boolean variables    | is/has/can   | `isActive`, `hasPermission`, `canRetry`          |
| Event handlers       | on/handle    | `onClick`, `handleSubmit`, `onError`             |
| Test files           | `.test.ts`   | `api-client.test.ts`, `user.test.ts`             |
| Test describe blocks | Class name   | `describe('ApiClient', ...)`                     |

### Interface Naming

- Do NOT prefix interfaces with `I` (e.g., `IUserService`). Use plain PascalCase: `UserService`.
- Name interfaces after the contract they describe: `HttpClient`, `Logger`, `CacheStore`.
- When both an interface and implementation exist, name the interface after the contract and the implementation descriptively: interface `Logger`, class `ConsoleLogger`.

### File Organization

- One primary class or interface per file.
- The file name matches the primary export in kebab-case: class `ApiClient` → file `api-client.ts`.
- Group related files in folders by domain or layer: `services/`, `models/`, `utils/`.
- Shared types and interfaces go in `types.ts` at the appropriate level.
- Custom errors go in `errors.ts`.
- Configuration goes in `config.ts`.

## Object-Oriented Design

### Standard OOP Pattern

All business logic belongs in classes. Module-level code is limited to imports, constants, and class/type definitions.

```typescript
import { Logger } from "./types.ts";

const DEFAULT_TIMEOUT = 5000;

interface ProcessorConfig {
  readonly inputPath: string;
  readonly maxRetries: number;
  readonly timeout: number;
}

class Processor {
  private readonly config: ProcessorConfig;
  private readonly logger: Logger;

  constructor(config: ProcessorConfig, logger: Logger) {
    if (!config.inputPath) {
      throw new ValidationError("inputPath is required");
    }
    if (config.maxRetries < 0) {
      throw new ValidationError("maxRetries must be non-negative");
    }
    this.config = config;
    this.logger = logger;
  }

  async run(): Promise<ProcessingResult> {
    this.logger.info(`Processing ${this.config.inputPath}`);
    const items = await this.discoverItems();
    const results = await this.processItems(items);
    this.logger.info(`Processed ${results.length} items`);
    return { items: results, count: results.length };
  }

  private async discoverItems(): Promise<Item[]> {
    // Discovery logic
  }

  private async processItems(items: Item[]): Promise<ProcessedItem[]> {
    const processed: ProcessedItem[] = [];
    for (const item of items) {
      if (this.shouldProcess(item)) {
        processed.push(await this.processItem(item));
      }
    }
    return processed;
  }

  private shouldProcess(item: Item): boolean {
    return item.status === "pending";
  }

  private async processItem(item: Item): Promise<ProcessedItem> {
    // Processing logic
  }
}

export { Processor };
export type { ProcessorConfig };
```

### Key OOP Rules

- All business logic belongs in classes.
- Use `private` for internal methods and properties.
- Use `readonly` on all properties not reassigned after construction.
- Use interfaces for dependency injection and public contracts.
- Use abstract classes when sharing implementation across a class hierarchy.
- Use composition over inheritance for cross-cutting concerns.
- Use the `implements` keyword to declare interface conformance explicitly.
- Prefer injecting dependencies through the constructor over importing singletons.

### Minimizing Non-OOP Code

The only code outside classes:

- `main.ts`: application bootstrap (instantiation, wiring, startup)
- Module-level: imports, constants, type definitions, class definitions
- `setup.ts` (tests): global test configuration

Everything else is a class method.

## Typing Rules

### Required Practices

- `strict: true` in tsconfig.json (enables all strict checks)
- Type annotations on all function/method parameters and return types
- Use `readonly` for properties and array types that are not mutated
- Use `unknown` instead of `any` and narrow with type guards
- Use union types (`'success' | 'error'`) and `as const` objects instead of `enum`
- Use `interface` for object shapes and public contracts
- Use `type` for unions, intersections, mapped types, and computed types
- Use generics for reusable data structures and utility classes
- Use discriminated unions for state modeling

### Forbidden Practices

- `any` type unless interfacing with untyped third-party code
- Untyped function signatures (implicit `any` on parameters or return)
- `// @ts-ignore` without a specific justification comment
- `as` type assertions without a code comment justifying the cast
- `enum` (use `as const` objects or string literal union types)
- Default exports
- Non-null assertion (`!`) without a justification comment

### Enum Alternatives

Instead of `enum`, use one of these patterns:

**String literal union (preferred for simple sets):**

```typescript
type LogLevel = "debug" | "info" | "warn" | "error";
```

**`as const` object (preferred when values or reverse lookup are needed):**

```typescript
const HTTP_STATUS = {
  Ok: 200,
  NotFound: 404,
  InternalError: 500,
} as const;

type HttpStatus = (typeof HTTP_STATUS)[keyof typeof HTTP_STATUS];
```

### Example Type Patterns

```typescript
// Generic repository interface
interface Repository<T, TId = string> {
  findById(id: TId): Promise<T | null>;
  findAll(filter?: Partial<T>): Promise<readonly T[]>;
  save(entity: T): Promise<T>;
  delete(id: TId): Promise<void>;
}

// Discriminated union for state modeling
interface LoadingState {
  readonly status: "loading";
}

interface SuccessState<T> {
  readonly status: "success";
  readonly data: T;
}

interface ErrorState {
  readonly status: "error";
  readonly error: AppError;
}

type AsyncState<T> = LoadingState | SuccessState<T> | ErrorState;

// Type guard
function isSuccessState<T>(state: AsyncState<T>): state is SuccessState<T> {
  return state.status === "success";
}

// Utility types
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};
```

## Error Handling

### Error Hierarchy

Define a base application error and extend it for specific error categories.

```typescript
abstract class AppError extends Error {
  abstract readonly code: string;
  readonly cause?: Error;

  constructor(message: string, options?: { cause?: Error }) {
    super(message, options);
    this.name = this.constructor.name;
    this.cause = options?.cause;
  }
}

class ValidationError extends AppError {
  readonly code = "VALIDATION_ERROR";
  readonly field: string;

  constructor(field: string, message: string, options?: { cause?: Error }) {
    super(`Validation failed for '${field}': ${message}`, options);
    this.field = field;
  }
}

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

class ExternalServiceError extends AppError {
  readonly code = "EXTERNAL_SERVICE_ERROR";
  readonly service: string;
  readonly statusCode?: number;

  constructor(
    service: string,
    message: string,
    options?: { cause?: Error; statusCode?: number },
  ) {
    super(`${service}: ${message}`, options);
    this.service = service;
    this.statusCode = options?.statusCode;
  }
}
```

### Error Handling Rules

- Throw specific error types, not generic `Error`.
- Catch specific error types, not bare `catch (error)` without narrowing.
- Include contextual information in error messages (what operation, what input, what went wrong).
- Use the `cause` option to chain underlying errors.
- Never catch and suppress silently. Either handle, log and re-throw, or let propagate.
- Validate at system boundaries (user input, API responses, file I/O). Trust internal code.

### Guard Clauses

```typescript
class UserService {
  constructor(
    private readonly repository: UserRepository,
    private readonly logger: Logger,
  ) {
    if (!repository) {
      throw new ValidationError("repository", "UserRepository is required");
    }
    if (!logger) {
      throw new ValidationError("logger", "Logger is required");
    }
  }

  async getUser(id: string): Promise<User> {
    if (!id || id.trim().length === 0) {
      throw new ValidationError("id", "User ID is required");
    }

    const user = await this.repository.findById(id);
    if (!user) {
      throw new NotFoundError("User", id);
    }

    return user;
  }
}
```

## Documentation (TSDoc)

### Required Documentation

- All public classes: describe purpose and usage
- All public methods: describe behavior, parameters, return value, and thrown errors
- All public interfaces: describe the contract
- Complex private methods: describe non-obvious logic

### TSDoc Format

````typescript
/**
 * Manages user authentication and session lifecycle.
 *
 * @remarks
 * Requires a configured {@link HttpClient} and {@link TokenStore}.
 * Tokens are automatically refreshed before expiry.
 *
 * @example
 * ```typescript
 * const auth = new AuthService(httpClient, tokenStore);
 * const session = await auth.login(credentials);
 * ```
 */
class AuthService {
  /**
   * Authenticates a user with the provided credentials.
   *
   * @param credentials - User login credentials.
   * @returns A new authenticated session.
   * @throws {@link ValidationError} If credentials are incomplete.
   * @throws {@link AuthenticationError} If credentials are invalid.
   */
  async login(credentials: LoginCredentials): Promise<Session> {
    // ...
  }
}
````

### Documentation Rules

- Use `@param` for each parameter (describe purpose, not type — the type is in the signature).
- Use `@returns` for the return value.
- Use `@throws` for each error type the method can throw, with a condition description.
- Use `@remarks` for extended discussion, caveats, or implementation notes.
- Use `@example` with a fenced code block for usage examples.
- Do not restate the method name or signature in the description.
- Do not document trivial getters/setters unless behavior is non-obvious.

## Logging

### Browser Projects

Use a structured logger class that wraps `console` methods with consistent formatting and log levels.

```typescript
type LogLevel = "debug" | "info" | "warn" | "error";

const LOG_LEVEL_PRIORITY: Record<LogLevel, number> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
} as const;

class Logger {
  private readonly context: string;
  private readonly minLevel: LogLevel;

  constructor(context: string, minLevel: LogLevel = "info") {
    this.context = context;
    this.minLevel = minLevel;
  }

  debug(message: string, data?: Record<string, unknown>): void {
    this.log("debug", message, data);
  }

  info(message: string, data?: Record<string, unknown>): void {
    this.log("info", message, data);
  }

  warn(message: string, data?: Record<string, unknown>): void {
    this.log("warn", message, data);
  }

  error(message: string, error?: Error, data?: Record<string, unknown>): void {
    this.log("error", message, {
      ...data,
      error: error?.message,
      stack: error?.stack,
    });
  }

  private log(
    level: LogLevel,
    message: string,
    data?: Record<string, unknown>,
  ): void {
    if (LOG_LEVEL_PRIORITY[level] < LOG_LEVEL_PRIORITY[this.minLevel]) {
      return;
    }
    const entry = {
      timestamp: new Date().toISOString(),
      level,
      context: this.context,
      message,
      ...data,
    };
    console[level](JSON.stringify(entry));
  }
}
```

### Node.js Projects

Use **pino** for structured logging in Node.js server and CLI projects. pino
outputs newline-delimited JSON by default, is the fastest Node.js logger, and
has zero required dependencies beyond the core package.

Configure the logger at the application entry point. Create child loggers with
context for each module.

```typescript
import pino from "pino";

// Application entry point — configure once
const logger = pino({
  level: process.env["LOG_LEVEL"] ?? "info",
});

// In service classes — create child loggers
class Processor {
  private readonly logger: pino.Logger;

  constructor(parentLogger: pino.Logger) {
    this.logger = parentLogger.child({ service: "Processor" });
  }

  async run(): Promise<void> {
    this.logger.info({ inputPath: this.config.inputPath }, "processing started");
    // ...
    this.logger.info({ count: results.length }, "processing complete");
  }
}
```

**CLI projects:** Log diagnostics to stderr only (stdout is reserved for
program output). Use `pino({ level: "info" }, pino.destination(2))` to direct
logs to stderr, or use `console.error` for lightweight CLIs that do not need
structured logging.

## CLI I/O Standards

CLI tools follow strict I/O conventions for composability. These apply to
Node.js CLI and agent skill CLI projects.

### stdout vs stderr

- **stdout:** Program output only — results, data, structured responses.
  This is what callers capture and parse.
- **stderr:** Diagnostics — progress, warnings, errors, log messages.
  This is what operators read during execution.

Never mix diagnostics into stdout. Callers (including AI agents) parse stdout
and expect clean, predictable output.

### Exit Codes

| Code | Meaning | When to Use |
| --- | --- | --- |
| 0 | Success | Operation completed normally |
| 1 | User error | Bad arguments, invalid input, validation failure |
| 2 | Runtime error | Unhandled exception, external service failure |

### Structured Output

When a CLI produces structured results, output JSON to stdout:

```typescript
// Correct: structured result to stdout
process.stdout.write(JSON.stringify(result, null, 2) + "\n");

// Correct: diagnostics to stderr
console.error("Processing complete");
```

For agent skill CLIs, always default to JSON output. Support a `--format`
flag for human-readable alternatives when appropriate.

## Runtime Version Management

Use **fnm** (Fast Node Manager) to manage Node.js versions. fnm is a
Rust-based version manager that reads `.node-version` and auto-switches
Node.js versions when entering a project directory.

### Why fnm

- **Fast:** Rust-based, near-instant version switching (no shell startup lag).
- **Cross-platform:** Native support for Windows, macOS, and Linux.
- **Reads `.node-version`:** Aligns with the `.node-version` file in project
  templates. Also reads `.nvmrc` for nvm compatibility.
- **Auto-switch:** With `--use-on-cd`, fnm detects `.node-version` on `cd`
  and activates the correct Node.js version automatically.
- **Analog to pyenv:** Same mental model as `.python-version` in the Python
  ecosystem.

### Setup

Install fnm and configure auto-switching in the shell profile:

**PowerShell (Windows):**

```powershell
# Install via winget
winget install Schniz.fnm

# Add to PowerShell profile ($PROFILE)
fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
```

**Bash/Zsh (macOS/Linux):**

```bash
# Install via curl
curl -fsSL https://fnm.vercel.app/install | bash

# Add to ~/.bashrc or ~/.zshrc
eval "$(fnm env --use-on-cd)"
```

### Project Integration

Every full project includes a `.node-version` file at the root:

```text
22
```

When a developer enters the project directory, fnm automatically installs
(if needed) and activates Node.js 22. This works in conjunction with:

- **`engines` in package.json:** pnpm warns at install time if the active
  Node.js version does not satisfy the constraint.
- **Corepack `packageManager`:** Pins the pnpm version independently of
  Node.js.

The three mechanisms are complementary:

| Mechanism | What it pins | When it acts |
| --- | --- | --- |
| `.node-version` + fnm | Node.js runtime version | On `cd` into project |
| `engines` in package.json | Node.js minimum version | On `pnpm install` |
| `packageManager` + Corepack | pnpm version | On any pnpm command |

## Nesting and Extraction

- Max 3 levels of nesting.
- Extract deeper logic into private methods.
- Use early returns (guard clauses) to reduce nesting.
- Prefer `Array.map`/`filter`/`reduce` over nested `for` loops where readability is preserved.
