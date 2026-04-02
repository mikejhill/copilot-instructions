---
name: adversarial-refinement
argument-hint: "[content to refine: file path, inline text, or description]"
---

# Adversarial Refinement

> **Invocation model**: This skill is user-invocable only. It intentionally omits
> the `description` frontmatter field so that Copilot cannot auto-discover or
> auto-activate it. Invoke it explicitly by name.

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
- Domain-adaptive sub-agent prompt construction

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
| **Content** | The text to refine. Provided as inline text, a file path, or an explicit reference to prior output. If a file path, read its full contents before beginning. |
| **Domain** | The subject area (e.g., "software testing", "API design", "incident response"). Infer from content if not explicitly stated. |

### Optional

| Input | Default | Description |
| --- | --- | --- |
| **Focus areas** | All dimensions equally | Quality dimensions to emphasize (e.g., "clarity and actionability"). |
| **Max iterations** | 3 | Override the iteration cap. Minimum: 2. Maximum: 5. |
| **Target audience** | Inferred from content | Who consumes this content. Shapes sub-agent framing. |
| **Model preference** | Most capable available | Model for sub-agents. MUST be high-capability (Opus-tier or equivalent). |

## Outputs

1. **Refined content** — The final improved version, ready for use or further
   review.
2. **Refinement log** — Per-iteration summary containing:
   - Researcher insights applied
   - Critic findings addressed
   - Changes made
   - Remaining concerns (if any)
3. **Convergence rationale** — Why the process stopped: convergence reached, or
   cap hit with unresolved items flagged.

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

- Both sub-agents MUST use the most capable model available. For the Copilot
  CLI, specify the model explicitly (e.g., `claude-opus-4.6` or the current
  top-tier equivalent). The quality ceiling of refinement is bounded by the
  reasoning depth of the sub-agents.
- Use `general-purpose` agent type for both sub-agents.

### Parallel Execution — SHOULD Follow

- The researcher and critic within each iteration are independent by design
  (information barriers guarantee this). Launch them in parallel to minimize
  wall-clock time.
- Do NOT parallelize across iterations. Each iteration's synthesis MUST complete
  before the next iteration begins.

### Synthesis Discipline — MUST Follow

- Do NOT blindly apply all suggestions. Evaluate each finding for relevance,
  accuracy, and impact before applying.
- When researcher and critic findings reinforce the same area, treat that area
  as high priority.
- When researcher and critic findings conflict, evaluate on reasoning quality
  rather than source. Document the conflict and resolution rationale in the
  refinement log.
- Track all changes across iterations. Do NOT regress — never re-introduce
  issues fixed in prior iterations.
- Apply the most impactful changes first. Minor polish comes last.

### Iteration Limits — MUST Follow

- Minimum iterations: 2. The first iteration nearly always surfaces substantial
  improvements; the second catches issues introduced by the first round of
  changes.
- Maximum iterations: 5 (hard ceiling). Default: 3.
- If the user supplies a custom maximum, clamp it to the range [2, 5].

## Procedure

### Phase 0 — Preparation

1. Read and internalize the content to refine.
2. Identify: domain, content type, purpose, target audience.
3. Determine which quality dimensions matter most for this content type:
   - **Completeness** — All necessary topics covered?
   - **Precision** — Language concrete, specific, unambiguous?
   - **Structure** — Logically organized, easy to navigate?
   - **Correctness** — Claims accurate, internally consistent?
   - **Actionability** — Reader can act without guessing?
   - **Conciseness** — No unnecessary repetition or filler?
4. Set the iteration counter to 0.

### Phase 1 — Dual-Agent Launch

Launch both sub-agents simultaneously (parallel). Replace all bracketed
placeholders with actual values derived from Phase 0.

#### 1A — Researcher

Launch a `general-purpose` agent (most capable model available) with a prompt
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

[IF iteration > 0]:
This is iteration [N]. Prior iterations already addressed fundamentals. Focus
exclusively on ADVANCED, SUBTLE, and NON-OBVIOUS insights that require deep
domain expertise to identify.
[END IF]

Prioritize depth over breadth. Five profound insights outweigh twenty surface
observations. Do NOT reference or propose changes to any specific document.
Report general findings only.
~~~

NEVER include the content being refined in the researcher prompt.

#### 1B — Critic

Launch a `general-purpose` agent (most capable model available) with a prompt
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

[IF iteration > 0]:
This is iteration [N] of refinement. Prior iterations addressed earlier
feedback. Focus on what REMAINS problematic despite prior changes. If the
content is now genuinely strong, say so — do not invent issues to justify your
role. Your credibility depends on accuracy, not volume of findings.
[END IF]

Be ruthless. Do not hedge, soften, or qualify. Prioritize findings by impact —
the most damaging issues first.
~~~

### Phase 2 — Synthesis

1. Collect outputs from both sub-agents.
2. **Process researcher output**:
   - For each finding, determine whether the current content already addresses
     it. If yes, discard. If no, flag as an improvement opportunity.
   - Rank retained findings by potential impact on the quality dimensions
     identified in Phase 0.
