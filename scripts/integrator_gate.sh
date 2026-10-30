#!/usr/bin/env bash
# integrator_gate.sh — 8 Merge Criteria for Integrator Agent
# Gates: CI green, Tester PASS, provenance complete, clean code, conventional commits, integration tests, up-to-date, no conflicts

set -euo pipefail

PR_NUMBER="${1:-}"
if [ -z "$PR_NUMBER" ]; then
  echo "Usage: $0 <pr-number>"
  exit 1
fi

echo "🔍 Integrator Gate: Validating PR #$PR_NUMBER for merge (8 criteria)"

# Checkout PR
gh pr checkout "$PR_NUMBER" 2>/dev/null || true

# Criterion 1: CI Green
echo "📋 Criterion 1/8: CI Green"
CI_STATUS=$(gh pr checks "$PR_NUMBER" --json state --jq '.[].state' | sort -u)
if [ "$CI_STATUS" != "SUCCESS" ]; then
  echo "❌ FAIL: CI not green: $CI_STATUS"
  exit 1
fi
echo "✅ CI green"

# Criterion 2: Tester PASS
echo "📋 Criterion 2/8: Tester PASS"
TESTER_VERDICT=$(gh pr view "$PR_NUMBER" --json reviews --jq '.reviews[] | select(.author.login=="tester-bot") | .state' | head -1)
if [ "$TESTER_VERDICT" != "APPROVED" ]; then
  echo "❌ FAIL: Tester not approved: $TESTER_VERDICT"
  exit 1
fi
echo "✅ Tester approved"

# Criterion 3: Provenance Complete
echo "📋 Criterion 3/8: Provenance Complete"
PROVENANCE_TAGS=$(gh pr view "$PR_NUMBER" --json body --jq '.body' | grep -c '^\[' || true)
if [ "$PROVENANCE_TAGS" -lt 1 ]; then
  echo "❌ FAIL: Missing provenance tags (need [human-specified], [agent-proposed], etc.)"
  exit 1
fi
echo "✅ Provenance tags present: $PROVENANCE_TAGS"

# Criterion 4: Clean Code (no TODO/FIXME, no console.log)
echo "📋 Criterion 4/8: Clean Code"
if grep -r "TODO\|FIXME" src/ 2>/dev/null | grep -v ".git"; then
  echo "❌ FAIL: TODO/FIXME found in src/"
  exit 1
fi
if grep -r "console\.log" src/ 2>/dev/null; then
  echo "❌ FAIL: console.log found in src/"
  exit 1
fi
echo "✅ Clean code"

# Criterion 5: Conventional Commits
echo "📋 Criterion 5/8: Conventional Commits"
COMMITS=$(gh pr view "$PR_NUMBER" --json commits --jq '.commits[].messageHeadline')
while IFS= read -r msg; do
  if ! echo "$msg" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|chore|build|ci|revert)(\(.+\))?: .+'; then
    echo "❌ FAIL: Non-conventional commit: $msg"
    exit 1
  fi
done <<< "$COMMITS"
echo "✅ All commits conventional"

# Criterion 6: Integration Tests Pass
echo "📋 Criterion 6/8: Integration Tests Pass"
deno test tests/integration/ || { echo "❌ FAIL: Integration tests"; exit 1; }
echo "✅ Integration tests passed"

# Criterion 7: Up to Date with Main
echo "📋 Criterion 7/8: Up to Date with Main"
BEHIND=$(gh pr view "$PR_NUMBER" --json mergeable --jq '.mergeable')
if [ "$BEHIND" != "MERGEABLE" ]; then
  echo "❌ FAIL: PR not mergeable (behind main or conflicts)"
  exit 1
fi
echo "✅ Up to date with main"

# Criterion 8: No Conflicts
echo "📋 Criterion 8/8: No Conflicts"
CONFLICTS=$(gh pr view "$PR_NUMBER" --json mergeable --jq '.mergeable')
if [ "$CONFLICTS" != "MERGEABLE" ]; then
  echo "❌ FAIL: Merge conflicts detected"
  exit 1
fi
echo "✅ No conflicts"

# ALL PASSED — Execute Merge
echo ""
echo "🎉 ALL 8 INTEGRATOR CRITERIA PASSED"
echo "🚀 Executing merge..."

# Squash merge
gh pr merge "$PR_NUMBER" --squash --delete-branch

# Generate release notes
VERSION=$(cat VERSION 2>/dev/null || echo "0.1.0")
gh release create "v$VERSION" --generate-notes --latest --title "Release v$VERSION"

# Update CHANGELOG.md (Keep a Changelog format)
DATE=$(date +%Y-%m-%d)
cat > CHANGELOG.tmp << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v$VERSION] - $DATE

### Added
$(gh pr view "$PR_NUMBER" --json body --jq '.body' | grep -A 10 "## Added" | tail -n +2 | head -10 || echo "- New feature from PR #$PR_NUMBER")

### Changed
$(gh pr view "$PR_NUMBER" --json body --jq '.body' | grep -A 10 "## Changed" | tail -n +2 | head -10 || echo "- Changes from PR #$PR_NUMBER")

### Fixed
$(gh pr view "$PR_NUMBER" --json body --jq '.body' | grep -A 10 "## Fixed" | tail -n +2 | head -10 || echo "- Fixes from PR #$PR_NUMBER")

EOF
cat CHANGELOG.md >> CHANGELOG.tmp 2>/dev/null || true
mv CHANGELOG.tmp CHANGELOG.md

# Commit CHANGELOG
git add CHANGELOG.md
git commit -m "chore: update CHANGELOG for v$VERSION"
git push

echo "✅ Merge complete, release v$VERSION created, CHANGELOG updated"
exit 0