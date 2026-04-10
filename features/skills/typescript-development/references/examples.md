# TypeScript Examples

## One-Off: Filter and Map

**Scenario:** Extract unique domain names from a list of email addresses

```typescript
const domains = [
  ...new Set(
    emails
      .filter((e: string) => e.includes("@"))
      .map((e: string) => e.split("@")[1]),
  ),
].sort();
```

## One-Off: Typed Utility Function

**Scenario:** Create a debounce function

```typescript
const debounce = <T extends (...args: unknown[]) => void>(
  fn: T,
  ms: number,
): ((...args: Parameters<T>) => void) => {
  let timer: ReturnType<typeof setTimeout>;
  return (...args: Parameters<T>): void => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), ms);
  };
};
```

## One-Off: Fetch with Type Safety

**Scenario:** Fetch JSON data with typed response

```typescript
const fetchJson = async <T>(url: string): Promise<T> => {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
  return res.json() as Promise<T>;
};
```

## Full Project (Skeleton)

Use the full project skeleton in [templates.md](templates.md) as the baseline. Place business logic in classes under `src/services/` and `src/models/`, tests under `tests/`, and configure building and tooling in the root config files.

## Full Project (Refactor Example)

### Before (Procedural)

```typescript
const API_URL = "https://api.example.com";

async function getUsers() {
  const response = await fetch(`${API_URL}/users`);
  const data = await response.json();
  const activeUsers = [];
  for (const user of data) {
    if (user.active) {
      console.log(`Found active user: ${user.name}`);
      activeUsers.push(user);
    }
  }
  console.log(`Total active: ${activeUsers.length}`);
  return activeUsers;
}

async function deactivateUser(id: any) {
  const response = await fetch(`${API_URL}/users/${id}`, {
    method: "PATCH",
    body: JSON.stringify({ active: false }),
    headers: { "Content-Type": "application/json" },
  });
  if (!response.ok) {
    console.log("Failed to deactivate");
  }
  return response.json();
}
```

### After (Refactored)

#### src/errors.ts

```typescript
abstract class AppError extends Error {
  abstract readonly code: string;

  constructor(message: string, options?: ErrorOptions) {
    super(message, options);
    this.name = this.constructor.name;
  }
}

class ValidationError extends AppError {
  readonly code = "VALIDATION_ERROR";
  readonly field: string;

  constructor(field: string, message: string) {
    super(`Validation failed for '${field}': ${message}`);
    this.field = field;
  }
}

class ApiError extends AppError {
  readonly code = "API_ERROR";
  readonly statusCode: number;
  readonly endpoint: string;

  constructor(endpoint: string, statusCode: number, message: string) {
    super(`API request to ${endpoint} failed (${statusCode}): ${message}`);
    this.statusCode = statusCode;
    this.endpoint = endpoint;
  }
}

export { ApiError, AppError, ValidationError };
```

#### src/types.ts

```typescript
interface Logger {
  debug(message: string, data?: Record<string, unknown>): void;
  info(message: string, data?: Record<string, unknown>): void;
  warn(message: string, data?: Record<string, unknown>): void;
  error(message: string, error?: Error, data?: Record<string, unknown>): void;
}

interface User {
  readonly id: string;
  readonly name: string;
  readonly email: string;
  readonly active: boolean;
}

interface UserUpdate {
  readonly active?: boolean;
}

export type { Logger, User, UserUpdate };
```

#### src/services/api-client.ts

```typescript
import { ApiError } from "../errors.ts";
import type { Logger } from "../types.ts";

interface ApiClientConfig {
  readonly baseUrl: string;
  readonly timeout: number;
}

/**
 * HTTP client for communicating with REST APIs.
 *
 * @remarks
 * Wraps the Fetch API with typed request/response handling,
 * error normalization, and structured logging.
 */
class ApiClient {
  private readonly config: ApiClientConfig;
  private readonly logger: Logger;

  constructor(config: ApiClientConfig, logger: Logger) {
    if (!config.baseUrl) {
      throw new ValidationError("baseUrl", "API base URL is required");
    }
    this.config = config;
    this.logger = logger;
  }

  /**
   * Sends a GET request and returns typed JSON response.
   *
   * @param path - API endpoint path (appended to base URL).
   * @returns Parsed response body.
   * @throws {@link ApiError} If the response status is not OK.
   */
  async get<T>(path: string): Promise<T> {
    return this.request<T>("GET", path);
  }

  /**
   * Sends a PATCH request with a JSON body.
   *
   * @param path - API endpoint path.
   * @param body - Request body to serialize as JSON.
   * @returns Parsed response body.
   * @throws {@link ApiError} If the response status is not OK.
   */
  async patch<T>(path: string, body: unknown): Promise<T> {
    return this.request<T>("PATCH", path, body);
  }

  private async request<T>(
    method: string,
    path: string,
    body?: unknown,
  ): Promise<T> {
    const url = `${this.config.baseUrl}${path}`;
    this.logger.debug(`${method} ${url}`);

    const response = await fetch(url, {
      method,
      headers: { "Content-Type": "application/json" },
      body: body !== undefined ? JSON.stringify(body) : undefined,
      signal: AbortSignal.timeout(this.config.timeout),
    });

    if (!response.ok) {
      throw new ApiError(path, response.status, response.statusText);
    }

    return response.json() as Promise<T>;
  }
}

export { ApiClient };
export type { ApiClientConfig };
```

