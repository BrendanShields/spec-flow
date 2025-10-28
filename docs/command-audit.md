# Command Inventory Audit

## Current Command Structure

### Core Flow Commands
| Current Command | Purpose | New Command | Status |
|----------------|---------|-------------|--------|
| `/flow` | Unified workflow menu | `/navi` | To migrate |
| `/flow init` | Initialize project | `/navi init` | To migrate |
| `/flow specify` | Create specification | `/navi spec` | To simplify |
| `/flow plan` | Create technical plan | `/navi plan` | To migrate |
| `/flow tasks` | Break into tasks | `/navi tasks` | To migrate |
| `/flow implement` | Execute implementation | `/navi implement` | To migrate |
| `/flow validate` | Check consistency | `/navi check` | To consolidate |
| `/flow status` | Show progress | `/navi status` | To migrate |

### Individual Commands (To Deprecate)
| Command | Purpose | Replacement | Action |
|---------|---------|-------------|--------|
| `/flow-init` | Initialize Flow | `/navi init` | Deprecate |
| `/flow-specify` | Create spec | `/navi spec` | Deprecate |
| `/flow-implement` | Implement tasks | `/navi implement` | Deprecate |
| `/flow-validate` | Validate workflow | `/navi check` | Deprecate |
| `/flow-status` | Show status | `/navi status` | Deprecate |
| `/flow-help` | Show help | `/navi help` | Deprecate |
| `/flow-resume` | Resume session | `/navi resume` | Deprecate |
| `/flow-session` | Manage session | `/navi session` | Deprecate |

### Utility Commands (Keep)
| Command | Purpose | Status |
|---------|---------|--------|
| `/status` | Quick status check | Keep as alias |
| `/validate` | Quick validation | Keep as alias |
| `/resume` | Resume work | Keep as alias |
| `/session` | Session management | Keep |
| `/help` | General help | Keep |

## Command Consolidation Strategy

### Phase 1: Core Consolidation
1. **Single Entry Point**: `/navi` replaces all `/flow*` commands
2. **Subcommands**: Direct routing via `/navi [subcommand]`
3. **Interactive Menu**: Default behavior when no subcommand

### Phase 2: Smart Routing
- Natural language interpretation
- Context-aware suggestions
- Fuzzy matching for commands

### Phase 3: Deprecation
- 30-day compatibility period
- Warning messages on old commands
- Auto-redirect to new commands

## Token Optimization Impact

### Current Token Usage (per command)
- `/flow-specify`: ~1200 tokens
- `/flow-plan`: ~1000 tokens
- `/flow-tasks`: ~800 tokens
- `/flow-implement`: ~1500 tokens
- **Total Average**: 1125 tokens

### Optimized Token Usage (projected)
- Shared base prompt: ~150 tokens
- Progressive loading: ~200 tokens on demand
- **New Average**: ~350 tokens (69% reduction)

## Command Simplification Benefits

### Before (15+ commands)
```
/flow, /flow-init, /flow-specify, /flow-plan, /flow-tasks,
/flow-implement, /flow-validate, /flow-status, /flow-help,
/flow-resume, /flow-session, /status, /validate, /resume, /help
```

### After (1 primary + 5 utility)
```
Primary: /navi (with subcommands)
Utility: /status, /validate, /resume, /session, /help
```

**Reduction**: 60% fewer commands to remember

## Migration Path

### Compatibility Layer (30 days)
```bash
# Old command shows deprecation warning
/flow-specify "feature"
> Warning: /flow-specify is deprecated. Use /navi spec instead.
> Redirecting to /navi spec...

# Alias mapping
alias /flow="/navi"
alias /flow-specify="/navi spec"
```

### User Communication
1. Migration guide in documentation
2. In-app deprecation warnings
3. Automatic command suggestions
4. Rollback option if needed

## Files to Update

### Command Definitions
- [ ] `.claude/commands/flow*.md` → `.claude/commands/navi*.md`
- [ ] Update command prompts and descriptions
- [ ] Add deprecation warnings to old commands

### Skill References
- [ ] `.claude/skills/flow-*/` → `.claude/skills/navi-*/`
- [ ] Update skill names and references
- [ ] Update inter-skill dependencies

### Documentation
- [ ] Update CLAUDE.md with new commands
- [ ] Update README.md with Navi branding
- [ ] Create migration guide
- [ ] Update all examples

## Metrics for Success

1. **Command Usage**: Track adoption of new commands
2. **Error Rate**: Monitor command not found errors
3. **User Feedback**: Collect migration experience
4. **Token Savings**: Measure actual reduction
5. **Performance**: Compare execution times

## Risk Mitigation

### Breaking Changes
- **Risk**: Users' workflows break
- **Mitigation**: Compatibility layer, clear migration guide

### Muscle Memory
- **Risk**: Users type old commands
- **Mitigation**: Auto-redirect, helpful suggestions

### Documentation Lag
- **Risk**: Outdated docs confuse users
- **Mitigation**: Update all docs before release