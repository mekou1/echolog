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