#### src/services/user-service.ts

```typescript
import { ValidationError } from "../errors.ts";
import type { Logger, User, UserUpdate } from "../types.ts";
import type { ApiClient } from "./api-client.ts";

/**
 * Manages user retrieval and status updates.
 *
 * @remarks
 * Depends on {@link ApiClient} for HTTP communication.
 */
class UserService {
  private readonly apiClient: ApiClient;
  private readonly logger: Logger;

  constructor(apiClient: ApiClient, logger: Logger) {
    if (!apiClient) {
      throw new ValidationError("apiClient", "ApiClient is required");
    }
    this.apiClient = apiClient;
    this.logger = logger;
  }

  /**
   * Retrieves all active users.
   *
   * @returns List of users where `active` is `true`.
   */
  async getActiveUsers(): Promise<readonly User[]> {
    const users = await this.apiClient.get<User[]>("/users");
    const activeUsers = users.filter((user) => user.active);
    this.logger.info("Retrieved active users", { count: activeUsers.length });
    return activeUsers;
  }

  /**
   * Deactivates a user by ID.
   *
   * @param userId - The ID of the user to deactivate.
   * @returns The updated user record.
   * @throws {@link ValidationError} If `userId` is empty.
   */
  async deactivateUser(userId: string): Promise<User> {
    if (!userId || userId.trim().length === 0) {
      throw new ValidationError("userId", "User ID is required");
    }

    const update: UserUpdate = { active: false };
    const updatedUser = await this.apiClient.patch<User>(
      `/users/${userId}`,
      update,
    );
    this.logger.info("Deactivated user", { userId });
    return updatedUser;
  }
}

export { UserService };
```

#### tests/services/user-service.test.ts

```typescript
import { describe, expect, it, vi } from "vitest";
import { ValidationError } from "../../src/errors.ts";
import type { Logger, User } from "../../src/types.ts";
import { UserService } from "../../src/services/user-service.ts";
import type { ApiClient } from "../../src/services/api-client.ts";

function createMockLogger(): Logger {
  return {
    debug: vi.fn(),
    info: vi.fn(),
    warn: vi.fn(),
    error: vi.fn(),
  };
}

function createMockApiClient(overrides?: Partial<ApiClient>): ApiClient {
  return {
    get: vi.fn(),
    patch: vi.fn(),
    ...overrides,
  } as unknown as ApiClient;
}

const activeUser: User = {
  id: "1",
  name: "Alice",
  email: "alice@example.com",
  active: true,
};
const inactiveUser: User = {
  id: "2",
  name: "Bob",
  email: "bob@example.com",
  active: false,
};

describe("UserService", () => {
  describe("getActiveUsers", () => {
    it("returns_only_active_users", async () => {
      const apiClient = createMockApiClient({
        get: vi.fn().mockResolvedValue([activeUser, inactiveUser]),
      });
      const service = new UserService(apiClient, createMockLogger());

      const result = await service.getActiveUsers();

      expect(result, "Should return only active users").toHaveLength(1);
      expect(result[0]?.id).toBe("1");
    });

    it("returns_empty_array_when_no_active_users", async () => {
      const apiClient = createMockApiClient({
        get: vi.fn().mockResolvedValue([inactiveUser]),
      });
      const service = new UserService(apiClient, createMockLogger());

      const result = await service.getActiveUsers();

      expect(result, "Should return empty array").toHaveLength(0);
    });
  });

  describe("deactivateUser", () => {
    it("deactivates_user_with_valid_id", async () => {
      const deactivated: User = { ...activeUser, active: false };
      const apiClient = createMockApiClient({
        patch: vi.fn().mockResolvedValue(deactivated),
      });
      const service = new UserService(apiClient, createMockLogger());

      const result = await service.deactivateUser("1");

      expect(result.active, "User should be deactivated").toBe(false);
    });

    it("rejects_empty_userId", async () => {
      const service = new UserService(
        createMockApiClient(),
        createMockLogger(),
      );

      await expect(service.deactivateUser("")).rejects.toThrow(ValidationError);
    });

    it("rejects_whitespace_userId", async () => {
      const service = new UserService(
        createMockApiClient(),
        createMockLogger(),
      );

      await expect(service.deactivateUser("   ")).rejects.toThrow(
        ValidationError,
      );
    });
  });
});
```

