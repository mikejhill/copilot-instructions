---
name: writing-ai-instructions
description: Use when authoring instruction sets for agents, skills, prompts, or custom instruction files. Produces enforceable, unambiguous instructions through 8-section template, conflict resolution clause, personas, and comprehensive examples.
---

# The Discipline of AI-Oriented Instruction Writing

## Overview

Instructions that work are concrete, specific, and demonstrate expected behavior. An effective instruction set contains eight sections that together force precision: an objective, scope, inputs, outputs, constraints, procedure, validation, and examples with personas.

**What makes instructions work for models:**

- **Precision over flexibility.** Vague language fails. Models execute literally; ambiguity creates variance.
- **Examples over explanation.** Showing is more powerful than telling. One complete example teaches format, edge cases, and expectations better than paragraphs of description.
- **Personas over generic competence.** When the task requires a specific viewpoint, a persona anchors the reasoning. Security reviews, performance optimization, and compliance checks each benefit from a defined perspective.
- **Constraints as boundaries.** Stating what you MUST NOT do and what you MUST do creates guardrails. Optional behavior uses MAY.

An instruction set follows this path: objective → scope → inputs → outputs → constraints → procedure → validation → examples. This order forces logical thinking. Skip any step and instructions become incomplete.

## Writing Effective Language for Models

Models are literal executors. The language you use determines whether they follow your intent or guess.

### Commands, Not Suggestions

- **Use:** "Validate each input before processing."
- **Avoid:** "You should probably validate inputs."
- **Use:** "Do not modify the original file."
- **Avoid:** "Try to avoid modifying the original file."

Models execute commands. Suggestions are optional. Use imperative verbs: validate, generate, extract, verify, compute.

### Eliminate Vagueness

Models cannot reason about vague criteria. Replace soft language with concrete thresholds.

- **Vague:** "Make the output efficient."
- **Concrete:** "Output must process 10,000 items in under 5 seconds."
- **Vague:** "Provide a reasonable explanation."
- **Concrete:** "Explain the decision with: threat type, CVSS score, mitigation step."

Banned words: "appropriate," "nice," "robust," "good," "reasonable," "consider," "might," "likely." Use measurable criteria instead.

### Lists Over Prose

Prose buries requirements. Lists expose them.

- **Prose:** "The system should handle errors gracefully, logging them appropriately and returning a user-friendly message."
- **Lists:**
  - Log all errors to stderr with timestamp and stack trace.
  - Return HTTP 400 with JSON: `{"error": "invalid_input", "details": "[field name]: [reason]"}`
  - Do not expose internal paths or system details in error messages.

### Explicit Decision Points

When behavior changes based on input, state the condition and action as if/then rules.

- **Weak:** "Update the config if needed."
- **Explicit:** "If existing config contains database URL, reuse it. If not, ask for database URL before proceeding."

## Procedure: Eight-Section Template

Execute all eight steps in order. Omitting any step produces incomplete instructions.

1. **Set the objective**
   - Write exactly one sentence stating the measurable outcome.
   - The sentence must begin with a verb (e.g., "Implement…", "Generate…", "Validate…").
2. **Define scope**
   - List every explicit in-scope item (what IS included).
   - List every explicit out-of-scope item (what IS NOT included).
   - Default scope to nothing; add only what you explicitly allow.
3. **List inputs**
   - Enumerate required inputs with type and format.
   - Enumerate optional inputs and describe their effect.
   - State all assumptions about the environment or prior state.
4. **Specify outputs**
   - Prescribe exact output format (JSON, Markdown, file path, etc.).
   - Name every file or artifact produced.
   - Include formatting rules (line length, indentation, naming conventions).
5. **State constraints**
   - Declare safety and security constraints.
   - Declare style, tone, and formatting constraints.
   - Declare tool usage, time, and resource constraints.
   - Use "MUST" and "MUST NOT" for rules; use "MAY" for options.
6. **Write the procedure**
   - Number every step sequentially.
   - Include decision points as explicit if/then rules.
   - Avoid "consider" or "think about"; instead, command action.
7. **Define validation**
   - Specify exactly how to verify correctness.
   - Include both pass conditions and failure handling.
   - Name what fails the validation.
8. **Add examples and personas**
   - Include a persona if the task requires a specific worldview or decision-making framework.
   - Provide minimum one example per input variation.
   - Examples show realistic, complete input and output.

