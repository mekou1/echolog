// tests/unit/logger_test.ts — Unit tests for Logger
import { assertEquals, assertExists } from "@std/assert";
import { Logger, LogLevel } from "../../src/logger.ts";
import { LogLevel as LevelEnum } from "../../src/levels.ts";

Deno.test("Logger - logs at correct level", () => {
  const entries: any[] = [];
  const logger = new Logger(LogLevel.DEBUG, [{
    write: (entry) => entries.push(entry),
  }]);

  logger.info("test message", { user: "admin" });

  assertEquals(entries.length, 1);
  assertEquals(entries[0].level, "info");
  assertEquals(entries[0].message, "test message");
  assertEquals(entries[0].context.user, "admin");
  assertExists(entries[0].timestamp);
});

Deno.test("Logger - respects minimum level", () => {
  const entries: any[] = [];
  const logger = new Logger(LogLevel.WARN, [{
    write: (entry) => entries.push(entry),
  }]);

  logger.debug("debug message");
  logger.info("info message");
  logger.warn("warn message");
  logger.error("error message");

  assertEquals(entries.length, 2);
  assertEquals(entries[0].level, "warn");
  assertEquals(entries[1].level, "error");
});

Deno.test("Logger - includes context in output", () => {
  const entries: any[] = [];
  const logger = new Logger(LogLevel.DEBUG, [{
    write: (entry) => entries.push(entry),
  }]);

  logger.info("user login", { userId: 123, role: "admin" });

  assertEquals(entries[0].context.userId, 123);
  assertEquals(entries[0].context.role, "admin");
});

Deno.test("Logger - debug/info/warn/error methods", () => {
  const entries: any[] = [];
  const logger = new Logger(LogLevel.DEBUG, [{
    write: (entry) => entries.push(entry),
  }]);

  logger.debug("debug");
  logger.info("info");
  logger.warn("warn");
  logger.error("error");

  assertEquals(entries.length, 4);
  assertEquals(entries[0].level, "debug");
  assertEquals(entries[1].level, "info");
  assertEquals(entries[2].level, "warn");
  assertEquals(entries[3].level, "error");
});

Deno.test("Logger - multiple transports", () => {
  const entries1: any[] = [];
  const entries2: any[] = [];
  const logger = new Logger(LogLevel.DEBUG, [
    { write: (e) => entries1.push(e) },
    { write: (e) => entries2.push(e) },
  ]);

  logger.info("test");

  assertEquals(entries1.length, 1);
  assertEquals(entries2.length, 1);
  assertEquals(entries1[0].message, "test");
  assertEquals(entries2[0].message, "test");
});