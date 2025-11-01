# Technical Plan: Plugin Stabilization

**Feature**: 001-plugin-stabilization
**Created**: 2024-10-30
**Status**: Planning

## Executive Summary

Systematically commit 393 changed files from the Navi→Spec refactor, organizing them into logical, atomic commits that maintain a clean git history and ensure no broken intermediate states.

## Technical Analysis

### Current State Assessment

**Git Status Summary**:
- **Total Changes**: 393 files
- **Deletions**: ~280 files (old Flow/Navi structure)
- **Additions**: ~100 files (new Spec structure)
- **Modifications**: ~13 files (configs and docs)

**Key Changes Identified**:
1. Complete removal of old naming (Flow/Navi)
2. New Spec plugin structure with 👻 branding
3. Optimized templates (66% size reduction)
4. New state management system
5. Comprehensive documentation

### Architecture Decisions

#### ADR-001: Commit Strategy
**Decision**: Use logical grouping over chronological commits
**Rationale**: Creates cleaner history, easier to review
**Approach**: Group by functionality, not by time

#### ADR-002: State File Handling
**Decision**: Commit templates, not active state files
**Rationale**: State files are instance-specific
**Implementation**: Ensure .gitignore properly configured

#### ADR-003: Documentation Updates
**Decision**: Update docs in same commit as related code
**Rationale**: Keeps documentation synchronized
**Trade-off**: Slightly larger commits

## Implementation Design

### Phase 1: Preparation (30 minutes)

#### 1.1 Backup Current State
```bash
# Create safety backup
cp -r . ../spec-backup-$(date +%Y%m%d)

# Create feature branch
git checkout -b feat/spec-refactor-stabilization
```

#### 1.2 Validate Structure
- Verify all new files are present
- Confirm old files are properly removed
- Check for any missed renames

### Phase 2: Commit Organization (2 hours)

#### 2.1 Commit 1: Remove Legacy Structure
**Files**: All deletions (~280 files)
**Message**:
```
feat: Remove legacy Flow/Navi structure

- Remove old __specification__ directory
- Remove previous .flow configurations
- Remove flow/navi commands and skills
- Remove backup directories
- Clean up obsolete documentation

Part of complete Navi→Spec migration
```

#### 2.2 Commit 2: Core Spec Structure
**Files**:
- `.spec/` directory (docs, scripts, config)
- `.spec-state/` and `.spec-memory/` templates
- Core configuration files

**Message**:
```
feat: Add Spec core structure and configuration

- Add .spec/ with docs, scripts, and config
- Add state and memory template structures
- Add workflow configuration
- Implement dual-layer state management

Establishes foundation for v2.1.0
```

#### 2.3 Commit 3: Skills and Commands
**Files**:
- `.claude/skills/` (14 skills)
- `.claude/commands/` (8 commands)
- `.claude/hooks/`

**Message**:
```
feat: Add Spec skills, commands, and integrations

- Add 14 optimized skills with progressive disclosure
- Add 8 streamlined commands with 👻 branding
- Add hook system for automation
- Include validation scripts

Token usage optimized by 66%
```

#### 2.4 Commit 4: Templates and Agents
**Files**:
- `templates/` directory
- `.claude/agents/`

**Message**:
```
feat: Add optimized templates and specialized agents

- Add v2.0 templates (66% size reduction)
- Add 3 specialized agents
- Include shared standards
- Optimize for context efficiency
```

#### 2.5 Commit 5: Documentation
**Files**:
- `README.md`
- `CLAUDE.md`
- Root documentation updates

**Message**:
```
docs: Update documentation for Spec v2.1.0

- Complete README with Spec branding
- Add CLAUDE.md plugin instructions
- Update marketplace metadata
- Include migration notes

Documentation coverage: 90%
```

#### 2.6 Commit 6: Configuration Fixes
**Files**:
- `.gitignore` updates
- `marketplace.json`
- `.mcp.json`

**Message**:
```
fix: Update configuration and marketplace metadata

- Fix .gitignore conflicts
- Update marketplace.json for v2.1.0
- Add MCP placeholder configuration
- Resolve directory structure issues
```

#### 2.7 Commit 7: Feature Tracking
**Files**:
- `features/001-plugin-stabilization/`
- Session and memory updates

**Message**:
```
feat: Initialize Spec workflow for plugin development

- Add first feature specification
- Initialize session and memory tracking
- Document architecture decisions
- Meta approach: Spec managing Spec

🤖 Co-authored-by: Claude <claude@anthropic.com>
```

### Phase 3: Validation (1 hour)

#### 3.1 Pre-commit Checks
```bash
# Verify no files missed
git status

# Check each commit builds
git rebase -i --exec "ls -la .claude/skills" HEAD~7

# Validate plugin structure
./scripts/validate.sh
```

#### 3.2 Installation Test
```bash
# Test local installation
/plugin install ./plugins/spec

# Test commands
/status
/help

# Test a skill
/spec-init test-project
```

#### 3.3 Documentation Review
- Verify all Navi references removed
- Confirm examples work
- Check command documentation

### Phase 4: Finalization (30 minutes)

#### 4.1 Merge Strategy
```bash
# Squash if needed for cleaner history
git rebase -i main

# Create pull request
gh pr create --title "feat: Spec v2.1.0 - Complete refactor"

# Or direct merge if authorized
git checkout main
git merge feat/spec-refactor-stabilization
```

#### 4.2 Post-commit Tasks
- Tag release v2.1.0
- Update marketplace listing
- Announce to users
- Archive backup

## Risk Mitigation

### Risk Matrix

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Lost work | Low | High | Create backup first |
| Broken commits | Medium | Medium | Test each commit |
| Missing files | Medium | Low | Validate thoroughly |
| Merge conflicts | Low | Medium | Work from feature branch |

### Rollback Plan
```bash
# If issues arise
git reset --hard HEAD~7
git checkout main

# Restore from backup
cp -r ../spec-backup-$(date +%Y%m%d)/* .
```

## Testing Strategy

### Unit Tests
- Each skill triggers correctly
- Commands parse arguments
- State files update properly

### Integration Tests
- Complete workflow execution
- Session persistence
- Memory tracking

### User Acceptance Tests
- Install from marketplace
- Execute example workflow
- Validate documentation

## Success Metrics

### Quantitative
- ✅ All 393 files properly committed
- ✅ Zero git conflicts
- ✅ Plugin installs successfully
- ✅ All commands functional

### Qualitative
- ✅ Clean, understandable git history
- ✅ No broken intermediate states
- ✅ Documentation accurate
- ✅ User-friendly structure

## Timeline

| Phase | Duration | Start | End |
|-------|----------|-------|-----|
| Preparation | 30 min | 09:00 | 09:30 |
| Commits | 2 hours | 09:30 | 11:30 |
| Validation | 1 hour | 11:30 | 12:30 |
| Finalization | 30 min | 12:30 | 13:00 |

**Total: 4 hours**

## Next Steps

After successful completion:
1. Publish to marketplace
2. Monitor for user issues
3. Plan v2.2.0 features
4. Gather feedback

---

*Generated by Spec Workflow System*
*Technical Plan Version: 1.0*