## Language Rules for Instructions

- **Write in imperative voice.** Command action. Do not suggest, recommend, or propose.
- **Eliminate vague language entirely.** Replace "robust," "appropriate," "nice," "good," and "reasonable" with concrete criteria.
- **Define conflicts explicitly.** State rule priority: "If X and Y conflict, Y takes precedence."
- **Specify every edge case.** Do not assume the reader will infer behavior for "unusual" inputs.
- **Prohibit undesired behavior by name.** Use "Do not X" instead of "Avoid X."
- **Bind outputs to exact formats.** JSON structure, Markdown heading levels, file paths—be specific.
- **Use lists, not prose.** Prose hides requirements; lists expose them.
- **Mark non-negotiable rules with MUST/MUST NOT.** Mark optional behavior with MAY.
- **Use identical terminology throughout.** Define a term once, then use only that term.

## Personas: Shaping Agent Perspective

**Include a persona whenever the agent's worldview, decision-making framework, or approach to the task should differ materially.**

A persona is an identity that shapes how the agent thinks, what it prioritizes, and how it reasons about problems. It goes beyond listing responsibilities to establishing a point of view.

**Persona format:**

```markdown
Persona: [identity and background]

You are [specific identity] with [relevant experience]. You approach problems by [characteristic method]. You prioritize [what matters most] and question [what you scrutinize first].

When facing tradeoffs, you choose [decision priority]. You are skeptical of [what you distrust] but trust [what you rely on].
```

**When to include:**

- The task requires a specific lens or expertise (security first, performance-aware, compliance-driven)
- The persona questions different assumptions than a generic agent would
- Different personas would make different tradeoff decisions on the same problem

**When to exclude:**

- The task is independent of perspective or expertise
- The persona would only change communication style, not reasoning
- Generic competence is sufficient (no specialized worldview needed)

**Example:**

Persona: Security-first backend architect with 12 years defending OAuth implementations

You are paranoid about token leakage and assume every storage mechanism is under attack until proven otherwise. You approach all design decisions by asking "How is this encrypted at rest, in transit, and when logged?" before considering performance or convenience.

When facing tradeoffs, you choose security hardening over feature velocity. You are skeptical of "we can fix it later" but trust principle-of-least-privilege designs. You demand explicit justification for any decision that touches credentials.

## In-Context Learning Through Examples (Zero/One/Few-Shot Prompting)

Examples teach the agent through demonstration. This is in-context learning (ICL)—showing patterns directly in the prompt so the agent learns from them without retraining.

**Always use examples.** The number and depth of examples determine how precisely the agent follows your task. Select the right "shot" strategy for your task complexity.

### Zero-Shot Prompting (No Examples)

Use zero-shot when the task is unambiguous and relies on the agent's pre-trained knowledge.

**Appropriate for:**

- Simple, well-defined tasks (classification with clear criteria, basic arithmetic, straightforward retrieval)
- Tasks the agent has frequently encountered during training
- When you have strict context budget constraints

**Risk:** The agent guesses at format, edge cases, and subtle requirements.

**Example (zero-shot):**

Instruction: Classify this review sentiment as positive, negative, or neutral.

Review: "The product works as advertised."

Expected output: positive

### One-Shot Prompting (Single Example)

Use one-shot to anchor the agent's understanding of your specific task format and style.

**Appropriate for:**

- Tasks requiring specific output format (JSON, Markdown, structured list)
- Basic classification or extraction where one example clarifies the pattern
- When the agent struggles with ambiguity but task complexity is low
- When you need to lock down output style without bloating the prompt

**Effect:** One example dramatically improves format adherence over zero-shot.

**Example (one-shot):**

Instruction: Classify review sentiment as positive, negative, or neutral.

Example:

- Review: "The product broke immediately."
- Sentiment: negative

Now classify:

- Review: "The product works as advertised."
- Sentiment: ?

### Few-Shot Prompting (2-5+ Examples)

Use few-shot to establish patterns, demonstrate edge cases, and ensure consistency across varied inputs.

**Appropriate for:**

- Complex tasks with multiple input variations
- Tasks requiring precise format adherence (JSON structure, specific field order, exact naming)
- Situations where different inputs need different handling
- When you need the agent to generalize from patterns
- Structured information extraction or multi-step transformations

**Effect:** More examples tighten format control and handle edge cases. Diminishing returns after 4-5 examples unless task is very complex.

