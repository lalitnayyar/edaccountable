---
name: sync-ed-branch
description: "Sync an Ed Donner lecture branch from https://github.com/ed-donner/accountable.git into the same-named branch and push it to https://github.com/lalitnayyar/edaccountable.git. Use when the user names an Ed Donner branch and asks to merge, sync, pull, or update their fork."
argument-hint: "<ed-donner-branch>"
user-invocable: true
disable-model-invocation: false
---

# Sync Ed Donner Branch

Merge one named lecture branch from Ed Donner's repository into the same-named
branch in the user's repository, then push the result.

## Inputs

The user supplies one exact branch name, such as `week1day3-end`.

Do not infer a different branch. Ask for the branch if none was supplied.

## Fixed repositories

- `upstream`: `https://github.com/ed-donner/accountable.git`
- `origin`: `https://github.com/lalitnayyar/edaccountable.git`

## Procedure

1. Run:

   ```bash
   bash .github/skills/sync-ed-branch/scripts/sync-ed-branch.sh "<branch>"
   ```

2. If the script refuses to run because the working tree is dirty, report the
   changed files. Do not discard, stash, or commit them without asking.
3. If merging reports conflicts, stop. Report the conflicting files and ask the
   user to choose how they should be resolved. Never force-push or silently
   choose either side.
4. If the script fails because the branch does not exist, report the exact
   branch and source URL. Do not substitute another branch.
5. After success, run `git status --short --branch` and report the branch and
   pushed repository.

## Safety

- Never use `git push --force` or `git push --force-with-lease`.
- Preserve personal commits already on the destination branch.
- Do not commit unrelated files.
- Do not rebase or rewrite existing history.
