// transports/file.ts — File transport
import { Transport, LogEntry } from "../logger.ts";

export class FileTransport implements Transport {
  private filePath: string;
  private file: Deno.FsFile | null = null;

  constructor(filePath: string) {
    this.filePath = filePath;
  }

  async open(): Promise<void> {
    this.file = await Deno.open(this.filePath, { 
      create: true, 
      append: true, 
      write: true 
    });
  }

  async close(): Promise<void> {
    if (this.file) {
      await this.file.close();
      this.file = null;
    }
  }

  write(entry: LogEntry): void {
    if (!this.file) {
      throw new Error("FileTransport not opened. Call open() first.");
    }
    const line = JSON.stringify(entry) + "\n";
    this.file.writeSync(new TextEncoder().encode(line));
  }
}