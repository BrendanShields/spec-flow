# Product Requirements Document

**Product**: Orbit Plugin
**Version**: 3.0.0
**Generated**: 2025-11-27
**Last Updated**: 2025-11-27

## Vision

A specification-driven development workflow for Claude Code that uses artifacts as the source of truth, enabling efficient feature development with parallel execution and comprehensive tracking.

## Goals

1. Reduce context switching by maintaining feature state in frontmatter
2. Enable parallel task execution where dependencies allow
3. Provide clear visibility into all in-progress features
4. Support brownfield projects with PRD/TDD generation
5. Alert on critical changes before implementation

## User Personas

### Developer
- **Role**: Software developer using Claude Code
- **Goals**: Implement features efficiently with clear guidance
- **Pain Points**: Context loss between sessions, unclear next steps

### Tech Lead
- **Role**: Technical decision maker
- **Goals**: Track progress across multiple features, ensure quality
- **Pain Points**: Lack of visibility, inconsistent documentation

## Feature Summary

| ID | Feature | Status | Priority |
|----|---------|--------|----------|
| F001 | Frontmatter state tracking | Implemented | P1 |
| F002 | Feature archival | Implemented | P1 |
| F003 | Context loader | Implemented | P1 |
| F004 | Parallel task execution | Implemented | P1 |
| F005 | Critical change alerts | Implemented | P1 |
| F006 | Brownfield support (PRD/TDD) | Implemented | P2 |
| F007 | MCP/extension discovery | Implemented | P2 |

## Non-Functional Requirements

### Performance
- Context loading < 500ms
- Support for 50+ features in archive

### Usability
- Single command entry point (`/orbit`)
- Clear suggestions for next action
- Maximum 4 questions per prompt

### Maintainability
- Artifacts are source of truth
- Self-documenting through templates

## Constraints

- Must work with Claude Code's tool set
- No external dependencies beyond Python 3
- State stored in project directory (`.spec/`)

---
*This document is maintained by the Orbit workflow*
*Update as features are added or requirements change*
