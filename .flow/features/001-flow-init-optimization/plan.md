# Technical Plan: Flow Init Optimization & Restructuring

**Feature ID**: 001-flow-init-optimization
**Created**: 2025-10-28
**Based on**: spec.md v1.2
**Status**: draft

## Executive Summary

This plan details the technical implementation for restructuring Flow's directory organization, adding interactive initialization, and creating a unified command interface. The goal is 50%+ token reduction, cleaner project structure, and improved user experience through progressive disclosure and smart navigation.

**Key Changes**:
1. Consolidate all Flow artifacts under `.flow/` directory
2. Implement interactive init with AskUserQuestion prompts
3. Create unified `/flow` command with phase-aware navigation
4. Add JSON configuration management
5. Optimize CLAUDE.md with progressive disclosure
6. Enhance output formatting with visual sections

## Architecture Decisions

### ADR-001: Consolidate Under Single `.flow/` Directory

**Context**: Currently Flow creates multiple top-level directories (`.flow-state/`, `.flow-memory/`, `features/`) which clutters project roots.

**Decision**: Move all Flow artifacts under `.flow/` directory with subdirectories for different concerns.

**Rationale**:
- Cleaner project root (single `.flow/` instead of 3+ directories)
- Logical grouping of related files
- Easier to find Flow-related files
- Simpler .gitignore rules
- Industry standard (similar to `.git/`, `.vscode/`, `.next/`)

**Structure**:
```
.flow/
├── config/      # Configuration (flow.json)
├── state/       # Session state (git-ignored)
├── memory/      # Persistent memory (committed)
├── features/    # Feature artifacts (committed)
├── templates/   # Document templates
├── scripts/     # Utility scripts
└── docs/        # Detailed documentation
```

**Consequences**:
- ✅ Cleaner project structure
- ✅ Easier navigation
- ✅ More professional appearance
- ⚠️ Need to update all path references
- ⚠️ Existing marketplace installation needs restructuring

---

### ADR-002: Use JSON for Configuration Storage

**Context**: Need to store user configuration (project type, integrations) in a way that's both human-readable and script-parseable.

**Decision**: Use plain JSON format stored at `.flow/config/flow.json`.

**Options Considered**:
1. **Plain JSON** - Standard, widely supported, bash-parseable with jq
2. **JSON5** - Supports comments, more readable, requires additional tooling
3. **YAML** - Very readable, harder to parse in bash
4. **TOML** - Good for config, less common, limited bash support

**Decision**: Plain JSON
**Rationale**:
- Native support in bash with `jq` (available on most systems)
- Standard format, no learning curve
- Easy to validate and parse
- Can add comments via separate documentation
- Future: can add JSON5 support if users request it

**Schema**:
```json
{
  "version": "2.0",
  "project": {
    "type": "greenfield|brownfield",
    "initialized": "2025-10-28T17:00:00Z",
    "name": "project-name"
  },
  "integrations": {
    "jira": {
      "enabled": false,
      "project_key": ""
    },
    "confluence": {
      "enabled": false,
      "root_page_id": ""
    }
  },
  "preferences": {
    "auto_checkpoint": true,
    "validate_on_save": true,
    "output_format": "standard"
  }
}
```

**Consequences**:
- ✅ Easy to parse in bash with `jq`
- ✅ Standard format, no special tooling
- ✅ Type-safe validation possible
- ⚠️ No inline comments (mitigate with documentation)
- ⚠️ Slightly more verbose than YAML

---

### ADR-003: Unified /flow Command with Routing

**Context**: Users need to remember multiple commands (`/flow-init`, `/flow-specify`, etc.) and the correct order to run them.

**Decision**: Create single `/flow` command that routes to subcommands or shows interactive menu.

**Design**:
```
/flow                     → Interactive menu (AskUserQuestion)
/flow <subcommand> [...args] → Direct execution
```

**Routing Logic**:
1. Parse first argument after `/flow`
2. If no argument: detect current phase, show menu with recommendations
3. If argument matches known subcommand: route to skill
4. If unknown: show error with available commands

**Phase Detection**:
- Read `.flow/state/current-session.md`
- Check file existence: `spec.md`, `plan.md`, `tasks.md`
- Determine current phase
- Highlight recommended next step with ➡️

