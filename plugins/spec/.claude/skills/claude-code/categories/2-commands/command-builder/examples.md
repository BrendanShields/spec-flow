# Claude Code Slash Commands: Real-World Examples

## Example 1: Git Commit Message Generator

**Purpose**: Generate commit message from current changes.

**File**: `.claude/commands/commit.md`

```markdown
---
description: Generate a commit message from current git changes
allowed-tools: Bash(git status:*), Bash(git diff:*)
model: sonnet
---

Current git status:
!`git status -s`

Staged changes:
!`git diff --cached`

Please analyze these changes and generate a concise commit message following conventional commits format (type(scope): description).

Focus on WHAT changed and WHY, not HOW.
```

**Usage**: `/commit`

**Result**: Analyzes git changes and suggests well-formatted commit message.

---

## Example 2: PR Review with Context

**Purpose**: Review a specific pull request with priority.

**File**: `.claude/commands/review-pr.md`

```markdown
---
description: Review a pull request with specified priority
argument-hint: <pr-number> <priority>
allowed-tools: Bash(gh:*)
---

Fetch PR #$1 details:
!`gh pr view $1`

Priority: $2

Please review this pull request focusing on:
1. Code quality and best practices
2. Security concerns
3. Test coverage
4. Breaking changes

Provide specific feedback with file:line references.
```

**Usage**: `/review-pr 123 high`

**Result**: Fetches PR #123, reviews with high priority focus.

---

## Example 3: Test Failure Analyzer

**Purpose**: Run tests and analyze any failures.

**File**: `.claude/commands/fix-tests.md`

```markdown
---
description: Run tests and analyze failures
allowed-tools: Bash(npm test:*), Bash(npm run:*)
model: sonnet
---

Running test suite:
!`npm test 2>&1 | tail -50`

Please analyze any test failures and:
1. Identify root cause of each failure
2. Suggest specific fixes with code examples
3. Recommend additional test cases if needed

Focus on getting tests to pass while maintaining correctness.
```

**Usage**: `/fix-tests`

**Result**: Runs tests, analyzes failures, suggests fixes.

---

## Example 4: Documentation Updater

**Purpose**: Update README based on current codebase.

**File**: `.claude/commands/update-docs.md`

```markdown
---
description: Update readme.md based on current codebase
allowed-tools: Read, Write, Glob
---

Current README:
@readme.md

Package configuration:
@package.json

Please update the README to ensure it accurately reflects:
1. Current dependencies and versions
2. Installation instructions
3. Usage examples
4. API documentation (if applicable)

Maintain existing structure but update outdated information.
```

**Usage**: `/update-docs`

**Result**: Reads current state, updates README accordingly.

---

## Example 5: Security Audit

**Purpose**: Quick security scan of recent changes.

**File**: `.claude/commands/security-check.md`

```markdown
---
description: Run security audit on recent changes
allowed-tools: Bash(git diff:*), Read, Grep
model: sonnet
---

Recent changes:
!`git diff main...HEAD --name-only`

Please perform a security audit focusing on:
1. Input validation and sanitization
2. Authentication and authorization checks
3. Sensitive data handling (passwords, tokens, API keys)
4. SQL injection, XSS, CSRF vulnerabilities
5. Insecure dependencies

Categorize findings by severity (CRITICAL, HIGH, MEDIUM, LOW).
```

**Usage**: `/security-check`

**Result**: Analyzes recent changes for security issues.

---

## Example 6: Code Refactoring Assistant

**Purpose**: Refactor specific file for better structure.

**File**: `.claude/commands/refactor.md`

```markdown
---
description: Refactor a file for better structure and maintainability
argument-hint: <file-path>
allowed-tools: Read, Edit
---

Current implementation:
@$1

Please refactor this code to improve:
1. Readability and clarity
2. Code organization and structure
3. Adherence to DRY principle
4. Function/method decomposition
5. Type safety (if TypeScript)

Preserve existing behavior and maintain test compatibility.
```

**Usage**: `/refactor src/utils/helpers.ts`

**Result**: Reads file, suggests refactoring improvements.

---

## Example 7: API Design Review

**Purpose**: Review OpenAPI/Swagger specification.

**File**: `.claude/commands/review-api.md`

```markdown
---
description: Review API design and OpenAPI specification
argument-hint: <openapi-file>
---

API Specification:
@$1

Please review this API design for:
1. RESTful best practices
2. Endpoint naming and structure
3. HTTP method usage (GET, POST, PUT, DELETE)
4. Response status codes
5. Error handling
6. Versioning strategy
7. Authentication/authorization
8. Documentation completeness

Suggest improvements with examples.
```

**Usage**: `/review-api docs/openapi.yaml`

**Result**: Reviews API spec, suggests improvements.

---

## Example 8: Performance Analysis

**Purpose**: Analyze code for performance issues.

**File**: `.claude/commands/perf-check.md`

```markdown
---
description: Analyze code for performance bottlenecks
argument-hint: <file-path>
allowed-tools: Read, Grep, Bash(time:*)
---

Code to analyze:
@$1

Please analyze for performance issues:
1. Algorithm complexity (time and space)
2. Unnecessary loops or operations
3. N+1 query problems (if database code)
4. Inefficient data structures
5. Missing caching opportunities
6. Blocking I/O operations

Suggest optimizations with complexity analysis.
```

**Usage**: `/perf-check src/api/users.ts`

**Result**: Analyzes code, suggests performance improvements.

