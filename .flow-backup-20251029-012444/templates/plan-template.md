# Technical Plan: {Feature Name}

**Feature ID**: {feature-id}
**Created**: {date}
**Based on**: spec.md
**Status**: {draft|in-review|approved}

## Architecture Overview

High-level architecture description for this feature.

## Technical Decisions

### Decision 1: {Decision Title}
**Context**: {Why is this decision needed?}
**Options Considered**:
1. {Option A} - {Pros/Cons}
2. {Option B} - {Pros/Cons}
3. {Option C} - {Pros/Cons}

**Decision**: {Chosen option}
**Rationale**: {Why this option}

---

### Decision 2: {Decision Title}
**Context**: {Context}
**Decision**: {Decision}
**Rationale**: {Rationale}

---

## Component Design

### Component 1: {Component Name}
**Purpose**: {What this component does}
**Responsibilities**:
- {Responsibility 1}
- {Responsibility 2}

**Interface**:
```
{Code interface/API}
```

**Dependencies**:
- {Dependency 1}
- {Dependency 2}

---

### Component 2: {Component Name}
**Purpose**: {Purpose}
**Responsibilities**:
- {Responsibility}

**Interface**:
```
{Interface}
```

---

## Data Model

### Entity 1: {Entity Name}
```
{Schema or structure}
```

**Fields**:
- `field1`: {type} - {description}
- `field2`: {type} - {description}

**Relationships**:
- {Relationship description}

---

## API Design

### Endpoint 1: {Method} /path
**Purpose**: {What this endpoint does}
**Request**:
```
{Request format}
```

**Response**:
```
{Response format}
```

**Error Cases**:
- {Error case 1}
- {Error case 2}

---

## Implementation Phases

### Phase 1: Foundation
**Goal**: {Phase goal}
**Components**:
- {Component}
- {Component}

**Dependencies**: None
**Estimated Tasks**: {count}

---

### Phase 2: Core Features
**Goal**: {Phase goal}
**Components**:
- {Component}
- {Component}

**Dependencies**: Phase 1
**Estimated Tasks**: {count}

---

### Phase 3: Integration
**Goal**: {Phase goal}
**Components**:
- {Component}
- {Component}

**Dependencies**: Phase 1, Phase 2
**Estimated Tasks**: {count}

---

## Testing Strategy

### Unit Tests
- {Test area 1}
- {Test area 2}

### Integration Tests
- {Test scenario 1}
- {Test scenario 2}

### End-to-End Tests
- {User flow 1}
- {User flow 2}

## Error Handling

### Error Types
1. {Error Type 1}: {How to handle}
2. {Error Type 2}: {How to handle}

### Recovery Strategies
- {Strategy 1}
- {Strategy 2}

## Performance Considerations

- {Consideration 1}
- {Consideration 2}

## Security Considerations

- {Consideration 1}
- {Consideration 2}

## Monitoring & Observability

### Metrics to Track
- {Metric 1}
- {Metric 2}

### Logging
- {What to log}
- {Log level}

## Migration Strategy

(If applicable)
- {Migration step 1}
- {Migration step 2}

## Rollback Plan

- {Rollback step 1}
- {Rollback step 2}

## Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {Risk 1} | {Low/Med/High} | {Low/Med/High} | {Strategy} |
| {Risk 2} | {Low/Med/High} | {Low/Med/High} | {Strategy} |

## Open Questions

[CLARIFY: {Technical question requiring resolution}]
[CLARIFY: {Another question}]

## References

- {External documentation}
- {Related ADRs}
- {Relevant RFCs}

---

**Next Steps**: Run `/flow-tasks` to break into actionable tasks
