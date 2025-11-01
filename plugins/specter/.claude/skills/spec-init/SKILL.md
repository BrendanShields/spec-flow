---
name: spec:init
description: Initialize spec workflow in project. Use when 1) Starting new project with spec workflow, 2) User says "initialize spec" or "setup spec workflow", 3) Adding spec to existing codebase, 4) Need to create .specter/ structure. Creates directory structure, state management, and configuration.
allowed-tools: Read, Write, Bash, Grep
---

# Spec Initialize

Initialize spec workflow structure in greenfield or brownfield projects.

## Core Capability

Sets up complete spec workflow infrastructure:
- Creates `.specter/` configuration directory
- Initializes `.specter-state/` for session tracking (gitignored)
- Creates `.specter-memory/` for persistent history (committed)
- Detects project type (greenfield vs brownfield)
- Generates starter templates and configuration

## Execution Flow

### Phase 1: Detect Project State

**Read existing structure**:
```bash
# Check for existing spec setup
test -d .specter && echo "exists" || echo "new"

# Detect project type
ls src/ package.json *.py 2>/dev/null | wc -l
```

**Project types**:
- **Greenfield**: Empty/new project → Create basic templates
- **Brownfield**: Existing code → Suggest `spec:discover` for analysis

### Phase 2: Create Directory Structure

**Core directories** (always created):
```
.specter/                      # Configuration (committed)
├── product-requirements.md    # Product vision
├── templates/                 # Custom templates
└── scripts/                   # Utility scripts

.specter-state/                # Session state (gitignored)
└── current-session.md         # Active work tracking

.specter-memory/               # Persistent memory (committed)
├── WORKFLOW-PROGRESS.md       # Feature metrics
├── DECISIONS-LOG.md           # Architecture decisions
├── CHANGES-PLANNED.md         # Pending tasks
└── CHANGES-COMPLETED.md       # Completed work
```

**Use Write tool** to create each file from templates (see REFERENCE.md for full templates).

### Phase 3: Initialize State Files

**Create from templates**:
1. `.specter-state/current-session.md` - Copy from plugin templates
2. `.specter-memory/WORKFLOW-PROGRESS.md` - Initialize with project metadata
3. `.specter-memory/DECISIONS-LOG.md` - Empty log ready for entries
4. `.specter-memory/CHANGES-PLANNED.md` - Empty task list
5. `.specter-memory/CHANGES-COMPLETED.md` - Empty completion log

### Phase 4: Update .gitignore

**Add to .gitignore**:
```bash
# Read existing .gitignore
# Append if missing:
.specter-state/
```

**Keep committed**:
- `.specter/` - Project configuration
- `.specter-memory/` - Persistent history

### Phase 5: Create Configuration

**Generate `.specter/product-requirements.md`**:
```markdown
# Product Requirements

## Vision
[To be defined]

## Success Metrics
[To be defined]

## Constraints
[To be defined]
```

**Optional features** (ask user):
- Architecture blueprint (`spec:blueprint`)
- Brownfield discovery (`spec:discover`)
- Team collaboration settings

## Output

```
✅ Spec workflow initialized!

📁 Structure:
   .specter/                 (configuration)
   .specter-state/          (session tracking, gitignored)
   .specter-memory/         (persistent history, committed)

📝 Files created:
   product-requirements.md
   current-session.md
   WORKFLOW-PROGRESS.md
   DECISIONS-LOG.md

🎯 Next steps:
   1. Edit .specter/product-requirements.md
   2. Run spec:specify to create first feature
   3. Or run spec:discover for brownfield analysis

📖 Learn more: docs/QUICK-START.md
```

## Brownfield Projects

If existing code detected (>5 source files), suggest:

```
🔍 Existing codebase detected!

Run spec:discover to:
- Analyze current architecture
- Identify integration points
- Generate baseline blueprint
- Map existing features

Or continue with spec:specify for new features.
```

## Error Handling

**Already initialized**:
```
⚠️  Spec already initialized!

Found: .specter/ directory

Options:
- Reinitialize: spec:init --force
- Validate: spec:validate
- Continue: spec:specify
```

**Git not initialized**:
```
⚠️  Git repository not found

Initialize git first:
  git init
  git add .
  git commit -m "Initial commit"

Then run: spec:init
```

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- Greenfield React app initialization
- Brownfield Python service setup
- Multi-team configuration
- Custom template configuration

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete directory structure specification
- Full file templates
- Configuration options
- Integration with spec:discover and spec:blueprint
- Team collaboration setup

## Related Skills

- **spec:discover**: Analyze existing codebase (brownfield)
- **spec:blueprint**: Define architecture guidelines
- **spec:specify**: Create first feature specification
- **spec:validate**: Check workflow consistency
