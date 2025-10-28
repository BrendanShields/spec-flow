# Navi Migration Plan - Flow → Navi

## Migration Overview

Transform the bloated 15-command Flow system into a streamlined single-command Navi system with 80% token reduction and 60% performance improvement.

## Step-by-Step Migration

### Step 1: Create __specification__ Directory Structure

```bash
# Create new structure
mkdir -p __specification__/{config,features,memory,scripts,state,templates}

# Copy existing features
cp -r .flow/features/* __specification__/features/

# Create simplified config
cat > __specification__/config/navi.json << 'EOF'
{
  "version": "1.0",
  "project": {
    "type": "brownfield",
    "name": "spec-flow"
  },
  "preferences": {
    "interactive": true,
    "auto_save": true,
    "parallel_execution": true
  }
}
EOF

# Create active progress tracking
cat > __specification__/memory/progress.json << 'EOF'
{
  "features": {},
  "current": null,
  "stats": {
    "total": 0,
    "completed": 0
  }
}
EOF
```

### Step 2: Create Single Navi Command

```markdown
# .claude/commands/navi.md
---
name: navi
description: Unified specification-driven development command
---

# Navi - Single Entry Point

Parse arguments: {{ARGS}}

## No Arguments → Interactive Menu
Use AskUserQuestion with phase-aware options

## With Arguments → Direct Routing
- `init` → Initialize project
- `specify` → Create specification
- `plan` → Design architecture
- `tasks` → Break down work
- `implement` → Execute tasks
- `status` → Show progress

Route to appropriate skill in .claude/skills/navi-*/
```

### Step 3: Rename and Simplify Skills

```bash
# Rename skills
mv .claude/skills/flow-init .claude/skills/navi-init
mv .claude/skills/flow-specify .claude/skills/navi-specify
mv .claude/skills/flow-plan .claude/skills/navi-plan
mv .claude/skills/flow-tasks .claude/skills/navi-tasks
mv .claude/skills/flow-implement .claude/skills/navi-implement

# Remove redundant skills
rm -rf .claude/skills/flow-{help,status,validate,session,resume}
# These become inline functions in /navi command
```

### Step 4: Consolidate Documentation

```bash
# Merge architecture files
cat .flow/docs/ARCHITECTURE.md > __specification__/architecture.md
# Remove design patterns from architecture-blueprint that duplicate

# Rename requirements
mv .flow/docs/product-requirements.md __specification__/requirements.md

# Remove redundant docs
rm .flow/docs/CLAUDE-FLOW.md  # Skills self-document
rm .flow/docs/COMMANDS.md     # /navi help covers it
rm .flow/docs/architecture-blueprint.md  # Merged above
```

### Step 5: Update Root CLAUDE.md (Minimal)

```markdown
# Navi - Specification-Driven Development

Navi helps you build features systematically. Use `/navi` for everything.

## Quick Start
```bash
/navi                    # Interactive menu
/navi specify "feature"  # Start new feature
/navi status            # Check progress
```

## Configuration
- Config: `__specification__/config/navi.json`
- Features: `__specification__/features/`
- Docs: Self-contained in skills

---
[Rest of existing CLAUDE.md content if any]
```

### Step 6: Implement Parallel Processing

```javascript
// In navi-implement skill
async function executeTasks(tasks) {
  const parallel = tasks.filter(t => t.includes('[P]'));
  const sequential = tasks.filter(t => !t.includes('[P]'));

  // Execute parallel tasks concurrently
  await Promise.all(parallel.map(executeTask));

  // Then sequential tasks
  for (const task of sequential) {
    await executeTask(task);
  }
}
```

### Step 7: Fix Memory System

```python
# Auto-update progress on task completion
def complete_task(task_id):
    progress = load_json('__specification__/memory/progress.json')
    feature = get_current_feature()

    progress['features'][feature]['completed'] += 1
    progress['features'][feature]['percent'] = (
        progress['features'][feature]['completed'] /
        progress['features'][feature]['total'] * 100
    )

    save_json('__specification__/memory/progress.json', progress)
```

### Step 8: Remove Old Files

```bash
# Remove all redundant command files
rm .claude/commands/flow*.md
rm .claude/commands/{status,validate,session,resume,help}.md

# Remove old flow directory after verification
# rm -rf .flow/

# Clean up plugin directory
rm plugins/flow/.claude/commands/flow*.md
```

## Testing Checklist

- [ ] `/navi` shows interactive menu
- [ ] `/navi init` initializes project
- [ ] `/navi specify "test"` creates spec
- [ ] `/navi status` shows correct progress
- [ ] Parallel tasks execute concurrently
- [ ] Memory updates automatically
- [ ] Token usage reduced by 80%

## Rollback Plan

If issues arise:
1. Keep `.flow/` directory until verified
2. Command aliases can map old → new
3. Symlink `__specification__` → `.flow` if needed

## Timeline

- **Hour 1**: Directory restructure, documentation consolidation
- **Hour 2**: Command simplification, skill updates
- **Hour 3**: Memory system fix, parallel implementation
- **Hour 4**: Testing and verification
- **Hour 5**: Cleanup and optimization

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Commands | 1 | Count .claude/commands/*.md |
| Token usage | <1000/msg | Measure CLAUDE.md + loaded docs |
| Parallel execution | 60% tasks | Time comparison |
| Memory accuracy | 100% | Compare actual vs tracked |
| User satisfaction | High | Simplified UX |

## Risk Mitigation

1. **Breaking changes**: Keep aliases during transition
2. **Lost data**: Backup .flow/ before migration
3. **Skill failures**: Test each skill individually
4. **Performance issues**: Profile before/after
5. **User confusion**: Clear migration guide

This migration will transform Flow into Navi - a cleaner, faster, more efficient system.