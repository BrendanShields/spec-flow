# Feature Specification: Flow Init Optimization & Restructuring

**Feature ID**: 001-flow-init-optimization
**Created**: 2025-10-28
**Status**: draft
**Owner**: Development Team
**Priority**: P1 (Critical - Architecture Change)

## Overview

Optimize Flow's initialization process and directory structure for token efficiency, better user experience, and improved organization. Consolidate all Flow artifacts under `.flow/` directory, add interactive prompts for configuration, and enhance output formatting. This is a fresh implementation without backward compatibility concerns.

## User Stories

### P1 (Must Have) - Core Restructuring

#### US1: Consolidated Directory Structure
**As a** Flow user
**I want** all Flow artifacts consolidated under `.flow/`
**So that** my project root stays clean and Flow files are organized

**Acceptance Criteria**:
- [ ] All Flow directories created under `.flow/` (memory, state, features)
- [ ] New structure: `.flow/{memory,state,features,config,templates,scripts,docs}/`
- [ ] .gitignore updated to reflect new structure
- [ ] All Flow skills/commands use new paths
- [ ] Existing marketplace root installation updated to new structure

**Technical Notes**:
- Clean slate implementation (no backward compatibility needed)
- Update all path references in skills, commands, and templates
- Current installation will be updated as part of this feature

---

#### US2: Interactive Init with User Prompts
**As a** developer initializing Flow
**I want** to be prompted for project type and integrations
**So that** Flow is configured correctly without reading documentation

**Acceptance Criteria**:
- [ ] Prompt 1: "Project type?" → Greenfield / Brownfield
- [ ] Prompt 2: "Enable JIRA integration?" → Yes / No
- [ ] Prompt 3 (if JIRA=Yes): "JIRA Project Key?" → Text input
- [ ] Prompt 4: "Enable Confluence integration?" → Yes / No
- [ ] Prompt 5 (if Confluence=Yes): "Confluence Root Page ID?" → Text input
- [ ] Responses stored in `.flow/config/flow.json`
- [ ] Skip prompts with CLI args: `--type=greenfield --jira=PROJ-123`

**Technical Notes**:
- Use Claude's AskUserQuestion tool for interactive prompts
- Validate inputs (JIRA key format, numeric page ID)
- Store config as JSON for easy parsing
- Default values if skipped: type=brownfield, integrations=disabled

---

#### US3: Token-Efficient CLAUDE.md Integration
**As a** Flow user
**I want** a concise Flow section in root CLAUDE.md
**So that** Claude loads only essential context, with details on-demand

**Acceptance Criteria**:
- [ ] Root CLAUDE.md prepended with 20-30 line Flow section
- [ ] Section links to `.flow/docs/CLAUDE-FLOW.md` for full details
- [ ] Section includes: workflow overview, quick commands, status check
- [ ] Detailed docs in `.flow/docs/` loaded only when needed
- [ ] Progressive disclosure pattern: brief → detailed as needed

**Technical Notes**:
- Keep root CLAUDE.md under 50 lines for Flow section
- Use markdown links: `[Full Details](.flow/docs/CLAUDE-FLOW.md)`
- Split current verbose instructions into modular docs
- Reference: Flow plugin's own structure as template

---

#### US4: Configuration File Management
**As a** Flow system
**I want** to store configuration in structured JSON
**So that** settings are easily readable by scripts and skills

**Acceptance Criteria**:
- [ ] Config stored at `.flow/config/flow.json`
- [ ] Schema: `{project_type, jira: {enabled, project_key}, confluence: {enabled, root_page_id}}`
- [ ] Scripts can source config with `jq` or similar
- [ ] Config validation on init and read operations
- [ ] Human-readable format with comments (JSON5 or annotated)

**Technical Notes**:
- Consider JSON5 for comments, fallback to JSON
- Provide bash function: `get_flow_config KEY`
- Validate on write: check required fields
- Default config template in templates directory

---

#### US5: Unified /flow Command with Smart Navigation
**As a** Flow user
**I want** a single `/flow` command that guides me through the workflow
**So that** I don't need to memorize individual commands and know what to do next

**Acceptance Criteria**:
- [ ] `/flow` with no arguments shows multi-select menu of available actions
- [ ] Menu highlights the suggested next step based on current workflow phase
- [ ] `/flow <subcommand>` executes directly (e.g., `/flow plan`, `/flow specify`)
- [ ] Menu shows: init, specify, plan, tasks, implement, validate, status, help
- [ ] Current phase marked with indicator (e.g., ✅ Done, ➡️ Next, ⏳ Not Ready)
- [ ] Consolidates existing commands under one namespace

