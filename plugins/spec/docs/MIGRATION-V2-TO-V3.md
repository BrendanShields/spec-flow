# Migration Guide: Spec v3.0 to v3.1

**Version**: 3.1.0
**Date**: November 2025

## Overview

Spec v3.1.0 introduces a powerful configuration system with zero-config auto-detection while maintaining full backward compatibility. Most users will experience a seamless upgrade.

---

## What's New in v3.1.0

### 🎯 Major Feature: Configuration System

**Zero-Config Experience**:
- Auto-creates `.claude/.spec-config.yml` on first run
- Detects project type, language, framework automatically
- Smart defaults based on detection
- Customize paths and naming via simple YAML

**Before (v3.0)**: Hardcoded paths
```markdown
features/001-user-auth/spec.md
.spec-state/current-session.md
```

**After (v3.1)**: Configurable paths
```yaml
paths:
  features: "src/features"  # Customize!
naming:
  feature_singular: "story"  # Your terminology
```

---

## Migration Steps

### For Most Users (Zero Action Required)

**Automatic Migration**:
1. Start Claude Code normally
2. On first SessionStart, Spec auto-creates config
3. Detects your project and sets optimal defaults
4. You'll see: `✨ Created .claude/.spec-config.yml with auto-detected settings`
5. **Done!** Everything works as before

### For Users with Custom Setups

If you have non-standard paths or naming:

**Step 1**: Let auto-config run first
```bash
# Start Claude Code
# Config auto-creates
```

**Step 2**: Edit `.claude/.spec-config.yml`
```yaml
# Customize to match your structure
paths:
  features: "docs/specifications"  # Your path
  spec_root: "project-config"

naming:
  feature_singular: "epic"  # Your terminology
  feature_directory: "{team}-{id}"  # Your pattern
```

**Step 3**: Restart Claude Code
- Changes apply immediately
- All commands use your custom paths

---

## Breaking Changes

**None!** v3.1 is fully backward compatible:
- Default paths match v3.0 exactly
- All commands work the same
- Existing features/ directories work
- No data migration needed

---

## Configuration Options

### Paths (all customizable)
```yaml
paths:
  spec_root: ".spec"           # Product requirements, blueprints
  features: "features"         # Feature specifications
  state: ".spec-state"         # Session state
  memory: ".spec-memory"       # Persistent memory
  templates: ".spec/templates" # Custom templates
```

### Naming Conventions
```yaml
naming:
  feature_directory: "{id:000}-{slug}"  # Pattern for directories
  feature_singular: "feature"           # What you call them
  feature_plural: "features"
  files:
    spec: "spec.md"
    plan: "plan.md"
    tasks: "tasks.md"
```

### Agent Behavior
```yaml
agents:
  implementer:
    strategy: "parallel"      # or sequential, adaptive
    max_parallel: 3          # Concurrent tasks
    timeout: 1800            # 30 minutes
```

---

## Common Scenarios

### Monorepo Setup
```yaml
paths:
  features: "packages/*/specs"
agents:
  implementer:
    max_parallel: 10  # More parallelism
```

### Existing Project Integration
```yaml
paths:
  features: "docs/requirements"
  spec_root: "architecture"
naming:
  feature_directory: "{slug}"  # No IDs
```

### Team Standards
```yaml
naming:
  feature_singular: "story"
  feature_directory: "{team}-{epic}-{id}"
  files:
    spec: "requirements.md"
```

---

## What Gets Auto-Detected

The new system automatically detects:

**Project Type**:
- ✅ App (default)
- ✅ Library (publishConfig in package.json)
- ✅ Monorepo (turbo.json, lerna.json, pnpm-workspace.yaml)
- ✅ Microservice

**Language**:
- ✅ TypeScript (tsconfig.json)
- ✅ JavaScript (package.json)
- ✅ Python (pyproject.toml, setup.py)
- ✅ Go (go.mod)
- ✅ Rust (Cargo.toml)

**Framework**:
- ✅ Next.js (next.config.*)
- ✅ React (package.json dependency)
- ✅ Vue (package.json dependency)
- ✅ Angular (@angular/core)
- ✅ Svelte
- ✅ Nuxt

**Build Tools**:
- ✅ Turbo (turbo.json)
- ✅ Vite (vite.config.*)
- ✅ Webpack (webpack.config.*)
- ✅ Rollup
- ✅ esbuild

---

## FAQ

### Q: Will my existing features/ directory still work?
**A**: Yes! Default config matches v3.0 exactly.

### Q: Do I need to configure anything?
**A**: No! Zero-config by default. Customize only if needed.

### Q: What if auto-detection is wrong?
**A**: Edit `.claude/.spec-config.yml` and override:
```yaml
project:
  type: "monorepo"  # Force correct type
  language: "typescript"
```

### Q: Can I use environment variables?
**A**: Not yet, but planned for v3.2:
```bash
export SPEC_PATHS_FEATURES="custom/path"  # Future
```

### Q: How do I check my config?
**A**: The config file is at `.claude/.spec-config.yml` - it's simple YAML

### Q: What if YAML parsing fails?
**A**: Spec falls back to defaults and shows an error

---

## Troubleshooting

### Config Not Loading

**Check YAML syntax**:
```bash
# Online YAML validator
# Or install yamllint
npm install -g yaml-lint
yamllint .claude/.spec-config.yml
```

### Paths Not Working

**Use relative paths from project root**:
```yaml
paths:
  features: "src/features"  # ✅ Relative
  # NOT: /absolute/path     # ❌ Absolute
```

### Session Not Initializing

**Check hooks are registered**:
```bash
cat plugins/spec/.claude/hooks/hooks.json | grep session-init
```

---

## Benefits of v3.1

1. **Flexibility**: Customize any path or naming
2. **Team Standards**: Enforce conventions via config
3. **Monorepo Support**: Better multi-package handling
4. **Zero Learning Curve**: Just edit YAML
5. **Smart Defaults**: Works out of the box
6. **Integration Ready**: JIRA/Confluence config built-in

---

## Need Help?

- **Full Config Guide**: See [CONFIGURATION.md](CONFIGURATION.md)
- **Quick Start**: See [README.md](../README.md)
- **Report Issues**: [GitHub Issues](https://github.com/anthropics/claude-code/issues)

---

## Summary

**For 90% of users**: Do nothing - it just works!
**For 10% with custom needs**: Edit one YAML file

The upgrade from v3.0 to v3.1 is seamless with automatic migration and zero breaking changes.

---

**Version**: 3.1.0
**Last Updated**: November 2025