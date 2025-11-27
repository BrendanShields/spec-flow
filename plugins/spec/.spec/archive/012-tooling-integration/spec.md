---
id: 012-tooling-integration
title: Integrate Suggesting-Tooling into Orbit Workflow
status: complete
priority: P1
created: 2025-11-27
updated: 2025-11-27
progress:
  tasks_total: 3
  tasks_done: 3
owner: spec-flow
tags:
  - orbit
  - workflow
  - tooling
  - integration
archived: true
archived_date: 2025-11-26
---

# Feature: Integrate Suggesting-Tooling into Orbit Workflow

## Overview

Integrate the `suggesting-tooling` skill into the orbit workflow at strategic points:
1. During project initialization (alongside PRD/TDD generation)
2. During feature completion (when patterns emerge that could be automated)

The goal is to proactively identify repeatable tasks and suggest skills/agents, NOT for one-off tasks.

## User Stories

### US1: Suggest Tooling on Project Initialize

As a developer starting Orbit on a new/existing project, I want tooling suggestions so that I set up useful automation from the start.

**Acceptance Criteria:**
- [ ] AC1.1: After analyzing-codebase runs, suggest tooling
- [ ] AC1.2: Include suggestions in PRD/TDD consideration
- [ ] AC1.3: User can approve/skip suggestions
- [ ] AC1.4: Only suggest for repeatable patterns, not one-offs

### US2: Suggest Tooling on Feature Complete

As a developer completing a feature, I want to know if the patterns I used could benefit from automation so that future similar work is faster.

**Acceptance Criteria:**
- [ ] AC2.1: On feature archive, analyze what was built
- [ ] AC2.2: Detect repeatable patterns (e.g., "created 3+ similar files")
- [ ] AC2.3: Suggest skills/agents for detected patterns
- [ ] AC2.4: User can approve/skip suggestions

### US3: Document Tooling in Architecture

As a developer, I want tooling decisions captured in architecture docs so that the team understands available automation.

**Acceptance Criteria:**
- [ ] AC3.1: Add "Recommended Tooling" section to PRD template
- [ ] AC3.2: Add "Automation" section to TDD template
- [ ] AC3.3: Update sections when new tooling is created

## Technical Constraints

- Integration points: orbit-workflow skill, analyzing-codebase agent
- Must not slow down workflow with unnecessary prompts
- Suggestions should be actionable and specific
- Only for repeatable tasks (check frequency heuristics)

## Out of Scope

- Automatic tooling creation without approval
- Retroactive analysis of all archived features
- Tooling for one-time tasks
