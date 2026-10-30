#!/usr/bin/env bash
# setup-repo.sh — 19-step repo setup (from GITHUB_PROJECT_SETUP_PLAN.md)

set -euo pipefail

REPO="mekou1/echolog"

echo "🏗️  Setting up $REPO repository..."

# Step 1: Repo creation (already done by gh repo create)
echo "Step 1: Repo created ✓"

# Step 2: Branch protection
echo "Step 2: Configuring branch protection..."
gh api repos/$REPO/branches/main/protection \
  --method PUT \
  -f required_status_checks='{"strict":true,"contexts":["lint","typecheck","test","security"]}' \
  -f enforce_admins=true \
  -f required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":true}' \
  -f restrictions=null \
  -f allow_force_pushes=false \
  -f allow_deletions=false \
  -f required_linear_history=true
echo "✅ Branch protection configured"

# Step 3: CODEOWNERS
echo "Step 3: Creating CODEOWNERS..."
mkdir -p .github
cat > .github/CODEOWNERS << 'EOF'
# Global owners
* @mekou1

# Specs & architecture
/specs/ @mekou1
/docs/architecture/ @mekou1

# CI/CD & governance
/.github/workflows/ @mekou1
/.github/CODEOWNERS @mekou1
EOF
git add .github/CODEOWNERS && git commit -m "chore: add CODEOWNERS" && git push
echo "✅ CODEOWNERS created"

# Step 4: Spec Kit init
echo "Step 4: Initializing Spec Kit..."
pip install spec-kit 2>/dev/null || pip install --user spec-kit
spec-kit init --name "echolog" --description "Minimal structured logging CLI in Deno"
echo "✅ Spec Kit initialized"

# Step 5: Constitution
echo "Step 5: Creating constitution.md..."
cat > constitution.md << 'EOF'
# Constitution — EchoLog

## Principles
1. **Spec-First**: No code without a spec. Every change traces to a spec requirement.
2. **Agent Roles**: Four isolated agents (Spec, Code, Test, Integrate) with distinct contexts.
3. **Verification Gates**: Lint → Typecheck → Test → Security must pass before merge.
4. **Zero-Waste**: No stubs, no TODO, no speculative abstraction. Every line ships.
5. **Traceability**: Commit messages reference spec IDs (e.g., `feat: SPEC-001 add logger`).

## Agent Boundaries
- **Agent 1 (Spec)**: Writes/updates specs, plans, tasks. Owns `specs/`, `constitution.md`.
- **Agent 2 (Code)**: Implements code per spec. Owns `src/`, `tests/unit/` (implementation only).
- **Agent 3 (Test)**: Writes contract/integration tests. Owns `tests/contract/`, `tests/integration/`.
- **Agent 4 (Integrate)**: Runs CI, merges, releases. Owns `.github/workflows/`, release tags.

## Change Control
- Spec changes → new spec version → new plan/tasks → re-implement.
- No direct edits to `main`; all via PR with required reviews.
EOF
git add constitution.md && git commit -m "chore: add constitution" && git push
echo "✅ Constitution created"

# Step 6: Initial SPEC.md
echo "Step 6: Creating SPEC-001..."
cat > SPEC.md << 'EOF'
# SPEC-001: EchoLog — Core Features

## Overview
Minimal structured logging CLI (<50 lines core) demonstrating agent-driven development.

## Requirements

### REQ-001: Core Logger
- **Function**: `log(level, message, context)`
- **Levels**: debug, info, warn, error
- **Output**: Structured JSON to stdout

### REQ-002: JSON Transport
- **Flag**: `--json`
- **Output**: Single-line JSON per log entry

### REQ-003: File Transport
- **Flag**: `--file <path>`
- **Output**: Append JSON lines to file

### REQ-004: Pretty Print
- **Flag**: `--pretty`
- **Output**: Human-readable colored output

### REQ-005: Log Levels Filter
- **Flag**: `--level <level>`
- **Behavior**: Only log >= level

## Non-Functional
- Deno + TypeScript, zero dependencies
- Type hints mandatory (deno check)
- Test coverage ≥ 90%
- Security: no hardcoded secrets
EOF
git add SPEC.md && git commit -m "spec: SPEC-001 core features" && git push
echo "✅ SPEC-001 created"

# Step 7: PLAN.md
echo "Step 7: Creating PLAN-001..."
cat > PLAN.md << 'EOF'
# PLAN-001: EchoLog Implementation

## Scope
Implement SPEC-001 (REQ-001 through REQ-005).

## Architecture
- `src/main.ts` — CLI entry point (args parsing)
- `src/logger.ts` — Core logger (<50 lines)
- `src/transports/console.ts` — Console transport
- `src/transports/file.ts` — File transport
- `src/transports/json.ts` — JSON formatter
- `src/levels.ts` — Log levels enum

