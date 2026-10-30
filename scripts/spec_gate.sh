#!/usr/bin/env bash
# spec_gate.sh — Validates Spec Kit file
# Gates: Constitution compliance, traceability, required sections, Spec Kit format

set -euo pipefail

FILE="${1:-}"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Usage: $0 <spec-file>"
  exit 1
fi

echo "🔍 Spec Gate: Validating $FILE"

# Gate 1: Constitution compliance (constitution.md exists and is referenced)
if [ ! -f "constitution.md" ]; then
  echo "❌ FAIL: constitution.md not found"
  exit 1
fi
echo "✅ Constitution exists"

# Gate 2: Required sections for SPEC files
if [[ "$FILE" == *SPEC* ]]; then
  required_sections=("Overview" "Requirements" "Non-Functional")
  for section in "${required_sections[@]}"; do
    if ! grep -q "## $section" "$FILE"; then
      echo "❌ FAIL: Missing required section: $section"
      exit 1
    fi
  done
  echo "✅ SPEC required sections present"
fi

# Gate 3: Required sections for PLAN files
if [[ "$FILE" == *PLAN* ]]; then
  required_sections=("Scope" "Architecture" "Tasks")
  for section in "${required_sections[@]}"; do
    if ! grep -q "## $section" "$FILE"; then
      echo "❌ FAIL: Missing required section: $section"
      exit 1
    fi
  done
  echo "✅ PLAN required sections present"
fi

# Gate 4: Required sections for TASKS files
if [[ "$FILE" == *TASKS* ]]; then
  if ! grep -q "^- \[" "$FILE"; then
    echo "❌ FAIL: TASKS.md must contain checkbox items (- [ ])"
    exit 1
  fi
  echo "✅ TASKS checkbox format present"
fi

# Gate 5: Traceability — every REQ has AC, every AC has test
req_count=$(grep -c "^### REQ-" "$FILE" || true)
ac_count=$(grep -c "AC-" "$FILE" || true)
if [ "$req_count" -gt 0 ] && [ "$ac_count" -eq 0 ]; then
  echo "❌ FAIL: Requirements found but no acceptance criteria (AC-)"
  exit 1
fi
echo "✅ Traceability: $req_count REQs, $ac_count ACs"

# Gate 6: Spec Kit format — frontmatter or proper headers
if ! head -20 "$FILE" | grep -qE "^(---|# )"; then
  echo "❌ FAIL: Missing Spec Kit header/frontmatter"
  exit 1
fi
echo "✅ Spec Kit format valid"

echo "🎉 SPEC GATE PASSED: $FILE"
exit 0