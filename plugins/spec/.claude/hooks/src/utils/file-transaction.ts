/**
 * File Transaction Utilities
 *
 * Provides atomic file operations with transaction support.
 * Ensures multi-file updates succeed or fail together.
 */

import * as fs from 'fs';
import * as path from 'path';
import { Transaction, FileOperation, TransactionResult } from '../types/transaction';
import { Logger } from '../core/logger';

/**
 * File transaction manager
 *
 * Coordinates atomic multi-file operations with rollback capability.
 */
export class FileTransactionManager {
  private readonly tempDir: string;
  private readonly backupDir: string;

  constructor(basePath: string) {
    this.tempDir = path.join(basePath, '.tmp');
    this.backupDir = path.join(basePath, '.backups');
    this.ensureDirectories();
  }

  /**
   * Execute a transaction atomically
   *
   * @param transaction - Transaction to execute
   * @returns Transaction result
   */
  public async executeTransaction(transaction: Transaction): Promise<TransactionResult> {
    Logger.info('Executing transaction', { transactionId: transaction.id });

    const filesModified: string[] = [];
    const backups: string[] = [];

    try {
      // Phase 1: Create backups for existing files
      for (const operation of transaction.files) {
        if (fs.existsSync(operation.path)) {
          const backupPath = await this.createBackup(operation.path, transaction.id);
          operation.backup = backupPath;
          backups.push(backupPath);
        }
      }

      // Phase 2: Write to temporary files
      const tempFiles: Map<string, string> = new Map();
      for (const operation of transaction.files) {
        const tempPath = await this.writeToTemp(operation, transaction.id);
        tempFiles.set(operation.path, tempPath);
      }

      // Phase 3: Atomically rename temp files to target (commit)
      for (const [targetPath, tempPath] of tempFiles.entries()) {
        this.ensureDirectory(path.dirname(targetPath));
        fs.renameSync(tempPath, targetPath);
        filesModified.push(targetPath);
      }

      Logger.info('Transaction committed successfully', {
        transactionId: transaction.id,
        filesModified: filesModified.length,
      });

      return {
        success: true,
        transactionId: transaction.id,
        filesModified,
        backups,
      };
    } catch (error) {
      // Rollback: Restore from backups
      Logger.error('Transaction failed, rolling back', error, {
        transactionId: transaction.id,
      });

      await this.rollback(transaction);

      return {
        success: false,
        transactionId: transaction.id,
        filesModified: [],
        backups: [],
        error: error instanceof Error ? error.message : String(error),
      };
    }
  }

  /**
   * Rollback a transaction using backups
   *
   * @param transaction - Transaction to rollback
   */
  private async rollback(transaction: Transaction): Promise<void> {
    Logger.info('Rolling back transaction', { transactionId: transaction.id });

    for (const operation of transaction.files) {
      if (operation.backup && fs.existsSync(operation.backup)) {
        try {
          // Restore from backup
          fs.copyFileSync(operation.backup, operation.path);
          Logger.info('Restored file from backup', {
            file: operation.path,
            backup: operation.backup,
          });
        } catch (error) {
          Logger.error('Failed to restore file from backup', error, {
            file: operation.path,
          });
        }
      } else if (fs.existsSync(operation.path)) {
        // File was created in this transaction, delete it
        try {
          fs.unlinkSync(operation.path);
          Logger.info('Removed file created in transaction', {
            file: operation.path,
          });
        } catch (error) {
          Logger.error('Failed to remove file', error, { file: operation.path });
        }
      }
    }

    Logger.info('Transaction rollback complete', { transactionId: transaction.id });
  }

  /**
   * Create backup of a file
   *
   * @param filePath - File to backup
   * @param transactionId - Transaction ID
   * @returns Backup file path
   */
  private async createBackup(filePath: string, transactionId: string): Promise<string> {
    const filename = path.basename(filePath);
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const backupFilename = `${filename}.${transactionId}.${timestamp}.backup`;
    const backupPath = path.join(this.backupDir, backupFilename);

    this.ensureDirectory(this.backupDir);
    fs.copyFileSync(filePath, backupPath);

    Logger.info('Created backup', { original: filePath, backup: backupPath });
    return backupPath;
  }

  /**
   * Write operation to temporary file
   *
   * @param operation - File operation
   * @param transactionId - Transaction ID
   * @returns Temporary file path
   */
  private async writeToTemp(
    operation: FileOperation,
    transactionId: string
  ): Promise<string> {
    const filename = path.basename(operation.path);
    const tempFilename = `${filename}.${transactionId}.tmp`;
    const tempPath = path.join(this.tempDir, tempFilename);

    this.ensureDirectory(this.tempDir);

    if (operation.type === 'append' && fs.existsSync(operation.path)) {
      // For append, read existing content first
      const existingContent = fs.readFileSync(operation.path, 'utf8');
      fs.writeFileSync(tempPath, existingContent + operation.content, 'utf8');
    } else {
      // For create/update, write new content
      fs.writeFileSync(tempPath, operation.content, 'utf8');
    }

    Logger.info('Wrote to temp file', { temp: tempPath, type: operation.type });
    return tempPath;
  }

  /**
   * Clean up old backups
   *
   * @param maxAgeMs - Maximum age in milliseconds
   */
  public async cleanupOldBackups(maxAgeMs: number = 30 * 24 * 60 * 60 * 1000): Promise<number> {
    if (!fs.existsSync(this.backupDir)) {
      return 0;
    }

    const now = Date.now();
    const files = fs.readdirSync(this.backupDir);
    let deletedCount = 0;

    for (const file of files) {
      if (!file.endsWith('.backup')) continue;

      const filePath = path.join(this.backupDir, file);
      const stats = fs.statSync(filePath);
      const age = now - stats.mtimeMs;

      if (age > maxAgeMs) {
        try {
          fs.unlinkSync(filePath);
          deletedCount++;
        } catch (error) {
          Logger.error('Failed to delete old backup', error, { file: filePath });
        }
      }
    }

    Logger.info('Cleaned up old backups', { deleted: deletedCount });
    return deletedCount;
  }

  /**
   * Clean up temporary files
   */
  public async cleanupTempFiles(): Promise<void> {
    if (!fs.existsSync(this.tempDir)) {
      return;
    }

    const files = fs.readdirSync(this.tempDir);
    for (const file of files) {
      if (file.endsWith('.tmp')) {
        try {
          fs.unlinkSync(path.join(this.tempDir, file));
        } catch (error) {
          Logger.error('Failed to delete temp file', error, { file });
        }
      }
    }

    Logger.info('Cleaned up temp files', { count: files.length });
  }

  /**
   * Ensure directory exists
   */
  private ensureDirectory(dirPath: string): void {
    if (!fs.existsSync(dirPath)) {
      fs.mkdirSync(dirPath, { recursive: true });
    }
  }

  /**
   * Ensure required directories exist
   */
  private ensureDirectories(): void {
    this.ensureDirectory(this.tempDir);
    this.ensureDirectory(this.backupDir);
  }
}

/**
 * Create a file transaction manager
 *
 * @param basePath - Base path for transactions
 * @returns FileTransactionManager instance
 */
export function createFileTransactionManager(basePath: string): FileTransactionManager {
  return new FileTransactionManager(basePath);
}
