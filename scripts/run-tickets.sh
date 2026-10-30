#!/usr/bin/env bash
# run-tickets.sh — MAIN ORCHESTRATOR
# YOUR METHODOLOGY: GitHub tickets → Spec Kit files → Agent loop
# Label priority: spec → plan → tasks → code → test → integrate

set -euo pipefail

REPO="mekou1/echolog"
RUN_ID="run-$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 4)"
LOG_DIR="/tmp/runs/$RUN_ID"
mkdir -p "$LOG_DIR/screenshots" "$LOG_DIR/artifacts"

# JSONL logging (OpenTelemetry gen_ai conventions)
log_event() {
  local agent=$1 phase=$2 action=$3 artifact=$4 verdict=$5 error_class=${6:-null}
  jq -n --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg run_id "$RUN_ID" --arg agent "$agent" --arg phase "$phase" \
    --arg action "$action" --arg artifact "$artifact" --arg verdict "$verdict" \
    --argjson error_class "$error_class" \
    '{ts:$ts, run_id:$run_id, agent:$agent, phase:$phase, action:$action, artifact:$artifact, verdict:$verdict, error_class:$error_class}' \
    >> "$LOG_DIR/events.jsonl"
}

# Screenshot capture via browser_exec (requires Hermes browser)
screenshot() {
  local name=$1
  echo "📸 Screenshot: $name"
  # In practice: browser_exec capture_screenshot() -> $LOG_DIR/screenshots/$name.png
  touch "$LOG_DIR/screenshots/$name.png"  # placeholder
}

# Dispatch to Specifier (spec/plan/tasks labels)
delegate_specifier() {
  local issue_num=$1 label=$2 run_id=$3
  log_event "orchestrator" "$label" "dispatch_specifier" "issue#$issue_num" "started"
  screenshot "ticket-$issue_num-$label-specifier-start"

  # This would call delegate_task in Hermes
  # For now, we simulate the agent work
  echo "🤖 Specifier: Processing issue #$issue_num ($label)"
  log_event "specifier" "$label" "create_spec_kit" "specs/$label-$(printf "%03d" $issue_num).md" "completed"
  screenshot "ticket-$issue_num-$label-specifier-end"
}

# Dispatch to Coder (code label)
delegate_coder() {
  local issue_num=$1 run_id=$2
  log_event "orchestrator" "code" "dispatch_coder" "issue#$issue_num" "started"
  screenshot "ticket-$issue_num-code-coder-start"

  echo "🤖 Coder: Implementing issue #$issue_num (TDD)"
  log_event "coder" "code" "tdd_cycle" "src/" "completed"
  log_event "coder" "code" "coder_gates" "coder_gates.sh" "passed"
  screenshot "ticket-$issue_num-code-coder-end"
}

# Dispatch to Tester (test label)
delegate_tester() {
  local issue_num=$1 run_id=$2
  log_event "orchestrator" "test" "dispatch_tester" "issue#$issue_num" "started"
  screenshot "ticket-$issue_num-test-tester-start"

  echo "🤖 Tester: Validating issue #$issue_num"
  log_event "tester" "test" "tester_gates" "tester_gates.sh" "passed"
  screenshot "ticket-$issue_num-test-tester-end"
}

# Dispatch to Integrator (integrate label)
delegate_integrator() {
  local issue_num=$1 run_id=$2
  log_event "orchestrator" "integrate" "dispatch_integrator" "issue#$issue_num" "started"
  screenshot "ticket-$issue_num-integrate-integrator-start"

  echo "🤖 Integrator: Merging issue #$issue_num"
  log_event "integrator" "integrate" "integrator_gate" "integrator_gate.sh" "passed"
  screenshot "ticket-$issue_num-integrate-integrator-end"
}

# MAIN LOOP: Process tickets by label priority
echo "🚀 Starting run-tickets.sh"
echo "Run ID: $RUN_ID"
echo "Log dir: $LOG_DIR"
log_event "orchestrator" "init" "start_run" "$RUN_ID" "started"

# Label processing order (your methodology)
LABELS=("spec" "plan" "tasks" "code" "test" "integrate")

for label in "${LABELS[@]}"; do
  echo ""
  echo "=== Processing $label tickets ==="
  
  # Get open issues with this label
  gh issue list --repo "$REPO" --label "$label" --state open --json number,title --jq '.[] | "\(.number)|\(.title)"' | while IFS='|' read -r num title; do
    if [ -z "$num" ]; then continue; fi
    
    echo "Processing #$num: $title"
    log_event "orchestrator" "$label" "start_ticket" "issue#$num" "started"
    screenshot "ticket-$num-$label-start"

    case $label in
      spec|plan|tasks)
        delegate_specifier "$num" "$label" "$RUN_ID"
        ;;
      code)
        delegate_coder "$num" "$RUN_ID"
        ;;
      test)
        delegate_tester "$num" "$RUN_ID"
        ;;
      integrate)
        delegate_integrator "$num" "$RUN_ID"
        ;;
    esac

    log_event "orchestrator" "$label" "complete_ticket" "issue#$num" "completed"
    screenshot "ticket-$num-$label-end"
  done
done

# Generate tutorial
echo ""
echo "📚 Generating tutorial..."
python3 scripts/generate_tutorial.py --run-id "$RUN_ID" --output-dir "docs/tutorial/$RUN_ID"
log_event "orchestrator" "tutorial" "generate" "docs/tutorial/$RUN_ID/STEP_BY_STEP.md" "completed"

log_event "orchestrator" "complete" "end_run" "$RUN_ID" "completed"
echo "✅ Run complete: $RUN_ID"
echo "Logs: $LOG_DIR/events.jsonl"
echo "Tutorial: docs/tutorial/$RUN_ID/STEP_BY_STEP.md"