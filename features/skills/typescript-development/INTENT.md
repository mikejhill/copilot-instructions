# Intent

Codify TypeScript development standards for browser UIs, Node.js servers, and Node.js CLI tools using a fast, modern toolchain.

## Goals

1. Every rule enforceable by tooling or verifiable by inspection
2. Three use-case profiles: Browser UI, Node.js Server, Node.js CLI — each with appropriate tooling and templates
3. Two modes: OneOff (inline snippet) and FullProject (compiled application)
4. Fast, unified toolchain: pnpm for packages, Biome for lint/format, tsc for type checking, Vitest for tests, tsx for Node.js development execution, fnm for Node.js version management
5. Templates are copy-paste ready with no placeholders requiring judgment
6. Parity with python-scripting skill for CLI development effectiveness — testable argument parsing, two-layer validation, structured logging, entry point architecture
7. ESLint + Prettier documented as alternative for framework-heavy browser projects requiring deep plugin ecosystems

## Decisions

- **Biome over ESLint + Prettier (default):** Biome provides unified lint+format in one Rust-based tool (10-25x faster). Type-aware rules cover ~75% of typescript-eslint strictTypeChecked; tsc --noEmit compensates for the gap. For Node.js CLIs, the combination is sufficient. ESLint + Prettier remains the better choice when framework-specific plugins (a11y, security, React/Vue) are needed.
- **tsx over vite-node for Node.js:** Zero-config, esbuild-powered, 100% Node.js compatible. Vite-node is overkill for CLI/server dev (requires vite.config.ts, SSR-oriented). Bun is faster but ~95-98% npm compatibility is a portability risk for agent environments.
- **tsc for Node.js builds, Vite for browser builds:** Node.js projects don't need bundling — tsc compilation to dist/ is sufficient. Vite remains for browser projects that need asset bundling and dev server.
- **fnm for Node.js version management:** fnm (Fast Node Manager) is a Rust-based version manager that reads `.node-version` and auto-switches on `cd`. Cross-platform (Windows, macOS, Linux). Chosen over Volta (doesn't read `.node-version`, uses its own `package.json` field) and nvm (slow, no native Windows). Analogous to pyenv for `.python-version`.
- **pnpm with Corepack:** pnpm is the TypeScript analog to uv — content-addressable store, strict dependency resolution, committed lockfile. Corepack pins the pnpm version via packageManager field.

## Log

- 2026-04-10: Enhancement plan — adopt Biome, tsx, use-case profiles, CLI patterns; bring skill to parity with python-scripting for agent CLI development
- 2026-04-10: Add fnm as recommended Node.js version manager — completes the `.node-version` story with an actual consumer
