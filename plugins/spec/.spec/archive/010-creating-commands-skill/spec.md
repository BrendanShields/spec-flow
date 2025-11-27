---
id: 010-creating-commands-skill
title: Slash Command Creation Skill
status: complete
priority: P1
created: 2025-11-27
updated: 2025-11-27
progress:
  tasks_total: 8
  tasks_done: 8
owner: spec-flow
tags:
  - skills
  - commands
  - tooling
archived: true
archived_date: 2025-11-26
---

# Feature: Slash Command Creation Skill

## Overview

A skill that guides users through creating Claude Code slash commands following best practices. Covers command file format, argument handling, prompt engineering, and integration with project workflows.

## User Stories

### US1: Create New Slash Command

As a developer, I want guided help creating slash commands so that I configure them correctly.

**Acceptance Criteria:**
- [ ] AC1.1: Guides through command purpose definition
- [ ] AC1.2: Generates proper command file with frontmatter
- [ ] AC1.3: Helps define arguments and placeholders
- [ ] AC1.4: Creates effective command prompts
- [ ] AC1.5: Validates command structure before saving

### US2: Understand Command Patterns

As a developer, I want to know common command patterns so that I create useful automation.

**Acceptance Criteria:**
- [ ] AC2.1: Documents command file format and frontmatter
- [ ] AC2.2: Provides examples for common patterns (review, test, deploy)
- [ ] AC2.3: Explains argument syntax ($ARGUMENTS, $1, etc.)
- [ ] AC2.4: Shows integration with skills and agents

### US3: Command Best Practices

As a developer, I want to follow best practices so my commands are maintainable.

**Acceptance Criteria:**
- [ ] AC3.1: Guidelines for command naming conventions
- [ ] AC3.2: Prompt engineering tips for commands
- [ ] AC3.3: Error handling and edge cases
- [ ] AC3.4: Testing commands before deployment

## Technical Constraints

- Command files stored in `.claude/commands/` or `~/.claude/commands/`
- File format: Markdown with optional YAML frontmatter
- Names: lowercase with hyphens (e.g., `review-pr.md`)
- Arguments via `$ARGUMENTS` or positional `$1`, `$2`, etc.

## Out of Scope

- Command scheduling/automation
- Multi-step command wizards
- Command versioning
