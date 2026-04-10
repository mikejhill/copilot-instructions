---
name: typescript-development
description: "Use when creating, modifying, or refactoring TypeScript projects for browser frontends, Node.js servers, or Node.js CLI tools. Enforces OOP architecture, strict typing, Biome linting/formatting, Vitest testing, structured error handling, TSDoc documentation, and kebab-case file naming conventions."
---

# TypeScript Development

## Objective

Produce TypeScript solutions in two modes: full projects for compiled browser
frontends, Node.js servers, or Node.js CLI tools, and one-offs for ad-hoc
execution. Full projects must be OOP-first, strictly typed, tested, and built
with the appropriate toolchain for the target use case; one-offs must be short
and self-contained.

## Scope

**In-scope:**

- New TypeScript projects, modules, and classes
- Refactors of existing TypeScript code
- One-off snippets
- OOP design with strict typing
- Project structure with src-layout
- Build configuration (Vite for browser, tsc for Node.js)
- pnpm dependency management with Corepack
- Vitest-based testing
- Biome linting and formatting
- Browser frontend projects
- Node.js server projects
- Node.js CLI tools (including agent skill CLIs)

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
- Target use case: Browser, Server, or CLI
- New development or refactor

**Optional inputs:**

- Mode selection override
- Existing patterns to mirror
- Domain context (DOM, API, data processing, CLI)
- Performance constraints
- Node.js version constraints (default: 22 LTS)
- Linting alternative (ESLint + Prettier instead of Biome)

**Assumptions:**

- TypeScript 5.x with strict mode
- pnpm as package manager (version pinned via Corepack)
- Biome for linting and formatting (ESLint + Prettier as alternative)
- fnm for Node.js version management (reads `.node-version`)
- Node.js 22 LTS unless specified
- Build tool determined by use case:
  - Browser: Vite (bundling + dev server)
  - Server / CLI: tsc (compilation), tsx (development execution)

## Outputs

**Format:**

- FullProject: directory tree with package.json, tsconfig.json, src/, tests/
- OneOff: snippet (1-10 lines preferred, max 20 lines)

**Full Project Structure:**

1. package.json with project metadata, scripts, dependencies, Corepack
   `packageManager` field, and `engines` constraint
2. tsconfig.json with strict compiler options
3. biome.json with lint and format configuration
4. .node-version pinning the Node.js runtime version (consumed by fnm)
5. src/ with entry point, classes, and modules
6. tests/ with Vitest test files
7. Type annotations on all signatures
8. Additional per use case:
   - Browser: vite.config.ts, index.html
   - Server: vitest.config.ts
   - CLI: vitest.config.ts, src/cli.ts for argument parsing

**Files produced:**

- FullProject: complete directory tree (see [references/templates.md](references/templates.md))
- OneOff: no file unless requested

**Formatting requirements (FullProject):**

- Formatting enforced by Biome (do not specify manually)
- Import ordering enforced by Biome `organizeImports`
- Naming conventions: see [references/standards.md](references/standards.md)
- Guard clauses at method entry (instruction-only; not enforceable by tooling)
- Max 3 levels of nesting (instruction-only; not enforceable by tooling)

## Constraints

**Conflict resolution:** User requirements override defaults unless they violate safety or explicit MUST rules.

**Mode selection rules:**

- OneOff when user asks for a snippet, quick function, or inline solution
- FullProject when user asks for an application, reusable library, or multi-file project
- Default to FullProject when ambiguous

**Use-case selection rules:**

- Browser when building a web frontend or browser utility
- Server when building a web server, API, or backend service
- CLI when building a command-line tool, script, or agent skill utility
- Default to CLI when ambiguous for Node.js projects

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
- Pass `pnpm biome check .` with zero violations
- Include Biome and Vitest in `devDependencies`

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
2. Determine use case (Browser, Server, or CLI).
3. FullProject: scaffold directory structure per use case, then populate
   tsconfig.json, package.json, biome.json, source files, and tests. Add
   vite.config.ts for Browser or vitest.config.ts for Server/CLI.
4. OneOff: write the minimal typed snippet within line limits.
5. Apply typing, guard clauses, error handling, naming conventions, and
   documentation.
6. CLI projects: apply patterns from
   [references/cli-patterns.md](references/cli-patterns.md) — testable
   argument parsing, two-layer validation, structured output.
7. FullProject post-generation: run `pnpm install`, `pnpm run build`,
   `pnpm run lint`, `pnpm run test`.

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
- `pnpm biome check .` reports zero violations
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
