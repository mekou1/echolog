// tests/contract/output_test.ts — Contract tests for output format
import { assertEquals, assertExists, assertStringIncludes } from "@std/assert";
import { Logger } from "../../src/logger.ts";
import { LogLevel, LogLevelNames } from "../../src/levels.ts";

Deno.test("Contract - LogEntry structure", () => {
  const entries: any[] = [];
  const logger = new Logger(LogLevel.DEBUG, [{
    write: (entry) => entries.push(entry),
  }]);

  logger.info("test", { key: "value" });

  const entry = entries[0];
  
  // Required fields
  assertExists(entry.timestamp);
  assertExists(entry.level);
  assertExists(entry.message);
  assertExists(entry.context);
  
  // Types
  assertEquals(typeof entry.timestamp, "string");
  assertEquals(typeof entry.level, "string");
  assertEquals(typeof entry.message, "string");
  assertEquals(typeof entry.context, "object");
  
  // ISO 8601 timestamp format
  assertStringIncludes(entry.timestamp, "T");
  assertStringIncludes(entry.timestamp, "Z");
  
  // Level is valid enum value
  assertEquals(Object.values(LogLevelNames).includes(entry.level), true);
});

Deno.test("Contract - JSON output is valid single-line JSON", () => {
  const entries: any[] = [];
  const logger = new Logger(LogLevel.DEBUG, [{
    write: (entry) => entries.push(entry),
  }]);

  logger.info("test message", { user: "admin", count: 42 });
  
  const jsonLine = JSON.stringify(entries[0]);
  
  // Must be valid JSON
  const parsed = JSON.parse(jsonLine);
  assertEquals(parsed.message, "test message");
  assertEquals(parsed.context.user, "admin");
  assertEquals(parsed.context.count, 42);
  
  // Must be single line (no newlines in JSON)
  assertEquals(jsonLine.split("\n").length, 1);
});

Deno.test("Contract - Context serialization", () => {
  const entries: any[] = [];
  const logger = new Logger(LogLevel.DEBUG, [{
    write: (entry) => entries.push(entry),
  }]);

  // Test various context types
  logger.info("string context", { str: "hello" });
  logger.info("number context", { num: 42 });
  logger.info("boolean context", { bool: true });
  logger.info("null context", { nil: null });
  logger.info("array context", { arr: [1, 2, 3] });
  logger.info("object context", { obj: { nested: true } });
  
  assertEquals(entries.length, 6);
  
  for (const entry of entries) {
    const json = JSON.stringify(entry);
    const parsed = JSON.parse(json);
    assertExists(parsed.context);
  }
});

Deno.test("Contract - Log levels in order", () => {
  const entries: any[] = [];
  const logger = new Logger(LogLevel.DEBUG, [{
    write: (entry) => entries.push(entry),
  }]);

  logger.debug("debug");
  logger.info("info");
  logger.warn("warn");
  logger.error("error");

  const levels = entries.map(e => e.level);
  assertEquals(levels, ["debug", "info", "warn", "error"]);
});

Deno.test("Contract - Timestamp is recent", () => {
  const entries: any[] = [];
  const logger = new Logger(LogLevel.DEBUG, [{
    write: (entry) => entries.push(entry),
  }]);

  const before = new Date().toISOString();
  logger.info("now");
  const after = new Date().toISOString();

  const entryTime = new Date(entries[0].timestamp).getTime();
  const beforeTime = new Date(before).getTime();
  const afterTime = new Date(after).getTime();

  // Entry timestamp should be between before and after (with small buffer)
  assertEquals(entryTime >= beforeTime - 1000, true);
  assertEquals(entryTime <= afterTime + 1000, true);
});

Deno.test("Contract - Empty context handled", () => {
  const entries: any[] = [];
  const logger = new Logger(LogLevel.DEBUG, [{
    write: (entry) => entries.push(entry),
  }]);

  logger.info("no context");
  
  assertEquals(entries[0].context, {});
  assertEquals(JSON.stringify(entries[0].context), "{}");
});