## Full Project (CLI Refactor Example)

### Before (Monolithic Script)

```typescript
import { readFileSync, writeFileSync } from "node:fs";

const args = process.argv.slice(2);
const inputFile = args[0];
if (!inputFile) {
  console.log("Error: no input file");
  process.exit(1);
}

const data = JSON.parse(readFileSync(inputFile, "utf-8"));
const results = [];
for (const item of data) {
  if (item.status === "active") {
    results.push({ id: item.id, name: item.name.toUpperCase() });
  }
}

console.log(JSON.stringify(results, null, 2));
```

**Problems:** No type safety, `console.log` for both output and errors,
argument parsing not testable, business logic mixed with I/O, no error
handling.

### After (Refactored CLI)

#### src/errors.ts (CLI)

```typescript
abstract class AppError extends Error {

```typescript
import { parseArgs } from "node:util";
import { ValidationError } from "./errors.ts";

interface CliOptions {
  readonly inputPath: string;
  readonly outputFormat: "json" | "text";
}

function parseCli(argv: string[]): CliOptions {
  const { values } = parseArgs({
    args: argv,
    options: {
      input: { type: "string", short: "i" },
      format: { type: "string", short: "f", default: "json" },
      help: { type: "boolean", short: "h" },
    },
    strict: true,
  });

  if (values.help) {
    console.error("Usage: transform --input <path> [--format json|text]");
    process.exit(0);
  }

  if (!values.input) {
    throw new ValidationError("input", "--input is required");
  }

  const format = values.format as string;
  if (format !== "json" && format !== "text") {
    throw new ValidationError("format", `invalid format: ${format}`);
  }

  return { inputPath: values.input, outputFormat: format };
}

export { parseCli };
export type { CliOptions };
```

#### src/types.ts (CLI)

```typescript
interface InputItem {
  readonly id: string;
  readonly name: string;
  readonly status: "active" | "inactive";
}

interface TransformedItem {
  readonly id: string;
  readonly name: string;
}

export type { InputItem, TransformedItem };
```

#### src/services/transformer.ts

```typescript
import type { InputItem, TransformedItem } from "../types.ts";

class Transformer {
  transform(items: readonly InputItem[]): readonly TransformedItem[] {
    return items
      .filter((item) => item.status === "active")
      .map((item) => ({
        id: item.id,
        name: item.name.toUpperCase(),
      }));
  }
}

export { Transformer };
```

#### src/main.ts

```typescript
#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { parseCli } from "./cli.ts";
import { Transformer } from "./services/transformer.ts";
import { AppError } from "./errors.ts";
import type { InputItem } from "./types.ts";

async function main(argv: string[]): Promise<number> {
  const options = parseCli(argv);

  const raw = readFileSync(options.inputPath, "utf-8");
  const items = JSON.parse(raw) as InputItem[];

  const transformer = new Transformer();
  const results = transformer.transform(items);

  if (options.outputFormat === "json") {
    process.stdout.write(JSON.stringify(results, null, 2) + "\n");
  } else {
    for (const item of results) {
      process.stdout.write(`${item.id}\t${item.name}\n`);
    }
  }

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

#### tests/cli.test.ts

```typescript
import { describe, expect, it } from "vitest";
import { parseCli } from "../src/cli.ts";
import { ValidationError } from "../src/errors.ts";

describe("parseCli", () => {
  it("parses valid arguments", () => {
    const options = parseCli(["--input", "data.json"]);
    expect(options).toEqual({
      inputPath: "data.json",
      outputFormat: "json",
    });
  });

  it("throws for missing input", () => {
    expect(() => parseCli([])).toThrow(ValidationError);
  });
});
```

#### tests/services/transformer.test.ts

```typescript
import { describe, expect, it } from "vitest";
import { Transformer } from "../../src/services/transformer.ts";
import type { InputItem } from "../../src/types.ts";

describe("Transformer", () => {
  const transformer = new Transformer();

  it("transforms active items", () => {
    const items: InputItem[] = [
      { id: "1", name: "alice", status: "active" },
      { id: "2", name: "bob", status: "inactive" },
    ];
    const result = transformer.transform(items);
    expect(result).toEqual([{ id: "1", name: "ALICE" }]);
  });

  it("returns empty array for no active items", () => {
    const items: InputItem[] = [{ id: "1", name: "alice", status: "inactive" }];
    expect(transformer.transform(items)).toHaveLength(0);
  });
});
```
