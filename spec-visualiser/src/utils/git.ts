import simpleGit, { SimpleGit } from 'simple-git';
import * as path from 'path';

export class GitHelper {
  private git: SimpleGit;

  constructor(projectRoot: string) {
    this.git = simpleGit(projectRoot);
  }

  async isGitRepo(): Promise<boolean> {
    try {
      await this.git.status();
      return true;
    } catch {
      return false;
    }
  }

  async getCurrentBranch(): Promise<string | null> {
    try {
      const status = await this.git.status();
      return status.current || null;
    } catch {
      return null;
    }
  }

  async getModifiedFiles(): Promise<string[]> {
    try {
      const status = await this.git.status();
      return [
        ...status.modified,
        ...status.created,
        ...status.deleted,
        ...status.renamed.map(r => r.to),
      ];
    } catch {
      return [];
    }
  }

  async getFeatureFiles(featureDir: string): Promise<{
    tracked: string[];
    modified: string[];
    untracked: string[];
  }> {
    try {
      const allFiles = await this.git.raw(['ls-files', featureDir]);
      const tracked = allFiles.split('\n').filter(Boolean);

      const status = await this.git.status();
      const modified = status.files
        .filter(f => f.path.startsWith(featureDir) && f.index !== '?')
        .map(f => f.path);

      const untracked = status.files
        .filter(f => f.path.startsWith(featureDir) && f.index === '?')
        .map(f => f.path);

      return { tracked, modified, untracked };
    } catch {
      return { tracked: [], modified: [], untracked: [] };
    }
  }

  async getLastCommit(): Promise<{ hash: string; message: string; date: Date } | null> {
    try {
      const log = await this.git.log({ maxCount: 1 });
      if (log.latest) {
        return {
          hash: log.latest.hash,
          message: log.latest.message,
          date: new Date(log.latest.date),
        };
      }
      return null;
    } catch {
      return null;
    }
  }

  async getCommitsSince(date: Date): Promise<number> {
    try {
      const log = await this.git.log({ since: date.toISOString() });
      return log.all.length;
    } catch {
      return 0;
    }
  }

  async hasUncommittedChanges(): Promise<boolean> {
    try {
      const status = await this.git.status();
      return status.files.length > 0;
    } catch {
      return false;
    }
  }
}
