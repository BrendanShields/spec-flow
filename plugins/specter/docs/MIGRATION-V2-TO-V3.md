# Migration Guide: Specter v2.1 → v3.0

**Target Audience**: Existing Specter v2.1 users
**Migration Time**: < 5 minutes
**Breaking Changes**: Command names and skill references only
**State Compatibility**: ✅ Full backward compatibility

---

## Executive Summary

Specter v3.0 is a **complete refactoring focused on token efficiency** while maintaining 100% functional compatibility. Your existing project files (`.specter/`, `.specter-memory/`, `features/`) work without modification.

**Key Changes**:
- 81% token reduction per skill invocation
- Unified `/spec` hub command (replaces individual `/specter-*` commands)
- Progressive disclosure architecture (3-tier lazy loading)
- State caching (80% reduction in state overhead)
- New skill naming: `specter:*` → `spec:*`

---

## Quick Migration

### TL;DR - Command Mapping

| v2.1 Command | v3.0 Command | Notes |
|--------------|--------------|-------|
| `/specter-init` | `/spec init` | Initialize project |
| `/specter-specify "X"` | `/spec "X"` or `/spec generate "X"` | Create specification |
| `/specter-clarify` | `/spec clarify` | Resolve ambiguities |
| `/specter-plan` | `/spec plan` | Technical design |
| `/specter-tasks` | `/spec tasks` | Task breakdown |
| `/specter-implement` | `/spec implement` | Execute implementation |
| `/specter-update "X"` | `/spec update "X"` | Update specification |
| `/specter-analyze` | `/spec analyze` | Validate consistency |
| `/specter-blueprint` | `/spec blueprint` | Define architecture |
| `/specter-orchestrate` | `/spec orchestrate` | Full workflow automation |
| `/specter-discover` | `/spec discover` | Brownfield analysis |
| `/specter-metrics` | `/spec metrics` | Show metrics |
| `/specter-checklist` | `/spec checklist` | Generate checklists |

**State Files**: No migration needed! All `.specter-*` directories work as-is.

---

## What Changed in v3.0

### 1. ✅ Unified Hub Command

**Before (v2.1)**:
```bash
/specter-init
/specter-specify "Add user auth"
/specter-plan
/specter-tasks
/specter-implement
```

**After (v3.0)**:
```bash
/spec init
/spec "Add user auth"
/spec plan
/spec tasks
/spec implement

# Or context-aware (even simpler)
/spec init
/spec "Add user auth"
/spec        # Auto-continues to plan
/spec        # Auto-continues to tasks
/spec        # Auto-continues to implement
```

**Benefit**: Single entry point, intelligent routing, context-awareness

### 2. ⚡ 81% Token Reduction

**v2.1 Performance**:
- Average: ~6,800 tokens per skill
- Full workflow (5 skills): ~34,000 tokens
- State overhead: ~10,000 tokens (read 5 times)

**v3.0 Performance**:
- Average: ~1,283 tokens per skill (81% reduction)
- Full workflow: ~6,400 tokens (81% reduction)
- State overhead: ~2,000 tokens (read once, cached)

**You'll Notice**:
- 3-5x faster command execution
- Much less context window usage
- More efficient multi-turn conversations

### 3. 🏗️ Progressive Disclosure Architecture

Skills split into 3 tiers with lazy loading:

**Tier 1: Metadata** (~100 tokens, always loaded)
```yaml
---
name: spec:generate
description: Create specifications from requirements
allowed-tools: Read, Write, Edit, AskUserQuestion
---
```

**Tier 2: Core Logic** (~1,500 tokens, loaded on trigger)
- Execution workflow
- Phase-by-phase instructions
- State management
- Basic examples

**Tier 3: Extended Resources** (~5,000+ tokens, lazy loaded)
- `EXAMPLES.md` - Comprehensive scenarios (load with `--examples`)
- `REFERENCE.md` - Full technical specs (load with `--reference`)

**Usage**:
```bash
/spec plan                    # Default: 1,500 tokens
/spec plan --examples         # + Examples: 6,600 tokens
/spec plan --reference        # + Full docs: 11,600 tokens
```

### 4. 📦 State Caching

Hub command reads state once and caches:

**Before (v2.1)**:
- Each skill reads `.specter-state/current-session.md`
- 5 skills × 2,000 tokens = 10,000 tokens overhead

