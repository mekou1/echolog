#!/usr/bin/env bash
# create-tickets.sh — Creates GitHub tickets from DEMO_APP_SPEC.md
# Each ticket = 1 Spec Kit file (spec/plan/tasks/code/test/integrate)

set -euo pipefail

REPO="mekou1/echolog"

echo "🎫 Creating tickets for EchoLog demo..."

# Function to create issue
create_issue() {
  local title="$1"
  local body="$2"
  local labels="$3"
  local milestone="$4"
  
  gh issue create --repo "$REPO" --title "$title" --body "$body" --label "$labels" --milestone "$milestone"
}

# Milestone IDs (created in setup-repo.sh)
MS_SPEC="v0.1 - Spec & Scaffold"
MS_CORE="v0.2 - Core Implementation"
MS_PROD="v1.0 - Production Ready"

echo "Creating SPEC/PLAN/TASKS tickets (v0.1 milestone)..."

# SPEC-001 (already created in setup-repo.sh, but create ticket for tracking)
create_issue \
  "[SPEC] SPEC-001: EchoLog Core Features" \
  "## Spec Kit Specification

**Spec ID**: SPEC-001
**Type**: spec
**Agent**: Specifier

## Requirements (from DEMO_APP_SPEC.md)

### REQ-001: Core Logger
- **Function**: log(level, message, context)
- **Levels**: debug, info, warn, error
- **Output**: Structured JSON to stdout

### REQ-002: JSON Transport
- **Flag**: --json
- **Output**: Single-line JSON per log entry

### REQ-003: File Transport
- **Flag**: --file <path>
- **Output**: Append JSON lines to file

### REQ-004: Pretty Print
- **Flag**: --pretty
- **Output**: Human-readable colored output

### REQ-005: Log Levels Filter
- **Flag**: --level <level>
- **Behavior**: Only log >= level

## Acceptance Criteria
- AC-001: Logger accepts level, message, context object
- AC-002: Outputs valid JSON with level, message, timestamp, context
- AC-003: --json flag produces single-line JSON
- AC-004: --file <path> appends JSON lines to file
- AC-005: --pretty flag produces colored human-readable output
- AC-006: --level filters logs correctly (debug > info > warn > error)

## Provenance
- [human-specified] All requirements from DEMO_APP_SPEC.md" \
  "spec,plan,tasks,agent:specifier,priority:high" \
  "$MS_SPEC"

# PLAN-001
create_issue \
  "[PLAN] PLAN-001: EchoLog Implementation Plan" \
  "## Spec Kit Plan

**Plan ID**: PLAN-001
**Type**: plan
**Agent**: Specifier
**Depends on**: SPEC-001

## Scope
Implement SPEC-001 (REQ-001 through REQ-005).

