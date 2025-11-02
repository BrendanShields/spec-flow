# Spec Configuration Guide

**Version**: 3.1.0
**Config File**: `.claude/.spec-config.yml`

## Overview

Spec uses a single YAML configuration file to customize paths, naming conventions, agent behavior, and integrations. The configuration is auto-generated on first run with smart defaults based on your project.

### Zero-Config Experience

On first run, Spec automatically:
- Detects your project type (app, library, monorepo, microservice)
- Identifies language (JavaScript, TypeScript, Python, Go, Rust)
- Discovers framework (Next.js, React, Vue, etc.)
- Finds build tools (Turbo, Vite, Webpack, etc.)
- Creates `.claude/.spec-config.yml` with optimal defaults

**You don't need to configure anything** - just start using Spec!

---

## Quick Start

### First Time Setup

```bash
# Just start Claude Code - config auto-creates
# You'll see:
✨ Created .claude/.spec-config.yml with auto-detected settings
   Project: app (TypeScript + Next.js + Turbo)

   You can customize paths and naming by editing .claude/.spec-config.yml
```

### Customizing Configuration

Edit `.claude/.spec-config.yml` directly:

```yaml
# Change where features are stored
paths:
  features: "src/features"  # instead of "features"

# Customize naming
naming:
  feature_singular: "story"  # instead of "feature"
  feature_plural: "stories"
```

Save the file - changes apply immediately on next session.

---

## Configuration Reference

### Paths

Configure where Spec stores files:

```yaml
paths:
  spec_root: ".spec"              # Product requirements, blueprints
  features: "features"            # Feature specifications
  state: ".spec-state"            # Session state (gitignored)
  memory: ".spec-memory"          # Persistent memory (committed)
  templates: ".spec/templates"    # Custom templates
```

**Common Customizations**:

```yaml
# Monorepo: features in packages
paths:
  features: "packages/*/specs"

# Existing project: match your structure
paths:
  features: "docs/specs"
  spec_root: "project-docs"

# Team standard: centralized specs
paths:
  features: "specifications"
```

### Naming

Customize how features are named and what you call them:

```yaml
naming:
  # Feature directory pattern
  # Variables: {id:000} (zero-padded), {id} (plain), {slug} (URL-friendly)
  feature_directory: "{id:000}-{slug}"  # → 001-user-auth

  # What you call them (domain-specific terminology)
  feature_singular: "feature"  # "Create a new feature"
  feature_plural: "features"   # "List all features"

  # Artifact filenames
  files:
    spec: "spec.md"
    plan: "plan.md"
    tasks: "tasks.md"
```

**Examples**:

```yaml
# Agile team
naming:
  feature_directory: "{id}-{slug}"
  feature_singular: "story"
  feature_plural: "stories"

# Product team
naming:
  feature_directory: "{slug}"  # No IDs
  feature_singular: "initiative"
  feature_plural: "initiatives"

# JIRA integration
naming:
  feature_directory: "PROJ-{id}"
  feature_singular: "ticket"

# Monorepo with teams
naming:
  feature_directory: "{team}/{epic}/{story}"
  feature_singular: "epic"
```

### Project

Auto-detected project metadata (can override):

```yaml
project:
  type: "app"                     # app | library | monorepo | microservice
  language: "typescript"          # Detected from config files
  framework: "nextjs"             # Detected from package.json
  build_tool: "turbo"             # Detected from config files
```

**When to Override**:
- Auto-detection is wrong for your setup
- You want to force specific optimizations
- Testing different configurations

```yaml
# Force monorepo mode (even if not detected)
project:
  type: "monorepo"

# Specify language when ambiguous
project:
  language: "typescript"
```

### Agents

Control how AI agents behave:

```yaml
agents:
  implementer:
    strategy: "parallel"          # parallel | sequential | adaptive
    max_parallel: 3               # Max concurrent tasks
    timeout: 1800                 # seconds (30 minutes)
    retry_attempts: 3

  researcher:
    confidence_threshold: 0.75    # Min confidence for auto-decisions (0-1)
    cache_ttl: 86400             # seconds (24 hours)

  analyzer:
    validation_depth: "standard"  # quick | standard | deep
    auto_fix: false              # Require manual review
```

**Tuning for Performance**:

```yaml
# Fast iteration (lower quality)
agents:
  implementer:
    strategy: "sequential"  # One at a time
    timeout: 600           # 10 minutes max
  analyzer:
    validation_depth: "quick"

# High quality (slower)
agents:
  implementer:
    strategy: "adaptive"    # Smart parallelization
    max_parallel: 5
    timeout: 3600          # 1 hour max
  analyzer:
    validation_depth: "deep"
    auto_fix: true         # Auto-fix issues

# Monorepo (high parallelism)
agents:
  implementer:
    max_parallel: 10       # Many packages
```

### Integrations

Optional external tool integrations:

```yaml
integrations:
  jira:
    enabled: false
    project_key: ""
    server_url: ""

  confluence:
    enabled: false
    space_key: ""
    root_page_id: ""
```

**Setting Up JIRA**:

```yaml
integrations:
  jira:
    enabled: true
    project_key: "PROJ"
    server_url: "https://company.atlassian.net"
```

Spec will automatically:
- Create JIRA tickets for new features
- Sync status updates
- Link specs to tickets

**Setting Up Confluence**:

```yaml
integrations:
  confluence:
    enabled: true
    space_key: "DEV"
    root_page_id: "123456"
```

Spec will automatically:
- Publish specs to Confluence
- Update on changes
- Maintain links between artifacts

### Workflow

General workflow preferences:

```yaml
workflow:
  auto_checkpoint: true           # Auto-save session state
  validate_on_save: true          # Validate before completing phases
  progressive_disclosure: true    # Load examples only when needed
```

**Customizations**:

```yaml
# Minimal validation (fast)
workflow:
  validate_on_save: false
  progressive_disclosure: true

# Explicit control (load all docs)
workflow:
  progressive_disclosure: false

# Manual checkpoints
workflow:
  auto_checkpoint: false
```

---

## Common Scenarios

### Existing Project Integration

You have an existing project with specs in `docs/requirements/`:

```yaml
paths:
  features: "docs/requirements"
  spec_root: "docs/architecture"
  templates: "docs/templates"

naming:
  feature_directory: "{slug}"  # Match existing naming
  files:
    spec: "requirements.md"    # Match existing filenames
    plan: "design.md"
```

### Team Standardization

Your team has naming conventions:

```yaml
naming:
  feature_directory: "{team}-{epic}-{id:0000}"  # → platform-auth-0042
  feature_singular: "epic"
  feature_plural: "epics"
  files:
    spec: "user-stories.md"
    plan: "technical-design.md"
    tasks: "implementation-plan.md"
```

### Monorepo Setup

Multiple packages need specs:

```yaml
paths:
  features: "packages/*/specs"
  spec_root: "docs/architecture"

agents:
  implementer:
    max_parallel: 10  # Many packages
    strategy: "adaptive"

project:
  type: "monorepo"
```

### High-Quality Documentation

You're writing public API specs:

```yaml
agents:
  analyzer:
    validation_depth: "deep"
    auto_fix: false  # Manual review required

  researcher:
    confidence_threshold: 0.9  # Very high confidence only

workflow:
  validate_on_save: true
  progressive_disclosure: false  # Load full docs
```

---

## Validation

Spec automatically validates your configuration on SessionStart.

**If config is invalid**, you'll see:

```
❌ Config validation failed:
   - paths.features: must be a string
   - agents.implementer.max_parallel: must be a number

Fix .claude/.spec-config.yml and restart Claude Code
```

**If config is missing**, Spec auto-creates it:

```
✨ Created .claude/.spec-config.yml with auto-detected settings
```

---

## Troubleshooting

### Config Not Loading

**Symptom**: Changes to config not taking effect

**Solution**: Check YAML syntax
```bash
# Install yamllint
npm install -g yaml-lint

# Validate syntax
yamllint .claude/.spec-config.yml
```

### Wrong Auto-Detection

**Symptom**: Project detected as wrong type/language

**Solution**: Override in config
```yaml
project:
  type: "monorepo"      # Force correct type
  language: "typescript"
```

### Paths Not Working

**Symptom**: Spec can't find directories

**Solution**: Use relative paths from project root
```yaml
paths:
  features: "src/features"  # ✅ Relative to root
  # NOT: /absolute/path      # ❌ Don't use absolute
```

### Hook Not Running

**Symptom**: Config not validated on startup

**Solution**: Check hooks are registered
```bash
# Verify hook is in .claude/hooks/hooks.json
cat .claude/hooks/hooks.json | grep session-init
```

---

## Migration

### From Hardcoded Paths (v3.0)

If you used Spec v3.0 with hardcoded paths:

1. **Automatic Migration**: Config auto-creates with defaults matching v3.0
2. **No action needed**: Existing features in `features/` still work
3. **Optional**: Customize paths to match your existing structure

### From CLAUDE.md Variables

If you used `CLAUDE.md` with `SPEC_*` variables:

Old (CLAUDE.md):
```markdown
SPEC_FEATURES_DIR=src/features
SPEC_AUTO_CHECKPOINT=true
```

New (.claude/.spec-config.yml):
```yaml
paths:
  features: "src/features"

workflow:
  auto_checkpoint: true
```

Spec automatically reads old `CLAUDE.md` variables and suggests migration.

---

## Advanced

### Environment Variables

Override config via environment variables:

```bash
# Override paths
export SPEC_PATHS_FEATURES="custom/path"

# Override agents
export SPEC_AGENTS_IMPLEMENTER_MAX_PARALLEL=5

# Run Claude Code
claude-code
```

Format: `SPEC_<section>_<key>=value` (uppercase, underscore-separated)

### Config Schema

Full JSON schema: `plugins/spec/.claude/.spec-config.schema.json` (coming soon)

### Programmatic Access

Skills and agents can read config:

```javascript
const config = loadSpecConfig();
console.log(config.paths.features);  // → "features"
```

See `plugins/spec/.claude/hooks/session-init.js` for implementation.

---

## Summary

1. **Zero-config by default** - auto-creates on first run
2. **Edit `.claude/.spec-config.yml`** to customize
3. **Changes apply immediately** on next session
4. **Validation errors** shown on startup
5. **Auto-detection** can be overridden

For help: See `plugins/spec/docs/` for full documentation.

---

**Version**: 3.1.0
**Last Updated**: November 2, 2025
**Related**: [Implementation Plan](../docs/analysis/CONFIG-IMPLEMENTATION-PIVOT.md)
