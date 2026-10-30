# TASKS-001: EchoLog Task Breakdown

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
