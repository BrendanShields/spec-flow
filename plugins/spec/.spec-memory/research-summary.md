# CLI Optimization Research - Executive Summary

**Date:** 2025-10-31
**Full Report:** [research-cli-optimization.md](./research-cli-optimization.md)

---

## Key Findings

### 1. Single Entry Point Pattern (Hub Command)

**Best Practice:** Tools like git, docker, kubectl use one command with subcommands.

**For Spec:**
```bash
# Before: 9 separate commands
/spec-init, /spec-specify, /spec-plan, etc.

# After: 1 hub command
spec init
spec spec new "feature"
spec plan
spec task list
```

**Benefits:**
- Single command to remember
- Better discoverability
- Consistent flag handling
- Easier documentation

**Implementation:** Use Clap (Rust), Click (Python), or Commander (Node.js)

---

### 2. Token Efficiency (Target: 80% Reduction)

**Best Practice:** Claude AI tools should lazy-load context and compress documentation.

**Current vs Target:**
```
SKILL.md:      800 tokens → 180 tokens (77% reduction)
examples.md:  3000 tokens → 500 tokens (83% reduction)
reference.md: 5000 tokens → 800 tokens (84% reduction)
Templates:    1500 tokens → 300 tokens (80% reduction)
```

**Techniques:**
1. **Lazy Loading:** Load skills only when invoked
2. **Compression:** Abbreviate, use YAML/JSON instead of prose
3. **Progressive Context:** Start minimal, expand as needed
4. **Compact Templates:** Separate instructions from templates
5. **File Pruning:** Tell Claude what to ignore

**Example Structure:**
```markdown
# CORE.md (2K tokens - always loaded)
Brief overview, current state only

# SKILL.md (180 tokens - load on command)
Minimal implementation guide

# examples.md (500 tokens - load on request)
Separate file, loaded via "spec help spec"

# reference.md (800 tokens - load on request)
Detailed docs, loaded via "spec help spec --detailed"
```

---

### 3. Interactive CLI Patterns

**Best Practice:** Support three interaction modes with progressive disclosure.

**Three Modes:**
```bash
# 1. Direct (experts)
spec spec new "feature" --priority=P1

# 2. Interactive (learning)
spec --interactive
> What would you like to do?
  1. Create specification
  2. Continue implementation
  3. Check status

# 3. Wizard (setup)
spec init --wizard
> Step 1 of 5: Project type?
  [ ] Web App
  [ ] API
  [ ] CLI Tool
```

**Progressive Help:**
```bash
# Level 1: No args - show common commands (5-7 items)
spec

# Level 2: Help flag - show full usage
spec spec --help

# Level 3: Help command - show detailed guide
spec help spec
```

**Key Libraries:**
- Node.js: Inquirer.js
- Python: Rich + Prompt Toolkit
- Rust: Dialoguer

---

### 4. Team Collaboration

**Best Practice:** Feature-level locking + merge-friendly formats + append-only logs.

**File Structure for Teams:**
```
.spec-state/          # Local only (git-ignored)
├── current-session.md   # Developer's current work
└── sessions/            # Local session history

.spec-memory/         # Team shared (append-only)
├── WORKFLOW-PROGRESS.md # Append-only log (no conflicts)
├── DECISIONS-LOG.md     # ADRs (append-only)
└── CHANGES-COMPLETED.md # Completed work

features/001-auth/       # Feature isolation
├── spec.md              # One owner at a time
├── plan.md              # Reviewed before merge
├── tasks.md             # Task assignments
└── .lock                # Lock file (auto-expires)
```

**Locking Behavior:**
```bash
# Alice starts work
$ spec implement --feature=001
🔒 Lock acquired for feature 001

# Bob tries same feature
$ spec implement --feature=001
❌ Feature 001 locked by alice@example.com (4 hours ago)

Options:
  1. Work on different feature
  2. Contact alice@example.com
  3. Force unlock (if stale)
```

**Merge-Friendly Formats:**
- ✅ Markdown with clear sections
- ✅ YAML (vertical structure)
- ✅ Append-only logs
- ❌ JSON (bracket hell)
- ❌ Inline edits to same sections

---

### 5. Living Documentation (Master Spec)

**Best Practice:** Auto-generate master spec from features + ADRs + use semantic versioning.

**Master Spec (Auto-Generated):**
```markdown
# .spec/master-spec.md

## Active Features (3)
- [001: Authentication](../features/001-authentication/spec.md) - P1, Implementation
- [002: Billing](../features/002-billing/spec.md) - P2, Planning
- [003: Reporting](../features/003-reporting/spec.md) - P3, Specification

## Architecture Decisions
- [ADR-001: Use PostgreSQL](.spec-memory/adrs/001-postgresql.md)
- [ADR-002: JWT Authentication](.spec-memory/adrs/002-jwt-auth.md)

## Team Assignments
- alice@example.com: Feature 001, 002
- bob@example.com: Feature 003
```

**Spec Versioning:**
```markdown
# Feature 001: Authentication
Version: 2.1.0

## Changelog
### 2.1.0 (2025-10-31)
- Added: OAuth2 support requirement (minor)

### 2.0.0 (2025-10-25)
- Changed: JWT instead of sessions (major - breaking)

### 1.0.0 (2025-10-15)
- Initial specification
```

**ADR Pattern:**
```markdown
# ADR-001: Use PostgreSQL

## Status
Accepted

## Context
Need relational database for transactions.

## Decision
Use PostgreSQL 15+

## Consequences
+ JSONB support, advanced indexing
- More complex than MySQL

## Alternatives
MySQL, MongoDB (rejected)
```

