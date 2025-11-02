# Config-Based Paths Reference

Quick reference for using config-based paths in Spec workflow documentation and skills.

## Available Config Variables

### Path Variables

```yaml
{config.paths.spec_root}      # .spec
{config.paths.features}        # features
{config.paths.state}           # .spec-state
{config.paths.memory}          # .spec-memory
{config.paths.templates}       # .spec/templates
```

### Naming Variables

```yaml
{config.naming.feature_directory}  # {id:000}-{slug}
{config.naming.files.spec}         # spec.md
{config.naming.files.plan}         # plan.md
{config.naming.files.tasks}        # tasks.md
```

## Usage Patterns

### In Documentation

**Feature artifacts**:
```markdown
Location: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
Example: features/001-user-auth/spec.md (with default config)
```

**Session state**:
```markdown
Read {config.paths.state}/current-session.md
Example: .spec-state/current-session.md (with default config)
```

**Persistent memory**:
```markdown
Update {config.paths.memory}/WORKFLOW-PROGRESS.md
Example: .spec-memory/WORKFLOW-PROGRESS.md (with default config)
```

### In Skill Instructions

**Reading files**:
```bash
# Read current feature spec
Read {config.paths.features}/001-user-auth/{config.naming.files.spec}

# Update session state
Write {config.paths.state}/current-session.md
```

**Directory operations**:
```bash
# List features
Glob {config.paths.features}/*/

# Create checkpoint
Write {config.paths.state}/checkpoints/2025-11-02.md
```

### In Code Examples

**Show both template and example**:
```markdown
**Path**: `{config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}`

**Example** (with default config):
```
features/001-user-authentication/spec.md
```
```

## Common Scenarios

### Scenario 1: Referencing Feature Artifacts

❌ **Don't**:
```markdown
- `features/001-feature-name/spec.md`
- `features/###-*/plan.md`
```

✅ **Do**:
```markdown
- `{config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}`
- `{config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan}`
```

### Scenario 2: State File References

❌ **Don't**:
```markdown
Read .spec-state/current-session.md
Write .spec-memory/WORKFLOW-PROGRESS.md
```

✅ **Do**:
```markdown
Read {config.paths.state}/current-session.md
Write {config.paths.memory}/WORKFLOW-PROGRESS.md
```

### Scenario 3: Directory Structure

❌ **Don't**:
```
Project Root/
├── .spec-state/
├── .spec-memory/
└── features/
```

✅ **Do**:
```
Project Root/
├── {config.paths.state}/
├── {config.paths.memory}/
└── {config.paths.features}/
```

## When to Use Config Variables

### ✅ Always Use Config Variables For:

1. **Directory paths**:
   - features/, .spec-state/, .spec-memory/, .spec/

2. **Artifact file names**:
   - spec.md, plan.md, tasks.md (when referring to specific artifacts)

3. **Feature directory patterns**:
   - ###-feature-name/ (the numbered directory format)

### ⚠️ Don't Use Config Variables For:

1. **Generic words** (not referring to paths):
   - "Create a spec for the feature" (not a file reference)
   - "Plan your approach" (not referring to plan.md)

2. **External references**:
   - JIRA, Confluence, GitHub paths

3. **Plugin structure**:
   - `.claude/skills/`, `.claude/commands/`

## Configuration File Location

Users configure paths in:
```
.claude/.spec-config.yml
```

## Default Values

All config variables have sensible defaults:

```yaml
paths:
  spec_root: .spec
  features: features
  state: .spec-state
  memory: .spec-memory
  templates: .spec/templates

naming:
  feature_directory: "{id:000}-{slug}"
  files:
    spec: spec.md
    plan: plan.md
    tasks: tasks.md
```

## How Config Is Loaded

1. **session-init hook** provides config in session context
2. Skills receive config variables automatically
3. If config missing, falls back to defaults

## Testing Your Documentation

Use these regex patterns to find hardcoded paths:

```bash
# Find hardcoded feature paths
grep -r "features/[0-9]\{3\}-" --include="*.md" . | grep -v "config\."

# Find hardcoded state paths
grep -r "\.spec-state/" --include="*.md" . | grep -v "config\."

# Find hardcoded memory paths
grep -r "\.spec-memory/" --include="*.md" . | grep -v "config\."
```

All should return zero results (excluding examples in this file).

## Related Documentation

- **Configuration Guide**: `/Users/dev/dev/tools/marketplace/plugins/spec/docs/CONFIGURATION.md`
- **Update Summary**: `/Users/dev/dev/tools/marketplace/plugins/spec/.claude/skills/PATH-UPDATE-SUMMARY.md`
- **Workflow SKILL**: `/Users/dev/dev/tools/marketplace/plugins/spec/.claude/skills/workflow/SKILL.md` (see Configuration Access section)

---

**Last Updated**: 2025-11-02
**Status**: ✅ All workflow documentation updated with config-based paths
