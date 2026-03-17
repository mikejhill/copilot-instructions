# TypeScript Scripting Modes

## Mode Selection Rules

Use these rules when the user does not explicitly choose a mode:

- OneOff: User asks for a snippet, quick function, inline solution, or REPL expression.
- FullProject: User asks for an application, library, reusable tool, or multi-file project.
- Default: If ambiguous, use FullProject.

## Mode Summary

| Mode        | When to Use                         | Output         | Core Expectations                                         |
| ----------- | ----------------------------------- | -------------- | --------------------------------------------------------- |
| FullProject | Compiled application or library     | Directory tree | OOP, strict typing, Vite, Vitest, ESLint, Prettier, TSDoc |
| OneOff      | Ad-hoc snippet, immediate execution | Inline snippet | Short, typed, modern syntax, no scaffolding               |

## OneOff Guardrails

- 1-10 lines preferred, max 20 lines
- No classes, TSDoc blocks, or project scaffolding
- Use arrow functions, template literals, and modern syntax
- Type annotations on all function definitions
- No imports beyond stdlib/platform APIs unless the user's context already includes the dependency

## FullProject Guardrails

- Directory structure with package.json, tsconfig.json, src/, tests/
- All business logic in classes
- Strict typing on all signatures (`strict: true` in tsconfig.json)
- Guard clauses at constructor and method entry
- Specific error classes extending `AppError`; no generic `Error` throws
- Named exports only; no default exports
- `as const` objects or union types instead of `enum`
- TSDoc on all public classes, methods, and interfaces
- Vitest tests in tests/ directory
- After generation: run `pnpm install`, `pnpm run build`, `pnpm run lint`, `pnpm run test`