**Example Menu**:
```
What would you like to do?

Workflow Commands:
  ✅ init       - Initialize Flow (completed)
  ✅ specify    - Create feature specification (completed)
➡️ plan       - Create technical plan (recommended next)
  ⏳ tasks      - Break into implementation tasks (requires plan)
  ⏳ implement  - Execute implementation (requires tasks)

Utility Commands:
  validate    - Check workflow consistency
  status      - Show current progress
  help        - Get context-aware help
```

**Subcommand Aliases**:
```bash
/flow init              # Same as /flow-init
/flow specify "Feature" # Same as /flow-specify "Feature"
/flow plan              # Same as /flow-plan
/flow tasks             # Same as /flow-tasks
/flow implement         # Same as /flow-implement
/flow validate          # Same as /flow-validate
/flow status            # Same as /status
/flow help              # Same as /help
```

**Technical Notes**:
- Use AskUserQuestion for multi-select menu
- Detect current phase from `.flow/state/current-session.md`
- Maintain backward compatibility with individual `/flow-*` commands
- Single command file that routes to appropriate skill
- Smart defaults: suggest next logical step based on progress

---

### P2 (Should Have) - Enhanced UX

#### US6: Enhanced Output Formatting
**As a** Flow user
**I want** visually distinct sections in command output
**So that** I can quickly identify next steps and TLDR sections

**Acceptance Criteria**:
- [ ] TLDR section uses markdown box formatting
- [ ] Next steps section uses numbered list with bold headers
- [ ] Color/emoji indicators: ✅ Success, ⚠️ Warning, ❌ Error
- [ ] Horizontal rules (---) separate major sections
- [ ] Summary boxes for key information

**Example Format**:
```markdown
## ✅ Flow Initialized Successfully

───────────────────────────────────────
📦 TLDR
───────────────────────────────────────
• All Flow files in .flow/ directory
• Config saved to .flow/config/flow.json
• Ready for first feature specification
───────────────────────────────────────

## 📂 What Was Created
[details...]

───────────────────────────────────────
🚀 NEXT STEPS
───────────────────────────────────────
1. Create your first feature:
   /flow-specify "Your feature"

2. Check status anytime:
   /status

3. Get help:
   /help
───────────────────────────────────────
```

**Technical Notes**:
- Use markdown boxes, bold, and emojis
- Consistent formatting across all Flow commands
- Create shared formatting utilities in scripts

---

### P3 (Nice to Have) - Polish & Future-Proofing

#### US7: Token Usage Analytics
**As a** Flow developer
**I want** to track token usage for each Flow operation
**So that** we can optimize for efficiency

**Acceptance Criteria**:
- [ ] Log token counts for each skill invocation
- [ ] Store in `.flow/state/token-usage.log`
- [ ] `/flow-metrics --tokens` shows usage breakdown
- [ ] Identify high-token operations for optimization

**Technical Notes**:
- Parse Claude's token usage from responses
- Aggregate by skill/command
- Target: keep init under 5K tokens

---

#### US8: Script-Based Consistency
**As a** Flow maintainer
**I want** common operations in reusable bash scripts
**So that** user experience is consistent and maintainable

**Acceptance Criteria**:
- [ ] Common operations extracted to `.flow/scripts/`
- [ ] Scripts: `init.sh`, `validate.sh`, `format-output.sh`
- [ ] Skills call scripts instead of inline bash
- [ ] Scripts have usage documentation
- [ ] Scripts are testable independently

**Technical Notes**:
- Bash functions for reusability
- Error handling and validation
- Exit codes: 0=success, 1=error, 2=warning
- Source common.sh for shared utilities

---

## Non-Functional Requirements

### Performance
- Init process completes in < 5 seconds
- Token usage for init < 10K tokens (stretch: < 5K)
- Validation completes in < 1 second

### Usability
- Interactive prompts are clear and concise
- Defaults are sensible (brownfield, no integrations)
- Error messages are actionable
- Output is scannable (headers, sections, spacing)

### Maintainability
- Directory structure is intuitive and documented
- Scripts are modular and testable
- Configuration is human-readable
- Migration path for future structure changes

### Compatibility
- Works with existing Flow installations
- Backward compatible detection and migration
- Git integration maintained
- MCP server integration preserved

