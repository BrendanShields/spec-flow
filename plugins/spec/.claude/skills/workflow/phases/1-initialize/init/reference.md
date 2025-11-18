# Initialize phase Reference

Complete technical documentation for the Initialize phase skill.

---

## Table of Contents

1. [Directory Structure Specification](#directory-structure-specification)
2. [File Templates](#file-templates)
3. [Configuration Options](#configuration-options)
4. [Detection Algorithms](#detection-algorithms)
5. [Integration Points](#integration-points)
6. [Error Handling](#error-handling)
7. [Advanced Usage](#advanced-usage)

---

## Directory Structure Specification

### Complete Directory Layout

```
project-root/
│
├── {config.paths.spec_root}/                          # Configuration directory (committed to git)
│   ├── product-requirements.md        # Product vision and goals
│   ├── architecture-blueprint.md      # (Optional) Architecture guidelines
│   ├── templates/                     # Custom templates
│   │   ├── feature-spec.md
│   │   ├── feature-plan.md
│   │   ├── adr-template.md
│   │   └── user-story.md
│   └── scripts/                       # Utility scripts
│       ├── config.sh                  # Configuration loader
│       ├── state-utils.sh             # State management utilities
│       └── hooks/                     # Git hooks (optional)
│           ├── pre-commit
│           └── post-checkout
│
├── {config.paths.state}/                    # Session state (gitignored)
│   ├── current-session.md             # Active work tracking
│   └── checkpoints/                   # Session snapshots
│       ├── checkpoint-001.md
│       └── checkpoint-002.md
│
├── {config.paths.memory}/                   # Persistent memory (committed to git)
│   ├── workflow-progress.md           # Feature completion metrics
│   ├── decisions-log.md               # Architecture Decision Records
│   ├── changes-planned.md             # Pending implementation tasks
│   └── changes-completed.md           # Completed work history
│
├── {config.paths.features}/                          # Feature artifacts (created by generate phase)
│   └── 001-feature-name/
│       ├── spec.md
│       ├── plan.md
│       └── tasks.md
│
└── .gitignore                         # Updated to ignore {config.paths.state}/
```

### File Size Expectations

| File | Typical Size | Max Size |
|------|--------------|----------|
| `product-requirements.md` | 50-200 lines | 500 lines |
| `current-session.md` | 100-300 lines | 1000 lines |
| `workflow-progress.md` | 50-500 lines | 2000 lines |
| `decisions-log.md` | 10-100 entries | Unlimited |
| `architecture-blueprint.md` | 200-800 lines | 2000 lines |

### Directory Permissions

```bash
# All directories: 755 (rwxr-xr-x)
chmod 755 .spec {config.paths.state} {config.paths.memory}

# Scripts: 755 (executable)
chmod 755 {config.paths.spec_root}/scripts/*.sh

# Config files: 644 (rw-r--r--)
chmod 644 {config.paths.spec_root}/*.md {config.paths.memory}/*.md
```

---

## File Templates

### Template 1: product-requirements.md

```markdown
# Product Requirements Document

**Project**: [Project Name]
**Created**: [Date]
**Owner**: [Product Owner]
**Status**: Draft

---

## Vision

### Problem Statement
[What problem are we solving?]

### Target Users
- **Primary**: [User persona 1]
- **Secondary**: [User persona 2]

### Success Criteria
1. [Measurable outcome 1]
2. [Measurable outcome 2]
3. [Measurable outcome 3]

---

## Goals & Non-Goals

### Goals
- [ ] [Goal 1]
- [ ] [Goal 2]
- [ ] [Goal 3]

### Non-Goals
- [Explicitly out of scope item 1]
- [Explicitly out of scope item 2]

---

## Constraints

### Technical Constraints
- [Constraint 1]
- [Constraint 2]

### Business Constraints
- Budget: [Amount]
- Timeline: [Date]
- Resources: [Team size]

### Regulatory Constraints
- [Compliance requirement 1]
- [Compliance requirement 2]

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| [Metric 1] | [Value] | [How measured] |
| [Metric 2] | [Value] | [How measured] |

---

## Stakeholders

- **Product Owner**: [Name]
- **Tech Lead**: [Name]
- **Engineering**: [Team]
- **Design**: [Name]
- **QA**: [Name]

---

## Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| [Risk 1] | High/Med/Low | High/Med/Low | [Strategy] |

---

*Last Updated: [Date]*
```

### Template 2: current-session.md

```markdown
# Current Session State

**Session ID**: sess_[UUID]
**Created**: [Timestamp]
**Updated**: [Timestamp]
**Claude Conversation**: [Conversation ID]

---

## Active Work

### Current Feature
- **Feature ID**: [ID]
- **Feature Name**: [Name]
- **Phase**: [specification|planning|implementation|complete]
- **Started**: [Timestamp]
- **JIRA**: [ID] (if applicable)

### Current Task
- **Task ID**: [ID]
- **Description**: [Description]
- **User Story**: [Story ID]
- **Status**: [in_progress|blocked|complete]
- **Progress**: [Current]/[Total] tasks

---

## Workflow Progress

### Completed Phases
- [x] Initialize phase - Project initialization ([Timestamp])
- [ ] generate phase - Feature specification
- [ ] plan phase - Technical design
- [ ] tasks phase - Task breakdown
- [ ] implement phase - Implementation

### Task Completion
```
Phase 1: Foundation [0/0]
(Tasks added during tasks phase)

Phase 2: Core Features [0/0]
(Tasks added during tasks phase)
```

---

## Configuration State

### Spec Settings
```bash
SPEC_JIRA_PROJECT_KEY=[KEY]
SPEC_REQUIRE_BLUEPRINT=[true|false]
SPEC_REQUIRE_ADR=[true|false]
SPEC_AUTO_VALIDATE=[true|false]
```

### Active Integrations
- **JIRA**: [Enabled/Disabled]
- **Confluence**: [Enabled/Disabled]
- **GitHub**: [Enabled/Disabled]

---

## Context Information

### Git State
- **Branch**: [Branch name]
- **Base Branch**: [main|master|develop]
- **Last Commit**: [Hash] "[Message]"
- **Uncommitted Changes**: [Count] files

### Recent Commands
1. [Timestamp] - Initialize phase (success)

---

## Pending Items

### Decisions Required
(None yet)

### Blockers
(None yet)

### Clarifications Pending
(None yet)

---

## Quick Resume Commands

Based on current state:
```bash
# Next step
generate phase "Feature Name"

# Check status
spec:status

# Validate setup
spec:validate
```

---

*Maintained by Spec Workflow System*
*Initialized: [Timestamp]*
```

### Template 3: workflow-progress.md

```markdown
# Workflow Progress

**Project Started**: [Date]
**Last Updated**: [Date]
**Total Features**: 0

---

## Feature Progress Overview

### Active Features

| Feature | Phase | Progress | Started | ETA | Blocked |
|---------|-------|----------|---------|-----|---------|
| (None yet) | - | - | - | - | - |

### Completed Features

| Feature | Completed | Duration | Tasks | Velocity | Quality |
|---------|-----------|----------|-------|----------|---------|
| (None yet) | - | - | - | - | - |

### Planned Features

| Priority | Feature | Estimated Tasks | Estimated Time | Dependencies |
|----------|---------|----------------|----------------|--------------|
| (None yet) | - | - | - | - |

---

## Workflow Metrics

### Overall Statistics
- **Features Completed**: 0
- **Total Tasks Completed**: 0
- **Average Velocity**: N/A
- **Success Rate**: N/A

### Phase Timing (Estimated)
| Phase | Avg Duration | Typical Output |
|-------|-------------|----------------|
| Specification | 30 min | spec.md (~200 lines) |
| Planning | 45 min | plan.md (~150 lines) |
| Tasks | 25 min | 10-20 tasks |
| Implementation | 4h | Feature complete |

---

## Development Insights

### Recent Achievements
(None yet)

### Current Blockers
(None yet)

---

## Next Steps

1. Create first feature: `generate phase "Feature Name"`
2. Define architecture: `blueprint phase`
3. Discover existing code: `discover phase` (brownfield)

---

*Maintained by Spec Workflow System*
*Project Version: [Version]*
```

### Template 4: decisions-log.md

```markdown
# Architecture Decisions Log

Record of all significant technical and architectural decisions.

---

## Decision Index

| ID | Date | Title | Status | Impact |
|----|------|-------|--------|--------|
| (None yet) | - | - | - | - |

---

## Decision Template

### ADR-XXX: [Decision Title]

**Date**: [YYYY-MM-DD]
**Status**: [Proposed | Accepted | Deprecated | Superseded]
**Deciders**: [Names]
**Feature**: [Feature ID]

#### Context
[What is the issue we're seeing that motivates this decision?]

#### Decision
[What is the change we're proposing/have agreed to?]

#### Consequences
**Positive**:
- [Benefit 1]
- [Benefit 2]

**Negative**:
- [Trade-off 1]
- [Trade-off 2]

**Neutral**:
- [Impact 1]

#### Alternatives Considered
1. **[Alternative 1]**: [Why rejected]
2. **[Alternative 2]**: [Why rejected]

#### Implementation Notes
[Technical details, migration path, etc.]

---

*Log Format: ADR (Architecture Decision Record)*
*For ADR template: `{config.paths.spec_root}/templates/adr-template.md`*
```

### Template 5: config.sh

```bash
#!/bin/bash
# Spec Workflow Configuration
# Auto-generated by Initialize phase

# Project Metadata
export SPEC_PROJECT_NAME="[Project Name]"
export SPEC_PROJECT_VERSION="0.1.0"
export SPEC_INIT_DATE="[Date]"

# Workflow Settings
export SPEC_REQUIRE_BLUEPRINT="false"      # Require architecture blueprint
export SPEC_REQUIRE_ADR="false"            # Require ADR for decisions
export SPEC_AUTO_VALIDATE="true"           # Auto-validate after commands
export SPEC_AUTO_CHECKPOINT="false"        # Auto-save checkpoints

# Integration Settings
export SPEC_JIRA_ENABLED="false"
export SPEC_JIRA_PROJECT_KEY=""
export SPEC_CONFLUENCE_ENABLED="false"
export SPEC_CONFLUENCE_ROOT_PAGE_ID=""
export SPEC_GITHUB_ENABLED="true"

# Feature Settings
export SPEC_FEATURE_PREFIX="features"      # Directory for features
export SPEC_BRANCH_PREPEND_JIRA="false"   # Prepend JIRA ID to branches

# Template Settings
export SPEC_TEMPLATES_DIR="{config.paths.spec_root}/templates"
export SPEC_USE_CUSTOM_TEMPLATES="false"

# Utility Functions
should_require_blueprint() {
  [[ "$SPEC_REQUIRE_BLUEPRINT" == "true" ]]
}

should_require_adr() {
  [[ "$SPEC_REQUIRE_ADR" == "true" ]]
}

should_auto_validate() {
  [[ "$SPEC_AUTO_VALIDATE" == "true" ]]
}

get_jira_key() {
  echo "$SPEC_JIRA_PROJECT_KEY"
}

# Load project-specific overrides
if [[ -f "{config.paths.spec_root}/config.local.sh" ]]; then
  source "{config.paths.spec_root}/config.local.sh"
fi
```

---

## Configuration Options

### Command-Line Flags

```bash
# Basic initialization
Initialize phase

# Force reinitialize (overwrites existing)
Initialize phase --force

# Skip interactive prompts (use defaults)
Initialize phase --quiet

# Custom configuration
Initialize phase --blueprint-required --adr-required

# Team configuration
Initialize phase --team=checkout --jira=CHKT
```

### Environment Variables

```bash
# Override default settings
export SPEC_INIT_QUIET=true
export SPEC_INIT_FORCE=true
export SPEC_DEFAULT_BRANCH=main
export SPEC_TEAM_NAME=checkout

# Then run
Initialize phase
```

### Configuration File

Create `{config.paths.spec_root}/config.local.sh` for project-specific overrides:

```bash
#!/bin/bash
# Project-specific configuration

# Override defaults
export SPEC_REQUIRE_BLUEPRINT="true"
export SPEC_REQUIRE_ADR="true"

# Team settings
export SPEC_TEAM="checkout"
export SPEC_SLACK_CHANNEL="#team-checkout"

# Custom paths
export SPEC_FEATURE_PREFIX="src/features"
```

---

## Detection Algorithms

### Project Type Detection

```bash
#!/bin/bash
# Detect greenfield vs brownfield

detect_project_type() {
  local source_files=$(find . -type f \
    \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o \
       -name "*.java" -o -name "*.go" -o -name "*.rb" \) \
    ! -path "*/node_modules/*" \
    ! -path "*/venv/*" \
    ! -path "*/.git/*" \
    | wc -l)

  if [[ $source_files -lt 5 ]]; then
    echo "greenfield"
  else
    echo "brownfield"
  fi
}

# Usage
PROJECT_TYPE=$(detect_project_type)
if [[ "$PROJECT_TYPE" == "brownfield" ]]; then
  echo "Suggest: discover phase"
fi
```

### Technology Stack Detection

```bash
#!/bin/bash
# Detect project technology

detect_stack() {
  # Node.js
  [[ -f "package.json" ]] && echo "node"

  # Python
  [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]] && echo "python"

  # Java
  [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]] && echo "java"

  # Go
  [[ -f "go.mod" ]] && echo "go"

  # Ruby
  [[ -f "Gemfile" ]] && echo "ruby"

  # Rust
  [[ -f "Cargo.toml" ]] && echo "rust"
}
```

### Monorepo Detection

```bash
#!/bin/bash
# Detect monorepo structure

is_monorepo() {
  # Check for common monorepo patterns
  [[ -f "lerna.json" ]] || \
  [[ -f "pnpm-workspace.yaml" ]] || \
  [[ -f "nx.json" ]] || \
  [[ -d "packages" && $(ls -1 packages | wc -l) -gt 2 ]]
}

get_package_root() {
  # Walk up directory tree to find package root
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/package.json" ]] && \
       [[ -f "$dir/../../package.json" ]]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  echo "$PWD"
}
```

---

## Integration Points

### Git Integration

**Auto-create .gitignore entries**:
```bash
# Read existing .gitignore
if [[ -f ".gitignore" ]]; then
  GITIGNORE=$(cat .gitignore)
else
  GITIGNORE=""
fi

# Append if missing
if ! echo "$GITIGNORE" | grep -q "{config.paths.state}"; then
  echo "" >> .gitignore
  echo "# Spec Workflow - Session State" >> .gitignore
  echo "{config.paths.state}/" >> .gitignore
fi
```

**Git hooks (optional)**:
```bash
# {config.paths.spec_root}/scripts/hooks/pre-commit
#!/bin/bash
# Validate spec consistency before commit

if [[ -d ".spec" ]]; then
  echo "Running spec validation..."
  spec:validate || {
    echo "Validation failed! Fix errors or skip with --no-verify"
    exit 1
  }
fi
```

### JIRA Integration

**Create JIRA configuration**:
```bash
# {config.paths.spec_root}/scripts/jira-config.sh
export SPEC_JIRA_URL="https://company.atlassian.net"
export SPEC_JIRA_PROJECT_KEY="PROJ"
export SPEC_JIRA_AUTH_METHOD="token"  # token|oauth|basic
```

**Feature-to-JIRA mapping**:
```markdown
# {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
---
jira: PROJ-123
confluence: 456789
---
```

### Confluence Integration

**Page hierarchy**:
```
Project Space
└── Requirements (root page)
    ├── Feature 001
    │   ├── Specification
    │   ├── Technical Plan
    │   └── Implementation Log
    └── Feature 002
```

---

## Error Handling

### Error 1: Already Initialized

**Detection**:
```bash
if [[ -d ".spec" ]]; then
  echo "Error: Already initialized"
  exit 1
fi
```

**Recovery**:
```bash
# Option 1: Validate
spec:validate

# Option 2: Force reinit
Initialize phase --force

# Option 3: Manual cleanup
rm -rf .spec {config.paths.state}
Initialize phase
```

### Error 2: Git Not Found

**Detection**:
```bash
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not a git repository"
  exit 1
fi
```

**Recovery**:
```bash
git init
git add .
git commit -m "Initial commit"
Initialize phase
```

### Error 3: Permission Denied

**Detection**:
```bash
if ! touch {config.paths.spec_root}/test 2>/dev/null; then
  echo "Error: Cannot write to directory"
  exit 1
fi
rm -f {config.paths.spec_root}/test
```

**Recovery**:
```bash
# Fix permissions
chmod 755 .
sudo chown -R $USER .

# Retry
Initialize phase
```

### Error 4: Corrupted State

**Detection**:
```bash
# Check for required files
REQUIRED_FILES=(
  "{config.paths.spec_root}/product-requirements.md"
  "{config.paths.state}/current-session.md"
  "{config.paths.memory}/workflow-progress.md"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Error: Missing $file"
    exit 1
  fi
done
```

**Recovery**:
```bash
# Backup existing
mv .spec .spec.backup.$(date +%Y%m%d)
mv {config.paths.state} {config.paths.state}.backup.$(date +%Y%m%d)

# Reinitialize
Initialize phase

# Restore memory (has history)
cp -r {config.paths.memory}.backup.$(date +%Y%m%d)/* {config.paths.memory}/
```

---

## Advanced Usage

### Custom Template Override

Create `{config.paths.spec_root}/templates/feature-spec.md`:
```markdown
# Custom Spec Template

## Your Custom Sections
[Team-specific content]

## Standard Sections
[Required content]
```

Enable:
```bash
export SPEC_USE_CUSTOM_TEMPLATES="true"
generate phase "Feature"  # Uses custom template
```

### Multi-Environment Setup

```bash
# {config.paths.spec_root}/config.dev.sh
export SPEC_ENV="development"
export SPEC_JIRA_ENABLED="false"

# {config.paths.spec_root}/config.prod.sh
export SPEC_ENV="production"
export SPEC_JIRA_ENABLED="true"
export SPEC_REQUIRE_ADR="true"

# Usage
source {config.paths.spec_root}/config.dev.sh
Initialize phase
```

### Team-Specific Initialization

```bash
# Initialize for specific team
Initialize phase \
  --team=checkout \
  --jira=CHKT \
  --slack="#team-checkout" \
  --blueprint-required \
  --adr-required
```

Creates:
```bash
{config.paths.spec_root}/
├── team.md              # Team documentation
├── config.sh            # Team configuration
└── templates/
    └── team-spec.md     # Team template
```

---

## Validation Checklist

After `Initialize phase`, validate with:

```bash
# Structure check
test -d .spec && echo "✅ Config directory"
test -d {config.paths.state} && echo "✅ State directory"
test -d {config.paths.memory} && echo "✅ Memory directory"

# File check
test -f {config.paths.spec_root}/product-requirements.md && echo "✅ PRD"
test -f {config.paths.state}/current-session.md && echo "✅ Session"
test -f {config.paths.memory}/workflow-progress.md && echo "✅ Progress"
test -f {config.paths.memory}/decisions-log.md && echo "✅ Decisions"

# Git check
grep -q "{config.paths.state}/" .gitignore && echo "✅ .gitignore"

# Permissions check
test -x {config.paths.spec_root}/scripts/config.sh && echo "✅ Scripts executable"

# Complete
echo "✅ Initialization validated"
```

---

## Plugin Template Locations

Templates source (in plugin):
```
/Users/dev/dev/tools/marketplace/plugins/spec/
├── {config.paths.state}/
│   └── current-session-template.md
├── {config.paths.memory}/
│   ├── workflow-progress.md
│   ├── decisions-log.md
│   ├── changes-planned.md
│   └── changes-completed.md
└── templates/
    └── product-requirements.md
```

Copy to user project during initialization.

---

## Related Commands

```bash
# After initialization
spec:validate              # Check structure
spec:status               # View current state
blueprint phase            # Define architecture
discover phase             # Analyze existing code (brownfield)
generate phase "Feature"    # Create first feature

# Configuration
spec:config --list        # Show configuration
spec:config --edit        # Edit config file
spec:config --reset       # Reset to defaults
```

---

*Last Updated: 2024-10-31*
*Spec Workflow Version: 3.0*
