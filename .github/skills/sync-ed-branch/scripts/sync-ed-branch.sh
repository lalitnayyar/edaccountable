#!/usr/bin/env bash

set -euo pipefail

UPSTREAM_URL="https://github.com/ed-donner/accountable.git"
ORIGIN_URL="https://github.com/lalitnayyar/edaccountable.git"

if [[ $# -ne 1 || -z "$1" ]]; then
  echo "Usage: $0 <ed-donner-branch>" >&2
  exit 2
fi

branch=$1

if ! git check-ref-format --branch "$branch" >/dev/null 2>&1; then
  echo "Invalid branch name: $branch" >&2
  exit 2
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Run this command from inside the Accountable Git repository." >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is not clean. Commit or explicitly set aside these changes first:" >&2
  git status --short >&2
  exit 1
fi

configure_remote() {
  local name=$1
  local url=$2

  if git remote get-url "$name" >/dev/null 2>&1; then
    git remote set-url "$name" "$url"
  else
    git remote add "$name" "$url"
  fi
}

configure_remote upstream "$UPSTREAM_URL"
configure_remote origin "$ORIGIN_URL"

echo "Fetching $branch from $UPSTREAM_URL"
git fetch upstream "refs/heads/$branch:refs/remotes/upstream/$branch"

if git show-ref --verify --quiet "refs/heads/$branch"; then
  git checkout "$branch"
else
  if git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
    git fetch origin "refs/heads/$branch:refs/remotes/origin/$branch"
    git checkout --track -b "$branch" "origin/$branch"
  else
    git checkout --track -b "$branch" "upstream/$branch"
  fi
fi

if git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
  git fetch origin "refs/heads/$branch:refs/remotes/origin/$branch"
  echo "Merging origin/$branch"
  git merge --no-edit "origin/$branch"
fi

echo "Merging upstream/$branch"
git merge --no-edit "upstream/$branch"

echo "Pushing $branch to $ORIGIN_URL"
git push -u origin "$branch"
