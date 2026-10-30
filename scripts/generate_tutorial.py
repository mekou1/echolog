#!/usr/bin/env python3
# generate_tutorial.py — Tutorial Generator from JSONL logs + screenshots
# Reads /tmp/runs/<run_id>/events.jsonl + screenshots → docs/tutorial/<run_id>/STEP_BY_STEP.md

import json
import os
import sys
import shutil
import argparse
from pathlib import Path
from datetime import datetime
from collections import defaultdict

def parse_args():
    p = argparse.ArgumentParser(description="Generate tutorial from run logs")
    p.add_argument("--run-id", required=True, help="Run ID (e.g., run-20261030-142312-a1b2c3d4)")
    p.add_argument("--output-dir", help="Output directory (default: docs/tutorial/<run_id>)")
    p.add_argument("--logs-dir", default="/tmp/runs", help="Base logs directory")
    return p.parse_args()

def load_events(run_id, logs_dir):
    events_file = Path(logs_dir) / run_id / "events.jsonl"
    if not events_file.exists():
        print(f"❌ Events file not found: {events_file}")
        return []
    events = []
    with open(events_file) as f:
        for line in f:
            if line.strip():
                try:
                    events.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
    return events

def load_screenshots(run_id, logs_dir):
    screenshots_dir = Path(logs_dir) / run_id / "screenshots"
    if not screenshots_dir.exists():
        return []
    return sorted(screenshots_dir.glob("*.png"))

def classify_phase(action, phase):
    """Map action/phase to tutorial phase"""
    if phase in ("init", "setup") or "setup" in action:
        return "Phase 1: Setup"
    elif phase in ("spec", "plan", "tasks"):
        return "Phase 2: Specification"
    elif phase == "code":
        return "Phase 3: Implementation"
    elif phase == "test":
        return "Phase 4: Validation"
    elif phase == "integrate":
        return "Phase 5: Release"
    elif phase == "tutorial":
        return "Phase 6: Tutorial"
    return "Other"

def format_event(e):
    ts = e.get("ts", "")
    agent = e.get("agent", "unknown")
    phase = e.get("phase", "")
    action = e.get("action", "")
    artifact = e.get("artifact", "")
    verdict = e.get("verdict", "")
    error_class = e.get("error_class", "")
    
    badge = "✅" if verdict in ("passed", "completed", "success") else "❌" if verdict in ("failed", "error") else "⏳"
    return f"**{ts}** | `{agent}` | `{phase}` | {action} | `{artifact}` | {badge} {verdict}"

def generate_badges():
    return """
![Methodology](https://img.shields.io/badge/Methodology-Level%205%20HDAE%20Hybrid-blue)
![Language](https://img.shields.io/badge/Language-Deno%20%2B%20TypeScript-blue)
![Agents](https://img.shields.io/badge/Agents-4%20Isolated-green)
![Gates](https://img.shields.io/badge/Gates-Mechanical-orange)
"""

def generate_mermaid_architecture():
    return """
```mermaid
graph TD
    A[GitHub Issues] --> B[run-tickets.sh]
    B --> C{Label Router}
    C -->|spec/plan/tasks| D[Specifier Agent]
    C -->|code| E[Coder Agent]
    C -->|test| F[Tester Agent]
    C -->|integrate| G[Integrator Agent]
    D --> H[Spec Kit Files]
    E --> I[Source + Unit Tests]
    F --> J[Contract + Integration Tests]
    G --> K[Release + CHANGELOG]
    H --> E
    I --> F
    J --> G
    style B fill:#f9f,stroke:#333
    style C fill:#bbf,stroke:#333
```
"""

def generate_mermaid_gates():
    return """
```mermaid
graph LR
    S[Spec Gate] --> C[Coder Gates 7]
    C --> T[Tester Gates 8+5]
    T --> I[Integrator Gates 8]
    I --> R[Release]
    style S fill:#ff9,stroke:#333
    style C fill:#9f9,stroke:#333
    style T fill:#9ff,stroke:#333
    style I fill:#f9f,stroke:#333
```
"""

def generate_mermaid_agents():
    return """
```mermaid
graph TB
    subgraph "Isolated Contexts"
        SA[Specifier<br/>Fresh worktree<br/>No code]
        CA[Coder<br/>Fresh worktree<br/>TDD only]
        TA[Tester<br/>Fresh checkout<br/>Zero Coder access]
        IA[Integrator<br/>Final gate<br/>Merge + Release]
    end
    SA -->|SPEC.md + PRP.md| CA
    CA -->|PR URL| TA
    TA -->|PASS verdict| IA
    IA -->|vX.Y.Z tag| Release
```
"""

