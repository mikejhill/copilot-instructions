---
name: adversarial-refinement
description: >-
  Use when iteratively refining text-based content to production quality through
  parallel dual-agent research and critique cycles with convergence detection.
argument-hint: "[content to refine: file path, inline text, or description]"
disable-model-invocation: true
---

# Adversarial Refinement

Iteratively refine any text-based content to the highest achievable quality
through parallel dual-agent analysis loops. An independent researcher discovers
what excellence looks like while an independent critic identifies what falls
short. The orchestrating agent synthesizes both perspectives and improves the
content between each cycle.

## Objective

Bring text-based content to production-ready quality by repeatedly subjecting it
to independent research and harsh critique, synthesizing findings, and applying
improvements until diminishing returns are reached.

## Scope

### In-Scope

- Refinement of any text-based content: documentation, skills, instructions,
  prompts, specifications, architecture decisions, policies, runbooks, templates
- Multi-iteration improvement through parallel research–critique cycles
- Convergence detection and automatic termination
- Domain-contextualized sub-agent prompt construction

### Out-of-Scope

- Initial content creation from scratch — content MUST exist before this skill
  is invoked
- Code compilation, execution, or automated testing
- Factual verification against external sources beyond the agent's training data
- Subjective aesthetic decisions that lack measurable quality criteria

## Inputs

### Required

| Input | Description |
| --- | --- |
| **Content** | The text to refine. See Content Resolution for disambiguation rules. |
| **Domain** | The subject area (e.g., "software testing", "API design", "incident response"). Infer from content if not explicitly stated. |

### Optional

| Input | Default | Description |
| --- | --- | --- |
| **Focus areas** | All dimensions equally | Quality dimensions to emphasize (e.g., "clarity and actionability"). |
| **Max iterations** | 3 | Override the iteration cap. Minimum: 2. Maximum: 5. |
| **Target audience** | Inferred from content | Who consumes this content. Shapes sub-agent framing. |
| **Model preference** | Most capable available | Model for sub-agents. See Model Selection for the fallback chain. |

### Content Resolution

Parse the user's input to identify the content to refine:

1. If the input contains a recognizable file path (contains path separators and
   a file extension), attempt to read it.
   - If the file exists, use its contents as the content to refine.
   - If the file does not exist, fail immediately with:
     "File not found: [path]. Provide the content inline or correct the path."
2. If the input is substantial text (more than 20 words) with no file path,
   treat it as inline content.
3. If the input is a short description with no file path and no substantial
   text, fail with: "Provide the content to refine as a file path or inline
   text."