---

## Example 9: Dependency Update Helper

**Purpose**: Check for outdated dependencies and suggest updates.

**File**: `.claude/commands/update-deps.md`

```markdown
---
description: Check for outdated dependencies and suggest updates
allowed-tools: Bash(npm outdated:*), Read
model: sonnet
---

Current dependencies:
@package.json

Outdated packages:
!`npm outdated 2>&1 || true`

Please:
1. Identify critical updates (security patches)
2. Suggest version updates with rationale
3. Highlight breaking changes to watch for
4. Recommend testing strategy after updates

Prioritize security updates and LTS versions.
```

**Usage**: `/update-deps`

**Result**: Lists outdated dependencies, suggests update strategy.

---

## Example 10: Bug Report Generator

**Purpose**: Generate detailed bug report with context.

**File**: `.claude/commands/bug-report.md`

```markdown
---
description: Generate bug report with full context
argument-hint: <description>
allowed-tools: Bash(git:*), Bash(npm:*), Read
---

Bug description: $ARGUMENTS

System information:
!`node --version && npm --version`

Git context:
!`git branch --show-current`
!`git log --oneline -5`

Package info:
@package.json

Please generate a detailed bug report including:
1. **Title**: Clear, concise description
2. **Description**: Detailed explanation
3. **Steps to Reproduce**: Numbered steps
4. **Expected Behavior**: What should happen
5. **Actual Behavior**: What actually happens
6. **Environment**: Versions, OS, etc.
7. **Additional Context**: Relevant code, logs, screenshots

Format as GitHub issue markdown.
```

**Usage**: `/bug-report Login fails with OAuth`

**Result**: Generates comprehensive bug report with system context.

---

## Example 11: Database Migration Helper

**Purpose**: Generate database migration from schema changes.

**File**: `.claude/commands/migration.md`

```markdown
---
description: Generate database migration script
argument-hint: <description>
allowed-tools: Read, Grep
---

Migration purpose: $ARGUMENTS

Current schema:
@prisma/schema.prisma

Please generate a database migration script that:
1. Creates necessary tables/columns
2. Handles data transformations safely
3. Includes rollback strategy
4. Preserves existing data
5. Uses transactions for safety

Include both UP and DOWN migrations.
```

**Usage**: `/migration Add user roles table`

**Result**: Generates migration script with up/down migrations.

---

## Example 12: Code Style Enforcer

**Purpose**: Check code against team style guide.

**File**: `.claude/commands/style-check.md`

```markdown
---
description: Check code against team style guide
argument-hint: <file-path>
allowed-tools: Read, Bash(eslint:*), Bash(prettier:*)
---

File to check:
@$1

Linter output:
!`npx eslint $1 2>&1 || true`

Prettier check:
!`npx prettier --check $1 2>&1 || true`

Team style guide:
@.eslintrc.json

Please review this file for:
1. ESLint violations with fixes
2. Prettier formatting issues
3. Team-specific conventions
4. Naming consistency
5. Code organization

Suggest specific fixes with code examples.
```

**Usage**: `/style-check src/components/Button.tsx`

**Result**: Checks code style, suggests fixes.

---

## Example 13: Quick Feature Implementation

**Purpose**: Implement feature following project standards.

**File**: `.claude/commands/feature.md`

```markdown
---
description: Implement a new feature following project standards
argument-hint: <feature-description>
allowed-tools: Read, Write, Edit, Grep
---

Feature request: $ARGUMENTS

Project structure:
!`tree -L 2 -I 'node_modules|.git' .`

Architecture guide:
@architecture.md

Please implement this feature:
1. Create necessary files in appropriate directories
2. Follow existing code patterns and conventions
3. Include TypeScript types
4. Add unit tests
5. Update relevant documentation

Show me the implementation plan first before creating files.
```

**Usage**: `/feature Add user profile page`

**Result**: Plans and implements feature following project standards.

---

## Example 14: Test Coverage Reporter

**Purpose**: Analyze test coverage and suggest improvements.

**File**: `.claude/commands/coverage.md`

```markdown
---
description: Analyze test coverage and suggest improvements
allowed-tools: Bash(npm run:*), Read, Grep
---

Running coverage report:
!`npm run test:coverage 2>&1 | tail -30`

Please analyze test coverage and:
1. Identify files with low coverage (<80%)
2. Suggest critical paths to test
3. Recommend test cases for edge cases
4. Highlight untested error paths
5. Estimate effort to improve coverage

Prioritize business-critical code paths.
```

**Usage**: `/coverage`

**Result**: Analyzes coverage, suggests test improvements.

---

## Example 15: Release Notes Generator

**Purpose**: Generate release notes from git history.

**File**: `.claude/commands/release-notes.md`

```markdown
---
description: Generate release notes from git commits
argument-hint: <from-tag> <to-tag>
allowed-tools: Bash(git log:*)
---

Commits between $1 and $2:
!`git log $1..$2 --oneline --no-merges`

Detailed changes:
!`git log $1..$2 --no-merges --format='%h %s'`

Please generate release notes categorized by:
- 🚀 **New Features**
- 🐛 **Bug Fixes**
- 📝 **Documentation**
- ⚡ **Performance**
- 🔒 **Security**
- 💥 **Breaking Changes**

Use markdown format suitable for GitHub releases.
```

**Usage**: `/release-notes v1.0.0 v1.1.0`

**Result**: Generates categorized release notes from commits.