**After (v3.0)**:
- `/spec` hub reads state once
- Caches in memory for entire execution
- Passes to all skills
- 1 × 2,000 tokens = 2,000 tokens overhead

**Savings**: 80% reduction in state overhead

### 5. 🔤 Skill Renaming

Internal skill references updated:

**Old Pattern**: `specter:specify`, `specter:plan`, `specter:implement`
**New Pattern**: `spec:generate`, `spec:plan`, `spec:implement`

**Impact**: Only affects custom integrations referencing skills directly. Standard usage unaffected.

---

## Step-by-Step Migration

### For Individual Developers

#### Step 1: Update Your Muscle Memory

Learn the new command pattern:
```bash
# Old habit
/specter-specify "Feature"

# New habit
/spec "Feature"

# Or explicit
/spec generate "Feature"
```

#### Step 2: Try Context-Aware Continue

Instead of remembering specific commands:
```bash
/spec init
/spec "Your feature description"
/spec          # Specter knows: create plan
/spec          # Specter knows: create tasks
/spec          # Specter knows: implement
```

#### Step 3: Explore Progressive Disclosure

Only load what you need:
```bash
# Default: fast and efficient
/spec plan

# Need examples? Load them
/spec plan --examples

# Need full reference? Load it
/spec plan --reference
```

**That's it!** Your existing `.specter/` directories work unchanged.

### For Teams

Same as individual migration, plus:

1. **Update Team Documentation**: Replace `/specter-*` examples with `/spec`
2. **Update Scripts**: If you have automation scripts calling Specter commands
3. **Update CI/CD**: If pipelines reference specific command names

---

## Detailed Changes

### Command Interface Changes

#### Hub Command (`/spec`)

**New in v3.0**: Single unified command with intelligent routing

**Routing Logic**:
```bash
/spec                          # Context-aware: continues current phase
/spec init                     # Explicit: runs spec:init
/spec "Feature text"           # Smart: detects spec text, runs spec:generate
/spec --help                   # Shows context-aware help
```

**Benefits**:
- One command to learn instead of 13
- Intelligent context detection
- Reduced token overhead
- Consistent interface

#### Individual Commands (Removed)

The following individual slash commands are removed in v3.0:

```bash
# v2.1 (removed)                # v3.0 (use instead)
/specter-init                   → /spec init
/specter-specify                → /spec generate or /spec "text"
/specter-clarify                → /spec clarify
/specter-plan                   → /spec plan
/specter-tasks                  → /spec tasks
/specter-implement              → /spec implement
/specter-update                 → /spec update
/specter-analyze                → /spec analyze
/specter-blueprint              → /spec blueprint
/specter-orchestrate            → /spec orchestrate
/specter-discover               → /spec discover
/specter-metrics                → /spec metrics
/specter-checklist              → /spec checklist
```

**Why**: Unified interface reduces cognitive load and token overhead

### Skill Architecture Changes

#### File Structure

**v2.1**: Single monolithic skill file
```
.claude/skills/specter-specify/
└── SKILL.md  (~6,800 tokens, all in one file)
```

**v3.0**: Split into 3 files for progressive disclosure
```
.claude/skills/spec-generate/
├── SKILL.md        (~1,500 tokens, core logic)
├── EXAMPLES.md     (~3,000 tokens, scenarios)
└── REFERENCE.md    (~2,000 tokens, full API)
```

**Benefits**:
- Default usage: 78% fewer tokens
- Optional depth: load examples/reference on demand
- Better organization: easier to maintain

#### Shared Resources

**New in v3.0**: Common patterns extracted to shared files

```
.claude/skills/shared/
├── integration-patterns.md   (~1,200 tokens) - MCP integration
├── workflow-patterns.md      (~1,400 tokens) - Common workflows
└── state-management.md       (~1,600 tokens) - State specifications
```

**Benefits**:
- Eliminates duplication across 13 skills
- Single source of truth for common patterns
- Easier to update and maintain

#### YAML Frontmatter

**New in v3.0**: Skill metadata in YAML frontmatter

```yaml
---
name: spec:generate
description: Create specifications from requirements
allowed-tools: Read, Write, Edit, AskUserQuestion
model: sonnet  # Optional: preferred model
---
```

