# Specter Hooks - User Guide

**Version**: 3.1.0
**Last Updated**: 2024-10-31

---

## Overview

Specter hooks automatically maintain consistency across workflow artifacts through event-driven automation. They eliminate manual synchronization and ensure reliable state management for team collaboration.

## What Hooks Do

Hooks are scripts that automatically run in response to workflow events:

- **post-command**: Updates state after every `/specter` command
- **on-task-complete**: Updates progress when tasks finish
- **pre-commit**: Validates state before git commits
- **post-merge**: Synchronizes state after git pull/merge

## Quick Start

### Installation

Hooks are automatically configured when you initialize Specter:

```bash
cd your-project
/specter-init
```

To install git hooks:

```bash
source .specter/lib/git-hooks-installer.sh
specter_install_git_hooks
```

### Verification

Check if hooks are working:

```bash
# Run a command and watch for hook output
/specter plan

# You should see: "✅ State synchronized after plan"
```

## Hook Configuration

Edit `.specter/hooks/config.json` to customize hook behavior:

```json
{
  "hooks": {
    "post-command": {
      "enabled": true,        // Enable/disable hook
      "mode": "async",        // sync or async
      "blocking": false,      // Block on failure
      "timeout": 5000,        // Milliseconds
      "scripts": [
        "core/post-command.sh"
      ]
    }
  }
}
```

### Configuration Options

| Option | Values | Description |
|--------|--------|-------------|
| `enabled` | true/false | Whether hook runs |
| `mode` | sync/async | Execution mode |
| `blocking` | true/false | Block workflow on failure |
| `timeout` | milliseconds | Max execution time |
| `scripts` | array | Hook scripts to run |

## Enabling/Disabling Hooks

### Disable All Hooks

Set environment variable:

```bash
export SPECTER_HOOKS_ENABLED=false
```

### Disable Specific Hook

Edit `config.json`:

```json
{
  "hooks": {
    "post-command": {
      "enabled": false
    }
  }
}
```

### Temporarily Skip Git Hooks

```bash
git commit --no-verify -m "Skip hooks"
```

## Hook Events

### post-command

**When**: After every `/specter` command
**Mode**: Async (non-blocking)
**Purpose**: Update session state, workflow metrics

**What it does**:
- Updates `session.json` with current phase
- Updates `workflow.json` with metrics
- Regenerates markdown files
- Triggers master spec regeneration (if needed)

**Example output**:
```
✅ State synchronized after plan
```

### on-task-complete

**When**: Task marked complete
**Mode**: Sync
**Purpose**: Track progress

**What it does**:
- Marks task complete in `session.json`
- Updates workflow metrics
- Moves task to `CHANGES-COMPLETED.md`
- Recalculates feature progress

**Example output**:
```
✅ Task T001 complete (15/53 = 28%)
```

### pre-commit

**When**: Before git commit
**Mode**: Sync (blocking)
**Purpose**: Validate state integrity

**What it does**:
- Validates JSON schema
- Checks JSON ↔ MD consistency
- Validates no stale locks
- Blocks commit if validation fails

**Example output**:
```
🔍 Specter: Validating state before commit...
✅ Validation passed
```

**If validation fails**:
```
❌ Pre-commit validation failed (2 errors)
   Fix errors above or commit with --no-verify to skip
```

### post-merge

**When**: After git pull/merge
**Mode**: Sync
**Purpose**: Synchronize state after merge

**What it does**:
- Regenerates all markdown from JSON
- Detects conflicting locks
- Warns if active feature was modified

**Example output**:
```
🔄 Syncing state after merge...
✅ Regenerated current-session.md
✅ Regenerated WORKFLOW-PROGRESS.md
✅ State synchronized
```

## Troubleshooting

### Hook Not Running

**Symptom**: No "✅ State synchronized" message after commands

**Solutions**:
1. Check if hooks are enabled:
   ```bash
   cat .specter/hooks/config.json | jq '.hooks."post-command".enabled'
   ```

2. Check environment variable:
   ```bash
   echo $SPECTER_HOOKS_ENABLED
   ```

3. Check hook logs:
   ```bash
   tail -f .specter/logs/hooks.log
   ```

### Hook Failing

**Symptom**: Error messages from hooks

**Solutions**:
1. Check hook logs:
   ```bash
   cat .specter/logs/hooks.log
   ```

