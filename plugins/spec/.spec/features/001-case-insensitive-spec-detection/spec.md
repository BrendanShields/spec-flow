---
id: 001-case-insensitive-spec-detection
title: Case-Insensitive Spec File Detection
status: specification
priority: P2
created: 2025-11-27
updated: 2025-11-27
progress:
  tasks_total: 0
  tasks_done: 0
---

# Feature: Case-Insensitive Spec File Detection

## Overview

Enable Orbit workflow to detect specification files regardless of case. External tools may create `SPEC.md`, `SPECS.md`, `spec.md`, or `specs.md`. Orbit should recognize all variants while maintaining its own preference for `spec.md` when creating new files.

## User Stories

### US1: Detect External Spec Files

As a developer using Orbit with external tooling, I want Orbit to find my specification file regardless of how it was named so that I can plan, task, and implement without renaming files.

**Acceptance Criteria:**
- [ ] AC1.1: Detect `spec.md`, `SPEC.md`, `Spec.md` (any case)
- [ ] AC1.2: Detect `specs.md`, `SPECS.md`, `Specs.md` (plural variants)
- [ ] AC1.3: When multiple variants exist, prefer lowercase `spec.md`
- [ ] AC1.4: Continue creating new specs as `spec.md` (no behavior change)

### US2: Consistent Workflow Experience

As a developer, I want the same workflow experience whether my spec file is uppercase or lowercase so that external tooling integration is seamless.

**Acceptance Criteria:**
- [ ] AC2.1: Phase detection works with any case variant
- [ ] AC2.2: Context loader reports correct state from any variant
- [ ] AC2.3: Validation scripts check any case variant
- [ ] AC2.4: Frontmatter parsing works regardless of filename case

## Technical Constraints

- Must be backwards compatible - existing `spec.md` files continue to work
- No changes to file creation - Orbit always creates `spec.md`
- Detection order preference: `spec.md` > `SPEC.md` > `specs.md` > `SPECS.md`
- Only affects file detection, not content parsing

## Out of Scope

- Renaming existing files to normalize case
- Supporting arbitrary filenames beyond spec/specs variants
- Changing the canonical filename Orbit creates
