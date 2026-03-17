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
├── package.json
├── tsconfig.json
├── tsconfig.node.json
├── vite.config.ts
├── eslint.config.ts
├── .prettierrc
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

### Node.js Application

```text
project-name/
├── package.json
├── tsconfig.json
├── vite.config.ts
├── eslint.config.ts
├── .prettierrc
├── src/
│   ├── main.ts                # Entry point (CLI or server bootstrap)
│   ├── cli.ts                 # Argument parsing (CLI projects)
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

Use a structured logger library (pino or winston). Configure at the application entry point. Instantiate per-module loggers with context.

## Nesting and Extraction

- Max 3 levels of nesting.
- Extract deeper logic into private methods.
- Use early returns (guard clauses) to reduce nesting.
- Prefer `Array.map`/`filter`/`reduce` over nested `for` loops where readability is preserved.
