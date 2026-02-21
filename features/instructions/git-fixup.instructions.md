---
name: Git Fixup Instructions
description: Use when creating fixup commits to automatically squash changes into a previous commit while discarding the fixup's message.
---

# Git Fixup Instructions

## What is a Fixup Commit?

A fixup commit is a special commit that automatically squashes into a previous commit during rebase, with the fixup commit's message discarded. It's useful for:

- Adding forgotten changes to an already-committed change without a complex rebase
- Fixing lint errors, typos, or minor bugs in a previous commit
- Keeping your working directory clean before the final rebase

**Fixup vs. Edit:**

- **Fixup**: Quick way to add small changes to a previous commit; message is discarded; fully automated during rebase with no user interaction
- **Edit** (via [git-rebase.instructions.md](git-rebase.instructions.md)): Interactive rebase requiring explicit decisions and manual editing at each step; allows message rewording or structural changes

## When to Use Fixup

Use fixup commits when:

1. You've already committed a change and need to add forgotten files or minor fixes
2. You want to keep your local history clean without amending the original commit
3. You plan to squash all fixups into their target commits before pushing
4. The fix is logically part of the previous commit, not a separate concern

**Do NOT use fixup when:**

- You need to reword the commit message
- You need to split a commit into multiple commits
- You need to reorder commits
- The change is a separate logical concern (create a new commit instead)

## Workflow: Create and Apply Fixup

### Phase 1: Identify Target Commit

1. **Display recent history**:

   ```bash
   git log --oneline -n 10
   ```

2. **Identify which commit needs the fix**:
   - Determine the specific commit hash and subject
   - Confirm with user if necessary: "Should I create a fixup for commit \[hash: subject\]?"

### Phase 2: Stage and Create Fixup Commit

1. **Make your changes** to files in the working directory

2. **Stage the changes**:

   ```bash
   git add <files>
   # or for selective staging:
   git add -p <file>
   ```

3. **Create fixup commit** (use the exact target commit hash):

   ```bash
   git commit --fixup=<TARGET_COMMIT_HASH>
   ```

   - This creates a commit with message: `fixup! <TARGET_COMMIT_MESSAGE>`
   - Git automatically references the target commit

4. **Verify fixup commit was created**:
   ```bash
   git log --oneline -n 3
   ```

   - Should show: `fixup! <target-message>` as the most recent commit

### Phase 3: Apply Fixup via Autosquash Rebase (Non-Interactive)

1. **Execute autosquash rebase** (non-interactive mode):

   ```bash
   git rebase --autosquash <TARGET_COMMIT_HASH>~1
   ```

   - Or use: `git rebase --autosquash HEAD~N` where N is how many commits to rebase
   - The `--autosquash` flag automatically moves fixup commits into position and marks them as `fixup`
   - Without `-i`, the rebase runs fully automated without requiring any interactive input

   **EXPECTED OUTPUT**:

   ```text
   Rebasing ...
   Successfully rebased ...
   ```

2. **Git automatically reorders and squashes**:
   - The rebase completes without pausing or user interaction
   - The fixup commit is merged into its target commit
   - The fixup commit's message is discarded
   - The target commit is modified to include the fixup changes

3. **Verify rebase succeeded**:
   ```bash
   git log --oneline -n 5
   ```

   - The fixup commit should no longer appear in history
   - The target commit should now include the changes
   - You should see fewer commits than before (target + fixup → target only)

### Phase 4: Verify and Push

1. **Verify the squashed commit contains correct changes**:

   ```bash
   git show <SQUASHED_COMMIT_HASH>
   ```

   - Verify that both original content and fixup changes are present

2. **Determine push strategy**:
   - If commits were NOT previously pushed to remote: `git push`
   - If commits WERE previously pushed to remote:
     - Force push is required: `git push --force-with-lease`
     - Get explicit user confirmation before force pushing
     - Warn user that collaborators need to reset their branches

3. **Verify push succeeded**:
   - Check exit code is 0

## Multiple Fixups for Different Commits

If you have multiple fixup commits targeting different commits:

```bash
# Create fixups for different commits
git commit --fixup=<HASH1>  # fixup for commit 1
git commit --fixup=<HASH2>  # fixup for commit 2
git commit --fixup=<HASH1>  # another fixup for commit 1

# Autosquash handles all of them automatically (non-interactive)
git rebase --autosquash <OLDEST_COMMIT>~1

# Result: All fixups are applied to their respective commits
```

The `--autosquash` flag automatically reorders fixups to their correct positions, marks them all as `fixup`, and applies the entire rebase without user interaction.

## Troubleshooting

**Fixup commit went to wrong commit:**

- Run `git rebase --abort` to cancel
- Verify the target commit hash with `git log --oneline`
- Reset the incorrect fixup commit: `git reset --soft HEAD~1`
- Create a new fixup with correct hash: `git commit --fixup=<CORRECT_HASH>`

**Need to amend the target commit's message:**

- Use [git-rebase.instructions.md](git-rebase.instructions.md) with interactive rebase instead
- Fixup is for changes only, not message modifications

**Fixup contains changes for multiple different concerns:**

- Run `git rebase --abort`
- Create separate fixup commits for each target
- Use autosquash to apply all of them together

**Merge conflicts during autosquash:**

- The rebase will pause automatically
- Run `git status` to identify conflicted files
- Resolve conflicts manually by editing files
- Run `git add <resolved-files>` to stage resolutions
- Run `git rebase --continue` to resume automation

## Quick Reference

| Task                               | Command                              |
| ---------------------------------- | ------------------------------------ |
| Create fixup for commit            | `git commit --fixup=<HASH>`          |
| Apply all fixups (non-interactive) | `git rebase --autosquash <OLDEST>~1` |
| Abort rebase if wrong              | `git rebase --abort`                 |
| View squashed result               | `git show <HASH>`                    |
| Force push after rebase            | `git push --force-with-lease`        |

## Validation

**Pass Conditions:**

- Fixup commit created with `--fixup=<HASH>` pointing to correct target
- Autosquash rebase executed without user intervention errors
- Fixup commit message follows pattern: `fixup! <TARGET_MESSAGE>`
- After rebase, fixup commit no longer appears in history
- Target commit contains both original and fixup changes
- Each fixup applied to correct target commit
- Force push (if required) received explicit user confirmation

**Failure Modes:**

- Autosquash fails to reorder fixup commits (wrong hash or hash not found)
- Rebase aborts due to merge conflicts
- User does not confirm force push when required
- Fixup contains changes for unrelated files instead of current concern