3. **Process critic output**:
   - Record the severity distribution: count of critical / significant /
     weakness / minor findings.
   - For each critical issue and significant gap, draft a specific change.
   - For weaknesses, draft changes where they align with researcher findings
     (reinforcement signals high priority).
   - Batch minor issues for a single polish pass.
4. **Apply changes** in priority order:
   1. Critical issues.
   2. Significant gaps.
   3. Weaknesses reinforced by researcher findings.
   4. Remaining weaknesses.
   5. Minor issues.
   - After each change, verify it does not regress a fix from a prior iteration.
5. Increment the iteration counter.
6. Record the iteration summary for the refinement log.

### Phase 3 — Convergence Check

Evaluate whether another iteration is warranted.

**STOP if ANY of these conditions is true:**

- Iteration counter ≥ maximum (default 3).
- Critic found 0 critical issues AND 0 significant gaps, AND the researcher
  surfaced no unaddressed insights.
- Critic explicitly assessed the content as strong or excellent without
  manufacturing concerns.
- Severity-weighted finding count increased from the prior iteration,
  indicating the synthesis degraded the content. In this case, revert to the
  prior version, note the degradation in the refinement log, and stop.

Severity weights for the degradation check:

| Severity | Weight |
| --- | --- |
| Critical | 8 |
| Significant gap | 4 |
| Weakness | 2 |
| Minor | 1 |

**CONTINUE if ALL of these conditions are true:**

- Iteration counter < maximum.
- Critic found ≥ 1 critical issue or significant gap, OR the researcher
  surfaced ≥ 1 genuine unaddressed insight.
- Severity-weighted finding count decreased or held steady compared to the
  prior iteration.

If continuing → return to Phase 1 with updated content.
If stopping → proceed to Phase 4.

### Phase 4 — Delivery

1. Present the refined content. If the content originated from a file, write
   the updated version to the file.
2. Present the refinement log (all iterations).
3. Present the convergence rationale.
4. If the process hit the iteration cap with unresolved critical issues, flag
   them explicitly and recommend further action.

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

- Maximum iterations reached with unresolved critical issues → Deliver the best
  version achieved, flag every unresolved issue, and inform the user.
- A sub-agent fails to produce structured output → Re-prompt once with tighter
  formatting instructions. If the second attempt also fails, proceed with the
  output from the functioning sub-agent and note reduced confidence in the
  refinement log.

### Edge Cases

- **Content already excellent** — If the first critic finds no critical issues
  or significant gaps, still complete the minimum 2 iterations. The researcher
  may surface non-obvious improvements the critic would not think to look for.
- **Researcher and critic fundamentally disagree** — Evaluate both positions on
  reasoning quality. Choose the better-reasoned position. Document the
  disagreement and resolution rationale in the refinement log.
- **Very long content (>2000 lines)** — Segment into logical sections. Refine
  each section independently, then run one final holistic iteration on the
  reassembled content.
- **Degradation detected** — If the severity-weighted finding count increases
  between consecutive iterations, the synthesis introduced new problems. Revert
  to the version from the prior iteration, record the degradation event, and
  stop.

## Examples

### Example 1 — Refining a Copilot Agent Skill

**User input**: `#adversarial-refinement features/skills/testing-standards/SKILL.md`

**Orchestrator behavior**:

1. Reads the skill file. Identifies domain = "software testing methodology",
   content type = "Copilot agent skill", audience = "AI coding assistants
   performing test generation and review."
2. **Iteration 1**:
   - Launches researcher: "You are a world-class expert in software testing
     methodology with deep knowledge of Copilot agent skill best
     practices..."
   - Launches critic (in parallel): "You are a harsh, meticulous critic
     specializing in software testing methodology..." followed by the full
     skill content.
   - Synthesizes: researcher surfaces advanced mutation-testing concepts not
     covered; critic flags 2 critical issues (ambiguous constraint language,
     missing edge case). Orchestrator applies fixes.
3. **Iteration 2**:
   - Researcher focuses on advanced/subtle insights; critic reviews updated
     content.
   - Critic finds 0 critical issues, 1 weakness. Researcher surfaces one new
     insight already addressed.
   - Convergence met → stop.
4. Writes updated SKILL.md, presents refinement log and convergence rationale.

### Example 2 — Refining API Documentation

**User input**: `#adversarial-refinement Refine docs/api-reference.md with focus
on developer experience`

**Orchestrator behavior**:

1. Reads the file. Identifies domain = "API documentation", audience =
   "developers consuming the API", focus areas = "developer experience."
2. Researcher prompt emphasizes: developer onboarding experience,
   time-to-first-successful-call, error message clarity, example coverage.
3. Critic prompt includes the full documentation text.
4. Synthesis prioritizes findings that affect developer experience over other
   quality dimensions, per the user-specified focus.
5. Iterates until convergence, writes result, delivers log.
