---
name: typescript-development
description: "Use when creating, modifying, or refactoring TypeScript projects for browser frontends or Node.js applications. Enforces OOP architecture, strict typing, Vite-based builds, Vitest testing, structured error handling, TSDoc documentation, and kebab-case file naming conventions."
---

# TypeScript Development

## Objective

Produce TypeScript solutions in two modes: full projects for compiled browser frontends or Node.js applications and one-offs for ad-hoc execution. Full projects must be OOP-first, strictly typed, tested, and built with Vite; one-offs must be short and self-contained.

## Scope

**In-scope:**

- New TypeScript projects, modules, and classes
- Refactors of existing TypeScript code
- One-off snippets
- OOP design with strict typing
- Project structure with src-layout
- Vite build configuration
- pnpm dependency management
- Vitest-based testing
- ESLint and Prettier configuration
- Browser frontend projects (primary)
- Node.js applications (secondary)

**Out-of-scope:**

- Framework-specific architecture (React, Angular, Vue component hierarchies)
- GraphQL schema design
- Database ORM configuration
- Docker or deployment configuration
- Monorepo tooling (Nx, Turborepo)
- Deno or Bun runtimes
- CSS/SCSS architecture

## Inputs

**Required inputs:**

- Purpose and functional requirements
- Target output form: FullProject or OneOff
- Target runtime: Browser or Node
- New development or refactor

**Optional inputs:**

- Mode selection override
- Existing patterns to mirror
- Domain context (DOM, API, data processing)
- Performance constraints
- Node.js version constraints (default: 22 LTS)

**Assumptions:**

- TypeScript 5.x with strict mode
- pnpm as package manager
- Vite as build tool / dev server
- ESLint + Prettier for linting and formatting
- Node.js 22 LTS unless specified

## Outputs

**Format:**

- FullProject: directory tree with package.json, tsconfig.json, src/, tests/
- OneOff: snippet (1-10 lines preferred, max 20 lines)

**Full Project Structure:**

1. package.json with project metadata, scripts, and dependencies
2. tsconfig.json with strict compiler options
3. vite.config.ts with build configuration
4. eslint.config.ts with linting rules
5. .prettierrc with formatting rules
6. src/ with entry point, classes, and modules
7. tests/ with Vitest test files
8. Type annotations on all signatures

**Files produced:**

- FullProject: complete directory tree (see [references/templates.md](references/templates.md))
- OneOff: no file unless requested

**Formatting requirements (FullProject):**

- Formatting enforced by Prettier (do not specify manually)
- Import ordering enforced by ESLint `perfectionist/sort-imports` rule
- Naming conventions: see [references/standards.md](references/standards.md)
- Guard clauses at method entry (instruction-only; not enforceable by tooling)
- Max 3 levels of nesting (instruction-only; not enforceable by tooling)

## Constraints

**Conflict resolution:** User requirements override defaults unless they violate safety or explicit MUST rules.

**Mode selection rules:**

- OneOff when user asks for a snippet, quick function, or inline solution
- FullProject when user asks for an application, reusable library, or multi-file project
- Default to FullProject when ambiguous

**Global MUST:**

- Choose FullProject or OneOff and follow the mode rules
- Use strict typing on all function and method signatures
- Enable `strict: true` in tsconfig.json
- Use ESM (`import`/`export`) exclusively; no CommonJS (`require`)

**Global MUST NOT:**

- Use `any` type unless interfacing with untyped third-party code (use `unknown` and narrow instead)
- Use `console.log` for diagnostics in production code (use a structured logger)
- Use `var` declarations (use `const` by default, `let` only when reassignment is required)
- Use non-null assertion operator (`!`) without a code comment justifying it
- Reimplement standard library or platform functionality
- Use default exports (use named exports exclusively)
- Use `enum` (use `as const` objects or union types instead)

**FullProject MUST:**

- Encapsulate all business logic in classes
- Use `private` and `readonly` modifiers to enforce encapsulation
- Use interfaces for public contracts and dependency injection
- Use abstract classes when sharing implementation across a hierarchy
- Use `readonly` on all properties that are not reassigned after construction
- Validate all constructor parameters with guard clauses
- Use specific error classes extending a base application error
- Include Vitest tests in tests/ directory
- Organize tests into `describe` blocks mirroring source classes
- Test happy paths, error paths, and edge cases for every public method
- Use `it.each` or `describe.each` for data-driven tests with 3+ input variations
- Define all configuration as typed objects (no loose string keys)
- Document all public classes, methods, and interfaces with TSDoc
- Keep module-level code limited to imports, constants, and class/function definitions
- Pass `tsc --noEmit` with zero errors
- Pass `eslint .` with zero violations
- Pass `prettier --check .` with zero violations
- Include ESLint, Prettier, and Vitest in `devDependencies`

**FullProject MUST NOT:**

- Hard-code environment-specific values (URLs, ports, paths) outside configuration
- Place business logic outside classes
- Use module-level mutable state
- Catch and suppress exceptions silently
- Mix argument parsing or I/O handling with business logic
- Use `// @ts-ignore` or `// @ts-expect-error` without a specific justification comment

**OneOff MUST:**

- Prefer 1-10 lines, maximum 20 lines
- Skip classes, TSDoc blocks, and project scaffolding
- Use arrow functions and modern syntax
- Use type annotations on any function definitions

**OneOff MUST NOT:**

- Create a full project scaffold
- Add long-form documentation

## Procedure

1. Select mode using the mode rules.
2. Determine runtime target (Browser or Node).
3. FullProject: scaffold directory structure, then populate tsconfig.json, package.json, vite.config.ts, ESLint config, source files, and tests.
4. OneOff: write the minimal typed snippet within line limits.
5. Apply typing, guard clauses, error handling, naming conventions, and documentation.
6. FullProject post-generation: run `pnpm install`, `pnpm run build`, `pnpm run lint`, `pnpm run test`.

## Validation

**Pass conditions (FullProject):**

- Structure matches the Full Project Structure list
- All public classes, methods, and interfaces have TSDoc documentation
- All signatures are strictly typed; no implicit `any`
- `strict: true` is enabled in tsconfig.json
- Guard clauses validate constructor and method preconditions
- Error classes extend a base application error
- Tests cover success paths, error paths, and boundary values
- `tsc --noEmit` reports zero errors
- `eslint .` reports zero violations
- `prettier --check .` reports zero violations
- `vitest run` passes with zero failures
- Max nesting depth is 3

**Pass conditions (OneOff):**

- Line count within limits
- Type annotations present on all function signatures
- No project scaffolding or documentation blocks
- Uses modern TypeScript syntax (const, arrow functions, template literals)

**Failure modes:**

- `any` type used without justification
- Public method or class missing TSDoc
- Business logic placed outside a class
- Default export used
- `enum` used instead of `as const` or union type
- Test file missing for a source module
- Error caught and suppressed without re-throw or specific handling
