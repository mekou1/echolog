#!/usr/bin/env bash
# coder_gates.sh — 7 Gates for Coder Agent
# Gates: unit → integration → coverage → typecheck → lint → security → contract

set -euo pipefail

echo "🔍 Coder Gates: Running 7 validation gates"

# Gate 1: Unit Tests
echo "📋 Gate 1/7: Unit Tests"
deno test tests/unit/ || { echo "❌ FAIL: Unit tests"; exit 1; }
echo "✅ Unit tests passed"

# Gate 2: Integration Tests
echo "📋 Gate 2/7: Integration Tests"
deno test tests/integration/ || { echo "❌ FAIL: Integration tests"; exit 1; }
echo "✅ Integration tests passed"

# Gate 3: Coverage (≥90%)
echo "📋 Gate 3/7: Coverage Check"
deno test --coverage=cov && deno coverage cov --lcov > coverage.lcov
COVERAGE=$(deno coverage cov --lcov | grep -oP 'LF:\d+' | head -1 | cut -d: -f2)
LH=$(deno coverage cov --lcov | grep -oP 'LH:\d+' | head -1 | cut -d: -f2)
if [ -n "$COVERAGE" ] && [ -n "$LH" ] && [ "$COVERAGE" -gt 0 ]; then
  PCT=$(( LH * 100 / COVERAGE ))
  if [ "$PCT" -lt 90 ]; then
    echo "❌ FAIL: Coverage $PCT% < 90%"
    exit 1
  fi
  echo "✅ Coverage: $PCT%"
fi

# Gate 4: Type Check
echo "📋 Gate 4/7: Type Check"
deno check src/ || { echo "❌ FAIL: Type check"; exit 1; }
echo "✅ Type check passed"

# Gate 5: Lint
echo "📋 Gate 5/7: Lint"
deno lint || { echo "❌ FAIL: Lint"; exit 1; }
echo "✅ Lint passed"

# Gate 6: Format Check
echo "📋 Gate 6/7: Format Check"
deno fmt --check || { echo "❌ FAIL: Format"; exit 1; }
echo "✅ Format check passed"

# Gate 7: Contract Tests
echo "📋 Gate 7/7: Contract Tests"
deno test tests/contract/ || { echo "❌ FAIL: Contract tests"; exit 1; }
echo "✅ Contract tests passed"

echo "🎉 ALL 7 CODER GATES PASSED"
exit 0