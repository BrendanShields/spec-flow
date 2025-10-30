# Migration Guide: Specter v2.1 → v3.0

**Target Audience**: Existing Specter v2.1 users
**Migration Time**: < 5 minutes
**Breaking Changes**: Command interface only (state files compatible)

---

## Quick Migration

### TL;DR

```bash
# Old commands → New unified command
/specter-init          → /👻 init
/specter-specify "X"   → /👻 "X"
/specter-plan          → /👻 plan
/specter-tasks         → /👻 tasks
/specter-implement     → /👻 implement

# Or just use context-aware continue
/👻                    → Automatically continues workflow
```

**Your existing `.specter/` and `features/` directories work as-is.** No migration needed!

---

## What Changed

### ✅ Single Unified Command

**Before (v2.1):**
```bash
/specter-init
/specter-specify "Add user auth"
/specter-plan
/specter-tasks
/specter-implement
```

**After (v3.0):**
```bash
/👻 init
/👻 "Add user auth"
/👻 plan
/👻 tasks
/👻 implement

# Or even simpler - context-aware
/👻 init
/👻 "Add user auth"
/👻        # Auto-creates plan
/👻        # Auto-creates tasks
/👻        # Auto-begins implementation
```

### ✅ 80% Token Reduction

v3.0 uses lazy loading and progressive disclosure:
- **v2.1**: ~14,400 tokens per command
- **v3.0**: ~2,250 tokens per command
- **Savings**: 84% reduction

You'll notice:
- Faster command execution
- Less context window usage
- More efficient conversations

### ✅ Team Collaboration Features

New in v3.0:
```bash
/👻 team                   # Team dashboard
/👻 assign @alice T001     # Task assignment
/👻 lock 002               # Feature locking
/👻 master-spec            # Consolidated documentation
```

### ✅ Interactive Mode

For users unfamiliar with commands:
```bash
/👻 --interactive

# Shows contextual menu:
# 1. Continue to next phase
# 2. Update current artifact
# 3. Check status
# ...
```

---

## Command Mapping

| v2.1 Command | v3.0 Command | Notes |
|--------------|--------------|-------|
| `/specter-init` | `/👻 init` | Initialize project |
| `/specter-specify "X"` | `/👻 "X"` | Create specification |
| `/specter-clarify` | `/👻 clarify` | Resolve ambiguities |
| `/specter-plan` | `/👻 plan` | Technical design |
| `/specter-tasks` | `/👻 tasks` | Task breakdown |
| `/specter-implement` | `/👻 implement` | Execute implementation |
| `/specter-update "X"` | `/👻 update "X"` | Update specification |
| `/specter-analyze` | `/👻 analyze` | Validate consistency |
| `/specter-blueprint` | `/👻 blueprint` | Define architecture |
| `/specter-metrics` | `/👻 metrics` | Show metrics |
| `/specter-discover` | `/👻 discover` | Brownfield analysis |
| `/specter-orchestrate` | `/👻` | Context-aware continue |
| `/status` | `/👻 status` | Check status |
| `/help` | `/👻 --help` | Context-aware help |
| `/validate` | `/👻 validate` | Validate consistency |

---

## State Files (No Changes Needed)

Your existing state files work as-is:
- `.specter/` - Project configuration ✅
- `.specter-state/` - Session state ✅
- `.specter-memory/` - Persistent memory ✅
- `features/` - Feature specifications ✅

**No manual migration required!**

v3.0 introduces optional JSON state files for better team collaboration, but markdown files remain fully supported.

---

## New Features You'll Love

### 1. Context-Aware Continue

Just type `/👻` and Specter knows what to do next:

```bash
# After specification
/👻          # Creates plan automatically

# After plan
/👻          # Creates tasks automatically

# During implementation
/👻          # Continues implementation
```

### 2. Interactive Menu

Not sure what command to use?

```bash
/👻 --interactive
```

Shows a menu based on your current phase with numbered options.

### 3. Team Dashboard

Working with a team?

```bash
/👻 team

# Output:
# 📊 Specter Team Status
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# 🔒 Active Locks:
#   - Feature 002: @alice (since 2024-10-31)
#
# 👥 Task Assignments:
#   - T001: Implement router (@bob)
#   - T002: Add lazy loading (@carol)
#
# 📈 Feature Progress:
#   - 001-plugin-stabilization: complete (100%)
#   - 002-v3-consolidation: active (50%)
```

### 4. Master Specification

Auto-generated consolidated documentation:

```bash
/👻 master-spec

# Generates .specter/master-spec.md with:
# - Product vision
# - Architecture
# - All features (completed + active + planned)
# - Technical decisions
# - Metrics
```

### 5. Shell Completion

Tab completion for commands:

```bash
/👻 <TAB>           # Lists all subcommands
/👻 assign @<TAB>   # Lists team members
```

---

## Step-by-Step Migration

### For Individual Users

1. **Update your muscle memory** - Use `/👻` instead of `/specter-*`
2. **Try context-aware continue** - Just `/👻` instead of explicit commands
3. **Explore new features** - Try `/👻 --interactive` and `/👻 team`

That's it! Your existing projects work unchanged.

### For Teams

1. **Individual migration** (same as above)
2. **Enable team features**:
   ```bash
   # Add to your CLAUDE.md
   SPECTER_TEAM_MODE=enabled
   SPECTER_AUTO_LOCK=true
   ```
3. **Use feature locking**:
   ```bash
   /👻 lock 002        # Lock feature for yourself
   # ... do work ...
   /👻 unlock 002      # Release when done
   ```
4. **Assign tasks**:
   ```bash
   /👻 assign @alice T001-T005
   /👻 assign @bob T006-T010
   ```

---

## Troubleshooting

### Command not found

**Problem**: `/👻` command not recognized

**Solution**: Update to Specter v3.0
```bash
/plugin update specter@specter-marketplace
```

### Context detection failed

**Problem**: "Cannot determine current phase"

**Solution**: Your `.specter-state/current-session.md` may be corrupted. Regenerate:
```bash
/👻 status          # Regenerates session state
```

### Old commands still shown

**Problem**: Still seeing old `/specter-*` commands in autocomplete

**Solution**: Restart Claude Code or refresh plugin cache
```bash
/plugin reload specter
```

---

## Benefits Summary

| Aspect | v2.1 | v3.0 | Improvement |
|--------|------|------|-------------|
| **Commands** | 8 separate | 1 unified | 87.5% simpler |
| **Token Usage** | 14,400 | 2,250 | 84% reduction |
| **Context Awareness** | Manual | Automatic | Smarter |
| **Team Features** | None | Full support | Collaboration++ |
| **Learning Curve** | Moderate | Easy | Interactive mode |
| **Speed** | Baseline | 3x faster | Lazy loading |

---

## Still Have Questions?

- **Documentation**: See `/👻 --help --reference`
- **Examples**: Try `/👻 --examples`
- **Interactive Tour**: Run `/👻 --interactive`
- **Support**: https://github.com/specter/issues

---

## Rollback (If Needed)

If you encounter issues, you can rollback:

```bash
/plugin install specter@2.1.0
```

Please report any issues so we can improve v3.0!

---

**Welcome to Specter v3.0!** 🎉

Simpler. Faster. Better for teams.
