// logger.ts — Core logger (<50 lines)
import { LogLevel, LogLevelNames, levelFromEnv } from "./levels.ts";

export interface LogContext {
  [key: string]: unknown;
}

export interface LogEntry {
  timestamp: string;
  level: string;
  message: string;
  context: LogContext;
}

export class Logger {
  private minLevel: LogLevel;
  private transports: Transport[];

  constructor(minLevel: LogLevel = levelFromEnv(), transports: Transport[] = []) {
    this.minLevel = minLevel;
    this.transports = transports.length > 0 ? transports : [new ConsoleTransport()];
  }

  addTransport(transport: Transport): void {
    this.transports.push(transport);
  }

  log(level: LogLevel, message: string, context: LogContext = {}): void {
    if (level < this.minLevel) return;
    
    const entry: LogEntry = {
      timestamp: new Date().toISOString(),
      level: LogLevelNames[level],
      message,
      context,
    };

    for (const transport of this.transports) {
      transport.write(entry);
    }
  }

  debug(message: string, context: LogContext = {}): void {
    this.log(LogLevel.DEBUG, message, context);
  }

  info(message: string, context: LogContext = {}): void {
    this.log(LogLevel.INFO, message, context);
  }

  warn(message: string, context: LogContext = {}): void {
    this.log(LogLevel.WARN, message, context);
  }

  error(message: string, context: LogContext = {}): void {
    this.log(LogLevel.ERROR, message, context);
  }
}

export interface Transport {
  write(entry: LogEntry): void;
}