#!/usr/bin/env bash
# Trigger dependabot to rebase each remaining open PR, wait for the bot to
# push the new commits, then merge them in order. Stops on the first failure.
#
# Usage:  bash scripts/rebase-and-merge-remaining.sh

set -e

gh config set pager cat >/dev/null 2>&1 || true
export GH_PAGER=cat PAGER=cat

PRS=(31 32 33 34 35 36 37 38)

echo "Asking dependabot to rebase ${#PRS[@]} PRs…"
for pr in "${PRS[@]}"; do
  gh pr comment "$pr" --body "@dependabot rebase" >/dev/null 2>&1 \
    && echo "  PR #$pr — rebase requested" \
    || echo "  PR #$pr — comment failed (may already be merged/closed)"
done

echo
echo "Waiting 90 s for dependabot to push rebased commits…"
sleep 90

for pr in "${PRS[@]}"; do
  printf '\n============================================================\n'
  printf '  Merging PR #%s\n' "$pr"
  printf '============================================================\n'

  # Wait up to 5 min for the PR to leave the BLOCKED/CONFLICTING/UNKNOWN state.
  for _ in $(seq 1 30); do
    state=$(gh pr view "$pr" --json mergeable --jq '.mergeable' 2>/dev/null || echo "ERROR")
    if [ "$state" = "MERGEABLE" ]; then break; fi
    if [ "$state" = "CONFLICTING" ]; then
      echo "PR #$pr is still CONFLICTING after rebase — skipping."
      break
    fi
    echo "  (state=$state, waiting 10 s…)"
    sleep 10
  done

  if [ "$state" != "MERGEABLE" ]; then
    echo "Skipping PR #$pr (state=$state)."
    continue
  fi

  if ! gh pr merge "$pr" --squash --delete-branch 2>&1; then
    echo "Merge failed for PR #$pr — stopping."
    exit 1
  fi

  git fetch origin --quiet
  git checkout main --quiet 2>/dev/null || true
  git pull --rebase origin main 2>&1 | tail -2 || true

  echo "→ typechecking…"
  pnpm --filter @bagour/api-client typecheck >/dev/null 2>&1 || {
    echo "api-client typecheck failed after PR #$pr"; pnpm --filter @bagour/api-client typecheck; exit 1; }
  pnpm --filter ./customer-web typecheck >/dev/null 2>&1 || {
    echo "customer-web typecheck failed after PR #$pr"; pnpm --filter ./customer-web typecheck; exit 1; }
  pnpm --filter ./driver-web typecheck >/dev/null 2>&1 || {
    echo "driver-web typecheck failed after PR #$pr"; pnpm --filter ./driver-web typecheck; exit 1; }
  echo "PR #$pr merged + typecheck clean"
done

echo
echo "Done. Remaining open PRs (if any):"
gh pr list --state open --json number,title --jq '.[] | "  #\(.number) \(.title)"'
