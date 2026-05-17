#!/usr/bin/env bash
# Merge every open Dependabot PR sequentially and run typecheck after each.
# Stops on the first PR that breaks the build so you can review.
#
# Usage:  bash scripts/merge-all-prs.sh

set -e

# Force gh to never use a pager.
gh config set pager cat >/dev/null 2>&1 || true
export GH_PAGER=cat
export PAGER=cat

PRS=(28 29 30 31 32 33 34 35 36 37 38)

for pr in "${PRS[@]}"; do
  printf '\n============================================================\n'
  printf '  Merging PR #%s\n' "$pr"
  printf '============================================================\n'

  if ! gh pr merge "$pr" --squash --delete-branch 2>&1; then
    echo "Merge failed for PR #$pr — stopping."
    exit 1
  fi

  git fetch origin --quiet
  git checkout main --quiet 2>/dev/null || true
  git pull --ff-only origin main 2>&1 | tail -2 || true

  echo "→ typechecking…"
  if ! pnpm --filter @bagour/api-client typecheck >/dev/null 2>&1; then
    echo "api-client typecheck failed after PR #$pr — stopping."
    pnpm --filter @bagour/api-client typecheck
    exit 1
  fi
  if ! pnpm --filter ./customer-web typecheck >/dev/null 2>&1; then
    echo "customer-web typecheck failed after PR #$pr — stopping."
    pnpm --filter ./customer-web typecheck
    exit 1
  fi
  if ! pnpm --filter ./driver-web typecheck >/dev/null 2>&1; then
    echo "driver-web typecheck failed after PR #$pr — stopping."
    pnpm --filter ./driver-web typecheck
    exit 1
  fi
  echo "PR #$pr merged + typecheck clean"
done

printf '\nAll 11 PRs merged.\n'
