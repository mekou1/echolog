// tests/integration/cli_test.ts — Integration tests for CLI
import { assertEquals, assertStringIncludes, assertExists } from "@std/assert";
import { Command } from "@std/cli/command";

const ECHOLOG = new Command()
  .name("echolog")
  .version("0.1.0")
  .description("Minimal structured logging CLI")
  .option("-j, --json", "Output single-line JSON")
  .option("-f, --file <path:string>", "Append JSON lines to file")
  .option("-p, --pretty", "Human-readable colored output")
  .option("-l, --level <level:string>", "Minimum log level", { default: "info" })
  .arguments("<message:string> [context...:string]")
  .action((options, message, ...context) => {
    // This is a placeholder - actual CLI is in main.ts
    // For integration tests, we run the actual binary
    throw new Error("Use deno run --allow-all src/main.ts for integration tests");
  });

// Integration tests run the actual compiled binary
// These tests use `deno run --allow-all src/main.ts ...`

Deno.test("CLI - basic JSON output", async () => {
  const proc = new Deno.Command("deno", {
    args: ["run", "--allow-all", "src/main.ts", "test message", "user=admin"],
    stdout: "piped",
    stderr: "piped",
  });
  const { code, stdout, stderr } = await proc.output();
  
  assertEquals(code, 0);
  const output = new TextDecoder().decode(stdout).trim();
  const parsed = JSON.parse(output);
  assertEquals(parsed.message, "test message");
  assertEquals(parsed.context.user, "admin");
  assertEquals(parsed.level, "info");
});

Deno.test("CLI - pretty output", async () => {
  const proc = new Deno.Command("deno", {
    args: ["run", "--allow-all", "src/main.ts", "--pretty", "hello", "user=admin"],
    stdout: "piped",
    stderr: "piped",
  });
  const { code, stdout } = await proc.output();
  
  assertEquals(code, 0);
  const output = new TextDecoder().decode(stdout);
  assertStringIncludes(output, "[INFO]");
  assertStringIncludes(output, "hello");
  assertStringIncludes(output, "user=admin");
});

Deno.test("CLI - JSON flag", async () => {
  const proc = new Deno.Command("deno", {
    args: ["run", "--allow-all", "src/main.ts", "--json", "json test"],
    stdout: "piped",
  });
  const { code, stdout } = await proc.output();
  
  assertEquals(code, 0);
  const output = new TextDecoder().decode(stdout).trim();
  const parsed = JSON.parse(output);
  assertEquals(parsed.message, "json test");
});

Deno.test("CLI - file transport", async () => {
  const tempFile = await Deno.makeTempFile({ prefix: "echolog-test-", suffix: ".json" });
  
  try {
    const proc = new Deno.Command("deno", {
      args: ["run", "--allow-all", "src/main.ts", "--file", tempFile, "file test", "key=value"],
      stdout: "piped",
      stderr: "piped",
    });
    const { code } = await proc.output();
    assertEquals(code, 0);

    const content = await Deno.readTextFile(tempFile);
    const lines = content.trim().split("\n");
    assertEquals(lines.length, 1);
    const parsed = JSON.parse(lines[0]);
    assertEquals(parsed.message, "file test");
    assertEquals(parsed.context.key, "value");
  } finally {
    await Deno.remove(tempFile).catch(() => {});
  }
});

Deno.test("CLI - level filtering", async () => {
  // Default level (info) should NOT show debug
  const proc1 = new Deno.Command("deno", {
    args: ["run", "--allow-all", "src/main.ts", "debug message"],
    stdout: "piped",
  });
  const { code: code1, stdout: stdout1 } = await proc1.output();
  assertEquals(code1, 0);
  // Debug should be filtered out at default info level
  assertEquals(stdout1.trim(), "");

  // With --level debug, should show debug
  const proc2 = new Deno.Command("deno", {
    args: ["run", "--allow-all", "src/main.ts", "--level", "debug", "debug message"],
    stdout: "piped",
  });
  const { code: code2, stdout: stdout2 } = await proc2.output();
  assertEquals(code2, 0);
  const output2 = new TextDecoder().decode(stdout2).trim();
  assertStringIncludes(output2, "debug message");
});

Deno.test("CLI - context parsing", async () => {
  const proc = new Deno.Command("deno", {
    args: ["run", "--allow-all", "src/main.ts", "user action", "user=admin", "action=login", "count=5"],
    stdout: "piped",
  });
  const { code, stdout } = await proc.output();
  
  assertEquals(code, 0);
  const output = new TextDecoder().decode(stdout).trim();
  const parsed = JSON.parse(output);
  assertEquals(parsed.context.user, "admin");
  assertEquals(parsed.context.action, "login");
  assertEquals(parsed.context.count, 5); // parsed as number
});

Deno.test("CLI - help flag", async () => {
  const proc = new Deno.Command("deno", {
    args: ["run", "--allow-all", "src/main.ts", "--help"],
    stdout: "piped",
    stderr: "piped",
  });
  const { code, stdout } = await proc.output();
  
  assertEquals(code, 0);
  const output = new TextDecoder().decode(stdout);
  assertStringIncludes(output, "EchoLog");
  assertStringIncludes(output, "--json");
  assertStringIncludes(output, "--file");
  assertStringIncludes(output, "--pretty");
  assertStringIncludes(output, "--level");
});

Deno.test("CLI - version flag", async () => {
  const proc = new Deno.Command("deno", {
    args: ["run", "--allow-all", "src/main.ts", "--version"],
    stdout: "piped",
  });
  const { code, stdout } = await proc.output();
  
  assertEquals(code, 0);
  const output = new TextDecoder().decode(stdout).trim();
  assertEquals(output, "echolog v0.1.0");
});