**Context cost:** Each example consumes tokens. Balance thoroughness against context budget.

**Limitations:** Examples can cause overfitting to shown patterns, especially if examples are too similar or unrepresentative.

**Example (few-shot):**

Instruction: Classify review sentiment as positive, negative, or neutral.

Examples:

- Review: "The product broke immediately." → Sentiment: negative
- Review: "Works fine, nothing special." → Sentiment: neutral
- Review: "Best purchase ever!" → Sentiment: positive
- Review: "Overpriced and slow." → Sentiment: negative

Now classify:

- Review: "The product works as advertised." → Sentiment: ?

### Format Specification with Examples

Examples define output format more reliably than prose descriptions. Use consistent input/output formatting.

**Recommended format structures:**

Short inputs/outputs (one-shot, few-shot):

```markdown
Input: [value]
Output: [value]
```

Or with labels:

```markdown
Review: "text"
Sentiment: positive
```

Longer examples (few-shot information extraction):

```markdown
INPUT:

[full input content]

OUTPUT:

[full output content]
```

JSON format specification:

```markdown
Input: "data"
Output: {"key": "value"}
```

### Choosing Your Shot Strategy

| Task Complexity             | Clarity  | Use This       | Why                                                      |
| --------------------------- | -------- | -------------- | -------------------------------------------------------- |
| Simple, well-known          | High     | Zero-shot      | No examples needed; agent knows the pattern              |
| Medium, specific format     | Medium   | One-shot       | One example locks down format expectations               |
| Complex, varied inputs      | Low      | Few-shot (2-5) | Multiple examples show pattern variations and edge cases |
| Very complex, many variants | Very low | Few-shot (5+)  | More examples handle edge cases but risk overfitting     |

Example 1: Standard GitHub OAuth flow

INPUT:

Provider: GitHub
Existing auth: Basic auth in Express middleware
Environment: staging

OUTPUT:

- Endpoints: POST /auth/oauth/github/callback, GET /auth/login/github
- Storage: Redis cache, 1-hour TTL
- Variables: GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, GITHUB_CALLBACK_URL

Example 2: Legacy app, Google OAuth, production

INPUT:

Provider: Google
Existing auth: None
Environment: production

OUTPUT:

- Endpoints: POST /auth/oauth/google/callback, GET /auth/login/google
- Storage: PostgreSQL encrypted column, no TTL (user revocation model)
- Variables: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_CALLBACK_URL
- Additional: Rate limiting (10 req/min), audit logging, encryption AES-256-GCM

Example 3: Edge case - Azure AD with existing token strategy

INPUT:

Provider: Azure AD
Existing auth: JWT bearer token in header
Environment: production

OUTPUT:

- Endpoints: POST /auth/oauth/azure/callback, GET /auth/azure/discovery
- Storage: In-memory cache with sync to Redis for multi-instance, 30-minute TTL
- Variables: AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_DISCOVERY_URL
- Additional: Require refresh token rotation, integrate with existing JWT validation

Now handle this case:

INPUT:

Provider: Okta
Existing auth: Sessions with cookies
Environment: staging

OUTPUT:

- Endpoints: POST /auth/oauth/okta/callback, GET /auth/login/okta
- Storage: In-memory cache, 30-minute TTL (staging), encrypted refresh token only
- Variables: OKTA_DOMAIN, OKTA_CLIENT_ID, OKTA_CLIENT_SECRET, OKTA_CALLBACK_URL, OKTA_DISCOVERY_URL
- Additional: Reuse existing session cookies, add logout route to clear session

## Tooling and Environment Constraints

Tooling constraints (part of Step 5: State constraints) define what the agent can and cannot do in terms of tools, files, and commands. These are non-negotiable boundaries that prevent unintended execution or modification.

**Why tooling constraints matter:**

- Models will execute commands if not explicitly forbidden.
- File modification can cause data loss or corruption if not carefully scoped.
- Tool access (APIs, libraries, external services) requires explicit authorization.
- Environment assumptions (database access, credentials, directory structure) must be stated.

**Include tooling constraints when:**

- The task involves any file I/O (read, write, delete, modify)
- The agent could execute shell commands or system operations
- Specific tools, APIs, or libraries are available or forbidden
- Credentials, API keys, or sensitive environment variables are involved
- The agent must understand the runtime environment

**Do not include if:**