## Constraints

### Technical Constraints
- Must work within Claude Code's file system restrictions
- Bash scripts for portability (macOS, Linux)
- Markdown for all documentation
- JSON for configuration (parseable by bash tools)

### Business Constraints
- Cannot break existing user workflows
- Must provide migration path from current structure
- Documentation must be updated in lockstep

### Time Constraints
- High priority - blocking other Flow improvements
- Target completion: 1-2 development sessions

## Dependencies

### Internal Dependencies
- All Flow skills must be updated for new paths
- All Flow commands must be updated for new paths
- Templates must reflect new structure
- Documentation must be completely rewritten

### External Dependencies
- `jq` or equivalent JSON parser (check availability, provide fallback)
- Git (already required by Flow)
- Bash 4+ features (check compatibility, degrade gracefully)

## Out of Scope

### Explicitly Not Included
- Web-based configuration interface
- GUI for init process
- Automatic JIRA/Confluence credential management
- Plugin system for custom init steps
- Multi-project workspaces

### Future Considerations
- Init templates for different project types
- Custom init workflows (e.g., enterprise vs. solo)
- Init profiles (save/restore configurations)
- Cloud sync for configuration

## Open Questions

**Question 1: Config format**
Should we use JSON5 (with comments) or plain JSON? JSON5 requires additional tooling but improves readability.
→ **Decision**: Start with JSON, add JSON5 if user feedback requests it

**Question 2: JIRA/Confluence validation**
Should we validate JIRA project key / Confluence page ID during init, or lazily on first use?
→ **Decision**: Lazy validation (faster init, handles offline scenarios)

**Question 3: Output formatting**
How much visual formatting (emojis, boxes) should we use? Balance between readability and token efficiency.
→ **Decision**: Use sparingly - emojis for status, boxes for TLDR/Next Steps only

## Success Metrics

### Quantitative Metrics
- **Token Reduction**: 50%+ reduction in init token usage
- **Init Time**: < 5 seconds end-to-end
- **User Satisfaction**: > 90% positive feedback on new UX
- **Validation Speed**: < 1 second for standard validation

### Qualitative Metrics
- User feedback: "Init is much clearer now"
- Developer feedback: "Much easier to maintain"
- Documentation: "New structure makes sense"

## Technical Architecture

### Command Structure

**Unified /flow Command**:
```bash
# Interactive menu (no arguments)
/flow
  → Shows multi-select menu with current phase indicators
  → Highlights recommended next step
  → Routes to appropriate skill based on selection

# Direct subcommand execution
/flow init              # Invokes flow:init skill
/flow specify "Feature" # Invokes flow:specify skill
/flow plan              # Invokes flow:plan skill
/flow tasks             # Invokes flow:tasks skill
/flow implement         # Invokes flow:implement skill
/flow validate          # Invokes flow:analyze skill
/flow status            # Shows current state
/flow help              # Context-aware help
```

**Implementation**:
- Single `/flow.md` command file in `.claude/commands/`
- Parses first argument to route to skill or show menu
- Reads `.flow/state/current-session.md` for phase detection
- Uses AskUserQuestion for interactive menu
- Maintains backward compatibility with `/flow-*` commands

**Phase Detection Logic**:
```
If no spec.md: suggest "init" or "specify"
If spec.md exists, no plan.md: suggest "plan"
If plan.md exists, no tasks.md: suggest "tasks"
If tasks.md exists, tasks incomplete: suggest "implement"
If tasks complete: suggest "validate" or next feature
```

### New Directory Structure
```
.flow/                          # All Flow artifacts (replaces root clutter)
├── config/                     # Configuration
│   └── flow.json              # Main config: type, integrations
├── state/                      # Session state (git-ignored)
│   ├── current-session.md
│   ├── checkpoints/
│   └── token-usage.log
├── memory/                     # Persistent memory (committed)
│   ├── WORKFLOW-PROGRESS.md
│   ├── DECISIONS-LOG.md
│   ├── CHANGES-PLANNED.md
│   └── CHANGES-COMPLETED.md
├── features/                   # Feature specs, plans, tasks
│   └── ###-feature-name/
│       ├── spec.md
│       ├── plan.md
│       └── tasks.md
├── templates/                  # Document templates
│   ├── spec-template.md
│   ├── plan-template.md
│   └── tasks-template.md
├── scripts/                    # Utility scripts
│   ├── common.sh
│   ├── init.sh
│   ├── validate.sh
│   ├── migrate.sh
│   └── format-output.sh
├── docs/                       # Detailed documentation
│   ├── CLAUDE-FLOW.md         # Full instructions for Claude
│   ├── ARCHITECTURE.md
│   └── COMMANDS.md
├── product-requirements.md     # Project requirements
└── architecture-blueprint.md   # Project architecture
```

