# Changelog

All notable changes to the Spec Workflow Plugin.

## [3.3.0] - 2025-11-03

### 🎉 Major Release - Interactive Workflow System

This release represents a comprehensive refactoring of the Spec plugin, transitioning from individual commands to a unified, menu-driven interface.

### Added

#### Interactive Menu System
- **Context-aware menus** with 6 workflow states (NOT_INITIALIZED, NO_FEATURE, IN_SPECIFICATION, IN_PLANNING, IN_IMPLEMENTATION, COMPLETE)
- **Single command interface** (`/workflow:spec`) replacing 14 individual commands
- **Help mode** with context-specific assistance and "Ask a Question" feature
- **State detection logic** automatically determines current workflow phase

#### State Management
- **5 state file templates** for consistent initialization:
  - `current-session.md` - Session tracking (88 lines)
  - `WORKFLOW-PROGRESS.md` - Feature metrics (88 lines)
  - `DECISIONS-LOG.md` - Architecture decision records (90 lines)
  - `CHANGES-PLANNED.md` - Pending tasks (90 lines)
  - `CHANGES-COMPLETED.md` - Completion audit trail (91 lines)
- **Dual-layer state management**: Session state (git-ignored) + Memory state (committed)
- **Template system** with placeholder replacement ({timestamp}, {date}, {uuid}, etc.)

#### Auto Mode
- **One-click workflow automation** from specification to implementation
- **Checkpoint system** between phases (continue/refine/review/exit options)
- **Delegation to orchestrate skill** for comprehensive workflow execution
- **Resume capability** from any workflow phase

#### Configuration
- **Auto-generated config** (`.spec/.spec-config.yml`) with smart project detection
- **Path customization** for spec_root, features, state, memory
- **Variable interpolation** in config paths
- **Smart hook auto-detection** for linters, type checkers, test runners

### Changed

#### Command Consolidation
- **Unified interface**: All workflow operations now via `/workflow:spec`
- **Removed 14 individual commands**: `/spec-init`, `/spec-generate`, `/spec-plan`, etc.
- **New tracking command**: `/workflow:track` for metrics and maintenance

#### Documentation
- **Complete rewrite** of quick-start.md (485 → 605 lines)
- **Updated 54 files** with correct command syntax
- **Removed all deprecated references** to old command structure
- **Updated internal terminology** from "spec:" to "phase" naming

#### Architecture
- **Command → Skill delegation**: Commands now delegate to workflow skill
- **Progressive disclosure**: 3-tier lazy loading (guide → examples → reference)
- **Cleaner separation of concerns**: State detection in skill, execution in guides
- **Removed redundant operations**: 4 redundant state reads eliminated

### Optimized

#### Token Reduction
- **25,202 tokens saved** (22% reduction from 115K baseline)
- **Deleted blueprint/examples.md**: 3,461 lines, ~19,527 tokens
- **Trimmed orchestrate/examples.md**: 957 lines, ~5,475 tokens
- **Removed redundant state reads**: ~200 tokens

### Fixed

#### Critical Bugs
- **100% error rate for new users**: All deprecated command references removed
- **Missing state templates**: Created 5 complete templates with proper structure
- **Inconsistent documentation**: Unified all references to current system
- **Broken navigation**: Fixed all guide cross-references

### Tested

#### Comprehensive Validation
- ✅ **Test 1**: First-time user initialization flow
- ✅ **Test 2**: Full workflow (auto mode) end-to-end
- ✅ **Test 3**: Resume mid-workflow capability
- ✅ **Test 4**: All 6 menu state transitions
- ✅ **Test 5**: Help mode functionality
- **100% pass rate** (5/5 critical scenarios)

### Migration Guide

#### For Users Upgrading from v3.2

**Old Commands → New Interface**:
```bash
# Before v3.3
/spec-init
/spec-generate "feature description"
/spec-plan
/spec-tasks
/spec-implement

# After v3.3 (Interactive)
/workflow:spec
# Select from menu:
# 🚀 Initialize Project → Auto Mode → (follow prompts)

# Or (Direct)
/workflow:spec
# Select: 🚀 Auto Mode
# Answer questions about your feature
```

**State Files**:
- v3.2 state files are compatible
- New installations use templates from `.claude/skills/workflow/templates/state/`
- Existing `.spec/` directories work without changes

**Configuration**:
- v3.3 auto-generates `.spec/.spec-config.yml` if missing
- Old configs continue to work
- New config format supports variable interpolation

### Breaking Changes

- **Command removal**: All `/spec-*` commands removed (use `/workflow:spec` menu)
- **Skill name changes**: Internal `spec:*` skills renamed to "phase" terminology (doesn't affect users)

### Deprecated

- Individual spec commands (removed in v3.3)
- Direct skill invocation via old names (use menu interface)

### Performance

- **22% token reduction** improves context efficiency
- **Lazy loading** via progressive disclosure reduces initial load
- **Cached state detection** avoids redundant reads

### Developer Notes

#### Files Modified (68 total)
- **Documentation**: 54 files updated
- **Templates**: 5 files created
- **Core workflow**: 9 files updated
- **Commands**: 2 files updated

#### Architectural Improvements
- Clear delegation pattern (Command → Skill → Phase guides)
- Single source of truth for state management
- No code duplication across guides
- Testable execution paths

---

## [3.2.0] - 2024-10-15

### Added
- Multi-agent coordination (6 strategies)
- TDD mode with 3 enforcement levels
- External integrations (JIRA, Confluence)
- Parallel task execution in implement phase

### Changed
- Enhanced orchestration with dependency resolution
- Improved spec generation with WebSearch
- Better error recovery in implement phase

---

## [3.1.0] - 2024-09-01

### Added
- Initial release of Spec workflow plugin
- 14 individual commands for workflow phases
- Basic state management
- Specification generation
- Technical planning
- Task breakdown
- Implementation guidance

---

## Version Schema

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes to user interface or workflow
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, documentation updates

## Support

For issues, feedback, or questions:
- Report bugs via GitHub Issues
- Use `/workflow:spec` → "❓ Get Help" → "Ask a question"
- See README.md for troubleshooting guide