- The task is pure reasoning or analysis (no tools needed)
- The agent operates in a standard, fully-available environment

**Structure tooling constraints using MUST and MUST NOT:**

```markdown
Constraints:

- MUST [action required for safety/correctness]
- MUST NOT [action strictly forbidden]
- MAY [action allowed but optional]

Examples:

- MUST NOT modify original source files; only provide diffs or new files.
- MUST NOT execute commands; provide them as copy-paste blocks.
- MUST reuse existing utility functions instead of reimplementing.
- MAY access read-only database backups.
```

**Real example from OAuth Implementation Plan:**

```markdown
Constraints:

- MUST NOT edit files; only provide code snippets and file changes.
- MUST NOT run commands; only provide shell commands that could be run.
- MUST reuse existing auth patterns in the codebase when applicable.
- MUST include security justification for token storage decisions.
- MUST specify all environment variables needed for the provider.
```

**Environment assumptions (declarative, not constraints):**

When the agent needs to know about the environment, state assumptions explicitly in the Inputs section:

```markdown
Assumptions:

- Project uses Express.js (not Django or FastAPI).
- Secrets are managed via environment variables (not config files).
- PostgreSQL or similar relational database is available.
- Runtime has Node.js 18+ installed.
- Docker is not available for deployment.
```

## Validation Checklist (Apply Before Submitting Instructions)

### Section Completeness

- [ ] Objective: Single sentence, begins with a verb, states measurable outcome.
- [ ] Scope: Explicit in-scope list and explicit out-of-scope list (not empty by default).
- [ ] Inputs: Required inputs with type/format, optional inputs with effects, all assumptions stated.
- [ ] Outputs: Exact format specified (JSON/Markdown/file path), file names and artifacts named, formatting rules included.
- [ ] Constraints: Safety, security, style, tone, tool usage, and resource constraints all declared.
- [ ] Procedure: Steps numbered sequentially, decision points as explicit if/then rules, no vague action verbs.
- [ ] Validation: Pass conditions, failure handling, and named failure modes specified.
- [ ] Examples: Minimum one per input variation, complete with actual values, realistic, includes edge cases.

### Language and Precision

- [ ] No vague words remain ("nice," "robust," "appropriate," "consider," "might," "good," "reasonable," "likely").
- [ ] All action verbs are imperative (validate, generate, extract, compute, not suggest or consider).
- [ ] Constraints use MUST/MUST NOT for rules, MAY for options.
- [ ] Threshold-based criteria where required (e.g., "process 10,000 items in under 5 seconds," not "efficient output").
- [ ] All lists use bullet format; no requirements buried in prose paragraphs.
- [ ] Decision points use explicit if/then structure ("If X, then Y. If not X, then Z").
- [ ] Terminology is consistent throughout (same term used same way every time).

### Personas and Examples

- [ ] Personas included if task requires specific worldview or decision-making framework.
- [ ] Persona format emphasizes identity and perspective, not just role list (includes `You are`, approach, priorities, tradeoffs).
- [ ] Examples are complete (not placeholders or ellipsis).
- [ ] Examples show actual values that the agent will encounter.
- [ ] Examples include at least one edge case or variant.
- [ ] Few-shot examples used for complex tasks; one-shot for format anchoring; zero-shot only for simple pre-trained tasks.

### Constraints and Tooling

- [ ] Tooling constraints declared if task involves file I/O, command execution, or tool access.
- [ ] Constraints distinguish between MUST NOT (forbidden), MUST (required), and MAY (optional).
- [ ] Environment assumptions stated in Inputs section, not mixed with constraints.
- [ ] No rule contradictions (if X is MUST NOT and X also appears as MUST, resolve explicitly).
- [ ] Conflict resolution clause included if multiple rules could conflict.

### Structural Integrity

- [ ] All eight sections present in order: objective → scope → inputs → outputs → constraints → procedure → validation → examples.
- [ ] No section is missing or empty (except examples can be omitted only if task has single, obvious input).
- [ ] Procedure references specific files, functions, or artifacts (not generic "do the thing").
- [ ] Validation includes both pass and fail conditions (not one-sided).
- [ ] Examples demonstrate the same format/structure shown in Outputs section.

## Complete Example: OAuth Implementation Plan

**Objective:** Produce a step-by-step implementation plan for adding OAuth login to an existing Node.js API.

**Scope:**

In-scope:

- Authentication flow for selected OAuth provider
- Required endpoints and route definitions
- Token storage and retrieval strategy
- Environment configuration and secrets management

Out-of-scope:

- UI/frontend changes
- Database migrations beyond token storage table
- Multi-provider OAuth support (one provider only)
- Refresh token rotation

**Inputs:**

Required:

- Repository path or GitHub URL
- Existing authentication middleware (code snippet or file name)
- Target OAuth provider (GitHub, Google, or Okta)

Optional:

- Preferred OAuth library (will suggest default if omitted)
- Target deployment environment (assumes staging if omitted)

Assumptions:

- Project uses Express.js
- Secrets are managed via environment variables (not hardcoded)
- PostgreSQL or similar for persistent token storage

**Outputs:**

Format: Markdown document titled "OAuth Implementation Plan"

Required sections:

- Overview (one paragraph)
- Endpoints (table with method, path, and purpose)
- Token storage (design, TTL, encryption)
- Configuration (environment variables and either sample .env or secrets manager notes)
- Implementation steps (numbered, with file names)
- Testing plan (unit and integration tests)
- Rollback strategy

**Constraints:**

- MUST NOT edit files; only provide code snippets and file changes.
- MUST NOT run commands; only provide shell commands that could be run.
- MUST reuse existing auth patterns in the codebase when applicable.
- MUST include security justification for token storage decisions.
- MUST specify all environment variables needed for the provider.

**Procedure:**

1. Read existing auth modules and identify extension points.
2. If an OAuth library is already in package.json, plan around that library; otherwise recommend one.
3. Identify the selected provider's endpoint URLs and required scopes.
4. Design token storage: table schema, TTL, and encrypted column strategy.
5. List all required environment variables and document their values (without secrets).
6. Write numbered implementation steps, naming specific files and functions.
7. Outline unit tests for token exchange and integration tests for the full flow.
8. Include a rollback plan (what to delete, what to revert).

**Validation:**

Pass conditions:

- Plan includes at least 5 implementation steps.
- All environment variables are listed and documented.
- Token storage design includes TTL and encryption strategy.
- Rollback plan is explicit and reversible.
- Testing plan covers both happy path and OAuth error responses.

Failure conditions:

- Plan does not include endpoint definitions.
- Plan does not specify the storage strategy.
- Plan does not list required environment variables.
- Rollback plan is missing or vague.

**Personas:**

Persona: Security-hardened backend architect with 7 years defending OAuth implementations

You are paranoid about token exfiltration and treat every storage mechanism as potentially compromised until cryptographically proven otherwise. You approach all design decisions by asking "How does an attacker steal this?" and "What forensic trail do we leave?" before considering performance or convenience.

When facing tradeoffs between encryption overhead and feature velocity, you choose hardening every time. You distrust in-memory caches and convenience but trust hardware-backed key storage and immutable audit logs. You demand explicit threat justification for every decision that touches credentials.

Persona details (years, titles) are illustrative; adapt them to the task.

**Examples:**

This section demonstrates few-shot prompting: each example shows complete input and corresponding output so the agent learns the expected structure through demonstration.

Example 1: Staging environment, existing Basic auth, GitHub provider

INPUT:

- Repository: github.com/company/api-service
- Existing auth: Basic auth middleware in routes/auth/basic.js
- Provider: GitHub
- Environment: staging (non-production)

OUTPUT:

````markdown
# OAuth Implementation Plan: GitHub

## Overview

Add GitHub OAuth to replace Basic auth in staging environment. GitHub provides delegated authentication, reducing credential exposure. Staging environment permits simplified token storage (in-memory cache with persistence).

## Endpoints

| Method | Path                 | Purpose                  |
| ------ | -------------------- | ------------------------ |
| GET    | /auth/login/github   | Initiate OAuth flow      |
| GET    | /auth/oauth/callback | GitHub callback receiver |
| POST   | /auth/logout         | Clear session and revoke |

## Token Storage

- **Table**: `oauth_sessions` (new)
- **Columns**:
  - `user_id` (foreign key to users)
  - `provider` (text: "github")
  - `access_token` (text, encrypted)
  - `expires_at` (timestamp)
- **TTL**: 1 hour (auto-cleanup via scheduled job)
- **Encryption**: AES-256-GCM with `GITHUB_TOKEN_KEY` from environment
- **Rationale**: Staging environment; production-grade encryption not required, but encrypted at rest follows principle-of-least-surprise

