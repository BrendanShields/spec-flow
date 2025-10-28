# Planned Changes

**Last Updated**: 2025-10-28
**Project**: Spec-Flow Marketplace

## Overview

This file tracks all planned changes that have not yet been implemented. Changes move to `CHANGES-COMPLETED.md` once done.

---

## Planned Changes by Feature

### Feature 001: Flow Init Optimization & Restructuring

**Status**: Task breakdown complete, ready for implementation
**Priority**: P1 (Critical)
**User Stories**: 8 total (P1: 5, P2: 2, P3: 2)
**Tasks**: 22 total (11 parallelizable)
**Estimated Duration**: 10-14 hours

**Implementation Tasks**:
1. Consolidate all Flow directories under `.flow/`
2. Add interactive init prompts (project type, JIRA, Confluence)
3. **NEW**: Create unified `/flow` command with smart navigation menu
4. Create configuration file at `.flow/config/flow.json`
5. Optimize CLAUDE.md for token efficiency
6. Enhanced output formatting with visual sections (TLDR, Next Steps)
7. Script-based consistency for common operations
8. Update all path references in skills/commands

**Changes from Initial Spec**:
- Removed migration tool (fresh implementation, no backward compatibility needed)
- Replaced `/flow-clarify` references with `/flow-validate`
- **NEW**: Added unified `/flow` command (US5) with phase-aware menu
- Updated estimated effort (10-14 hours vs initial 8-14 hours)

**Next Steps**: Run `/flow-plan` to create technical design

---

## Planned Changes by Priority

### P1 (Must Have)

None yet.

### P2 (Should Have)

None yet.

### P3 (Nice to Have)

None yet.

---

## Planned Changes by Category

### New Features

None yet.

### Enhancements

None yet.

### Bug Fixes

None yet.

### Refactoring

None yet.

### Documentation

None yet.

---

## Infrastructure Changes

None yet.

---

## Dependencies

None yet.

---

## Notes

Changes will appear here after running `/flow-tasks` for a feature.