**Sync Commands:**
```bash
# Generate master spec
spec sync master-spec

# Sync to Jira
spec sync --to=jira

# Bidirectional sync daemon
spec sync daemon start
```

---

## Implementation Roadmap

### Phase 1: Single Entry Point (Weeks 1-2)
**Priority:** High
**Effort:** Medium
**Impact:** High (immediate UX improvement)

Tasks:
- [ ] Create hub command structure
- [ ] Migrate slash commands to subcommands
- [ ] Implement global options (--verbose, --quiet, etc.)
- [ ] Add shell completion
- [ ] Update all documentation

**Example:** `spec <command> [subcommand] [options]`

---

### Phase 2: Token Optimization (Weeks 2-3)
**Priority:** High
**Effort:** Medium
**Impact:** High (cost savings, performance)

Tasks:
- [ ] Create lazy-loading architecture
- [ ] Compress all SKILL.md files (target: 180 tokens each)
- [ ] Split examples.md and reference.md (load on demand)
- [ ] Optimize templates (target: 300 tokens)
- [ ] Implement token budget tracking

**Target:** 80% reduction in context size

---

### Phase 3: Interactive Patterns (Weeks 3-4)
**Priority:** Medium
**Effort:** Medium
**Impact:** Medium (better for new users)

Tasks:
- [ ] Add `--interactive` mode with menus
- [ ] Implement `--wizard` mode for setup
- [ ] Create progressive help system (3 levels)
- [ ] Add context-aware prompts
- [ ] Implement validation with suggestions

**Example:** `spec --interactive` for menu-driven workflow

---

### Phase 4: Team Collaboration (Weeks 4-5)
**Priority:** Medium
**Effort:** High
**Impact:** High (enables teams)

Tasks:
- [ ] Implement feature-level locking
- [ ] Convert memory files to append-only format
- [ ] Add team status visibility
- [ ] Create sync commands
- [ ] Implement conflict detection/resolution

**Example:** `spec status --team` to see who's working on what

---

### Phase 5: Living Documentation (Weeks 5-6)
**Priority:** Low
**Effort:** High
**Impact:** Medium (long-term value)

Tasks:
- [ ] Generate master-spec.md from features
- [ ] Implement ADR support
- [ ] Add semantic versioning for specs
- [ ] Create sync engine (Jira/Confluence)
- [ ] Implement validation commands

**Example:** `spec sync master-spec` for auto-generated overview

---

## Quick Reference

### Command Consolidation

| Before | After |
|--------|-------|
| `/spec-init` | `spec init` |
| `/spec-specify` | `spec spec new` |
| `/spec-plan` | `spec plan` |
| `/spec-tasks` | `spec task list` |
| `/spec-implement` | `spec implement` |
| `/status` | `spec status` |
| `/help` | `spec help` |
| `/session save` | `spec session save` |
| `/validate` | `spec validate` |

### Token Budget Targets

| File Type | Current | Target | Reduction |
|-----------|---------|--------|-----------|
| SKILL.md | 800 | 180 | 77% |
| examples.md | 3000 | 500 | 83% |
| reference.md | 5000 | 800 | 84% |
| Templates | 1500 | 300 | 80% |
| **Total** | **10300** | **1780** | **83%** |

### File Organization

| Path | Purpose | Git | Conflicts |
|------|---------|-----|-----------|
| `.spec-state/` | Current session | Ignored | None (local) |
| `.spec-memory/` | Team memory | Tracked | None (append-only) |
| `features/###/` | Feature specs | Tracked | Low (locked) |
| `.spec/config.yaml` | Project config | Tracked | Low (rare changes) |

---

## Anti-Patterns to Avoid

### Command Design
❌ Arbitrary abbreviations (`spe` → `spec`)
❌ Too many positional arguments
❌ Inconsistent flag names
❌ Required interactive prompts without `--no-input`

### Token Management
❌ Loading all documentation upfront
❌ Repeating content across files
❌ Verbose templates with inline instructions
❌ Keeping infinite conversation history

### Team Collaboration
❌ Using JSON for shared configuration
❌ Allowing concurrent edits to same feature
❌ Locks without expiration times
❌ No conflict detection before push

### Documentation
❌ External wiki that gets stale
❌ Manual sync processes (forgotten)
❌ No version history for decisions
❌ Separate decision tracking systems

---

## Resources

### Essential Reading
- [Command Line Interface Guidelines](https://clig.dev/) - Comprehensive CLI UX guide
- [Claude Token Optimization](https://claudelog.com/faqs/how-to-optimize-claude-code-token-usage/)
- [Terraform State Locking](https://developer.hashicorp.com/terraform/language/state/locking)

### Key Libraries
- **Rust:** clap (argument parsing), dialoguer (interactive)
- **Python:** click (CLI framework), rich (formatting)
- **Node.js:** commander (arguments), inquirer (prompts)

### Case Studies
- [76% Token Reduction](https://web-werkstatt.at/aktuell/breaking-the-claude-context-limit/) - Context compression
- [Atlantis](https://www.runatlantis.io/) - Terraform PR workflow with locking
- [Semantic Release](https://github.com/semantic-release/semantic-release) - Auto-versioning

---

## Next Steps

1. **Review full report:** [research-cli-optimization.md](./research-cli-optimization.md)
2. **Prioritize phases:** Confirm implementation order
3. **Create prototypes:** Test hub command and token optimization
4. **Update roadmap:** Integrate findings into feature planning
5. **Begin Phase 1:** Start with single entry point migration

---

**Document Status:** Complete
**Full Report:** 43,000+ tokens of detailed research
**Implementation:** Ready to begin Phase 1
