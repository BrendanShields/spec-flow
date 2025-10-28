# Navi Architecture

Navi is a specification-driven development system built on progressive disclosure and token efficiency principles.

## Design Principles

### 1. Progressive Disclosure
- **Root CLAUDE.md**: <50 lines, essential commands only
- **Detailed docs**: `.navi/docs/` loaded on-demand
- **Skills**: Self-contained, reference docs as needed

### 2. Token Efficiency
- **Scripts over repetition**: Reusable bash utilities
- **JSON config**: Structured data, not text parsing
- **Lazy loading**: Documentation loaded when needed

### 3. Session Continuity
- **State tracking**: Current feature, phase, progress
- **Memory files**: Decisions, changes, metrics
- **Checkpoints**: Resume from interruption

## Directory Structure

```
.navi/
├── config/              # Configuration layer
│   └── navi.json        # JSON config (jq-based)
│
├── state/               # Session layer (transient)
│   ├── current-session.md
│   └── checkpoints/
│
├── memory/              # Persistence layer (committed)
│   ├── WORKFLOW-PROGRESS.md
│   ├── DECISIONS-LOG.md
│   ├── CHANGES-PLANNED.md
│   └── CHANGES-COMPLETED.md
│
├── features/            # Artifact layer (committed)
│   └── ###-name/
│       ├── spec.md
│       ├── plan.md
│       └── tasks.md
│
├── templates/           # Template layer
│   └── *.md
│
├── scripts/             # Utility layer
│   ├── config.sh        # Config management
│   ├── format-output.sh # Output formatting
│   └── routing.sh       # Phase detection & routing
│
└── docs/                # Documentation layer
    ├── CLAUDE-FLOW.md
    ├── ARCHITECTURE.md  # This file
    └── COMMANDS.md
```

## Component Design

### Configuration System (`config.sh`)

**Purpose**: Manage JSON configuration with validation.

**Functions**:
- `init_navi_config(type)` - Create default config
- `get_navi_config(key)` - Read nested values
- `set_navi_config(key, value)` - Update values
- `validate_navi_config()` - Validate schema
- `validate_jira_key(key)` - Validate format
- `validate_confluence_page_id(id)` - Validate numeric

**Dependencies**: `jq` (with fallback parser)

**Key Design Decision**: JSON over YAML for jq ubiquity.

### Output Formatting (`format-output.sh`)

**Purpose**: Consistent visual formatting across all commands.

**Functions**:
- `format_tldr(content)` - TLDR box with separators
- `format_next_steps(steps)` - Next steps box
- `format_status_indicator(status)` - Emoji indicators
- `format_success_header(title)` - Success headers
- `format_progress_bar(completed, total)` - Progress bars
- `format_complete_success(...)` - Full success message

**Visual Elements**:
- ✅ Completed
- ➡️ Next/Recommended
- ⏳ Pending/Not Ready
- ❌ Error
- ⚠️ Warning
- ℹ️ Info

### Routing System (`routing.sh`)

**Purpose**: Phase detection and command routing.

**Functions**:
- `detect_current_phase()` - Determine worknavi phase
- `get_current_feature_dir()` - Find active feature
- `get_next_suggested_command()` - Recommend next step
- `route_navi_command(subcmd)` - Route to skill
- `render_navi_menu()` - Display interactive menu
- `is_phase_complete(phase)` - Check phase status

**Phase Detection Logic**:
```
if no .navi/features/: return "init"
if no spec.md: return "specify"
if no plan.md: return "plan"
if no tasks.md: return "tasks"
if tasks incomplete: return "implement"
else: return "complete"
```

## Data Navi

### Initialization Navi

```
User: /navi init
  ↓
navi:init skill
  ↓
AskUserQuestion (project type, JIRA, Confluence)
  ↓
config.sh: init_navi_config()
  ↓
config.sh: set_navi_config() for each integration
  ↓
init-state.sh: create directories & files
  ↓
format-output.sh: format_complete_success()
  ↓
Output: TLDR + Next Steps
```

### Worknavi Progression

```
init → specify → plan → tasks → implement → complete
  ↑                                            ↓
  └────────────── validate ←──────────────────┘
```

### State Updates

```
Skill execution
  ↓
Update .navi/state/current-session.md
  ↓
Update .navi/memory/WORKFLOW-PROGRESS.md
  ↓
Log to .navi/memory/DECISIONS-LOG.md (if ADR)
  ↓
Move tasks: CHANGES-PLANNED → CHANGES-COMPLETED
```