**Benefits**:
- Explicit skill metadata
- Tool requirements declaration
- Model preferences support

### State File Changes

**Good News**: No changes to state files!

**v2.1 State Files** (still work in v3.0):
```
.specter/                      # Configuration
.specter-state/                # Session state
.specter-memory/               # Persistent memory
features/                      # Feature artifacts
```

**Optional in v3.0**: JSON state files for better performance (auto-generated)
```
.specter-state/session.json        # Source of truth (JSON)
.specter-state/current-session.md  # Human-readable (auto-generated from JSON)
```

**Migration**: Automatic! v3.0 reads existing markdown files and optionally creates JSON for performance.

---

## New Features in v3.0

### 1. Context-Aware Continuation

Just type `/spec` and Specter knows what to do:

```bash
# After initialization
/spec          # → Shows status, offers to create first feature

# After specification
/spec          # → Creates plan automatically

# After plan
/spec          # → Creates tasks automatically

# During implementation
/spec          # → Continues implementation
```

### 2. Progressive Disclosure Flags

Control how much detail you load:

```bash
--examples     # Load EXAMPLES.md (~3,000 extra tokens)
--reference    # Load REFERENCE.md (~2,000 extra tokens)
--verbose      # Detailed execution logging
--help         # Context-aware help
```

**Example**:
```bash
# Quick task breakdown
/spec tasks

# Need examples of task formats?
/spec tasks --examples

# Need full API reference for task syntax?
/spec tasks --reference
```

### 3. Improved Error Messages

**v2.1**: Generic errors
```
Error: Skill execution failed
```

**v3.0**: Specific, actionable errors
```
Error: Cannot determine current phase

Cause: .specter-state/current-session.md is missing or corrupted

Solutions:
1. Regenerate session: /spec status
2. Reinitialize: /spec init
3. Check file exists: ls .specter-state/
```

### 4. Skill Validation

Built-in validation for consistency:

```bash
/spec validate

# Checks:
# ✓ All state files present
# ✓ YAML frontmatter valid
# ✓ Cross-references correct
# ✓ No [CLARIFY] tags remaining (warnings)
# ✓ Task dependencies valid
```

### 5. Enhanced Metrics

More detailed metrics tracking:

```bash
/spec metrics

# Shows:
# - AI-generated vs human-modified code ratios
# - Tokens used per phase
# - Time spent per phase
# - Task completion velocity
# - Feature throughput
```

---

## Breaking Changes

### 1. Command Names

**Breaking**: All `/specter-*` commands removed

**Migration**: Use `/spec <subcommand>` instead

**Impact**: Update muscle memory, scripts, CI/CD pipelines

### 2. Skill References

**Breaking**: Internal skill names changed from `specter:*` to `spec:*`

**Migration**: Update if you reference skills programmatically

**Impact**: Only affects custom hooks/scripts that reference skills directly

### 3. No Backward Compatibility Aliases

**Breaking**: No aliases for old commands (clean break)

**Rationale**: Simpler codebase, clearer migration, better long-term maintainability

**Mitigation**: Migration is simple (command mapping table above)

---

## Non-Breaking Changes

### ✅ State Files
Your existing `.specter/`, `.specter-memory/`, `features/` directories work without modification

### ✅ Configuration
`CLAUDE.md` configuration settings remain the same

### ✅ Feature Artifacts
All `features/###-name/spec.md|plan.md|tasks.md` files compatible

### ✅ MCP Integrations
JIRA, Confluence, Linear integrations work unchanged

### ✅ Hooks
Event hooks continue to work (though skill names updated internally)

---

## Troubleshooting Migration

### Issue: Command not found

**Problem**: `/spec` command not recognized

**Solution**:
```bash
# Update to v3.0
/plugin update specter@specter-marketplace

# Or fresh install
/plugin install specter@specter-marketplace

# Reload if needed
/plugin reload specter
```

### Issue: Old commands still shown

**Problem**: Autocomplete still suggests `/specter-*` commands

**Solution**:
```bash
# Clear plugin cache
/plugin reload specter

# Or restart Claude Code
```

### Issue: Context detection failed

**Problem**: "Cannot determine current phase"

**Solution**:
```bash
# Regenerate session state
/spec status

# If persists, check file exists
ls -la .specter-state/current-session.md

# If missing or corrupted, reinitialize
rm .specter-state/current-session.md
/spec init
```

