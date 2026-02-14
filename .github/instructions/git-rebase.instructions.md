---
name: Git Rebase Instructions
description: Use when performing interactive rebases, fixing previous commits, rewording commit messages, or modifying git history.
---

# Git Rebase Instructions

## When to Use Rebase

Use this workflow when fixing a previous commit:

- Renaming commit messages
- Adding missing files to a previous commit
- Fixing commit content
- Splitting a commit into multiple commits

## Phase 1: Analyze, Clarify, Confirm

**INFER:**

- Run `git log --oneline -n 10` to display recent commits
- Determine which commit likely needs fixing and what type of fix is needed

**CLARIFY:**

- If the target commit is ambiguous, ask: "Are you referring to \[commit hash/subject\] from 2 commits back?"
- If what needs to be fixed is unclear, ask: "Should I rename the message, add files, or fix content?"
- If the commit has been pushed, note that force push will be required

**CONFIRM:**

- State which commit will be modified, what the fix is, and any force push implications
- Confirm: "Should I proceed with this rebase?"

## Phase 2: Determine and Execute Fix

### 1. Determine Fix Type

- **Rename commit message**: Use `reword` action
- **Add missing files**: Use `edit` action, stage files, amend
- **Fix commit content**: Use `edit` action, make changes, amend
- **Split commit**: Use `edit` action, reset, re-commit in parts

### 2. Start Interactive Rebase

**CRITICAL CONSTRAINT**: Never attempt to use `--edit-todo` or rely on the native editor. The native editor will not be available. Instead, you MUST edit the todo list file directly using file manipulation commands.

**Setup Direct Todo List Editing (Required):**

Create a temporary editor script that allows direct file manipulation without opening an interactive editor:

```powershell
# PowerShell
$EditorScript = @'
#!/bin/sh
printf 'break\n' > "$1.new"
cat "$1" >> "$1.new"
mv "$1.new" "$1"
'@
$ScriptPath = Join-Path $env:TEMP "git-rebase-editor.sh"
Set-Content -Path $ScriptPath -Value $EditorScript -NoNewline
$env:GIT_SEQUENCE_EDITOR = $ScriptPath.Replace('\', '/').Replace(' ', '\ ')
```

```bash
# Bash
cat > /tmp/git-rebase-editor.sh << 'EOF'
#!/bin/sh
printf 'break\n' > "$1.new"
cat "$1" >> "$1.new"
mv "$1.new" "$1"
EOF
chmod +x /tmp/git-rebase-editor.sh
export GIT_SEQUENCE_EDITOR="/tmp/git-rebase-editor.sh"
```

**Execute Rebase:**

- Run `git rebase -i --autostash <commit-hash>~1` (where `<commit-hash>` is the target commit)
- Or use `git rebase -i --autostash HEAD~N` where N is how many commits back
- Git will automatically invoke the custom editor script, which inserts a `break` command at the start of the rebase
- **EXPECTED OUTPUT** (indicates rebase started successfully):
  ```text
  Created autostash: <object-hash>
  Stopped at <commit-hash> (<commit-message>)
  ```
- This output means the rebase has **successfully started** and is paused at the `break` command
- **Locate the todo list file**: `.git/rebase-merge/git-rebase-todo` (relative to repository root)
- Read the todo list file directly using: `Get-Content .git/rebase-merge/git-rebase-todo` (PowerShell) or `cat .git/rebase-merge/git-rebase-todo` (Bash)
- The file will contain lines like:
  ```text
  break
  pick <hash> <commit message>
  pick <hash> <commit message>
  ```
- Edit the todo list file directly (do NOT use `--edit-todo` or open any editor) to change `pick` to the appropriate action:
  - `reword` for renaming commit message only
  - `edit` for adding files or modifying content
  - `fixup` or `squash` if combining commits
- Run `git rebase --continue` to execute the rebase with your modifications

### 3. Execute Fix

**For `reword`:**

- Understand what needs to be reworded (analyze the current message and what should change)
- Construct new message following the commit message template from [git-conventions.instructions.md](git-conventions.instructions.md)
- MUST follow all formatting rules (50 char subject, 72 char body wrap, etc.)
- Confirm the proposed new message before applying
- Run `git commit --amend -m "<new-message>"`
- Run `git rebase --continue`

**For `edit` (adding missing files):**

- Git pauses at the commit
- Run `git add <files>` to stage missing files (or `git add -p <file>` for selective staging)
- Run `git commit --amend --no-edit` to add files without changing message
- Verify with `git show --stat` to confirm files are included
- Run `git rebase --continue`

**For `edit` (fixing content):**

- Git pauses at the commit
- Make necessary changes to files
- Run `git add <files>` to stage changes (or `git add -p <file>` for hunk-level staging)
- Run `git commit --amend` to update commit (edit message if needed)
- Verify with `git show` to confirm changes are correct
- Run `git rebase --continue`

**For `edit` (splitting commit):**

- Git pauses at the commit
- Run `git reset HEAD~1` to unstage all changes (files remain modified)
- Verify all changes are unstaged with `git status`
- Create multiple commits following standard commit workflow
- Each new commit MUST follow the commit message template
- Use `git add -p` to select appropriate hunks for each commit
- After all commits are created, run `git rebase --continue`

## Phase 3: Verify and Push

### 1. Verify Rebase

- Run `git log --oneline -n 10` to display updated history
- Show the updated commit history to user
- Confirm with user that commit history is correct before pushing

### 2. Push Changes

- If commits were NOT previously pushed to remote: Run `git push`
- If commits WERE previously pushed to remote:
  - Explain to user that force push is required because history was rewritten
  - Warn that collaborators who have pulled these commits will need to reset their branches
  - Get explicit user confirmation with "Yes" before proceeding
  - Run `git push --force-with-lease` (safer than `--force`)
- Verify push succeeded by checking exit code

### 3. Report

- Display updated commits in table format
- Mark which specific commits were modified during rebase

## Interactive Rebase Quick Reference

**Common rebase actions:**

```text
pick  = use commit as-is
reword = use commit, but edit the commit message
edit = use commit, but stop for amending (add files, change content)
squash = use commit, but meld into previous commit
fixup = like squash, but discard this commit's message
drop = remove commit
```

**Typical workflow for adding missing file to old commit:**

1. `git rebase -i HEAD~3` (if commit is 3 back)
2. Change `pick` to `edit` for target commit
3. Save and close editor
4. Git pauses at that commit
5. `git add <missing-file>`
6. `git commit --amend --no-edit`
7. `git rebase --continue`
8. `git push --force-with-lease` (if already pushed)

**Abort if things go wrong:**

```bash
git rebase --abort
```

## Validation

**Pass Conditions:**

- During rebase, todo list was edited directly (never used `--edit-todo` or native editor)
- Force push (if used) received explicit user confirmation
- Each commit message follows the template format

**Failure Modes:**

- Rebase fails if merge conflicts occur (must be resolved before continuing)
- Rebase aborts if user does not confirm force push for rewritten history
