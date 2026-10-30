// levels.ts — Log levels enum
export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
}

export const LogLevelNames: Record<LogLevel, string> = {
  [LogLevel.DEBUG]: "debug",
  [LogLevel.INFO]: "info",
  [LogLevel.WARN]: "warn",
  [LogLevel.ERROR]: "error",
};

export function parseLevel(level: string): LogLevel {
  const normalized = level.toLowerCase();
  switch (normalized) {
    case "debug": return LogLevel.DEBUG;
    case "info": return LogLevel.INFO;
    case "warn": return LogLevel.WARN;
    case "error": return LogLevel.ERROR;
    default: throw new Error(`Invalid log level: ${level}`);
  }
}

export function levelFromEnv(): LogLevel {
  return parseLevel(Deno.env.get("LOG_LEVEL") || "info");
}