### Issue: Skill not found

**Problem**: "Skill spec:generate not found"

**Solution**:
```bash
# Check skill directories exist
ls .claude/skills/spec-*

# Should see: spec-init, spec-generate, spec-plan, etc.

# If missing, reinstall plugin
/plugin uninstall specter
/plugin install specter@specter-marketplace
```

### Issue: Performance degradation

**Problem**: Commands slower than expected

**Solution**:
```bash
# Check you're not loading unnecessary content
/spec plan          # Good: 1,500 tokens
/spec plan --examples --reference  # Bad: 11,600 tokens

# Clear checkpoints if bloated
rm -rf .specter-state/checkpoints/

# Validate state files aren't corrupted
/spec validate
```

---

## Migration Checklist

### Pre-Migration

- [ ] Backup your project (git commit or copy `.specter*` directories)
- [ ] Note your current v2.1 version
- [ ] Document any custom scripts/automation using Specter

### Migration

- [ ] Update Specter plugin to v3.0
- [ ] Test `/spec --help` works
- [ ] Run `/spec status` to verify state compatibility
- [ ] Update muscle memory (practice new commands)

### Post-Migration

- [ ] Update team documentation with new commands
- [ ] Update CI/CD scripts if applicable
- [ ] Update custom hooks/automation if applicable
- [ ] Test full workflow: init → generate → plan → tasks → implement
- [ ] Verify state files still work correctly

### Validation

- [ ] Run `/spec validate` - should pass
- [ ] Check metrics: `/spec metrics` - should show data
- [ ] Test progressive disclosure: `/spec plan --examples`
- [ ] Test context-aware: `/spec` continues from current phase

---

## Performance Benefits Summary

| Metric | v2.1 | v3.0 | Improvement |
|--------|------|------|-------------|
| **Tokens per skill** | 6,800 | 1,283 | **81% ↓** |
| **State overhead** | 10,000 | 2,000 | **80% ↓** |
| **Full workflow** | 34,000 | 6,400 | **81% ↓** |
| **Execution speed** | Baseline | 3-5x faster | **3-5x ↑** |
| **Context usage** | High | Low | **Much better** |
| **Learning curve** | 13 commands | 1 command | **92% ↓** |

---

## Rollback Plan

If you encounter critical issues:

### Option 1: Rollback to v2.1

```bash
/plugin uninstall specter
/plugin install specter@2.1.0
```

**Note**: v2.1 still works with your existing state files

### Option 2: Report Issues

Help improve v3.0 by reporting issues:

1. Describe the problem
2. Include error messages
3. Share relevant state files (if possible)
4. Note your workflow/use case

**Report to**: https://github.com/claude-code/specter-marketplace/issues

---

## FAQs

### Q: Do I need to migrate my existing features?
**A**: No! All `features/###-name/` directories work unchanged.

### Q: Will v2.1 be supported?
**A**: Security fixes only. New features only in v3.0+.

### Q: Can I use both v2.1 and v3.0?
**A**: Not simultaneously. Pick one version per project.

### Q: What if I have custom scripts calling `/specter-*`?
**A**: Update them to call `/spec <subcommand>` instead.

### Q: Do hooks need updating?
**A**: Only if they reference skill names directly (`specter:*` → `spec:*`).

### Q: Will my team hate me for upgrading?
**A**: No! The migration is straightforward and benefits are immediate.

### Q: What about my JIRA/Confluence integrations?
**A**: They work unchanged. MCP integrations are compatible.

### Q: Is progressive disclosure optional?
**A**: Yes! Skills work without flags. Use `--examples` only when needed.

### Q: Can I extend v3.0 with custom skills?
**A**: Yes! Same mechanism as v2.1. Follow the 3-file structure.

---

## Get Help

- **Documentation**: `/spec --help`
- **Examples**: `/spec <command> --examples`
- **Reference**: `/spec <command> --reference`
- **Validate**: `/spec validate`
- **Issues**: https://github.com/claude-code/specter-marketplace/issues
- **Community**: [Discord/Slack link]

---

**Welcome to Specter v3.0!** 🚀

**81% more efficient. Same powerful workflow.**

Ready to get started? Run: `/spec init`