## Architecture Decisions

### ADR-001: Marketplace Root Initialization

**Context**: Navi can be used in marketplace repo itself for development.

**Decision**: Initialize Navi at marketplace root, not plugin directory.

**Rationale**:
- Test Navi using Navi
- Self-hosting validates design
- Easier development worknavi

**Alternatives**: Plugin-only use
**Impact**: Marketplace has `.navi/` directory

### ADR-002: Consolidate Under `.navi/`

**Context**: Multiple root directories (`.navi-state/`, `.navi-memory/`, `features/`) scattered files.

**Decision**: Single `.navi/` directory with subdirectories.

**Rationale**:
- Cleaner project root
- Clear ownership
- Easier .gitignore
- Better discoverability

**Alternatives**: Keep separate directories
**Impact**: Breaking change requiring migration

### ADR-003: JSON Configuration

**Context**: Need structured configuration for integrations.

**Decision**: Use JSON at `.navi/config/navi.json` with jq.

**Rationale**:
- `jq` widely available
- Structured data validation
- Easy to parse and update
- Better than env vars or text parsing

**Alternatives**: YAML (requires yq), TOML, env vars
**Impact**: Requires jq installation (with fallback)

### ADR-004: Unified `/navi` Command

**Context**: Multiple `/navi-*` commands cluttering namespace.

**Decision**: Single `/navi` command with subcommands.

**Rationale**:
- Cleaner command space
- Easier discovery
- Phase-aware menu
- Industry standard pattern (git, docker)

**Alternatives**: Keep separate commands
**Impact**: Backward compatible, legacy commands still work

### ADR-005: Progressive Disclosure in Documentation

**Context**: Long CLAUDE.md increases token usage every message.

**Decision**: Brief root CLAUDE.md (<50 lines) linking to `.navi/docs/`.

**Rationale**:
- Token efficiency (50-70% reduction)
- Faster context loading
- Details loaded on-demand
- Better organization

**Alternatives**: Single large file
**Impact**: Requires documentation split

### ADR-006: Interactive Prompts with AskUserQuestion

**Context**: Need user input for configuration without CLI knowledge.

**Decision**: Use AskUserQuestion tool for guided configuration.

**Rationale**:
- Better UX for new users
- Validation before storage
- Self-documenting options
- CLI args for automation

**Alternatives**: CLI-only, config file editing
**Impact**: Requires AskUserQuestion tool access

---

**Feature 002: AskUserQuestion Integration - New ADRs**

### ADR-007: Use AskUserQuestion for Interactive Menus

**Context**: `/navi` command currently shows text-only menu, users must type commands.

**Decision**: Use AskUserQuestion tool to show visual selection interface for `/navi` menu.

**Rationale**:
- Click to select > typing commands for discovery
- Phase-aware options guide users through worknavi
- Reduces cognitive load for new users
- Status indicators (✅ done, ➡️ next, ⏳ not ready) provide context

**Alternatives**:
- Text menu with typed response (current)
- Numbered menu with number selection
- Fuzzy search input

**Impact**:
- Requires AskUserQuestion tool access
- Better UX for new users
- Power users can still use direct commands

### ADR-008: Interactive by Default with CLI Override

**Context**: Need to balance discoverability with power user efficiency.

**Decision**: Make interactive mode default, but skip all prompts when CLI arguments provided.

**Rationale**:
- New users benefit from visual prompts
- Power users use CLI args (`/navi init --type=brownfield`)
- Any CLI argument presence automatically skips interactive mode
- Config toggle available: `preferences.interactive_mode: false`

**Alternatives**:
- Interactive opt-in (requires flag)
- Always interactive (annoying for automation)
- Always CLI (hard for new users)

**Impact**:
- Better onboarding experience
- Backward compatible (CLI args work as before)
- No breaking changes to automation

### ADR-009: Conditional Multi-Step Prompts

**Context**: navi:init needs 5 inputs but AskUserQuestion max is 4 questions per call.

**Decision**: Use two-step conditional approach:
1. Ask 3 core questions (type, JIRA yes/no, Confluence yes/no)
2. Only ask for keys if integrations enabled in step 1

**Rationale**:
- Reduces questions asked (skip keys if not needed)
- Better UX than asking all 5 upfront
- Respects AskUserQuestion constraints
- Conditional logic feels natural