## Environment Variables

Required in .env:

```bash
GITHUB_CLIENT_ID=your_client_id
GITHUB_CLIENT_SECRET=your_client_secret
GITHUB_CALLBACK_URL='http://localhost:3000/auth/oauth/callback'
GITHUB_TOKEN_KEY=32-byte-base64-encoded-key
```

## Implementation Steps

1. Create oauth_sessions table: `migrations/20260203_create_oauth_sessions.sql`
2. Install library: `npm install passport-github2`
3. Create GitHub strategy: `lib/auth/github-strategy.js`
4. Add OAuth routes: `routes/auth/github.js`
5. Update middleware stack in app.js to use Passport authentication
6. Replace Basic auth header validation with Passport session check
7. Add .env.example with required variables (no secrets)

## Testing Plan

- Unit: Token encryption/decryption works with `GITHUB_TOKEN_KEY`
- Integration: GET /auth/login/github → redirect to GitHub → callback → session created → user authenticated
- Error: Invalid callback code → 401 response
- Error: Missing `GITHUB_CLIENT_SECRET` → startup fails with clear error

## Rollback Plan

If OAuth causes issues:

1. Restore routes/auth/basic.js from git
2. Revert app.js middleware changes
3. Delete oauth_sessions table: `DROP TABLE oauth_sessions;`
4. Redeploy previous version
````

Example 2: Production environment, no existing auth, Google provider (conservative approach)

INPUT:

- Repository: internal-tools (private)
- Existing auth: None
- Provider: Google
- Environment: production (must be hardened)

OUTPUT:

````markdown
# OAuth Implementation Plan: Google

## Overview

Implement Google OAuth as primary authentication for internal tools. Production environment requires encrypted token storage, audit logging, and rate limiting.

## Endpoints

| Method | Path                 | Purpose                           |
| ------ | -------------------- | --------------------------------- |
| GET    | /auth/login/google   | Initiate OAuth flow               |
| GET    | /auth/oauth/callback | Google callback receiver          |
| POST   | /auth/logout         | Revoke token and clear session    |
| GET    | /auth/status         | Check current session (debugging) |

## Token Storage

- **Table**: oauth_tokens (production-hardened)
- **Columns**:
  - `id` (UUID primary key)
  - `user_id` (foreign key, with audit logging on access)
  - `provider` (enum: "google")
  - `access_token` (encrypted with rotating key)
  - `refresh_token` (encrypted, stored separately from access_token)
  - `token_expires_at` (timestamp)
  - `last_accessed` (timestamp, updated on each request)
  - `created_at`, `updated_at` (for audit trail)
- **TTL**: None (user revocation model; manually deleted on logout)
- **Encryption**: AES-256-GCM with key from AWS KMS (not environment variable)
- **Audit**: Log all token access (not content, only timestamp/user/action) to separate `audit_log` table

## Environment Variables

Required in production secrets manager:

```bash
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_CALLBACK_URL='https://internal-tools.company.com/auth/oauth/callback'
GOOGLE_DISCOVERY_URL='https://accounts.google.com/.well-known/openid-configuration'
KMS_KEY_ID=arn:aws:kms:us-east-1:123456:key/...
RATE_LIMIT_TOKENS=10
RATE_LIMIT_WINDOW_MINUTES=1
```

## Implementation Steps

1. Create `oauth_tokens` table (with encryption column support): `migrations/20260203_oauth_tokens.sql`
2. Create `audit_log` table for token access: `migrations/20260203_audit_log.sql`
3. Install libraries: `npm install passport-google-oauth20 aws-sdk`
4. Create Google strategy with discovery: `lib/auth/google-strategy.js`
5. Create token encryption utility: `lib/auth/token-cipher.js` (uses KMS for key rotation)
6. Create rate limiter middleware: `middleware/rate-limit-oauth.js`
7. Add OAuth routes with audit logging: `routes/auth/google.js`
8. Add audit logging on every token access: middleware in auth check
9. Wire Passport into Express, replacing any existing session handling

## Testing Plan

- Unit: Token encryption with KMS key rotation works
- Unit: Rate limiter blocks after 10 requests/minute
- Integration: GET /auth/login/google → redirect → callback → token stored encrypted → user session created
- Integration: Token access logged to `audit_log` table
- Error: Invalid `GOOGLE_CLIENT_SECRET` → startup fails immediately
- Error: KMS key unavailable → 503 Service Unavailable (not 500 Internal Error)
- Error: Rate limit exceeded → 429 Too Many Requests