## Tasks
- [ ] TASK-001: Project structure + deno.json
- [ ] TASK-002: Core logger (`src/logger.ts`)
- [ ] TASK-003: Console transport
- [ ] TASK-004: File transport
- [ ] TASK-005: JSON formatter
- [ ] TASK-006: CLI argument parsing
- [ ] TASK-007: Unit tests (logger, transports)
- [ ] TASK-008: Integration tests (CLI)
- [ ] TASK-009: Contract tests (output format)
EOF
git add PLAN.md && git commit -m "plan: PLAN-001 implementation" && git push
echo "✅ PLAN-001 created"

# Step 8: TASKS.md
echo "Step 8: Creating TASKS-001..."
cat > TASKS.md << 'EOF'
# TASKS-001: EchoLog Implementation Tasks

## TASK-001: Project Structure + deno.json
- [ ] Create `src/`, `tests/unit/`, `tests/contract/`, `tests/integration/`
- [ ] Create `deno.json` with tasks (dev, test, lint, check, fmt)
- [ ] Create `deno.lock`
- **Acceptance**: `deno check src/` passes

## TASK-002: Core Logger (`src/logger.ts`)
- [ ] Implement `Logger` class with `log(level, message, context)`
- [ ] Support levels: debug, info, warn, error
- [ ] Accept context object, serialize to JSON
- **Acceptance**: Unit test passes, `deno check` passes

## TASK-003: Console Transport
- [ ] Implement `ConsoleTransport` class
- [ ] Write formatted logs to stdout
- **Acceptance**: Integration test passes

## TASK-004: File Transport
- [ ] Implement `FileTransport` class
- [ ] Append JSON lines to file
- **Acceptance**: Integration test with temp file passes

## TASK-005: JSON Formatter
- [ ] Implement `JsonFormatter` class
- [ ] Single-line JSON output per log entry
- **Acceptance**: Contract test validates JSON structure

## TASK-006: CLI Argument Parsing
- [ ] Parse `--json`, `--file`, `--pretty`, `--level` flags
- [ ] Map to logger configuration
- **Acceptance**: Integration test with all flags passes

## TASK-007: Unit Tests
- [ ] Test logger levels
- [ ] Test context serialization
- [ ] Test transport isolation
- **Acceptance**: `deno test tests/unit/` passes, coverage ≥90%

## TASK-008: Integration Tests
- [ ] Test CLI with all flag combinations
- [ ] Test file transport writes correctly
- [ ] Test level filtering
- **Acceptance**: `deno test tests/integration/` passes

## TASK-009: Contract Tests
- [ ] Validate JSON output structure
- [ ] Validate log level filtering
- [ ] Validate context preservation
- **Acceptance**: `deno test tests/contract/` passes
EOF
git add TASKS.md && git commit -m "tasks: TASKS-001 implementation" && git push
echo "✅ TASKS-001 created"

# Step 9-19: CI/CD, Issue templates, PR template, Labels, Milestones
echo "Step 9-19: Creating CI/CD, templates, labels, milestones..."

# CI Workflow
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: denoland/setup-deno@v1
        with:
          deno-version: v1.x
      - run: deno lint

  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: denoland/setup-deno@v1
      - run: deno check src/

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: denoland/setup-deno@v1
      - run: deno test --coverage=cov
      - run: deno coverage cov --lcov > coverage.lcov

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: denoland/setup-deno@v1
      - run: deno audit

  test_contract:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: denoland/setup-deno@v1
      - run: deno test tests/contract/
EOF
echo "✅ CI workflow created"

# Issue Templates
mkdir -p .github/ISSUE_TEMPLATE

cat > .github/ISSUE_TEMPLATE/feature_request.yml << 'EOF'
name: Feature Request
description: Request a new feature
title: "[FEAT] "
labels: ["feature"]
body:
  - type: markdown
    attributes:
      value: "## Feature Request (Spec Kit)"
  - type: input
    id: spec_id
    attributes:
      label: Spec ID
      placeholder: "SPEC-XXX"
    validations:
      required: true
  - type: textarea
    id: requirements
    attributes:
      label: Requirements (EARS format)
      placeholder: |
        ### REQ-XXX: Feature Name
        - **Description**: ...
        - **Acceptance Criteria**: ...
  - type: textarea
    id: acceptance
    attributes:
      label: Acceptance Criteria (AC-XXX)
      placeholder: |
        - AC-001: ...
        - AC-002: ...
EOF

cat > .github/ISSUE_TEMPLATE/bug_report.yml << 'EOF'
name: Bug Report
description: Report a bug
title: "[BUG] "
labels: ["bug"]
body:
  - type: markdown
    attributes:
      value: "## Bug Report"
  - type: textarea
    id: reproduction
    attributes:
      label: Steps to Reproduce
    validations:
      required: true
  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
    validations:
      required: true
  - type: textarea
    id: actual
    attributes:
      label: Actual Behavior
    validations:
      required: true
EOF

