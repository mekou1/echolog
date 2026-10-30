# SPEC-001: EchoLog — Core Features

## Overview
Minimal structured logging CLI (<50 lines core) demonstrating agent-driven development.

## Requirements

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

## Non-Functional
- Deno + TypeScript, zero dependencies
- Type hints mandatory (deno check)
- Test coverage ≥ 90%
- Security: no hardcoded secrets
