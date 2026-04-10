# TypeScript Scripting Modes

## Mode Selection Rules

Use these rules when the user does not explicitly choose a mode:

- OneOff: User asks for a snippet, quick function, inline solution, or REPL expression.
- FullProject: User asks for an application, library, reusable tool, or multi-file project.
- Default: If ambiguous, use FullProject.

## Use-Case Selection Rules

When FullProject mode is selected, determine the use case:

- **Browser:** Web frontend, browser utility, or DOM-based application.
- **Server:** Web server, API, HTTP service, or backend with long-running process.
- **CLI:** Command-line tool, script, agent skill utility, or data processor.
- Default: If the target is Node.js and ambiguous, use CLI.

## Mode Summary

| Mode        | When to Use                         | Output         | Core Expectations                                 |
| ----------- | ----------------------------------- | -------------- | ------------------------------------------------- |
| FullProject | Compiled application or library     | Directory tree | OOP, strict typing, Biome, Vitest, TSDoc          |
| OneOff      | Ad-hoc snippet, immediate execution | Inline snippet | Short, typed, modern syntax, no scaffolding       |

## Use-Case Tooling Matrix

| Concern     | Browser              | Server              | CLI                  |
| ----------- | -------------------- | ------------------- | -------------------- |
| Build       | Vite                 | tsc                 | tsc                  |
| Dev run     | `vite`               | `tsx --watch`       | `tsx`                |
| Lint+Format | Biome                | Biome               | Biome                |
| Test        | Vitest (jsdom)       | Vitest (node)       | Vitest (node)        |
| Test config | vite.config.ts       | vitest.config.ts    | vitest.config.ts     |
| Logger      | Custom console class | pino                | stderr / pino        |
| Entry point | src/main.ts          | src/main.ts         | src/main.ts          |
| CLI parsing | N/A                  | N/A                 | src/cli.ts           |

## OneOff Guardrails

- 1-10 lines preferred, max 20 lines
- No classes, TSDoc blocks, or project scaffolding
- Use arrow functions, template literals, and modern syntax
- Type annotations on all function definitions
- No imports beyond stdlib/platform APIs unless the user's context already includes the dependency

## FullProject Guardrails

- Directory structure with package.json, tsconfig.json, biome.json,
  .node-version, src/, tests/
- All business logic in classes
- Strict typing on all signatures (`strict: true` in tsconfig.json)
- Guard clauses at constructor and method entry
- Specific error classes extending `AppError`; no generic `Error` throws
- Named exports only; no default exports
- `as const` objects or union types instead of `enum`
- TSDoc on all public classes, methods, and interfaces
- Vitest tests in tests/ directory
- After generation: run `pnpm install`, `pnpm run build`, `pnpm run lint`,
  `pnpm run test`
