# Skill Builder: Examples

## Example 1: Creating a Code Review Skill

### User Request
"I need a skill that automatically reviews code for best practices and security issues"

### Skill Builder Execution

#### Step 1: Requirements Analysis
```
Purpose: Automated code review
Triggers: "review code", "check code quality", "security audit"
Audience: Development teams
Frequency: Multiple times daily
Complexity: Multi-step workflow
```

#### Step 2: Generated SKILL.md
```yaml
---
name: code-reviewer
description: Perform comprehensive code reviews checking style, security, performance, and best practices. Use when: 1) User requests code review, 2) PR needs review, 3) Security audit requested, 4) Code quality check needed, 5) Before deployment. Generates detailed review report with actionable feedback.
allowed-tools: Read, Grep, Glob, WebSearch
---

# Code Reviewer: Automated Code Quality Analysis

Comprehensive code review system checking style, security, performance, and maintainability.

## What This Skill Does

- Analyzes code for style violations
- Identifies security vulnerabilities
- Detects performance bottlenecks
- Suggests refactoring opportunities
- Checks test coverage

## Execution Flow

### Phase 1: Code Discovery
1. Identify changed files
2. Detect programming languages
3. Load language-specific rules

### Phase 2: Analysis
1. Style check (linting)
2. Security scan (OWASP patterns)
3. Performance analysis
4. Complexity metrics
5. Test coverage check

### Phase 3: Report Generation
1. Prioritize issues (Critical/High/Medium/Low)
2. Provide fix suggestions
3. Generate actionable report
```

#### Step 3: Generated examples.md
```markdown
# Code Reviewer: Examples

## Example 1: Python Security Review
### Input
"Review this Python API for security issues"

### Output
✅ Security Review Complete
- SQL Injection Risk: Line 45 (use parameterized queries)
- Missing input validation: Lines 23, 67
- Hardcoded credentials: Line 12 (use environment variables)
```

---

## Example 2: Creating a Data Transformation Skill

### User Request
"Build a skill for transforming CSV files into different formats with filtering"

### Skill Builder Process

#### Requirements Gathering via Questions
```
Q1: What formats should it support?
A: CSV, JSON, Excel, Parquet

Q2: What filtering capabilities?
A: Column selection, row filtering, aggregations

Q3: Typical file sizes?
A: 1MB to 1GB
```

#### Generated Description
```yaml
description: Transform CSV files to multiple formats with filtering, column selection, and aggregations. Use when: 1) Converting CSV to JSON/Excel/Parquet, 2) Filtering data by conditions, 3) Selecting specific columns, 4) Aggregating data (sum/avg/count), 5) User mentions data transformation or ETL. Outputs transformed file in requested format.
```

#### Key Design Decisions
- **Progressive Disclosure**: Core transformations in SKILL.md, advanced options in reference.md
- **Tool Restrictions**: `allowed-tools: Read, Write, Bash` (no Edit needed)
- **Error Handling**: File size limits, format validation, encoding detection

---

## Example 3: Creating a Documentation Generator Skill

### User Request
"I want a skill that generates documentation from code"

### Complete Skill Structure Created

```
doc-generator/
├── SKILL.md (2.8 KB)
│   - Core documentation logic
│   - Language detection
│   - Output format selection
├── examples.md (2.1 KB)
│   - Python docstring example
│   - JavaScript JSDoc example
│   - API documentation example
├── reference.md (4.5 KB)
│   - Supported languages
│   - Documentation formats
│   - Template customization
├── templates/
│   ├── api-doc.md
│   ├── readme.md
│   └── changelog.md
└── scripts/
    └── extract-comments.sh
```

### Generated YAML Frontmatter
```yaml
---
name: doc-generator
description: Generate documentation from code comments, function signatures, and structure. Use when: 1) Creating API documentation, 2) Generating README files, 3) Extracting docstrings/JSDoc, 4) Building reference guides, 5) User mentions documentation or docs. Creates markdown documentation with examples.
allowed-tools: Read, Write, Glob, Grep
---
```

---

## Example 4: Creating a Testing Skill

### User Request
"Create a skill for generating and running tests"

### Skill Builder Decisions

#### Activation Pattern Design
Primary triggers:
- "write tests"
- "generate unit tests"
- "create test suite"
- "test this code"

#### Progressive Disclosure Structure
```
Level 1 (Metadata): Name + Description
Level 2 (SKILL.md): Test generation logic
Level 3 (On-demand):
  - examples.md: Test patterns for each language
  - reference.md: Testing frameworks and assertions
  - templates/: Test file templates
```

#### Tool Restriction Logic
```yaml
allowed-tools: Read, Write, Edit, Bash
# Read: Analyze code to test
# Write: Create test files
# Edit: Update existing tests
# Bash: Run test commands
```

---

## Example 5: Creating a Skill from Repetitive Task

### Observed Pattern
User repeatedly asks:
1. "Check if this PR is ready"
2. "Are all tests passing?"
3. "Is documentation updated?"
4. "Are there merge conflicts?"

### Skill Builder Creates: PR Readiness Checker

```yaml
---
name: pr-checker
description: Verify pull request readiness by checking tests, conflicts, documentation, and review status. Use when: 1) PR readiness check requested, 2) Pre-merge validation needed, 3) CI/CD status check, 4) User mentions "ready to merge", 5) Deployment preparation. Outputs readiness report with checklist.
allowed-tools: Bash, Read, Grep
---
```

### Test Phrases Generated
✅ Should activate:
- "Is this PR ready?"
- "Check pull request status"
- "Can we merge this?"

❌ Should NOT activate:
- "Create a PR" (different intent)
- "Review code" (use code-reviewer skill)

---

## Example 6: Fixing a Vague Skill

### Original (Poor Discovery)
```yaml
name: helper
description: Helps with various tasks
```

### Skill Builder Diagnosis
❌ Issues identified:
- No specific triggers
- No use cases listed
- Unclear capability
- Generic name

### Improved Version
```yaml
name: git-workflow
description: Streamline git operations including branch management, commits, and conflict resolution. Use when: 1) Creating feature branches, 2) Committing with conventional messages, 3) Resolving merge conflicts, 4) Cherry-picking commits, 5) User mentions git workflow or branch management. Executes git commands with safety checks.
```

### Impact
- Discovery rate: 10% → 95%
- Auto-activation: Never → Consistently
- User satisfaction: Improved significantly

---

## Example 7: Enterprise Integration Skill

### Requirements
"Need a skill that integrates with our internal API for deployment"

### Security-Conscious Design
```yaml
---
name: deploy-internal
description: Deploy applications to internal infrastructure via secure API. Use when: 1) Deployment requested, 2) "Ship to production", 3) Release preparation, 4) Environment promotion, 5) User mentions deploy or release. Handles authentication and validation.
allowed-tools: Bash, WebFetch  # Minimal tools
---
```

### Security Measures Added
- Input sanitization functions
- API key management via environment
- Deployment validation checks
- Rollback procedures
- Audit logging

---

## Common Patterns Observed

### Pattern 1: Discovery Optimization
Before: 20% activation rate
After: 95% activation rate
Key: Added "Use when:" with 5+ specific triggers

### Pattern 2: Context Reduction
Before: 8,000 tokens loaded
After: 2,000 tokens (75% reduction)
Key: Moved examples and reference to separate files

### Pattern 3: Tool Minimization
Before: All tools available
After: Only required tools
Impact: Improved security and clarity

### Pattern 4: Version Evolution
v1: Basic functionality
v2: Added error handling
v3: Progressive disclosure
v4: Optimized descriptions
Result: 10x improvement in usability