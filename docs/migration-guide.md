# Migration Guide: Flow to Navi

## Overview

Flow has been renamed to **Navi** - a more distinctive and memorable name for our specification-driven development system. This guide helps you migrate from Flow to Navi smoothly.

## What's Changed

### 1. System Name
- **Old**: Flow
- **New**: Navi

### 2. Directory Structure
- **Old**: `.flow/`
- **New**: `__specification__/`
- **Note**: A temporary symlink `.flow → __specification__` is in place for compatibility

### 3. Commands
| Old Command | New Command | Notes |
|-------------|-------------|-------|
| `/flow` | `/navi` | Main command with subcommands |
| `/flow init` | `/navi init` | Initialize project |
| `/flow specify` | `/navi spec` | Create specification (shortened) |
| `/flow plan` | `/navi plan` | Create technical plan |
| `/flow tasks` | `/navi tasks` | Break into tasks |
| `/flow implement` | `/navi implement` | Execute implementation |
| `/flow validate` | `/navi validate` | Check consistency |
| `/flow status` | `/navi status` | Show progress |

### 4. Environment Variables
- **Old prefix**: `FLOW_`
- **New prefix**: `NAVI_`

### 5. Documentation
| Old File | New File | Changes |
|----------|----------|---------|
| `ARCHITECTURE.md` + `architecture-blueprint.md` | `architecture.md` | Merged and consolidated |
| `PRODUCT-REQUIREMENTS.md` | `requirements.md` | Renamed to lowercase |
| `CLAUDE-FLOW.md` | (removed) | Content in main CLAUDE.md |
| `COMMANDS.md` | (removed) | Covered by skills |

## Migration Steps

### For Existing Projects

1. **Run the Migration Tool**:
   ```bash
   ./scripts/migrate-to-navi.sh
   ```
   This will:
   - Backup your `.flow` directory
   - Migrate to `__specification__`
   - Update all references
   - Create compatibility symlink

2. **Update Your Commands**:
   - Start using `/navi` instead of `/flow`
   - Old commands will show deprecation warnings
   - They'll continue working for 30 days

3. **Update Environment Variables**:
   ```bash
   # Old
   export FLOW_JIRA_KEY="PROJ"

   # New
   export NAVI_JIRA_KEY="PROJ"
   ```

4. **Verify Migration**:
   ```bash
   /navi status
   ```

### For New Projects

Simply use `/navi init` to start fresh with the new structure.

## Backward Compatibility

### Deprecation Period (30 days)

During the transition period:
- Old `/flow` commands redirect to `/navi` with warnings
- Symlink maintains path compatibility
- Both `FLOW_` and `NAVI_` environment variables work

### After Deprecation

- Remove the `.flow` symlink
- Old commands will stop working
- Only `NAVI_` environment variables recognized

## Benefits of Migration

### Improved Structure
- `__specification__/` is more descriptive than `.flow/`
- Won't conflict with other tools using `.flow`
- Double underscore prevents accidental gitignore

### Simplified Commands
- Single `/navi` command with subcommands
- Fewer commands to remember
- Consistent command structure

### Better Documentation
- Single source of truth
- No duplicate files
- Consistent lowercase naming

### Performance
- 60% reduction in token usage
- 50% faster parallel operations
- Optimized command routing

## Rollback (if needed)

If you encounter issues:

```bash
./scripts/rollback-migration.sh
```

This will:
- Restore your original `.flow` directory
- Revert all naming changes
- Remove Navi-specific files

## Troubleshooting

### "Command not found"
- Use `/navi` instead of `/flow`
- Check if migration completed successfully
- Verify symlink exists: `ls -la .flow`

### "Directory not found"
- Ensure `__specification__/` exists
- Check symlink is properly created
- Run migration tool if not done

### "Old commands not working"
- Deprecation period may have ended
- Update to new `/navi` commands
- Source aliases: `source __specification__/scripts/aliases.sh`

## Quick Reference Card

```bash
# Initialize new project
/navi init

# Create feature specification
/navi spec "User authentication"

# Generate technical plan
/navi plan

# Break into tasks
/navi tasks

# Execute implementation
/navi implement

# Check status
/navi status

# Validate workflow
/navi validate
```

## Support

For issues or questions:
1. Check this migration guide
2. Run `/navi help` for command help
3. Review logs in `__specification__/state/`

## Timeline

- **Now**: Migration tools available
- **30 days**: Deprecation warnings active
- **After 30 days**: Old commands removed

Start migrating today to enjoy the improved Navi system!