## Architecture
- \`src/main.ts\` — CLI entry point (args parsing)
- \`src/logger.ts\` — Core logger (<50 lines)
- \`src/transports/console.ts\` — Console transport
- \`src/transports/file.ts\` — File transport
- \`src/transports/json.ts\` — JSON formatter
- \`src/levels.ts\` — Log levels enum

## Tasks
- TASK-001: Project structure + deno.json
- TASK-002: Core logger (\`src/logger.ts\`)
- TASK-003: Console transport
- TASK-004: File transport
- TASK-005: JSON formatter
- TASK-006: CLI argument parsing
- TASK-007: Unit tests (logger, transports)
- TASK-008: Integration tests (CLI)
- TASK-009: Contract tests (output format)

## Provenance
- [human-specified] Architecture from DEMO_APP_SPEC.md
- [agent-proposed] Modular transport pattern" \
  "plan,agent:specifier,priority:high" \
  "$MS_SPEC"

# TASKS-001
create_issue \
  "[TASKS] TASKS-001: EchoLog Task Breakdown" \
  "## Spec Kit Tasks

**Tasks ID**: TASKS-001
**Type**: tasks
**Agent**: Specifier
**Depends on**: PLAN-001

## Task Breakdown

### TASK-001: Project Structure + deno.json
- [ ] Create \`src/\`, \`tests/unit/\`, \`tests/contract/\`, \`tests/integration/\`
- [ ] Create \`deno.json\` with tasks (dev, test, lint, check, fmt)
- [ ] Create \`deno.lock\`
- **Acceptance**: \`deno check src/\` passes

### TASK-002: Core Logger (\`src/logger.ts\`)
- [ ] Implement \`Logger\` class with \`log(level, message, context)\`
- [ ] Support levels: debug, info, warn, error
- [ ] Accept context object, serialize to JSON
- **Acceptance**: Unit test passes, \`deno check\` passes

### TASK-003: Console Transport
- [ ] Implement \`ConsoleTransport\` class
- [ ] Write formatted logs to stdout
- **Acceptance**: Integration test passes

### TASK-004: File Transport
- [ ] Implement \`FileTransport\` class
- [ ] Append JSON lines to file
- **Acceptance**: Integration test with temp file passes

### TASK-005: JSON Formatter
- [ ] Implement \`JsonFormatter\` class
- [ ] Single-line JSON output per log entry
- **Acceptance**: Contract test validates JSON structure

### TASK-006: CLI Argument Parsing
- [ ] Parse \`--json\`, \`--file\`, \`--pretty\`, \`--level\` flags
- [ ] Map to logger configuration
- **Acceptance**: Integration test with all flags passes

### TASK-007: Unit Tests
- [ ] Test logger levels
- [ ] Test context serialization
- [ ] Test transport isolation
- **Acceptance**: \`deno test tests/unit/\` passes, coverage ≥90%

### TASK-008: Integration Tests
- [ ] Test CLI with all flag combinations
- [ ] Test file transport writes correctly
- [ ] Test level filtering
- **Acceptance**: \`deno test tests/integration/\` passes

### TASK-009: Contract Tests
- [ ] Validate JSON output structure
- [ ] Validate log level filtering
- [ ] Validate context preservation
- **Acceptance**: \`deno test tests/contract/\` passes

## Provenance
- [human-specified] Task breakdown from DEMO_APP_SPEC.md
- [agent-proposed] Modular transport pattern" \
  "tasks,agent:specifier,priority:high" \
  "$MS_SPEC"

echo "Creating CODE tickets (v0.2 milestone)..."

# Code tickets - one per TASK
CODE_TASKS=(
  "TASK-001: Project structure + deno.json"
  "TASK-002: Core logger (src/logger.ts)"
  "TASK-003: Console transport"
  "TASK-004: File transport"
  "TASK-005: JSON formatter"
  "TASK-006: CLI argument parsing"
  "TASK-007: Unit tests"
  "TASK-008: Integration tests"
  "TASK-009: Contract tests"
)

for i in "${!CODE_TASKS[@]}"; do
  task="${CODE_TASKS[$i]}"
  create_issue \
    "[CODE] $task" \
    "## Code Implementation

**Task**: $task
**Type**: code
**Agent**: Coder
**Depends on**: TASKS-001

## Instructions
Implement this task following TDD:
1. Write failing test first (tests/unit/ or tests/integration/)
2. Implement minimal code to pass
3. Refactor
4. Run coder_gates.sh (7 gates)

## Provenance
- [agent-proposed] Implementation approach
- [test-driven] Gate failures drive fixes
- [implementation-detail] Concrete code choices" \
    "code,agent:coder,priority:high" \
    "$MS_CORE"
done

echo "Creating TEST tickets (v0.2 milestone)..."

# Test tickets
TEST_SUITES=(
  "Unit tests (logger, transports)"
  "Integration tests (CLI flags)"
  "Contract tests (JSON output structure)"
)

for suite in "${TEST_SUITES[@]}"; do
  create_issue \
    "[TEST] $suite" \
    "## Test Suite

**Suite**: $suite
**Type**: test
**Agent**: Tester
**Depends on**: Corresponding code tickets

## Instructions
Independently validate the implementation:
1. Fresh checkout of PR branch
2. Run tester_gates.sh (8 gates + 5 security scans)
3. Verify ALL acceptance criteria from SPEC.md
4. Post PR review with PASS/FAIL

## Provenance
- [test-driven] Gate failures drive fixes
- [collaborative] Test/Coder coordination on edge cases" \
    "test,agent:tester,priority:high" \
    "$MS_CORE"
done

echo "Creating INTEGRATE tickets (v1.0 milestone)..."

# Integrate tickets
create_issue \
  "[INTEGRATE] v0.1.0 Release - Spec & Scaffold" \
  "## Release Integration

**Release**: v0.1.0
**Type**: integrate
**Agent**: Integrator
**Depends on**: SPEC-001, PLAN-001, TASKS-001

## Merge Criteria (integrator_gate.sh)
- [ ] CI green (lint, typecheck, test, security)
- [ ] Tester PASS
- [ ] Provenance complete
- [ ] Clean code (no TODO/FIXME, no console.log)
- [ ] Conventional commits
- [ ] Integration tests pass
- [ ] Up to date with main
- [ ] No conflicts

## Actions
- Squash merge
- Tag v0.1.0
- AI release notes
- Update CHANGELOG.md (Keep a Changelog)
- GitOps deploy

## Provenance
- [human-specified] Release criteria from methodology
- [agent-proposed] Release automation" \
  "integrate,agent:integrator,priority:high" \
  "$MS_PROD"

create_issue \
  "[INTEGRATE] v0.2.0 Release - Core Features" \
  "## Release Integration

**Release**: v0.2.0
**Type**: integrate
**Agent**: Integrator
**Depends on**: All code + test tickets

## Merge Criteria (integrator_gate.sh)
- [ ] CI green (lint, typecheck, test, security)
- [ ] Tester PASS for all features
- [ ] Provenance complete
- [ ] Clean code
- [ ] Conventional commits
- [ ] Integration tests pass
- [ ] Up to date with main
- [ ] No conflicts

## Actions
- Squash merge all feature PRs
- Tag v0.2.0
- AI release notes (categorized)
- Update CHANGELOG.md
- GitOps deploy to staging
- Smoke tests
- Promote to production

## Provenance
- [human-specified] Release criteria
- [agent-proposed] Release automation" \
  "integrate,agent:integrator,priority:high" \
  "$MS_PROD"

create_issue \
  "[INTEGRATE] v1.0.0 Release - Modification + Production" \
  "## Release Integration

**Release**: v1.0.0
**Type**: integrate
**Agent**: Integrator
**Depends on**: All features + MOD ticket

## Modification: Add debug level
- [MOD] Add debug level (below info)
- Follows same 4-agent loop

## Final Release
- All features + modification
- Complete CHANGELOG
- Production deployment

## Provenance
- [human-specified] Full methodology demo
- [agent-proposed] End-to-end automation" \
  "integrate,agent:integrator,priority:high" \
  "$MS_PROD"

echo "Creating MODIFICATION ticket..."
create_issue \
  "[MOD] Add debug level (below info)" \
  "## Feature Modification

**Modification**: Add debug level
**Type**: spec,plan,tasks,code,test,integrate (full loop)
**Depends on**: v0.2.0 release

## Requirement
- **REQ-006**: Add debug level (below info)
- **Function**: log(debug, message, context)
- **Behavior**: Only outputs when --level debug set

## Acceptance Criteria
- AC-007: debug level added to levels enum
- AC-008: --level debug enables debug output
- AC-009: Default level (info) excludes debug

## Full Agent Loop Required
This modification goes through ALL 4 agents:
1. Specifier: Update SPEC/PLAN/TASKS
2. Coder: Implement debug level
3. Tester: Validate debug level
4. Integrator: Release v1.0.0

## Provenance
- [human-specified] Modification from DEMO_APP_SPEC.md
- [agent-proposed] Implementation approach" \
  "spec,plan,tasks,code,test,integrate,agent:specifier,priority:high" \
  "$MS_PROD"

echo ""
echo "✅ All tickets created!"
echo "Run: ./scripts/run-tickets.sh to start the agent loop"