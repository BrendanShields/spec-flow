/**
 * Transaction Type Definitions
 *
 * Types for atomic multi-file operations
 */

/**
 * Transaction status
 */
export type TransactionStatus = 'pending' | 'committed' | 'rolled_back';

/**
 * File operation type
 */
export type FileOperationType = 'create' | 'update' | 'append';

/**
 * Single file operation within a transaction
 */
export interface FileOperation {
  /** Absolute path to the file */
  path: string;
  /** Type of operation */
  type: FileOperationType;
  /** New content to write */
  content: string;
  /** Backup path for rollback (created automatically) */
  backup?: string;
}

/**
 * Transaction for atomic multi-file updates
 */
export interface Transaction {
  /** Transaction UUID */
  id: string;
  /** ISO 8601 timestamp when transaction created */
  timestamp: string;
  /** Operation type */
  operation: 'update_session' | 'append_memory' | 'snapshot' | 'migrate';
  /** File operations in this transaction */
  files: FileOperation[];
  /** Current transaction status */
  status: TransactionStatus;
  /** Error message if transaction failed */
  error?: string;
  /** Metadata for debugging */
  metadata?: Record<string, unknown>;
}

/**
 * Transaction result
 */
export interface TransactionResult {
  /** Whether transaction succeeded */
  success: boolean;
  /** Transaction ID */
  transactionId: string;
  /** Files that were modified */
  filesModified: string[];
  /** Backup paths created (for rollback) */
  backups: string[];
  /** Error if transaction failed */
  error?: string;
}
