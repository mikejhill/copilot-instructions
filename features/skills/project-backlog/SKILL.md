---
name: project-backlog
description: "Use when operating on the user's local project backlog, such as capturing ideas, promoting backlog items into spec directories with spec.md, iterating on lifecycle-managed specifications, or archiving completed spec directories."
---

# Project Backlog Skill

## Overview

This skill manages a three-stage project lifecycle for ideas and initiatives
that span multiple projects:

1. **Backlog** — Capture ideas in a compact list. Items are brief and
   lightweight. The backlog stays reasonably sized; it is not a task tracker.
2. **Specification** — Promote backlog items into dedicated spec directories
   for detailed design. Iterate on specs until they are ready for execution.
3. **Archive** — After a spec is executed, move its directory to an archive
   so it is no longer front-and-center.

The backlog and all specs live under `_meta/specs/` at the projects root,
following the conventions established by the `meta-workspace` skill.

## Directory Structure

```
<projects-root>/_meta/specs/
├── project-backlog.md              # Compact backlog list (Stage 1)
├── <item-slug>/                    # Promoted spec directory (Stage 2)
│   ├── spec.md                     #   Primary specification (required)
│   └── <auxiliary>.md              #   Supporting files (optional)
└── archive/                        # Completed specs (Stage 3)
    └── <item-slug>/                #   Archived spec directory
        ├── spec.md
        └── <auxiliary>.md
```

**Naming conventions:**

- Spec directories use kebab-case slugs derived from the backlog item title
- The primary spec file is always `spec.md`
- Auxiliary files use descriptive kebab-case names
- `archive/` is a flat collection of completed spec directories

## Scope

**In-scope:**

- Adding, listing, modifying, and removing backlog items
- Promoting backlog items into spec directories
- Iterating on existing specifications
- Adding auxiliary files to spec directories
- Archiving completed specs after execution
- Listing active and archived specs

**Out-of-scope:**

- General `_meta/` directory management (handled by `meta-workspace` skill)
- Project implementation (the skill prepares specs for execution; it does
  not implement them)
- Task tracking with statuses, assignments, or priorities

## Backlog File Format

```markdown
# Project Backlog

Ideas and initiatives to be fleshed out later. Items here are compact
— just enough context to remember the idea. Promote items to full
specifications when ready to design them in detail.

## Category Name

### Item Title

Brief description — a few sentences capturing the idea, context, and
initial thoughts. Keep it concise.
```

Items should be short. If a description is growing past a short paragraph,
that is a signal to promote it to a spec.

## Spec File Format

The primary `spec.md` starts from the backlog description and expands it
into a structured specification. The exact structure varies by item, but a
typical spec includes:

- **Overview** — What this is and why it matters
- **Goals** — What success looks like
- **Design** — Approach, components, key decisions
- **Open Questions** — Unresolved decisions needing input
- **References** — Related projects, prior art, links

Auxiliary files are added as needed during iteration: research notes,
diagrams, sub-specifications, or any supporting material that would clutter
the primary spec.

## Procedure

### Stage 1: Backlog Management

#### Adding an Item

1. Read `_meta/specs/project-backlog.md`.
2. Determine whether the item fits an existing category or needs a new one.
3. Append the item with a `### Title` heading and a brief description.
4. Confirm the addition to the user in one line.
5. Return to whatever the user was doing before — do not disrupt the current
   conversation's focus.

#### Listing the Backlog

1. Read `_meta/specs/project-backlog.md`.
2. Present the items to the user, optionally filtered by category if
   requested.

#### Modifying an Item

1. Read `_meta/specs/project-backlog.md`.
2. Locate the item by title.
3. Update the description, title, or category as requested.

#### Removing an Item

1. Read `_meta/specs/project-backlog.md`.
2. Locate the item by title. If multiple items share the same title across
   categories, disambiguate by category before proceeding.
3. Remove the `### Title` heading and its description. If this leaves an
   empty category (a `## Category` heading with no items beneath it), remove
   the empty category heading as well.

#### Handling Ambiguity

When an operation targets an item "by title" and multiple items share the
same or similar title across categories, ask the user to clarify which item
they mean by presenting the category and title of each match.

### Stage 2: Specification Management

#### Promoting a Backlog Item to Spec

1. Read the target item from `_meta/specs/project-backlog.md`.
2. Derive a kebab-case slug from the item title
   (e.g., "Centralized Documentation Source" → `centralized-docs`).
3. Check whether `_meta/specs/<slug>/` already exists. If it does, ask the
   user whether to merge into the existing spec or choose a different slug.
4. Create the directory `_meta/specs/<slug>/`.
5. Create `_meta/specs/<slug>/spec.md` with an expanded specification
   derived from the backlog description. Use the spec file format above as a
   starting point.
6. Remove the item from `project-backlog.md`. If this leaves an empty
   category, remove the empty category heading.
7. Present the new spec to the user for review or further iteration.

#### Iterating on a Spec

1. Read the contents of the spec directory to understand its current state.
2. Read `spec.md` (and any relevant auxiliary files).
3. Update based on user input — expand sections, resolve open questions,
   add design detail.
