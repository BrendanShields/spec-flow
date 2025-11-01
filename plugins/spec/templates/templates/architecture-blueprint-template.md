# Architecture Blueprint: [PROJECT_NAME]

**Status**: [Draft/Active/Deprecated] | **Version**: 1.0.0 | **Updated**: [DATE]

This document defines **HOW** we build. Features reference this for guidance (peer artifact, not enforced).

---

## Core Principles

### Principle 1: [Name]
**Guideline**: [The principle]
**Rationale**: [Why]
**Application**: [How applied]

### Principle 2: [Name]
[Follow same format]

---

## Architecture Patterns

**Overall Style**: [Monolith/Microservices/Modular Monolith/etc.]
**Rationale**: [Why chosen]

**Modules**:
| Module | Responsibility | Exposes | Dependencies |
|--------|---|---|---|
| [Name] | [Owns what] | [APIs] | [Dependencies] |

**Communication**: Sync: [pattern], Async: [pattern], Real-time: [pattern]

---

## Technology Stack

| Layer | Component | Version | Why |
|-------|-----------|---------|-----|
| Frontend | [Framework] | [v] | [Rationale] |
| | State | [Tool] | [Rationale] |
| Backend | [Language/Framework] | [v] | [Rationale] |
| Data | [Database] | [v] | [Rationale] |
| | Cache | [Tool] | [If applicable] |
| Infra | [Hosting/CI/Monitoring] | - | [Brief] |

---

## API Design

**Versioning**: [Strategy] | **Naming**: [Convention] | **Format**: [JSON/other]
**Auth**: [Method] | **Rate Limit**: [Strategy] | **Pagination**: [Method]
**Error Format**:
```json
{"error": {"code": "CODE", "message": "text"}}
```

---

## Data Modeling

**Naming**: Tables [snake_case], Columns [snake_case], Enums [SCREAMING_SNAKE_CASE]
**Keys**: [Strategy] | **Timestamps**: created_at, updated_at (ISO 8601 UTC)
**Soft Deletes**: [Strategy] | **Foreign Keys**: [Enforcement level]

---

## Security & Performance

**Security**: Auth [method], Data [protection], Input [validation], Secrets [management]
**Performance**: P50 [target], P95 [target], P99 [target]
**Testing**: Unit [coverage%], Integration [scope], E2E [scope]

---

## Operations

**Deployment**: [Process steps]
**Rollback**: [Strategy]
**Monitoring**: [Metrics], **Alerting**: [Triggers]

---

## ADRs (Architecture Decision Records)

### ADR-001: [Title]
**Status**: [Accepted/Superseded] | **Date**: [DATE]
**Context**: [Problem] | **Decision**: [What] | **Rationale**: [Why]

### ADR-002: [Title]
[Follow same format]

---

**Related**: Product Requirements | API Contracts | Data Models | See docs for complete guidance