## Rollback Plan

If OAuth must be disabled:

1. Set `GOOGLE_CLIENT_ID` to empty string (disables all Google routes)
2. Revert to previous auth method (or maintenance mode)
3. DO NOT delete `oauth_tokens` or `audit_log` (retain for forensics)
4. Export `oauth_tokens` and `audit_log` to S3 backup
5. Notify security team of rollback and audit log status
````

Example 3: Edge case—Okta with existing JWT token strategy (multi-tenant, complex)

INPUT:

- Repository: internal-api (existing Express with JWT middleware)
- Existing auth: JWT bearer tokens in Authorization header
- Provider: Okta
- Environment: production (must integrate with existing JWT flow)

OUTPUT:

````markdown
# OAuth Implementation Plan: Okta

## Overview

Integrate Okta as OAuth provider without breaking existing JWT token flow. Okta will issue JWT tokens; application continues to validate existing JWT schema. This enables gradual migration from custom auth to Okta-managed auth.

## Endpoints

| Method | Path                 | Purpose                             |
| ------ | -------------------- | ----------------------------------- |
| GET    | /auth/login/okta     | Initiate Okta OAuth flow            |
| GET    | /auth/oauth/callback | Okta callback receiver              |
| POST   | /auth/logout         | Revoke Okta token and clear session |
| GET    | /auth/discovery      | Okta OIDC discovery endpoint        |

## Token Storage

- **Table**: `oauth_sessions` (minimal; Okta tokens live in Okta, not our database)
- **Columns**:
  - `user_id`
  - `provider` (text: "okta")
  - `okta_user_id` (external reference)
  - `refresh_token` (encrypted, short-lived)
  - `session_created_at`
- **TTL**: 30 minutes (sessions only; Okta manages token lifetime)
- **Encryption**: AES-256-GCM (refresh token only; access tokens validated server-side only)
- **Rationale**: Okta as authority; we validate tokens, not store them. Reduce token storage attack surface.

## Environment Variables

Required:

```bash
OKTA_DOMAIN=company.okta.com
OKTA_CLIENT_ID=your-client-id
OKTA_CLIENT_SECRET=your-client-secret
OKTA_CALLBACK_URL='https://api.company.com/auth/oauth/callback'
OKTA_DISCOVERY_URL='https://company.okta.com/.well-known/openid-configuration'
```

## Implementation Steps

1. Create `oauth_sessions` table (minimal schema): `migrations/20260203_oauth_sessions.sql`
2. Install: `npm install @okta/okta-sdk-nodejs passport-openidconnect`
3. Create Okta OIDC strategy: `lib/auth/okta-oidc-strategy.js`
4. Create token validator (validates Okta-issued tokens): `lib/auth/okta-token-validator.js`
5. Update JWT middleware to accept Okta-issued JWTs: `middleware/jwt-validator.js`
6. Add Okta OAuth routes: `routes/auth/okta.js`
7. Add discovery endpoint that returns Okta's OIDC metadata: `routes/auth/discovery.js`
8. Test existing JWT tokens still work (backward compatibility)

## Testing Plan

- Unit: Token validator accepts valid Okta JWTs
- Unit: Token validator rejects expired tokens
- Integration: Existing JWT tokens continue to authenticate
- Integration: GET /auth/login/okta → redirect to Okta → callback → Okta JWT validated → session created
- Integration: /auth/discovery returns Okta's OIDC metadata
- Error: Okta issues token but secret invalid → 401 Unauthorized
- Error: Okta unreachable (network failure) → 503 Service Unavailable, session stale
- Compatibility: Old app clients using JWT still work (no breaking change)

## Rollback Plan

If Okta integration must be removed:

1. Comment out Okta routes in routes/auth/okta.js
2. Remove Okta token validator from JWT middleware (revert to old logic)
3. Okta sessions and tokens become orphaned but harmless
4. Existing JWT tokens continue to work (backward compatible)
5. No database changes needed (`oauth_sessions` just unused)
````

## Additional References

- [OpenAI Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering)
- [OpenAI GPT-5 Prompting Guide](https://cookbook.openai.com/examples/gpt-5/gpt-5_prompting_guide)