def main():
    args = parse_args()
    
    run_id = args.run_id
    output_dir = Path(args.output_dir) if args.output_dir else Path("docs/tutorial") / run_id
    output_dir.mkdir(parents=True, exist_ok=True)
    images_dir = output_dir / "images"
    images_dir.mkdir(exist_ok=True)
    
    print(f"📖 Generating tutorial for {run_id}")
    
    # Load data
    events = load_events(run_id, args.logs_dir)
    screenshots = load_screenshots(run_id, args.logs_dir)
    
    if not events:
        print("❌ No events found")
        sys.exit(1)
    
    # Copy screenshots
    for i, ss in enumerate(screenshots):
        dst = images_dir / f"step_{i:03d}{ss.suffix}"
        shutil.copy2(ss, dst)
    
    # Group events by phase
    phases = defaultdict(list)
    for e in events:
        phase_name = classify_phase(e.get("action", ""), e.get("phase", ""))
        phases[phase_name].append(e)
    
    # Phase order
    phase_order = [
        "Phase 1: Setup",
        "Phase 2: Specification", 
        "Phase 3: Implementation",
        "Phase 4: Validation",
        "Phase 5: Release",
        "Phase 6: Tutorial",
        "Other"
    ]
    
    # Calculate stats
    start_ts = events[0].get("ts", "")
    end_ts = events[-1].get("ts", "")
    agents = set(e.get("agent", "") for e in events)
    verdicts = [e.get("verdict", "") for e in events]
    passed = sum(1 for v in verdicts if v in ("passed", "completed", "success"))
    failed = sum(1 for v in verdicts if v in ("failed", "error"))
    
    # Generate markdown
    md = []
    md.append(f"# EchoLog Demo Tutorial — Run `{run_id}`")
    md.append("")
    md.append(generate_badges())
    md.append("")
    
    # Project Overview
    md.append("## Project Overview")
    md.append("")
    md.append(f"- **Run ID**: `{run_id}`")
    md.append(f"- **Started**: `{start_ts}`")
    md.append(f"- **Completed**: `{end_ts}`")
    md.append(f"- **Total Events**: {len(events)}")
    md.append(f"- **Agents Involved**: {', '.join(sorted(agents))}")
    md.append(f"- **Gates Passed**: {passed}")
    md.append(f"- **Gates Failed**: {failed}")
    md.append(f"- **Screenshots**: {len(screenshots)}")
    md.append("")
    
    # Methodology Summary
    md.append("## Methodology Summary")
    md.append("")
    md.append("| Principle | Implementation |")
    md.append("|-----------|----------------|")
    md.append("| **Level 5 HDAE Hybrid** | Mechanical gates, provenance, false success rejection |")
    md.append("| **Ticket → Spec Kit** | 1 GitHub issue = 1 Spec Kit file (spec/plan/tasks/code/test/integrate) |")
    md.append("| **4 Isolated Agents** | Specifier → Coder → Tester → Integrator (fresh context each) |")
    md.append("| **Mechanical Gates** | No trust — spec_gate, coder_gates (7), tester_gates (8+5), integrator_gates (8) |")
    md.append("| **Provenance Tags** | [human-specified], [agent-proposed], [collaborative], [test-driven], [implementation-detail] |")
    md.append("| **Tutorial Generation** | Auto-generated from JSONL logs + screenshots |")
    md.append("")
    
    # Diagrams
    md.append("## Architecture Diagrams")
    md.append("")
    md.append("### System Architecture")
    md.append(generate_mermaid_architecture())
    md.append("")
    md.append("### Gate Flow")
    md.append(generate_mermaid_gates())
    md.append("")
    md.append("### Agent Isolation")
    md.append(generate_mermaid_agents())
    md.append("")
    
    # Phases
    for phase_name in phase_order:
        if phase_name not in phases:
            continue
        phase_events = phases[phase_name]
        md.append(f"## {phase_name}")
        md.append("")
        md.append(f"*{len(phase_events)} events*")
        md.append("")
        
        for i, e in enumerate(phase_events):
            md.append(f"### Step {i+1}: {e.get('action', 'unknown')}")
            md.append("")
            md.append(format_event(e))
            md.append("")
            
            # Add screenshot if available
            if i < len(screenshots):
                md.append(f"![Step {i+1}](images/step_{i:03d}.png)")
                md.append("")
    
    # Appendix
    md.append("## Appendix")
    md.append("")
    md.append("### Raw Event Log")
    md.append("```jsonl")
    for e in events:
        md.append(json.dumps(e))
    md.append("```")
    md.append("")
    
    md.append("### Screenshot Inventory")
    md.append("")
    for i, ss in enumerate(screenshots):
        md.append(f"- `step_{i:03d}.png` — {ss.name}")
    md.append("")
    
    md.append("### Generation Metadata")
    md.append("")
    md.append(f"- **Generated**: {datetime.utcnow().isoformat()}Z")
    md.append(f"- **Generator**: generate_tutorial.py v1.0")
    md.append(f"- **Source Logs**: /tmp/runs/{run_id}/events.jsonl")
    md.append("")
    
    md.append("### References")
    md.append("")
    md.append("- [MASTER_PLAN.md](/MASTER_PLAN.md) — Complete methodology synthesis")
    md.append("- [DEMO_APP_SPEC.md](/DEMO_APP_SPEC.md) — EchoLog specification")
    md.append("- [GITHUB_PROJECT_SETUP_PLAN.md](/GITHUB_PROJECT_SETUP_PLAN.md) — 19-step setup")
    md.append("- [EXECUTION_TIMELINE_TICKET_MAP.md](/EXECUTION_TIMELINE_TICKET_MAP.md) — 36 tickets")
    md.append("- [LOGGING_SCREENSHOT_FRAMEWORK.md](/LOGGING_SCREENSHOT_FRAMEWORK.md) — JSONL schema")
    md.append("")
    
    # Write output
    output_file = output_dir / "STEP_BY_STEP.md"
    with open(output_file, "w") as f:
        f.write("\n".join(md))
    
    print(f"✅ Tutorial generated: {output_file}")
    print(f"   Phases: {len([p for p in phase_order if p in phases])}")
    print(f"   Events: {len(events)}")
    print(f"   Screenshots: {len(screenshots)}")

if __name__ == "__main__":
    main()