4. If the user provides new supporting material, create auxiliary files
   alongside `spec.md`.

#### Adding Auxiliary Files

1. Create the file in the spec directory with a descriptive kebab-case name.
2. Reference it from `spec.md` if appropriate.

#### Listing Active Specs

1. List directories under `_meta/specs/` (excluding `archive/` and the
   `project-backlog.md` file).
2. For each directory, read the first few lines of `spec.md` to present a
   summary.

### Stage 3: Execution and Archive

#### Pulling a Spec for Execution

1. Read the spec directory contents.
2. Read `spec.md` and any auxiliary files.
3. Present the full specification to guide the implementation session.

#### Archiving a Completed Spec

1. Confirm the spec has been executed or is no longer needed.
2. Check whether `_meta/specs/archive/<slug>/` already exists. If it does,
   ask the user how to proceed (e.g., rename with a suffix, overwrite).
3. Move the entire `_meta/specs/<slug>/` directory to
   `_meta/specs/archive/<slug>/`.
4. Confirm the archival to the user.

#### Listing Archived Specs

1. List directories under `_meta/specs/archive/`.
2. For each, read the first few lines of `spec.md` to present a summary.

## Constraints

**MUST:**

- Store the backlog at `_meta/specs/project-backlog.md`.
- Create spec directories matching the item slug in kebab-case.
- Name the primary spec file `spec.md` in every spec directory.
- Follow kebab-case naming for all files and directories.
- Keep quick-capture (add to backlog) to a single edit and a one-line
  confirmation — do not disrupt the user's current work.
- Preserve existing backlog category structure when adding items.
- Remove items from the backlog when they are promoted to specs.
- Move (not copy) spec directories to `archive/` on completion.

**MUST NOT:**

- Add status fields, priority numbers, or other project-management metadata
  to backlog items. The backlog is a list of ideas, not a kanban board.
- Leave promoted items in the backlog after creating their spec directory.
- Create specs as standalone files — every spec gets its own directory, even
  if it is a single file.
- Delete archived specs. The archive is append-only.
- Place backlog or spec files outside `_meta/specs/`.

**MAY:**

- Create new backlog categories when an item does not fit existing ones.
- Suggest promotion when a backlog item's description is growing too long.
- Include a brief archival note at the top of `spec.md` when archiving,
  noting when and why it was archived.
- Nest one level of subdirectories within a spec directory for complex specs
  (e.g., `_meta/specs/<slug>/research/`).

## Examples

### Example 1: Quick Capture During Unrelated Work

**Scenario:** The user is working on a Python project and mentions
"oh, also add an idea for a CLI dashboard tool to the backlog."

**Action:**

1. Read `_meta/specs/project-backlog.md`.
2. Append under the most fitting category (or create `## Tooling` if none
   fits):

```markdown
### CLI Dashboard Tool

A terminal-based dashboard for monitoring project status across
repositories.
```

3. Respond: "Added **CLI Dashboard Tool** to the backlog under Tooling."
4. Continue with the Python work.

---

### Example 2: Promoting an Item to a Spec

**Scenario:** The user says "promote the centralized docs idea to a spec."

**Action:**

1. Read the "Centralized Documentation Source" item from the backlog.
2. Create `_meta/specs/centralized-docs/`.
3. Create `_meta/specs/centralized-docs/spec.md`:

```markdown
# Centralized Documentation Source

## Overview

A centralized documentation hub serving as both a personal knowledge base
and an automated aggregation point for project documentation.

## Goals

- Provide a single location for personal notes, thoughts, and reference
  material.
- Allow each project to automatically contribute documentation through a
  standard GitHub Actions component.
- Keep documentation current without manual effort.

## Design

(To be expanded — initial thoughts on architecture, hosting, contribution
mechanism.)

## Open Questions

- What hosting platform? (GitHub Pages, dedicated site, wiki?)
- What format for contributed documentation? (Markdown, structured data?)
- How does the GHA component discover and publish content?

## References

- Previous Devdocs concept (inspiration for this initiative)
```

4. Remove "Centralized Documentation Source" from `project-backlog.md`.
5. Present the spec for review.

---

### Example 3: Iterating on a Spec

**Scenario:** The user says "add a section about the GHA component design
to the centralized docs spec."

**Action:**

1. Read `_meta/specs/centralized-docs/spec.md`.
2. Add or expand the relevant section based on user input.
3. If the detail is extensive, create
   `_meta/specs/centralized-docs/gha-component-design.md` as an auxiliary
   file and reference it from `spec.md`.

---

### Example 4: Archiving a Completed Spec

**Scenario:** The user says "the centralized docs spec has been implemented,
archive it."

**Action:**

1. Move `_meta/specs/centralized-docs/` to
   `_meta/specs/archive/centralized-docs/`.
2. Respond: "Archived **centralized-docs** spec."

---

### Example 5: Listing Active Work

**Scenario:** The user says "what specs are in progress?"

**Action:**

1. List directories under `_meta/specs/` (excluding `archive/` and
   `project-backlog.md`).
2. Read the first heading from each `spec.md`.
3. Present a summary list.