**Alternatives**:
- Two rounds always (wasteful)
- Single round with "Other" for everything (complex)
- Multiple separate prompts (fragmented)

**Impact**:
- Fewer questions for users not using integrations
- Slight complexity in skill logic
- Better user experience overall

### ADR-010: Phase Transitions Opt-In via Config

**Context**: "What's next?" prompts after each phase could interrupt power users.

**Decision**: Make phase transitions opt-in via `preferences.interactive_transitions: false` (default).

**Rationale**:
- Power users don't want interruptions
- New users can enable for guidance
- Separate from main `interactive_mode` toggle
- Can be enabled per-project basis

**Alternatives**:
- Always show transitions (annoying)
- Never show transitions (less guided)
- Auto-detect user experience level (complex)

**Impact**:
- Flexibility for different user preferences
- Minimal additional config
- Clear opt-in semantics

### ADR-011: Automatic Skill Invocation After Selection

**Context**: After user selects from AskUserQuestion menu, what happens next?

**Decision**: Automatically invoke the corresponding skill based on user selection.

**Rationale**:
- Reduces friction (select → execute, not select → copy command → run)
- Matches user mental model ("I want to do X" → X happens)
- Consistent with Claude Code's interaction patterns

**Alternatives**:
- Show command to run (user must copy/paste)
- Ask for confirmation first (extra step)
- Execute in preview mode (complex)

**Impact**:
- Seamless worknavi progression
- Must handle errors gracefully
- Clear communication of what's being executed

## Extension Points

### Adding New Skills

1. Create `.claude/skills/navi-{name}/SKILL.md`
2. Follow state integration pattern (SKILL-STATE-INTEGRATION.md)
3. Use utility scripts:
   ```bash
   source .navi/scripts/config.sh
   source .navi/scripts/format-output.sh
   ```
4. Update routing.sh if new phase needed

### Custom Output Formatting

Create custom formatters in scripts:
```bash
source .navi/scripts/format-output.sh

custom_format() {
  format_success_header "Custom"
  # Your logic
  format_next_steps "Next actions"
}
```

### Integration Plugins

Add to config.json:
```json
{
  "integrations": {
    "custom": {
      "enabled": true,
      "config_key": "value"
    }
  }
}
```

Access in skills:
```bash
custom_enabled=$(get_navi_config "integrations.custom.enabled")
```

## Performance Considerations

### Token Optimization

**Before** (old structure):
- Root CLAUDE.md: 200+ lines
- Plugin CLAUDE.md: 300+ lines
- Total per message: ~500 lines

**After** (new structure):
- Root CLAUDE.md: 51 lines
- Details loaded on-demand
- Total per message: ~50-100 lines
- **Reduction**: 70-80%

### File System Operations

- Phase detection: O(1) file checks
- Config reads: jq parsing (fast)
- State updates: Atomic writes
- Feature lookup: Directory listing (cached)

### Parallel Execution

Tasks marked `[P]` can run in parallel:
- T001 [P], T002 [P], T003 [P] → parallel
- T004 depends on T005 → sequential

## Security Considerations

### Git Ignore

**Ignored** (`.navi/state/`):
- Session-specific data
- Temporary checkpoints
- Local state

**Committed** (`.navi/memory/`, `.navi/features/`):
- Project history
- Architecture decisions
- Feature artifacts

### Configuration Secrets

Never commit:
- API tokens
- Passwords
- Personal access tokens

Use `.navi/config/navi.local.json` for secrets (git-ignored).

## Testing Strategy

### Unit Testing

Scripts are testable:
```bash
source .navi/scripts/config.sh
init_navi_config "greenfield"
validate_navi_config  # Should pass
```

### Integration Testing

Test worknavis end-to-end:
```bash
/navi init --type=greenfield
/navi specify "Test feature"
/navi plan
/navi tasks
# Verify file creation
```

### Validation

Use `/navi validate` to check:
- File consistency
- Configuration validity
- State coherence

## Future Enhancements

### Planned

1. **Token usage analytics** (US7)
   - Track tokens per command
   - Measure efficiency gains
   - Report statistics

2. **Advanced validation**
   - Schema validation
   - Cross-file consistency
   - Dependency checking

3. **MCP integrations**
   - Auto-detect available MCPs
   - Configure based on availability
   - Sync with external systems

### Possible

- Visual progress dashboard
- Team collaboration features
- CI/CD integration
- Custom worknavi phases

---

**Version**: 2.0
**Architecture Review**: 2025-10-28
