---
id: 006-creating-skills-skill
title: Skill Creation Best Practices Skill
status: complete
priority: P1
created: 2025-11-27
updated: 2025-11-27
progress:
  tasks_total: 6
  tasks_done: 6
owner: spec-flow
tags:
  - skills
  - meta
  - tooling
archived: true
archived_date: 2025-11-26
---

# Feature: Skill Creation Best Practices Skill

## Overview

A meta-skill that guides users through creating new Claude Code skills following documented best practices. The skill teaches by example, using progressive disclosure to provide the right level of detail at each step.

## User Stories

### US1: Create New Skill from Scratch

As a developer, I want guided help creating a new skill so that I follow best practices without reading extensive documentation.

**Acceptance Criteria:**
- [ ] AC1.1: Skill asks clarifying questions about the new skill's purpose
- [ ] AC1.2: Generates properly structured skill directory
- [ ] AC1.3: Creates SKILL.md with valid frontmatter
- [ ] AC1.4: Includes example content matching skill's domain
- [ ] AC1.5: Validates result against best practices checklist

### US2: Review Existing Skill

As a developer, I want to validate an existing skill against best practices so that I can improve its quality.

**Acceptance Criteria:**
- [ ] AC2.1: Analyzes SKILL.md structure and content
- [ ] AC2.2: Checks for common anti-patterns
- [ ] AC2.3: Validates frontmatter format
- [ ] AC2.4: Reports issues with actionable suggestions
- [ ] AC2.5: Offers to fix identified issues

### US3: Progressive Disclosure Structure

As a developer, I want help organizing complex skill content so that Claude loads only what's needed.

**Acceptance Criteria:**
- [ ] AC3.1: Identifies content that should be in separate files
- [ ] AC3.2: Suggests reference file organization
- [ ] AC3.3: Creates proper linking structure
- [ ] AC3.4: Keeps references one level deep

## Technical Constraints

- SKILL.md must stay under 500 lines
- Use gerund naming format (verb + -ing)
- Maximum 64 character skill names
- Lowercase letters, numbers, hyphens only
- No time-sensitive information
- Unix-style paths only

## Out of Scope

- Creating MCP servers (separate tooling)
- Automated testing framework (future enhancement)
- Multi-model optimization (document as best practice only)
