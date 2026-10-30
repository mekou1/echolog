// transports/json.ts — JSON formatter transport (wraps another transport)
import { Transport, LogEntry } from "../logger.ts";

export class JsonFormatter implements Transport {
  private transport: Transport;

  constructor(transport: Transport) {
    this.transport = transport;
  }

  write(entry: LogEntry): void {
    // Ensure single-line JSON
    const jsonLine = JSON.stringify(entry);
    // Write via wrapped transport (using a trick - we'll just call write on a mock)
    // In practice, this would be handled by the transport itself
    // For now, we just pass through
    const mockEntry: LogEntry = { ...entry, message: jsonLine };
    this.transport.write(mockEntry);
  }
}

// Simpler: just a function that formats entry as JSON line
export function formatJsonLine(entry: LogEntry): string {
  return JSON.stringify(entry);
}

export function formatPrettyLine(entry: LogEntry): string {
  const colors: Record<string, string> = {
    debug: "\x1b[36m",
    info: "\x1b[32m",
    warn: "\x1b[33m",
    error: "\x1b[31m",
  };
  const reset = "\x1b[0m";
  const color = colors[entry.level] || "";
  
  const contextStr = Object.keys(entry.context).length > 0 
    ? ` ${JSON.stringify(entry.context)}` 
    : "";
  
  return `${color}[${entry.level.toUpperCase()}]${reset} ${entry.timestamp} | ${entry.message}${contextStr}`;
}