**Rationale**:
- Single entry point reduces cognitive load
- Smart menu guides users through workflow
- Direct subcommands for power users
- Backward compatible (keep `/flow-*` commands)
- Better token efficiency (load menu first, then skill)

**Implementation**:
- Single command file: `.claude/commands/flow.md`
- Bash function library: `.flow/scripts/routing.sh`
- Phase detection: `.flow/scripts/detect-phase.sh`
- Menu rendering: `.flow/scripts/render-menu.sh`

**Consequences**:
- ✅ Easier to learn and use
- ✅ Self-documenting (menu shows options)
- ✅ Reduces user errors (can't run out of order)
- ⚠️ Slightly more complex implementation
- ⚠️ Need to maintain routing logic

---

### ADR-004: Progressive Disclosure in CLAUDE.md

**Context**: Current CLAUDE.md files are verbose, loading thousands of tokens even for simple operations.

**Decision**: Use progressive disclosure pattern with brief root CLAUDE.md linking to detailed docs.

**Structure**:
```
CLAUDE.md (root)          ~50 lines, essential only
  ↓ links to
.flow/docs/CLAUDE-FLOW.md  Full details, loaded on-demand
.flow/docs/COMMANDS.md     Command reference
.flow/docs/ARCHITECTURE.md Architecture details
```

**Root CLAUDE.md Content** (30 lines max):
- Project overview (5 lines)
- Flow workflow summary (10 lines)
- Quick commands (10 lines)
- Link to `.flow/docs/CLAUDE-FLOW.md` for details (5 lines)

**Detailed Docs** (loaded when needed):
- Full skill descriptions
- Integration guides
- Architecture details
- Troubleshooting

**Rationale**:
- Massive token reduction (thousands → hundreds for common operations)
- Faster Claude response times
- Only loads details when actually needed
- Better organization of documentation

**Consequences**:
- ✅ 50%+ token reduction for most operations
- ✅ Faster init and common commands
- ✅ Better organized documentation
- ⚠️ Need to maintain clear linking structure
- ⚠️ Docs must be well-indexed for discovery

---

### ADR-005: Interactive Prompts with AskUserQuestion

**Context**: Init requires configuration but users shouldn't need to read docs or remember command-line arguments.

**Decision**: Use Claude's `AskUserQuestion` tool for interactive configuration during init.

**Prompt Flow**:
1. Project type (Greenfield / Brownfield)
2. JIRA integration (Yes / No)
   - If Yes: Project key (text input)
3. Confluence integration (Yes / No)
   - If Yes: Root page ID (text input)

**Validation**:
- JIRA key format: `^[A-Z][A-Z0-9]+-[0-9]+$` or `^[A-Z][A-Z0-9]+$`
- Confluence page ID: numeric only
- Project type: must be "greenfield" or "brownfield"

**CLI Override**:
```bash
/flow-init --type=greenfield --jira=PROJ-123 --confluence=456789
```

**Rationale**:
- Better UX (guided vs. reading docs)
- Prevents invalid configuration
- Defaults to sensible values
- Power users can skip with CLI args

**Consequences**:
- ✅ Much better user experience
- ✅ Prevents configuration errors
- ✅ Self-documenting (prompts explain options)
- ⚠️ Requires AskUserQuestion tool access
- ⚠️ Need to handle CLI args + prompts

---

### ADR-006: Bash Scripts for Common Operations

**Context**: Common operations (config reading, phase detection, formatting) should be consistent and reusable.

**Decision**: Extract common operations to bash scripts in `.flow/scripts/`.

**Scripts**:
- `common.sh` - Shared utilities (already exists, expand)
- `init.sh` - Initialization logic
- `validate.sh` - Validation utilities
- `format-output.sh` - Output formatting (TLDR, Next Steps)
- `routing.sh` - Command routing logic
- `detect-phase.sh` - Phase detection
- `config.sh` - Config read/write/validate

**Functions**:
```bash
# Config management
get_flow_config KEY          # Read config value
set_flow_config KEY VALUE    # Write config value
validate_flow_config         # Validate config schema

# Phase detection
detect_current_phase         # Returns: init|specify|plan|tasks|implement|complete
get_next_suggested_command   # Returns recommended command

# Output formatting
format_tldr CONTENT          # Wraps in TLDR box
format_next_steps STEPS      # Formats next steps section
format_status_indicator STATUS # Returns ✅/➡️/⏳

# Routing
route_flow_command SUBCOMMAND ARGS # Routes to appropriate skill
```

**Rationale**:
- DRY (Don't Repeat Yourself)
- Easier to test and maintain
- Consistent behavior across all commands
- Skills can focus on logic, not plumbing

**Consequences**:
- ✅ Cleaner skill implementations
- ✅ Easier to maintain and test
- ✅ Consistent behavior
- ⚠️ Need to maintain bash script compatibility
- ⚠️ More files to manage

---

## Component Design

### Component 1: Directory Restructuring

**Purpose**: Move existing files to new `.flow/` structure

**Responsibilities**:
- Create new directory structure
- Move existing files to new locations
- Update all path references
- Update .gitignore

**Implementation**:
```bash
# Create new structure
mkdir -p .flow/{config,state,memory,features,templates,scripts,docs}

# Move existing files
mv .flow-state/* .flow/state/ 2>/dev/null || true
mv .flow-memory/* .flow/memory/ 2>/dev/null || true
mv features/* .flow/features/ 2>/dev/null || true

# Move existing .flow/ contents
mv .flow/*.md .flow/docs/ 2>/dev/null || true
mv .flow/templates .flow/templates/ 2>/dev/null || true
mv .flow/scripts .flow/scripts/ 2>/dev/null || true

# Cleanup
rmdir .flow-state .flow-memory features 2>/dev/null || true
```

**Path Updates Required**:
- All skills: update file paths
- All commands: update file paths
- Templates: update relative paths
- Documentation: update examples

**Files to Update** (~30 files):
- Skills: `flow-init`, `flow-specify`, `flow-plan`, `flow-tasks`, `flow-implement`, etc.
- Commands: `flow-*.md`, `status.md`, `help.md`, etc.
- Templates: All template files
- Scripts: `common.sh` and others

---

### Component 2: Configuration Management System

**Purpose**: Manage Flow configuration with JSON storage

**Interface**:
```bash
# Initialize config with defaults
init_flow_config() {
  local type="${1:-brownfield}"
  cat > .flow/config/flow.json <<EOF
{
  "version": "2.0",
  "project": {
    "type": "$type",
    "initialized": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "name": "$(basename $(pwd))"
  },
  "integrations": {
    "jira": {"enabled": false, "project_key": ""},
    "confluence": {"enabled": false, "root_page_id": ""}
  },
  "preferences": {
    "auto_checkpoint": true,
    "validate_on_save": true
  }
}
EOF
}

# Read config value
get_flow_config() {
  local key="$1"
  jq -r ".$key" .flow/config/flow.json
}

# Write config value
set_flow_config() {
  local key="$1"
  local value="$2"
  local tmp=$(mktemp)
  jq ".$key = \"$value\"" .flow/config/flow.json > "$tmp"
  mv "$tmp" .flow/config/flow.json
}

# Validate config
validate_flow_config() {
  if ! jq empty .flow/config/flow.json 2>/dev/null; then
    echo "Error: Invalid JSON in flow.json"
    return 1
  fi

  # Check required fields
  local version=$(jq -r '.version' .flow/config/flow.json)
  if [ "$version" != "2.0" ]; then
    echo "Error: Unsupported config version: $version"
    return 1
  fi

  return 0
}
```

**Dependencies**:
- `jq` for JSON parsing (check availability, provide fallback)
- File system access to `.flow/config/`

**Error Handling**:
- Invalid JSON: show error, provide repair instructions
- Missing file: create with defaults
- Permission errors: clear error message

---

### Component 3: Interactive Init System

**Purpose**: Guide users through initialization with prompts

**Flow**:
```
1. Check if already initialized
   → If yes: show error, suggest /flow-update

2. Prompt: Project type
   → Greenfield | Brownfield
   → Store in config

3. Prompt: JIRA integration
   → Yes | No
   → If Yes: Prompt for project key
   → Validate format
   → Store in config

4. Prompt: Confluence integration
   → Yes | No
   → If Yes: Prompt for root page ID
   → Validate numeric
   → Store in config

5. Create directory structure
6. Generate templates
7. Update CLAUDE.md
8. Show success message with next steps
```

**Implementation**:
```bash
# In flow:init skill
interactive_init() {
  # Detect if already initialized
  if [ -f .flow/config/flow.json ]; then
    echo "Error: Flow already initialized"
    echo "Use /flow-update to modify configuration"
    return 1
  fi

  # Prompt 1: Project type
  local type=$(ask_user_question \
    "What type of project is this?" \
    "Greenfield" "Brownfield")

  # Prompt 2: JIRA
  local jira_enabled=$(ask_user_question \
    "Enable JIRA integration?" \
    "Yes" "No")

  local jira_key=""
  if [ "$jira_enabled" = "Yes" ]; then
    jira_key=$(ask_user_text "JIRA Project Key (e.g., PROJ)?")
    # Validate format
    if ! validate_jira_key "$jira_key"; then
      echo "Warning: Invalid JIRA key format"
    fi
  fi

  # Similar for Confluence...

  # Create structure
  create_directory_structure
  init_flow_config "$type"
  set_flow_config "integrations.jira.enabled" "$jira_enabled"
  set_flow_config "integrations.jira.project_key" "$jira_key"

  # Success output
  format_success_message
}
```

---

### Component 4: Unified /flow Command

**Purpose**: Single entry point with routing and interactive menu

**Structure**:
```
.claude/commands/flow.md
  ↓ parses args
  ↓ if no args: show menu
  ↓ if subcommand: route to skill
```

**Command File** (`.claude/commands/flow.md`):
````markdown
# /flow

Unified Flow command with smart navigation.

## Usage
```bash
/flow                 # Interactive menu
/flow <subcommand>    # Direct execution
```

## Implementation

When you invoke this command, execute the routing logic:

1. Parse arguments
2. Detect current phase
3. If no arguments: show interactive menu
4. If subcommand: route to appropriate skill

```bash
# Source routing library
source .flow/scripts/routing.sh

# Parse command
SUBCOMMAND="${1:-}"
shift || true

if [ -z "$SUBCOMMAND" ]; then
  # Show interactive menu
  show_flow_menu
else
  # Route to skill
  route_flow_command "$SUBCOMMAND" "$@"
fi
```
````

**Menu Rendering** (`.flow/scripts/render-menu.sh`):
```bash
show_flow_menu() {
  local current_phase=$(detect_current_phase)

  # Build menu options
  local options=()

  # Workflow commands
  options+=("✅ init|Initialize Flow|completed")
  options+=("✅ specify|Create feature specification|completed")

  if [ "$current_phase" = "specify" ]; then
    options+=("➡️ plan|Create technical plan|recommended")
  else
    options+=("✅ plan|Create technical plan|completed")
  fi

  if [ "$current_phase" = "plan" ]; then
    options+=("➡️ tasks|Break into tasks|recommended")
  else
    options+=("⏳ tasks|Break into tasks|requires plan")
  fi

  # ... etc

  # Show menu with AskUserQuestion
  ask_user_question_menu "${options[@]}"
}
```

**Phase Detection** (`.flow/scripts/detect-phase.sh`):
```bash
detect_current_phase() {
  local feature_dir=$(get_current_feature_dir)

  if [ ! -f "$feature_dir/spec.md" ]; then
    echo "init"
  elif [ ! -f "$feature_dir/plan.md" ]; then
    echo "specify"
  elif [ ! -f "$feature_dir/tasks.md" ]; then
    echo "plan"
  else
    # Check task completion
    local completed=$(grep -c "\\[x\\]" "$feature_dir/tasks.md" || echo 0)
    local total=$(grep -c "\\[ \\]\\|\\[x\\]" "$feature_dir/tasks.md" || echo 0)

    if [ $completed -lt $total ]; then
      echo "implement"
    else
      echo "complete"
    fi
  fi
}
```

---

### Component 5: Output Formatting System

**Purpose**: Consistent, visually distinct output with TLDR and Next Steps

**Format Template**:
```markdown
## ✅ [Action] Successful

───────────────────────────────────────
📦 TLDR
───────────────────────────────────────
• Key point 1
• Key point 2
• Key point 3
───────────────────────────────────────

## 📂 Details
[Detailed information...]

───────────────────────────────────────
🚀 NEXT STEPS
───────────────────────────────────────
1. First action:
   /command-here

2. Second action:
   /another-command

3. Check status:
   /status
───────────────────────────────────────
```

**Implementation** (`.flow/scripts/format-output.sh`):
```bash
format_tldr() {
  local content="$1"
  cat <<EOF
───────────────────────────────────────
📦 TLDR
───────────────────────────────────────
$content
───────────────────────────────────────
EOF
}

format_next_steps() {
  local steps="$1"
  cat <<EOF
───────────────────────────────────────
🚀 NEXT STEPS
───────────────────────────────────────
$steps
───────────────────────────────────────
EOF
}

format_section_separator() {
  echo "───────────────────────────────────────"
}
```

**Usage in Skills**:
```bash
# In flow:init
show_init_success() {
  cat <<EOF
## ✅ Flow Initialized Successfully

$(format_tldr "• Flow structure created at .flow/
• Configuration saved
• Ready for first feature")

## 📂 What Was Created
- .flow/config/flow.json
- .flow/state/
- .flow/memory/
[...]

$(format_next_steps "1. Create your first feature:
   /flow specify \"Your feature\"

2. Check status:
   /flow status")
EOF
}
```

---

### Component 6: CLAUDE.md Optimization

**Purpose**: Reduce token usage with progressive disclosure

**Root CLAUDE.md** (~30 lines):
```markdown
# Project Name

[Existing project description...]

## Flow Workflow

This project uses Flow for specification-driven development.

**Quick Commands**:
- `/flow` - Interactive menu with smart navigation
- `/flow specify "Feature"` - Create feature spec
- `/flow plan` - Create technical plan
- `/flow implement` - Execute implementation
- `/status` - Check current progress

**Documentation**: [Full Flow docs](.flow/docs/CLAUDE-FLOW.md)

[Rest of project documentation...]
```

**Detailed Docs** (`.flow/docs/CLAUDE-FLOW.md`):
```markdown
# Flow Documentation

Complete documentation for Flow workflow system.

## Directory Structure
[Full structure...]

## Commands Reference
[All commands with examples...]

## Integration Guide
[JIRA/Confluence setup...]

## Troubleshooting
[Common issues...]
```

**Benefits**:
- Root CLAUDE.md: ~500 tokens (down from ~2000)
- Details loaded only when needed
- 75% token reduction for common operations

---

## Implementation Phases

### Phase 1: Directory Restructuring & Config (4-5 hours)

**Goal**: Establish new structure and configuration system

**Tasks**:
1. Create `.flow/scripts/` utility functions
   - `config.sh` - Config management
   - `common-v2.sh` - Enhanced utilities
   - `format-output.sh` - Output formatting

2. Implement directory restructuring
   - Create new `.flow/` subdirectories
   - Move existing files (`.flow-state/`, `.flow-memory/`, `features/`)
   - Verify all files moved correctly

3. Implement configuration system
   - JSON schema design
   - Config read/write functions
   - Validation logic
   - Default template

4. Update `.gitignore`
   - Remove old paths (`.flow-state/`, `.flow-memory/`, `features/`)
   - Add new path (`.flow/state/`)

**Deliverables**:
- New directory structure in place
- Configuration system working
- Scripts library functional
- .gitignore updated

**Testing**:
- Verify all files accessible at new paths
- Test config read/write operations
- Validate .gitignore rules

---

### Phase 2: Interactive Init & Command Updates (3-4 hours)

**Goal**: Implement interactive init and update all commands

**Tasks**:
1. Update `flow:init` skill
   - Add AskUserQuestion prompts
   - Integrate config system
   - Add CLI argument support
   - Enhanced output formatting

2. Update all path references
   - Update all skills (8 skills × 15 min = 2 hours)
   - Update all commands (8 commands × 10 min = 1.5 hours)
   - Update templates (3 templates × 10 min = 30 min)

3. Test end-to-end
   - Run `/flow-init` with prompts
   - Verify config created correctly
   - Test all commands with new paths

**Deliverables**:
- Interactive init working
- All skills/commands use new paths
- Config system integrated

**Testing**:
- Interactive init flow
- CLI argument override
- Path resolution in all commands

---

### Phase 3: Unified /flow Command (2-3 hours)

**Goal**: Implement unified command with routing

**Tasks**:
1. Create routing system
   - `routing.sh` - Command routing
   - `detect-phase.sh` - Phase detection
   - `render-menu.sh` - Menu rendering

2. Create unified command
   - `.claude/commands/flow.md`
   - Argument parsing
   - Menu integration
   - Routing logic

3. Implement phase detection
   - File existence checks
   - Task completion analysis
   - Recommendation logic

4. Test routing
   - Test interactive menu
   - Test direct subcommands
   - Test phase detection
   - Test backward compatibility

**Deliverables**:
- `/flow` command working
- Interactive menu functional
- Routing to all subcommands
- Phase detection accurate

**Testing**:
- `/flow` shows correct menu
- `/flow plan` routes correctly
- Phase detection accurate
- Backward compat maintained

---

### Phase 4: Documentation & UX Polish (2-3 hours)

**Goal**: Optimize documentation and enhance UX

**Tasks**:
1. Update CLAUDE.md
   - Create concise root section (~30 lines)
   - Move details to `.flow/docs/CLAUDE-FLOW.md`
   - Add links and references

2. Create detailed documentation
   - `.flow/docs/CLAUDE-FLOW.md` - Full instructions
   - `.flow/docs/COMMANDS.md` - Command reference
   - `.flow/docs/ARCHITECTURE.md` - Architecture details

3. Apply output formatting
   - Update all skills to use formatting functions
   - Add TLDR sections
   - Add Next Steps sections
   - Consistent separators

4. Final testing
   - End-to-end workflow test
   - Token usage measurement
   - User experience validation

**Deliverables**:
- Optimized CLAUDE.md
- Complete detailed documentation
- Enhanced output formatting
- Validated token reduction

**Testing**:
- Measure token usage (before/after)
- Full workflow: init → specify → plan → tasks → implement
- Verify documentation accuracy

---

## Testing Strategy

### Unit Testing

**Config System**:
- Test config creation with defaults
- Test config read/write operations
- Test validation (valid/invalid JSON)
- Test error handling (missing file, permissions)

**Phase Detection**:
- Test each phase detection scenario
- Test edge cases (empty files, missing dirs)
- Test task completion calculation

**Routing**:
- Test argument parsing
- Test subcommand routing
- Test menu rendering
- Test error handling (invalid commands)

**Output Formatting**:
- Test TLDR formatting
- Test Next Steps formatting
- Test separators and emojis

### Integration Testing

**Directory Restructuring**:
- Create old structure
- Run restructuring
- Verify all files moved
- Verify paths work

**Interactive Init**:
- Test with prompts (all options)
- Test with CLI args
- Test validation (valid/invalid inputs)
- Verify config created correctly

**Unified Command**:
- Test interactive menu (each phase)
- Test direct subcommands (all commands)
- Test phase detection (all phases)
- Test backward compatibility

**End-to-End Workflow**:
```bash
# Test complete workflow
/flow init                  # Interactive prompts
/flow specify "Test"        # Create spec
/flow plan                  # Create plan
/flow tasks                 # Create tasks
/flow implement             # Execute
/flow validate              # Validate
/flow status                # Check status
```

### Performance Testing

**Token Usage**:
- Measure before: `/flow-init` token count
- Measure after: `/flow init` token count
- Target: 50%+ reduction
- Document results

**Execution Time**:
- Init time: < 5 seconds
- Command routing: < 100ms
- Phase detection: < 50ms
- Config operations: < 10ms

---

## Error Handling

### Config Errors

**Missing Config File**:
```
Error: Flow configuration not found

This usually means Flow is not initialized.

Run: /flow init
```

**Invalid JSON**:
```
Error: Invalid Flow configuration

The .flow/config/flow.json file contains invalid JSON.

Fix: Edit .flow/config/flow.json or delete and reinitialize
```

**Permission Errors**:
```
Error: Cannot write to .flow/config/flow.json

Check file permissions and try again.
```

### Routing Errors

**Unknown Subcommand**:
```
Error: Unknown subcommand: 'foo'

Available commands:
  init, specify, plan, tasks, implement, validate, status, help

Run /flow for interactive menu
```

**Command Out of Order**:
```
Warning: Recommended to run /flow plan first

Current phase: specify (completed)
Next step: plan

Continue anyway? (Yes/No)
```

### Initialization Errors

**Already Initialized**:
```
Error: Flow already initialized

Configuration exists at .flow/config/flow.json

To reconfigure: /flow-update
To start fresh: Delete .flow/ and reinitialize
```

**Invalid Project Type**:
```
Error: Invalid project type: 'invalid'

Valid options: greenfield, brownfield
```

---

## Performance Considerations

### Token Optimization

**Root CLAUDE.md**:
- Current: ~2000 tokens
- Target: ~500 tokens
- Reduction: 75%

**Init Command**:
- Current: ~3000 tokens (verbose instructions)
- Target: ~1000 tokens (brief + on-demand details)
- Reduction: 67%

**Average Command**:
- Current: ~1500 tokens
- Target: ~600 tokens
- Reduction: 60%

**Overall Target**: 50%+ reduction across all operations

### Execution Performance

**Init**:
- Directory creation: < 100ms
- Config creation: < 50ms
- File operations: < 200ms
- Total: < 5 seconds (including prompts)

**Routing**:
- Argument parsing: < 10ms
- Phase detection: < 50ms
- Menu rendering: < 20ms
- Total: < 100ms

**Config Operations**:
- Read: < 5ms
- Write: < 10ms
- Validate: < 5ms

---

## Security Considerations

### Config File Security

**Sensitive Data**:
- JIRA project keys are not sensitive (public identifiers)
- Confluence page IDs are not sensitive (public identifiers)
- No passwords or tokens stored
- Config can be committed to git

**Validation**:
- Validate all user inputs
- Prevent path traversal
- Sanitize config values
- Check file permissions

### Script Security

**Path Handling**:
- Always use absolute paths
- Validate file existence before operations
- Check permissions before write
- Prevent directory traversal

**Input Validation**:
- Validate JIRA key format
- Validate Confluence page ID (numeric only)
- Sanitize all user inputs
- Reject malicious patterns

---

## Monitoring & Observability

### Token Usage Tracking (P3)

**Log Format** (`.flow/state/token-usage.log`):
```
2025-10-28T17:00:00Z,flow:init,1200,success
2025-10-28T17:05:00Z,flow:specify,800,success
2025-10-28T17:10:00Z,flow:plan,950,success
```

**Metrics**:
- Token count per operation
- Success/failure rate
- Execution time
- Trend analysis

**Reporting**:
```bash
/flow-metrics --tokens
# Shows token usage breakdown
# Identifies high-token operations
# Suggests optimizations
```

### Validation Metrics

**Validation Success Rate**:
- Track validation runs
- Success vs. failure rate
- Common error types
- Time to fix issues

---

## Rollback Plan

### If Issues Arise

**Immediate Rollback**:
1. Keep old `/flow-*` commands working (backward compatibility)
2. If unified command fails, users can use old commands
3. Config system is additive (doesn't break existing)

**Full Rollback**:
1. Restore files from git (before restructuring)
2. Remove `.flow/` directory
3. Restore old structure (`.flow-state/`, `.flow-memory/`, `features/`)
4. Revert CLAUDE.md changes

**Prevention**:
- Extensive testing before deployment
- Gradual rollout (test in marketplace first)
- Document rollback procedure
- Keep backups during restructuring

---

## Technical Risks

### Risk 1: Path Reference Updates

**Risk**: Missing a path reference could break a command
**Probability**: Medium
**Impact**: High (command failure)

**Mitigation**:
- Comprehensive grep for all path references
- Automated testing of all commands
- Checklist of files to update
- Verify each command after update

### Risk 2: jq Availability

**Risk**: `jq` might not be available on user's system
**Probability**: Low (widely available)
**Impact**: Medium (config system fails)

**Mitigation**:
- Check `jq` availability on init
- Provide fallback (simple grep/sed parsing)
- Clear error message if missing
- Document `jq` as dependency

### Risk 3: AskUserQuestion Reliability

**Risk**: AskUserQuestion might fail or have bugs
**Probability**: Low
**Impact**: Medium (init fails, but has fallback)

**Mitigation**:
- Provide CLI argument fallback
- Test extensively
- Handle errors gracefully
- Document non-interactive mode

### Risk 4: Token Usage Doesn't Improve

**Risk**: Token optimization might not achieve 50% reduction
**Probability**: Low (based on analysis)
**Impact**: Low (still improvements in UX)

**Mitigation**:
- Measure token usage before implementation
- Track during implementation
- Iterate on optimization
- Document actual savings

---

## Open Questions

**Q1: Should we support Python-based config parsing as jq fallback?**
- Python is more universally available than jq
- Could use `python3 -c 'import json; ...'`
- More portable but slower
→ **Decision**: Start with jq, add Python fallback if users report jq missing

**Q2: Should backward compatibility with `/flow-*` be permanent or deprecated?**
- Permanent: easier for users, more maintenance
- Deprecated: cleaner long-term, requires migration
→ **Decision**: Keep for 6 months, then deprecate with warnings

**Q3: Should config support environment variables for CI/CD?**
- Useful for automated testing
- Could override config values
- Pattern: `FLOW_JIRA_PROJECT_KEY` overrides config
→ **Decision**: Add in v2.1 if requested by users

---

## Implementation Checklist

### Phase 1: Restructuring
- [ ] Create `.flow/scripts/config.sh`
- [ ] Create `.flow/scripts/format-output.sh`
- [ ] Implement directory restructuring
- [ ] Move all existing files
- [ ] Update `.gitignore`
- [ ] Test file accessibility

### Phase 2: Interactive Init
- [ ] Update `flow:init` with prompts
- [ ] Implement config system
- [ ] Add CLI argument support
- [ ] Update all skills (8 skills)
- [ ] Update all commands (8 commands)
- [ ] Update templates (3 templates)
- [ ] Test end-to-end

### Phase 3: Unified Command
- [ ] Create `routing.sh`
- [ ] Create `detect-phase.sh`
- [ ] Create `render-menu.sh`
- [ ] Create `.claude/commands/flow.md`
- [ ] Test interactive menu
- [ ] Test direct subcommands
- [ ] Test phase detection
- [ ] Test backward compatibility

### Phase 4: Documentation
- [ ] Update root CLAUDE.md (concise)
- [ ] Create `.flow/docs/CLAUDE-FLOW.md`
- [ ] Create `.flow/docs/COMMANDS.md`
- [ ] Create `.flow/docs/ARCHITECTURE.md`
- [ ] Apply output formatting to all skills
- [ ] Measure token usage (before/after)
- [ ] Final end-to-end test

---

## Success Criteria

### Functional Requirements
- ✅ All Flow artifacts under `.flow/` directory
- ✅ Interactive init with prompts working
- ✅ Config stored in `.flow/config/flow.json`
- ✅ Unified `/flow` command routing correctly
- ✅ Phase detection accurate
- ✅ All commands work with new paths
- ✅ Backward compatibility maintained

### Non-Functional Requirements
- ✅ Token usage reduced by 50%+
- ✅ Init completes in < 5 seconds
- ✅ Command routing in < 100ms
- ✅ CLAUDE.md under 50 lines for Flow section
- ✅ Config operations in < 10ms

### User Experience
- ✅ Users find init intuitive (prompt-based)
- ✅ Users can navigate workflow without docs (menu-based)
- ✅ Output is scannable (TLDR, Next Steps)
- ✅ Error messages are actionable

---

## Next Steps

**After plan approval:**

1. **Break into tasks**:
   ```bash
   /flow-tasks
   ```

2. **Start implementation**:
   ```bash
   /flow-implement
   ```

3. **Track progress**:
   ```bash
   /status
   ```

---

**Plan Status**: Ready for task breakdown
**Estimated Effort**: 10-14 hours
**Implementation Phases**: 4 phases
**Technical Decisions**: 6 ADRs documented
