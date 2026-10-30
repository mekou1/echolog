// main.ts — CLI entry point
import { parseArgs } from "@std/cli/parse-args";
import { Logger, LogContext } from "./logger.ts";
import { LogLevel, LogLevelNames, parseLevel } from "./levels.ts";
import { ConsoleTransport } from "./transports/console.ts";
import { FileTransport } from "./transports/file.ts";
import { formatJsonLine, formatPrettyLine } from "./transports/json.ts";

interface CliOptions {
  json: boolean;
  file?: string;
  pretty: boolean;
  level: string;
  help: boolean;
  version: boolean;
  _: string[];
}

function printHelp(): void {
  console.log(`
EchoLog — Minimal structured logging CLI

USAGE:
  echolog [OPTIONS] <message> [context...]

OPTIONS:
  --json           Output single-line JSON per log entry
  --file <path>    Append JSON lines to file
  --pretty         Human-readable colored output
  --level <level>  Minimum log level (debug, info, warn, error) [default: info]
  --help           Show this help
  --version        Show version

EXAMPLES:
  echolog "Hello world"                           # JSON to stdout
  echolog --pretty "Hello" user=admin action=login # Colored output with context
  echolog --json --file logs.json "Error" code=500 # JSON to file
  echolog --level debug "Debug info"              # Enable debug logs

ENVIRONMENT:
  LOG_LEVEL    Default log level (debug, info, warn, error)
`);
}

function printVersion(): void {
  console.log("echolog v0.1.0");
}

function parseContext(args: string[]): LogContext {
  const ctx: LogContext = {};
  for (const arg of args) {
    const idx = arg.indexOf("=");
    if (idx > 0) {
      const key = arg.slice(0, idx);
      const value = arg.slice(idx + 1);
      // Try to parse as JSON, fallback to string
      try {
        ctx[key] = JSON.parse(value);
      } catch {
        ctx[key] = value;
      }
    }
  }
  return ctx;
}

async function main(): Promise<void> {
  const args = parseArgs(Deno.args, {
    boolean: ["json", "pretty", "help", "version"],
    string: ["file", "level"],
    default: { level: "info" },
    alias: { h: "help", v: "version" },
  }) as CliOptions;

  if (args.help) {
    printHelp();
    Deno.exit(0);
  }

  if (args.version) {
    printVersion();
    Deno.exit(0);
  }

  if (args._.length === 0) {
    printHelp();
    Deno.exit(1);
  }

  const message = args._[0];
  const context = parseContext(args._.slice(1));
  const level = parseLevel(args.level);

  // Setup transports
  const transports: Array<{ transport: any; write: (entry: any) => void }> = [];

  // Console transport
  const consoleTransport = new ConsoleTransport(args.pretty);
  transports.push({
    transport: consoleTransport,
    write: (entry: any) => {
      if (args.json) {
        console.log(formatJsonLine(entry));
      } else if (args.pretty) {
        console.log(formatPrettyLine(entry));
      } else {
        console.log(JSON.stringify(entry));
      }
    },
  });

  // File transport
  if (args.file) {
    const fileTransport = new FileTransport(args.file);
    await fileTransport.open();
    transports.push({
      transport: fileTransport,
      write: (entry: any) => fileTransport.write(entry),
    });
    // Ensure file closes on exit
    Deno.addSignalListener("SIGINT", async () => {
      await fileTransport.close();
      Deno.exit(0);
    });
  }

  // Create logger
  const logger = new Logger(parseLevel(args.level), []);

  // Override transports with our custom ones
  (logger as any).transports = transports.map(t => t.transport);

  // Log the message
  logger.log(level, message, context);

  // Close file transport
  for (const t of transports) {
    if (t.transport instanceof FileTransport) {
      await t.transport.close();
    }
  }
}

if (import.meta.main) {
  await main();
}