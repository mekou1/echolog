// transports/console.ts — Console transport
import { Transport, LogEntry } from "../logger.ts";

export class ConsoleTransport implements Transport {
  private pretty: boolean;

  constructor(pretty: boolean = false) {
    this.pretty = pretty;
  }

  write(entry: LogEntry): void {
    if (this.pretty) {
      this.writePretty(entry);
    } else {
      this.writeJson(entry);
    }
  }

  private writeJson(entry: LogEntry): void {
    console.log(JSON.stringify(entry));
  }

  private writePretty(entry: LogEntry): void {
    const colors: Record<string, string> = {
      debug: "\x1b[36m",   // cyan
      info: "\x1b[32m",    // green
      warn: "\x1b[33m",    // yellow
      error: "\x1b[31m",   // red
    };
    const reset = "\x1b[0m";
    const color = colors[entry.level] || "";
    
    const contextStr = Object.keys(entry.context).length > 0 
      ? ` ${JSON.stringify(entry.context)}` 
      : "";
    
    console.log(
      `${color}[${entry.level.toUpperCase()}]${reset} ${entry.timestamp} | ${entry.message}${contextStr}`
    );
  }
}