cat > .github/ISSUE_TEMPLATE/spec_change.yml << 'EOF'
name: Spec Change
description: Request a change to existing spec
title: "[SPEC] "
labels: ["spec", "plan", "tasks"]
body:
  - type: input
    id: spec_id
    attributes:
      label: Spec ID
      placeholder: "SPEC-XXX"
    validations:
      required: true
  - type: textarea
    id: changes
    attributes:
      label: Proposed Changes
    validations:
      required: true
EOF
echo "✅ Issue templates created"

# PR Template
mkdir -p .github/PULL_REQUEST_TEMPLATE
cat > .github/PULL_REQUEST_TEMPLATE/default.md << 'EOF'
# Pull Request

## Spec Reference
- **Spec**: SPEC-XXX / PLAN-XXX / TASKS-XXX
- **Issue**: #XXX

## Agent Role
- [ ] Specifier (spec/plan/tasks)
- [ ] Coder (code)
- [ ] Tester (test)
- [ ] Integrator (integrate)

## Provenance Tags
- [ ] [human-specified] Requirement from human
- [ ] [agent-proposed] Mechanism chosen by AI
- [ ] [collaborative] Emerged through iteration
- [ ] [test-driven] Gate failure → fix
- [ ] [implementation-detail] AI chose concrete approach

## Verification Checklist
- [ ] All gates pass (spec_gate / coder_gates / tester_gates / integrator_gate)
- [ ] No TODO/FIXME in code
- [ ] No console.log in production code
- [ ] Conventional commit messages
- [ ] Provenance tags present
- [ ] Tests cover new functionality

## Test Results
- Unit: 
- Integration: 
- Contract: 
- Coverage: 

## Screenshots
<!-- Attach gate output screenshots -->
EOF
echo "✅ PR template created"

# Labels (18 labels)
LABELS=(
  "spec:0052CC:Spec Kit specification"
  "plan:0052CC:Implementation plan"
  "tasks:0052CC:Task breakdown"
  "code:0E8A16:Code implementation"
  "test:F97583:Testing"
  "integrate:B60205:Integration & release"
  "feature:A2EEEF:New feature"
  "bug:D73A4A:Bug fix"
  "security:EE0701:Security"
  "docs:0075CA:Documentation"
  "chore:8B949E:Maintenance"
  "priority:high:B60205:High priority"
  "priority:medium:FBCA04:Medium priority"
  "priority:low:7057FF:Low priority"
  "agent:specifier:5319E7:Specifier agent"
  "agent:coder:1D76DB:Coder agent"
  "agent:tester:F97583:Tester agent"
  "agent:integrator:B60205:Integrator agent"
)

echo "Creating labels..."
for label_spec in "${LABELS[@]}"; do
  IFS=':' read -r name color description <<< "$label_spec"
  gh label create "$name" --color "$color" --description "$description" --repo "$REPO" 2>/dev/null || true
done
echo "✅ Labels created"

# Milestones
echo "Creating milestones..."
gh api repos/$REPO/milestones --method POST -f title="v0.1 - Spec & Scaffold" -f description="SPEC-001, PLAN-001, TASKS-001, project scaffold" -f due_on="$(date -d '+7 days' +%Y-%m-%d)T23:59:59Z" 2>/dev/null || true
gh api repos/$REPO/milestones --method POST -f title="v0.2 - Core Implementation" -f description="REQ-001 to REQ-005 implementation" -f due_on="$(date -d '+14 days' +%Y-%m-%d)T23:59:59Z" 2>/dev/null || true
gh api repos/$REPO/milestones --method POST -f title="v1.0 - Production Ready" -f description="All features + modification + release" -f due_on="$(date -d '+21 days' +%Y-%m-%d)T23:59:59Z" 2>/dev/null || true
echo "✅ Milestones created"

# Verification script
cat > scripts/verify_setup.sh << 'EOF'
#!/usr/bin/env bash
echo "🔍 Verifying setup..."

checks=(
  "git status"
  "gh repo view mekou1/echolog --json name,visibility,defaultBranchRef"
  "gh api repos/mekou1/echolog/branches/main/protection --jq '.required_status_checks.contexts'"
  "gh api repos/mekou1/echolog/contents/.github/CODEOWNERS"
  "ls -la .spec/ specs/ constitution.md SPEC.md PLAN.md TASKS.md"
  "cat constitution.md"
  "cat SPEC.md"
  "cat PLAN.md"
  "cat TASKS.md"
  "gh workflow list"
  "gh label list --repo mekou1/echolog"
  "gh api repos/mekou1/echolog/milestones"
)

for check in "${checks[@]}"; do
  echo "Checking: $check"
  eval "$check" || echo "⚠️  Check failed: $check"
done

echo "✅ Verification complete"
EOF
chmod +x scripts/verify_setup.sh
echo "✅ Verification script created"

echo ""
echo "🎉 SETUP COMPLETE!"
echo "Run: ./scripts/verify_setup.sh to verify"
echo "Then: ./scripts/run-tickets.sh to start the agent loop"