### Config Schema
```json
{
  "version": "2.0",
  "project": {
    "type": "greenfield|brownfield",
    "initialized": "2025-10-28T17:00:00Z"
  },
  "integrations": {
    "jira": {
      "enabled": false,
      "project_key": "PROJ"
    },
    "confluence": {
      "enabled": false,
      "root_page_id": "123456"
    }
  },
  "preferences": {
    "auto_checkpoint": true,
    "validate_on_save": true
  }
}
```

### Implementation Strategy
1. **Move**: Relocate existing files to `.flow/` subdirectories
2. **Update**: Update `.gitignore` and all path references
3. **Verify**: Check all files accessible at new paths
4. **Test**: Validate all commands work with new structure
5. **Document**: Update all documentation with new paths

## Timeline

### Phase 1: Core Restructuring (Session 1)
- **Duration**: 3-4 hours
- **Deliverables**:
  - Restructure existing installation to new `.flow/` layout
  - Updated path references in all skills/commands
  - Updated `.gitignore`
  - Verify all paths work correctly

### Phase 2: Interactive Init & Config (Session 1)
- **Duration**: 2-3 hours
- **Deliverables**:
  - Interactive prompts for project type and integrations
  - Config file creation (`.flow/config/flow.json`)
  - CLI argument support for non-interactive use
  - Config validation utilities

### Phase 3: Documentation & UX (Session 2)
- **Duration**: 2-3 hours
- **Deliverables**:
  - Updated CLAUDE.md (concise version)
  - Detailed docs in `.flow/docs/`
  - Enhanced output formatting
  - Script consolidation

### Phase 4: Testing & Polish (Session 2)
- **Duration**: 1-2 hours
- **Deliverables**:
  - End-to-end testing of new structure
  - Verify all commands work with new paths
  - Documentation review
  - Update plugin Flow installation

**Target Completion**: 2 development sessions (8-12 hours total)

## Implementation Notes

### Critical Path
1. Restructure to `.flow/` directory layout
2. Update all path references in skills/commands
3. Add interactive init prompts
4. Create config file management
5. Update documentation for token efficiency
6. Test end-to-end with new structure

### Risk Mitigation
- **Risk**: Breaking current marketplace installation
  - **Mitigation**: Careful testing, verify all paths work
- **Risk**: Token usage increases
  - **Mitigation**: Measure before/after, optimize, use progressive disclosure
- **Risk**: User confusion with new structure
  - **Mitigation**: Clear documentation, enhanced output formatting

### Testing Strategy
- Unit test new directory structure creation
- Integration test full init → specify → implement flow
- Verify all skills/commands work with new paths
- Performance test token usage and execution time
- Test both interactive and non-interactive init modes

---

## 📋 TLDR

**What**: Restructure Flow to consolidate all files under `.flow/`, add interactive init prompts, and optimize for token efficiency

**Why**: Cleaner project roots, better UX, easier maintenance, lower token costs

**How**:
1. Move all Flow artifacts under `.flow/` directory
2. Add interactive prompts for project type and integrations
3. Create unified `/flow` command with smart navigation
4. Store config in `.flow/config/flow.json`
5. Simplify CLAUDE.md, move details to `.flow/docs/`
6. Enhanced output formatting with TLDR and Next Steps sections

**Impact**:
- ✅ 50%+ token reduction
- ✅ Cleaner project structure
- ✅ Better user experience
- ✅ Easier to maintain

---

## 🚀 Next Steps

**After spec approval:**

1. **Create technical plan**:
   ```bash
   /flow-plan
   ```

2. **Break into tasks**:
   ```bash
   /flow-tasks
   ```

3. **Start implementation**:
   ```bash
   /flow-implement
   ```

4. **Check progress**:
   ```bash
   /status
   ```

---

**Status**: Ready for planning phase
**Estimated Effort**: 10-14 hours (2 sessions)
**User Stories**: 8 total (P1: 5, P2: 2, P3: 2)
**Priority**: P1 (Critical)
