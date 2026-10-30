# CONSTITUTION.md

## Article I: Code Quality
All code must pass lint, typecheck, and security scans before merge.

## Article II: Test-First
Write failing test before implementation. No implementation without test.

## Article III: Library-First
Prefer existing libraries over custom implementations.

## Article IV: Simplicity
Minimize abstraction. No speculative flexibility. 200 lines -> 50 if possible.

## Article V: Anti-Abstraction
No interfaces for single implementations. No patterns for hypothetical futures.

## Article VI: Explicit Error Handling
Every external call has error handling. No silent failures.

## Article VII: Security by Default
RLS enabled. Secrets in env. Input validated. Auth checked.

## Article VIII: Observability
Structured logging. Metrics for business + technical events.

## Article IX: Documentation as Code
Specs in version control. ADRs for decisions. AGENTS.md for agents.