Separate any non-content instructions (e.g., "with focus on developer
experience") from the content reference before processing.

## Outputs

1. **Refined content** — The final improved version, ready for use or further
   review.
2. **Refinement log** — Per-iteration summary containing:
   - Researcher insights applied (with novelty rate)
   - Critic findings addressed (with severity distribution)
   - Changes made and whether each was clear-cut or a judgment call
   - Remaining concerns (if any)
3. **Convergence rationale** — Why the process stopped: convergence reached, or
   cap hit with unresolved items flagged.
4. **Diff summary** — If content originated from a file, a summary of changes
   between the original and refined versions, presented before any file write.

## Constraints

### Information Barriers — MUST Enforce

These barriers are the mechanism that makes dual-agent refinement produce
stronger results than self-review. Violating them collapses the technique into a
weaker single-perspective analysis.

| Agent | MUST receive | MUST NOT receive |
| --- | --- | --- |
| Researcher | Topic, domain, content type, target audience, iteration number | Existing content, orchestrator's opinions, critic's output |
| Critic | Current content version, domain context, iteration number | Orchestrator's self-assessment, improvement plans, researcher's output |

**Why the researcher never sees the content**: The researcher's value comes from
independently discovering what excellence looks like, unanchored by the existing
text. Showing the content causes anchoring bias — the researcher gravitates
toward confirming what already exists rather than imagining what could exist.

**Why the critic never sees the orchestrator's framing**: The critic's value
comes from evaluating the content on its own merits. Knowing what the
orchestrator thinks is strong or weak biases which issues get surfaced.

### Model Selection — MUST Follow

- Both sub-agents MUST use a high-capability model. The quality ceiling of
  refinement is bounded by the reasoning depth of the sub-agents.
- Use `general-purpose` agent type for both sub-agents.
- **Preferred**: Opus-tier or equivalent top-tier model (e.g.,
  `claude-opus-4.6`).
- **Acceptable fallback**: If the preferred tier is unavailable (rate-limited,
  not on the user's plan), use the next-best available model (e.g.,
  Sonnet-tier). Note the downgrade in the refinement log.
- **Minimum floor**: Do NOT use models below the Sonnet tier. If no model at or
  above Sonnet-tier is available, inform the user and do not proceed.

### Parallel Execution — SHOULD Follow

- The researcher and critic within each iteration are independent by design
  (information barriers guarantee this). Launch them in parallel to minimize
  wall-clock time.
- Do NOT parallelize across iterations. Each iteration's synthesis MUST complete
  before the next iteration begins.

### Synthesis Discipline — MUST Follow

The orchestrator's synthesis step is where the majority of refinement value is
created or destroyed. Sub-agent quality matters, but the orchestrator's judgment
in reconciling and applying findings determines the outcome.

**Anti-bias protocol:**

- Process researcher findings FIRST, in isolation. Note which findings suggest
  genuine gaps or improvements. Then process critic findings independently.
  Only AFTER evaluating each set in isolation, cross-reference for
  reinforcement.
- Document which synthesis decisions were clear-cut (both agents agree, or
  evidence is unambiguous) vs. judgment calls (orchestrator chose between
  conflicting or ambiguous signals). This transparency enables the user to
  audit decisions.

**Anti-pattern avoidance:**

- **Synthesis-by-averaging**: Do NOT take the middle ground between researcher
  and critic when they conflict. Instead, identify the underlying concern behind
  each recommendation and ask: "Is there a solution that addresses BOTH concerns
  simultaneously?" Only if genuine synthesis is impossible, choose the position
  with stronger evidence. Averaging dilutes both perspectives and produces
  mediocre output. True synthesis creates something that transcends both inputs
  rather than splitting the difference.
- **Anchored revision trap**: Do NOT limit changes to line-level edits of the
  prior version. If findings suggest structural reorganization, section
  reordering, or section removal, implement those structural changes. Each
  iteration MUST be willing to make bold changes, not just incremental tweaks.
- **Semantic drift**: Over multiple iterations, cumulative reinterpretation can
  cause the artifact to drift from its original intent without any single step
  being wrong. Re-validate every iteration against the original purpose, target
  audience, and constraints — not just against the prior iteration's version.

**Conflict resolution criteria (in priority order):**

When researcher and critic findings conflict, prefer the finding that:

1. Cites a specific, concrete flaw or piece of evidence.
2. Explains causation (why something fails) rather than correlation (it seems
   off).
3. Proposes a testable, verifiable improvement rather than a subjective opinion.

If both findings meet these criteria equally, prefer the critic (the critic has
evaluated the actual content; the researcher has not).

**Change tracking:**

- Track all changes across iterations. Do NOT regress — never re-introduce
  issues fixed in prior iterations.
- Apply the most impactful changes first. Minor polish comes last.

### Iteration Limits — MUST Follow

- Minimum iterations: 2. The first iteration nearly always surfaces substantial
  improvements; the second catches issues introduced by the first round of
  changes.
- Maximum iterations: 5 (hard ceiling). Default: 3.
- If the user supplies a custom maximum, clamp it to the range [2, 5].

### Context Window Awareness — MUST Follow

- Before constructing the critic prompt, estimate whether the full content plus
  the prompt template plus response headroom fits within the model's context
  window.
- If content is too long for a single critic prompt, segment it as described in
  the Edge Cases section.
- Use content length in tokens (not lines) as the sizing metric. As a rough
  heuristic, one line of dense prose is approximately 30–50 tokens.

## Procedure

### Phase 1 — Preparation

1. Resolve the content input using the Content Resolution rules.
2. Read and internalize the content.
3. Identify: domain, content type, purpose, target audience.
4. Determine which quality dimensions matter most for this content type:
   - **Completeness** — All necessary topics covered?
   - **Precision** — Language concrete, specific, unambiguous?
   - **Structure** — Logically organized, easy to navigate?
   - **Correctness** — Claims accurate, internally consistent?
   - **Actionability** — Reader can act without guessing?
   - **Conciseness** — No unnecessary repetition or filler?
5. If the user specified focus areas, identify which quality dimensions they
   map to. Weight those dimensions above others throughout the process.
6. If the content references external files (e.g., "See ARCHITECTURE.md"),
   attempt to read them. Include relevant context in the critic's domain
   framing. Do NOT pass external file contents to the researcher (information
   barrier).
7. Record the original purpose statement, audience, and constraints as the
   **intent anchor**. Re-validate against this anchor every iteration to
   prevent semantic drift.
8. Set the iteration counter to 0.

### Phase 2 — Dual-Agent Launch

Launch both sub-agents simultaneously (parallel). Replace all bracketed
placeholders with actual values derived from Phase 1.

If the researcher was dropped due to diminishing returns (see 2A), launch only
the critic. Skip researcher-dependent steps in Phase 3 (steps 2 and 4) and
treat the researcher novelty rate as 0% in Phase 4.

When constructing sub-agent prompts, use imperative voice, no vague language,
explicit conditionals, and MUST/MUST NOT/MAY modality (as defined by the
`writing-ai-instructions` skill, which is the authoritative reference for the
full set of prompt construction conventions).

#### 2A — Researcher

Launch a `general-purpose` agent (most capable available model) with a prompt
built from this template:

~~~text
You are a world-class expert in [DOMAIN] with deep knowledge of [CONTENT TYPE]
best practices.

Your task: independently research and report what constitutes excellence for
[CONTENT TYPE] intended for [AUDIENCE].

Produce a structured report with these sections:

1. ESSENTIAL QUALITIES — What properties MUST a high-quality [CONTENT TYPE]
   exhibit? Be specific and concrete.
2. COMMON FAILURE MODES — What mistakes do authors of [CONTENT TYPE] most
   frequently make? Why do these matter?
3. ADVANCED BEST PRACTICES — What separates exceptional [CONTENT TYPE] from
   merely adequate ones? Focus on techniques that require expertise to know.
4. STRUCTURAL PATTERNS — What organizational approaches work best for this
   content type? Why?
5. OVERLOOKED DIMENSIONS — What aspects or audiences are commonly neglected?

[IF focus areas specified]:
Prioritize the following quality dimensions above all others: [FOCUS AREAS].
Weight your findings heavily toward these dimensions.
[END IF]

[IF iteration == 0]:
Cover both fundamental and advanced aspects of excellence for this content type.
[END IF]

[IF iteration == 1]:
Prior research covered fundamentals. Focus exclusively on ADVANCED, SUBTLE, and
NON-OBVIOUS insights that require deep domain expertise to identify.
[END IF]

[IF iteration >= 2]:
Prior research covered fundamentals and advanced practices. Adopt a contrarian
stance: challenge conventional wisdom about [CONTENT TYPE]. Identify best
practices that are actually harmful in specific contexts, or unconventional
approaches that outperform standard ones. Question underlying assumptions.
[END IF]

For each finding, state your confidence: HIGH (clear evidence), MEDIUM (strong
inference), or LOW (possible concern). Do not present LOW-confidence findings as
definitive.

Prioritize depth over breadth. Five profound insights outweigh twenty surface
observations. Do NOT reference or propose changes to any specific document.
Report general findings only.
~~~

NEVER include the content being refined in the researcher prompt.

**Researcher diminishing returns**: The researcher never sees the content, so
later iterations produce increasingly generic domain knowledge untethered from
the actual artifact. If the researcher's novelty rate (see Phase 3) drops below
20% in two consecutive iterations, drop the researcher for subsequent iterations
and run only the critic. This optimization primarily applies when max iterations
is 4 or higher; at the default of 3, the drop rarely triggers because the
broad iteration-0 prompt nearly always produces high novelty.

#### 2B — Critic

Launch a `general-purpose` agent (most capable available model) with a prompt
built from this template:

~~~text
You are a harsh, meticulous, and deeply knowledgeable critic specializing in
[DOMAIN]. You have zero tolerance for mediocrity and an expert eye for
[CONTENT TYPE].

Review this [CONTENT TYPE] and identify every flaw, gap, weakness,
inconsistency, and missed opportunity:

---
[INSERT FULL CURRENT CONTENT]
---

Produce a structured critique with findings sorted by descending severity:

1. CRITICAL ISSUES — Flaws that undermine the content's core purpose or would
   mislead the audience. For each: state what is wrong, why it matters, and
   what a correct version looks like.
2. SIGNIFICANT GAPS — Important topics, scenarios, or edge cases missing
   entirely. For each: state what is missing, why it matters, and where it
   belongs.
3. WEAKNESSES — Areas present but underdeveloped, vague, or substantially
   improvable. For each: state what is weak and how to strengthen it.
4. MINOR ISSUES — Polish items: formatting, word choice, organization. Batch
   related items together.
5. OVERALL VERDICT — One blunt paragraph: current quality level, readiness for
   production use, and the single most impactful improvement remaining.

[IF focus areas specified]:
Prioritize the following quality dimensions above all others: [FOCUS AREAS].
Weight your critique heavily toward these dimensions. A flaw in a focus
dimension is one severity level higher than it would otherwise be.
[END IF]

[IF iteration == 0]:
This is the first review. Evaluate comprehensively across all severity levels.
[END IF]

[IF iteration > 0]:
This is iteration [N] of refinement. Prior iterations addressed earlier
feedback. Focus on what REMAINS problematic despite prior changes. If the
content is now genuinely strong, say so — do not invent issues to justify your
role. Your credibility depends on accuracy, not volume of findings.
[END IF]

Be ruthless. Do not hedge, soften, or qualify. Prioritize findings by impact —
the most damaging issues first.

If you find no significant issues, explicitly state "No significant issues
found" rather than inventing minor ones to appear thorough. Your credibility
depends on accuracy, not volume. For each finding, state your confidence: HIGH
(clear evidence), MEDIUM (strong inference), or LOW (possible concern).
~~~

### Phase 3 — Synthesis

1. Collect outputs from both sub-agents (or critic only if the researcher was
   dropped).
2. **Process researcher output** (do this BEFORE reading critic output to
   prevent the orchestrator from anchoring on the critic's framing). Skip this
   step if the researcher was dropped.
   - For each finding, categorize as: **novel** (not addressed in current
     content), **already addressed**, or **not applicable**.
   - Calculate the researcher novelty rate: `novel / total findings`.
   - Rank novel findings by potential impact on the quality dimensions
     identified in Phase 1 (weight focus-area dimensions 2× if specified).
3. **Process critic output** (after completing researcher evaluation):
   - Record the severity distribution: count of critical, significant,
     weakness, and minor findings.
   - Record per-dimension severity: for each quality dimension from Phase 1,
     note the count and severity of findings that affect it.
   - For each critical issue and significant gap, draft a specific change.
   - For weaknesses, draft changes where they align with researcher findings
     (reinforcement signals high priority).
   - Batch minor issues for a single polish pass.
4. **Cross-reference** (skip if researcher was dropped): Identify areas where
   both agents independently flagged the same concern. Treat these as highest
   priority regardless of individual severity ratings.
5. **Re-validate against intent anchor**: Before applying changes, re-read the
   original purpose statement, audience, and constraints recorded in Phase 1.
   Verify that the planned changes do not drift from the original intent.
6. **Retain the current content version** as the rollback target in case
   degradation is detected in Phase 4.
7. **Apply changes** in priority order:
   1. Cross-referenced findings (both agents independently agree).
   2. Critical issues from the critic.
   3. Significant gaps from the critic.
   4. Novel researcher findings with high impact.
   5. Weaknesses reinforced by researcher findings.
   6. Remaining weaknesses.
   7. Minor issues.
   - After each change, verify it does not regress a fix from a prior iteration.
   - Verify no individual quality dimension regressed (per-dimension check).
   - For each change, note whether it was clear-cut or a judgment call.
8. Increment the iteration counter.
9. Record the iteration summary for the refinement log, including:
   - Severity distribution from the critic (aggregate and per-dimension)
   - Researcher novelty rate (or "researcher dropped" if applicable)
   - Count of changes applied vs. findings discarded (with reasons)

### Phase 4 — Convergence Check

**Minimum iteration gate**: If the iteration counter is less than the minimum
(default 2), return to Phase 2 unconditionally. Do NOT evaluate stop conditions
until the minimum is reached.

After the minimum is met, evaluate whether another iteration is warranted.

**Severity score formula:**

~~~text
severity_score = (critical × 8) + (significant_gaps × 4) + (weaknesses × 2) + (minor × 1)
~~~

The weights reflect that critical issues make content actively harmful (8×),
significant gaps make it materially incomplete (4×), weaknesses reduce
effectiveness (2×), and minor issues affect polish only (1×). These weights are
heuristic — the orchestrator MAY adjust them if domain context warrants it
(e.g., in safety-critical documentation, weaknesses may warrant 4× weight).

Severity scores are approximate due to model stochasticity — different critic
invocations may rate identical content differently. Treat degradation and
stagnation as signals to investigate, not automatic triggers. Inspect the
specific findings before reverting or stopping.

**STOP if ANY of these conditions is true:**

- Iteration counter ≥ maximum (default 3).
- Critic found 0 critical issues AND 0 significant gaps, AND the researcher's
  novelty rate is below 20% (or the researcher was dropped).
- Critic explicitly assessed the content as strong or excellent without
  manufacturing concerns.
- **Degradation detected**: The severity score increased compared to the prior
  iteration. Inspect the specific findings to confirm real degradation (not
  stochastic noise). If confirmed, revert to the retained rollback version from
  Phase 3, record the degradation event in the refinement log, and stop. This
  check applies only when two or more severity scores exist (the first iteration
  establishes the baseline).
- **Stagnation detected**: The severity score did not decrease by more than 10%
  across two consecutive iterations, indicating the process is not making
  meaningful progress.
- **Per-dimension regression**: Any individual quality dimension worsened between
  iterations without documented justification, even if the aggregate score
  improved.

**CONTINUE if ALL of these conditions are true:**

- Iteration counter is less than the maximum.
- Critic found at least 1 critical issue or significant gap, OR the
  researcher's novelty rate is at or above 20%.
- Severity score decreased by more than 10% compared to the prior iteration.
- No individual quality dimension regressed without justification.

If continuing, return to Phase 2 with the updated content.
If stopping, proceed to Phase 5.

### Phase 5 — Delivery

1. If the content originated from a file:
   a. Present a diff summary showing the key changes between the original and
      the refined version.
   b. If the host environment supports interactive confirmation, wait for user
      approval before writing. If not, proceed with the write.
   c. Write the updated content to the file.
2. If the content was provided inline, present the refined content directly.
3. Present the refinement log (all iterations).
4. Present the convergence rationale.
5. If the process hit the iteration cap with unresolved critical issues, flag
   them explicitly and recommend further action to the user.

## Validation

### Pass Conditions

- Minimum 2 iterations completed.
- All critical issues identified across all iterations were either resolved or
  explicitly justified as not applicable (with rationale documented).
- Final critic assessment contains 0 critical issues and 0 significant gaps.
- Content is internally consistent — no contradictions introduced by merging
  feedback from different iterations.
- Information barriers were maintained throughout every iteration.

### Failure Conditions

Failure conditions take precedence over pass conditions when both apply:

- Maximum iterations reached with unresolved critical issues: deliver the best
  version achieved, flag every unresolved issue, and inform the user.
- A sub-agent fails to produce structured output: re-prompt once with tighter
  formatting instructions. If the second attempt also fails, proceed with the
  output from the functioning sub-agent and note reduced confidence in the
  refinement log.

### Edge Cases

- **Content already excellent** — If the first critic finds no critical issues
  or significant gaps, still complete the minimum 2 iterations. The researcher
  may surface non-obvious improvements the critic would not think to look for.
- **Researcher and critic fundamentally disagree** — Apply the conflict
  resolution criteria from the Synthesis Discipline constraint. Document the
  disagreement and resolution rationale in the refinement log.
- **Very long content (estimated over 60K tokens)** — Segment into logical
  sections. Run a single iteration per segment (no minimum for segments), then
  reassemble and run a 2-iteration holistic pass on the full content.
  Inter-section consistency issues (terminology, cross-references) are addressed
  during the holistic pass. Total sub-agent calls are bounded by:
  `(segments × 2) + (holistic iterations × 2)`.
- **Degradation detected** — See Phase 4. Revert to the version from the prior
  iteration and stop.

## Examples

### Example 1 — Refining a Copilot Agent Skill

**User input**: `#adversarial-refinement features/skills/testing-standards/SKILL.md`

**Phase 1 — Preparation**:

- Reads the file (content resolution: path with extension, file exists).
- Domain = "software testing methodology". Content type = "Copilot agent
  skill". Audience = "AI coding assistants performing test generation and
  review."
- No focus areas specified; all quality dimensions weighted equally.

**Phase 2, Iteration 1 — Dual-Agent Launch**:

Researcher prompt (instantiated):

> You are a world-class expert in software testing methodology with deep
> knowledge of Copilot agent skill best practices. Your task: independently
> research and report what constitutes excellence for Copilot agent skills
> intended for AI coding assistants performing test generation and review.
> \[Sections 1–5 as defined in template.] Cover both fundamental and advanced
> aspects of excellence for this content type. Prioritize depth over breadth.
> Five profound insights outweigh twenty surface observations. Do NOT reference
> or propose changes to any specific document. Report general findings only.

Critic prompt (instantiated):

> You are a harsh, meticulous, and deeply knowledgeable critic specializing in
> software testing methodology. You have zero tolerance for mediocrity and an
> expert eye for Copilot agent skills. Review this Copilot agent skill and
> identify every flaw, gap, weakness, inconsistency, and missed opportunity:
> \[full skill content inserted here]. \[Sections 1–5 as defined in template.]
> This is the first review. Evaluate comprehensively across all severity levels.
> Be ruthless. Do not hedge, soften, or qualify. Prioritize findings by
> impact — the most damaging issues first.

**Phase 3, Iteration 1 — Synthesis**:

- Researcher (processed first): 12 findings total. 8 novel (novelty rate: 67%).
  Highest-impact novel finding: mutation-testing concepts not covered in the
  skill's anti-pattern catalog.
- Critic (processed second): 2 critical issues (ambiguous constraint language,
  missing edge case for framework mocking), 3 significant gaps, 5 weaknesses,
  4 minor issues. Severity score: (2 × 8) + (3 × 4) + (5 × 2) + (4 × 1) = 42.
- Cross-reference: Both agents independently flagged the testing-framework
  mocking gap. Elevated to highest priority.
- Applied: 2 critical fixes, 3 gap fills, 3 novel researcher findings, 2
  reinforced weaknesses. Deferred: 3 weaknesses, 4 minor items to next
  iteration.

**Phase 4, Iteration 1**: Counter = 1, which is less than minimum = 2. Continue
unconditionally.

**Phase 2, Iteration 2 — Dual-Agent Launch**:

Researcher prompt uses iteration-1 framing: "Focus exclusively on ADVANCED,
SUBTLE, and NON-OBVIOUS insights." Critic reviews updated content: "Focus on
what REMAINS problematic despite prior changes."

**Phase 3, Iteration 2 — Synthesis**:

- Researcher: 8 findings total. 1 novel (novelty rate: 12%).
- Critic: 0 critical, 0 significant gaps, 2 weaknesses, 3 minor.
  Severity score: (0 × 8) + (0 × 4) + (2 × 2) + (3 × 1) = 7.
- Applied: deferred weaknesses from iteration 1, 2 new weaknesses, 1 novel
  researcher finding, 3 minor polish items.

**Phase 4, Iteration 2**: Minimum met. Critic: 0 critical, 0 significant gaps.
Researcher novelty rate: 12% (below 20% threshold). Severity score dropped
42 to 7 (83% decrease). STOP — 0 critical + 0 significant gaps + researcher
novelty below 20%.

**Phase 5 — Delivery**: Writes updated SKILL.md, presents diff summary,
refinement log covering both iterations, and convergence rationale.

### Example 2 — Refining API Documentation with Focus Areas

**User input**:
`#adversarial-refinement docs/api-reference.md -- focus on developer experience`

**Orchestrator behavior**:

1. Content resolution: `docs/api-reference.md` recognized as file path (path
   separator + extension). File exists. Separate instruction extracted: focus
   areas = "developer experience".
2. Domain = "API documentation". Audience = "developers consuming the API".
   Focus dimensions mapped to: actionability, structure, completeness of
   examples.
3. Researcher prompt includes: "Prioritize the following quality dimensions
   above all others: developer experience — specifically onboarding ease,
   time-to-first-successful-call, error message clarity, and example quality.
   Weight your findings heavily toward these dimensions."
4. Critic prompt includes: "Prioritize the following quality dimensions above
   all others: developer experience. Weight your critique heavily toward these
   dimensions. A flaw in a focus dimension is one severity level higher than it
   would otherwise be."
5. Synthesis weights focus-area findings 2× in priority ordering. For example,
   if the critic flags a "weakness" in example quality (a focus dimension), it
   is treated with the same priority as a "significant gap" in a non-focus
   dimension. If the researcher independently identifies example coverage as a
   best practice, the cross-reference elevates it to highest priority.
6. Iterates until convergence, presents diff, writes result, delivers log.