2. Check performance logs:
   ```bash
   cat .specter/logs/hook-performance.log
   ```

3. Run hook manually:
   ```bash
   echo '{"command":"test"}' | bash .specter/hooks/core/post-command.sh
   ```

### Hook Timeout

**Symptom**: "Timeout after Xms" error

**Solutions**:
1. Increase timeout in `config.json`:
   ```json
   {
     "hooks": {
       "post-command": {
         "timeout": 10000
       }
     }
   }
   ```

2. Optimize hook performance (see Performance section)

### Pre-Commit Blocking

**Symptom**: Git commit blocked by validation

**Solutions**:
1. Fix validation errors shown
2. Regenerate markdown:
   ```bash
   source .specter/lib/state-sync.sh
   specter_generate_md .specter-state/session.json > .specter-state/current-session.md
   ```

3. Skip validation (not recommended):
   ```bash
   git commit --no-verify
   ```

## Performance

### Check Hook Performance

```bash
cat .specter/logs/hook-performance.log | tail -20
```

Example output:
```
[2024-10-31T10:30:00Z] post-command:core/post-command.sh - 45ms - exit:0
[2024-10-31T10:31:00Z] on-task-complete:core/on-task-complete.sh - 23ms - exit:0
```

### Performance Budgets

| Hook | Budget | Purpose |
|------|--------|---------|
| post-command | 100ms | Frequent use |
| on-task-complete | 50ms | Very frequent |
| pre-commit | 500ms | Blocking, rare |
| post-merge | 200ms | Rare but important |

### Optimization Tips

1. **Use async mode** for non-critical hooks
2. **Increase timeout** for complex operations
3. **Disable hooks** temporarily during bulk operations:
   ```bash
   SPECTER_HOOKS_ENABLED=false /specter implement
   ```

## Advanced Usage

### Wait for Async Hooks

```bash
source .specter/lib/hook-runner.sh
specter_wait_for_hooks post-command
```

### Run Hooks Manually

```bash
source .specter/lib/hook-runner.sh

# Create context
context='{"command":"test","activeFeature":{"id":"002","phase":"planning"}}'

# Run hook
specter_run_hooks post-command "$context"
```

### Custom Hooks

See [CUSTOM-HOOKS-API.md](./CUSTOM-HOOKS-API.md) for creating your own hooks.

## Configuration Examples

### Development Mode (Fast)

```json
{
  "hooks": {
    "post-command": {
      "enabled": true,
      "mode": "async"
    },
    "pre-commit": {
      "enabled": false
    }
  }
}
```

### Production Mode (Strict)

```json
{
  "hooks": {
    "post-command": {
      "enabled": true,
      "mode": "sync"
    },
    "pre-commit": {
      "enabled": true,
      "blocking": true
    }
  }
}
```

### Team Mode (Maximum Validation)

```json
{
  "hooks": {
    "post-command": { "enabled": true },
    "on-task-complete": { "enabled": true },
    "pre-commit": { "enabled": true, "blocking": true },
    "post-merge": { "enabled": true }
  },
  "validation": {
    "schema": true,
    "consistency": true,
    "locks": true
  }
}
```

## FAQ

**Q: Can I disable hooks temporarily?**
A: Yes, set `SPECTER_HOOKS_ENABLED=false` or use `--no-verify` for git hooks.

**Q: Why is my commit blocked?**
A: Pre-commit hook found validation errors. Fix them or use `--no-verify`.

**Q: How do I uninstall git hooks?**
A: Run `specter_uninstall_git_hooks` (source `git-hooks-installer.sh` first).

**Q: Can I write custom hooks?**
A: Yes! See [CUSTOM-HOOKS-API.md](./CUSTOM-HOOKS-API.md).

**Q: Where are hook logs stored?**
A: `.specter/logs/hooks.log` and `.specter/logs/hook-performance.log`.

**Q: What if a hook fails?**
A: Non-blocking hooks log errors. Blocking hooks prevent the operation.

## See Also

- [CUSTOM-HOOKS-API.md](./CUSTOM-HOOKS-API.md) - Writing custom hooks
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - General troubleshooting
- [USER-GUIDE.md](./USER-GUIDE.md) - Complete Specter guide

---

**Need help?** Check the troubleshooting section above or create an issue on GitHub.
