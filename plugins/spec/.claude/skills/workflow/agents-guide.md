# Agent System Guide

**Understanding and working with Spec's autonomous agents**

---

## Overview

### What Are Spec Agents?

Agents are **autonomous AI workers** that handle specialized, complex tasks within the Spec workflow. Unlike skills (which you invoke directly), agents operate independently with their own execution context, tools, and decision-making capabilities.

**Key Characteristics**:
- **Autonomous**: Execute multi-step workflows without constant supervision
- **Specialized**: Each agent has a specific domain expertise
- **Parallel Execution**: Can run tasks concurrently for efficiency
- **Stateful**: Track progress, handle errors, and maintain context
- **Result-Oriented**: Focus on outcomes, not just execution steps

### Why Use Agents Instead of Direct Execution?

**Skills vs Agents**:

| Aspect | Skills | Agents |
|--------|--------|--------|
| Invocation | User-initiated (`/spec plan`) | Skill-delegated (automatic) |
| Execution | Sequential, guided | Autonomous, parallel |
| Scope | Single focused task | Complex multi-step workflows |
| Tools | Limited to skill context | Full tool access |
| State | Session-bound | Persistent tracking |
| Error Handling | Manual intervention | Automatic retry/recovery |

**When skills use agents**:
- Task complexity exceeds simple execution (e.g., parallel implementation)
- Research or deep analysis required (e.g., technology evaluation)
- Validation across multiple artifacts (e.g., consistency checking)
- Progress tracking essential (e.g., long-running implementations)

### When Agents Activate vs Main Skill Executes

**Agent Activation Conditions**:
1. **implement phase** → **spec-implementer**: When tasks.md has 3+ tasks OR parallel execution requested
2. **plan phase** → **spec-researcher**: When technology decisions needed OR domain patterns unknown
3. **analyze phase** → **spec-analyzer**: When validation spans 3+ artifacts OR deep consistency check needed

**Main Skill Direct Execution**:
- Single-task workflows (e.g., updating one file)
- Simple transformations (e.g., formatting)
- Interactive prompts (e.g., clarify questions)
- Configuration changes (e.g., init setup)

---

## The Agent System Architecture

### Task Delegation Model

```
User → Skill → Agent Delegation Decision → Agent Execution → Result Collection
         ↓                                         ↓
    Direct Execution                      Progress Updates
```

**Delegation Flow**:

1. **Skill Analysis**: Skill evaluates task complexity
2. **Decision Point**:
   - Complex? → Delegate to agent
   - Simple? → Execute directly
3. **Context Preparation**: Skill prepares context files for agent
4. **Agent Invocation**: Skill transfers control to specialized agent
5. **Execution**: Agent runs autonomously
6. **Result Collection**: Skill receives agent output
7. **State Update**: Skill updates workflow state

### Context Passing Mechanism

**What context is passed**:
- **Artifact Files**: spec.md, plan.md, tasks.md, blueprint
- **State Files**: current-session.md, workflow-progress.md
- **Configuration**: claude.md settings, {config.paths.spec_root}/config.json
- **Metadata**: Feature ID, phase, priorities, constraints

**How context is passed**:
```markdown
## Implementation Context

### Feature Details
- **ID**: 003
- **Name**: user-authentication
- **Phase**: implementation
- **Priority**: P1

### Artifacts
- spec.md: /path/to/{config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
- plan.md: /path/to/{config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan}
- tasks.md: /path/to/{config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks}

### Configuration
- Max Parallel Tasks: 3
- Test Strategy: TDD
- Skip Tests: false
```

### Result Collection

**Agent output structure**:
```markdown
## Execution Results

### Status
- Completed: 12/15 tasks (80%)
- Failed: 0 tasks
- Skipped: 3 tasks (dependencies not met)

### Artifacts Modified
- src/auth/login.ts (created)
- src/auth/middleware.ts (created)
- tests/auth.test.ts (created)

### Issues Encountered
- None

### Next Steps
- Complete remaining 3 tasks
- Run integration tests
```

### Error Propagation

**Error handling chain**:

1. **Agent Level**: Agent encounters error
   - Retry with exponential backoff (max 3 attempts)
   - Try alternative approaches
   - Log detailed error context

2. **If agent can't recover**:
   - Return partial results + error details
   - Preserve completed work
   - Document failure state

3. **Skill Level**: Skill receives error
   - Evaluate severity (blocking vs non-blocking)
   - Update state with failure information
   - Present user with recovery options

4. **User Level**: User sees actionable error
   - Clear explanation of what failed
   - Why it failed (root cause)
   - How to fix (recovery steps)
   - What succeeded (partial progress)

---

## The Three Agents

### spec-implementer

**Purpose**: Parallel task execution with progress tracking

**Full Agent Name**: `spec-implementer`

**Invoked By**: `implement phase` skill

**When Invoked**:
- tasks.md has 3+ pending tasks
- User runs `/spec implement --parallel`
- Resuming multi-task implementation with `--continue`

**Context Provided**:

Files passed to agent:
- `implementation-context.md` (generated by implement phase)
  - Feature ID, name, phase
  - Configuration (max parallel, test strategy)
  - Constraints (no destructive operations, etc.)
- `tasks.md` (from feature directory)
  - Full task list with dependencies
  - Parallel markers `[P]`
  - User story groupings `[US#]`
- `plan.md` (from feature directory)
  - Architecture guidance
  - API contracts
  - Testing strategy
- `{config.paths.state}/current-session.md` (session state)
  - Previously completed tasks
  - Known blockers

**Tools Available**:
- **Read**: Load source files, dependencies
- **Write**: Create new files (components, tests, configs)
- **Edit**: Modify existing files
- **Bash**: Run tests, install dependencies, git operations
- **Grep**: Search codebase for patterns
- **Glob**: Find files for modification

**Execution Modes**:

1. **Serial Mode** (default for < 3 tasks):
   - Execute tasks sequentially (T001 → T002 → T003)
   - Easier debugging
   - No file conflicts

2. **Parallel Mode** (enabled with `--parallel` or auto for tasks with `[P]`):
   - Analyze task dependencies
   - Identify independent tasks
   - Execute multiple tasks concurrently
   - Real-time progress tracking

**Progress Tracking**:

The agent updates `{config.paths.state}/current-session.md` in real-time:

```markdown
## Implementation Progress

### Task Status
- [X] T001 Setup authentication module (COMPLETED - 45s)
- [X] T002 Create User model (COMPLETED - 32s)
- [→] T003 [P] Implement login endpoint (IN PROGRESS - 18s elapsed)
- [→] T004 [P] Implement logout endpoint (IN PROGRESS - 12s elapsed)
- [ ] T005 Add password hashing (PENDING - waiting for T003)
- [ ] T006 Create auth tests (PENDING)

### Parallelization
Currently running in parallel:
- T003 (writes to src/auth/login.ts)
- T004 (writes to src/auth/logout.ts)

### Metrics
- Completed: 2/6 (33%)
- In Progress: 2/6 (33%)
- Pending: 2/6 (33%)
- Est. Completion: 3 minutes
```

**Failure Modes & Fallbacks**:

| Failure | Agent Response | User Action Required |
|---------|----------------|---------------------|
| Task fails (retryable) | Retry 3x with backoff | None (automatic) |
| Task fails (non-retryable) | Skip, continue with independents | Fix blocker, run `--continue` |
| Test failure | Halt, log test output | Fix tests, run `--continue` |
| File conflict | Serialize conflicting tasks | None (automatic) |
| Dependency missing | Install via Bash | Verify installation succeeded |
| Parallel deadlock | Detect after 2 min, serialize | None (automatic fallback) |

**Control Mechanisms**:

**Command-line flags**:
```bash
/spec implement                    # Auto-detect parallel opportunities
/spec implement --parallel         # Force parallel execution
/spec implement --parallel=false   # Force serial execution
/spec implement --continue         # Resume from last checkpoint
/spec implement --task=T005        # Start from specific task
/spec implement --skip-tests       # Skip test execution (not recommended)
```

**Configuration** (in claude.md or {config.paths.spec_root}/config.json):
```markdown
SPEC_IMPLEMENT_MAX_PARALLEL=3      # Max concurrent tasks
SPEC_IMPLEMENT_TEST_STRATEGY=tdd   # tdd | after | skip
SPEC_IMPLEMENT_RETRY_COUNT=3       # Max retries per task
SPEC_IMPLEMENT_TIMEOUT=600         # Task timeout in seconds
```

**Best Practices**:
- Mark truly independent tasks with `[P]` in tasks.md
- Group related tasks by user story `[US#]` for natural parallelism
- Use absolute file paths (agent detects conflicts)
- Let agent decide parallel vs serial (it's smart about conflicts)
- Use `--continue` to resume after fixing blockers

---

### spec-researcher

**Purpose**: Research-backed technical decisions and best practices discovery

**Full Agent Name**: `spec-researcher`

**Invoked By**: `plan phase` skill (automatically during planning phase)

**When Invoked**:
- Technology choices need to be made (e.g., "Which database?")
- Architecture patterns unclear (e.g., "How to structure API?")
- Best practices discovery needed (e.g., "Security for payment processing")
- Library evaluation required (e.g., "React vs Vue vs Svelte")

**Context Provided**:

Files passed to agent:
- `spec.md` (from feature directory)
  - User stories and requirements
  - Acceptance criteria
  - Priorities
  - [CLARIFY] tags indicating ambiguities
- `{config.paths.spec_root}/architecture-blueprint.md` (if exists)
  - Existing tech stack constraints
  - Architectural principles
  - Approved technologies
- `{config.paths.memory}/decisions-log.md` (existing ADRs)
  - Previous architecture decisions
  - Technology choices made
  - Rationale and trade-offs
- `research-query.md` (generated by plan phase)
  - Specific questions to research
  - Decision criteria (performance, cost, DX, etc.)
  - Constraints (budget, team size, timeline)

**Tools Available**:
- **WebSearch**: Find current best practices, benchmarks, comparisons
- **WebFetch**: Retrieve official documentation, security advisories
- **Read**: Load existing codebase patterns, package.json dependencies
- **Write**: Generate research reports, decision matrices, ADRs

**Research Focus Areas**:

1. **Best Practices**:
   - Industry standards for domain (e.g., e-commerce checkout flow)
   - Current recommendations (not outdated patterns)
   - Community consensus from trusted sources

2. **Library Recommendations**:
   - Feature comparison matrix
   - Performance benchmarks
   - Maintenance indicators (last update, issue count, contributors)
   - Security assessment (CVE count, audit status)
   - License compatibility

3. **Architecture Patterns**:
   - Proven solutions for similar problems
   - Scale considerations (monolith vs microservices)
   - Domain-specific patterns (event sourcing for audit trails)

4. **Technology Evaluation**:
   - Learning curve assessment
   - Ecosystem maturity
   - Long-term viability
   - Team expertise alignment

**Output Format**:

The agent produces three deliverables:

1. **Research Report** (`{config.paths.spec_root}/research/reports/[topic].md`):
```markdown
# Authentication Library Research

## Summary
Evaluated 4 authentication libraries for JWT implementation.
Recommendation: Passport.js for Express ecosystem compatibility.

## Candidates Analyzed
1. Passport.js - Most popular, extensive strategy support
2. jsonwebtoken - Lightweight, JWT-only
3. Auth0 SDK - Comprehensive but vendor lock-in
4. NextAuth.js - Next.js specific

## Decision Matrix
| Library | Features | Performance | Maintenance | Security | Score |
|---------|----------|-------------|-------------|----------|-------|
| Passport.js | 9/10 | 8/10 | 9/10 | 9/10 | 8.75 |
| jsonwebtoken | 6/10 | 10/10 | 8/10 | 8/10 | 8.0 |
| Auth0 SDK | 10/10 | 7/10 | 10/10 | 10/10 | 9.25* |
| NextAuth.js | 8/10 | 8/10 | 9/10 | 9/10 | 8.5 |

*Excluded due to vendor lock-in constraint

## Recommendation
**Passport.js** - Best balance for Express-based app
- 500+ authentication strategies
- Active maintenance (weekly updates)
- Zero CVEs in last 12 months
- Extensive documentation and community support

## Implementation Notes
- Install: `npm install passport passport-jwt`
- Setup requires strategy configuration
- Integrates with existing Express middleware
```

2. **Architecture Decision Record** (appended to `{config.paths.memory}/decisions-log.md`):
```markdown
## ADR-005: Use Passport.js for Authentication

**Date**: 2025-11-02
**Status**: Accepted
**Context**: Need JWT authentication for REST API

**Decision**: Use Passport.js with passport-jwt strategy

**Rationale**:
- Pros:
  - Most popular auth library (23k+ stars)
  - 500+ strategies (extensible)
  - Active maintenance
  - Excellent Express integration
- Cons:
  - Steeper learning curve than jsonwebtoken
  - More boilerplate for simple use cases

**Alternatives Considered**:
- jsonwebtoken: Too low-level, manual strategy implementation
- Auth0 SDK: Vendor lock-in concerns
- NextAuth.js: Next.js specific, not framework agnostic

**Consequences**:
- Team needs to learn Passport.js patterns
- Enables future OAuth integration
- Slightly more complex initial setup

**References**:
- Research: `{config.paths.spec_root}/research/reports/authentication-library.md`
- Passport docs: https://www.passportjs.org/
```

3. **Quick Summary** (returned to plan phase):
```markdown
## Research Findings: Authentication

**Recommendation**: Passport.js
**Effort**: Medium (2-3 hours setup)
**Risk**: Low
**Confidence**: High

Key Points:
- Best Express integration
- Extensible for future OAuth
- Active maintenance
- Strong security track record
```

**Failure Modes & Fallbacks**:

| Failure | Agent Response | Plan Impact |
|---------|----------------|-------------|
| WebSearch unavailable | Use cached knowledge from training | Warning in plan: "Created without current research" |
| Documentation unreachable | Use alternative sources | Note in ADR: "Based on community sources" |
| No clear winner | Present top 2-3 with trade-offs | User chooses, agent documents decision |
| Conflicting information | Weight by source authority | Include uncertainty in recommendation |

**Control Mechanisms**:

**Automatic invocation** (no user flags needed):
- plan phase detects decision points
- Automatically invokes researcher
- Incorporates findings into plan.md

**Configuration** (in claude.md):
```markdown
SPEC_RESEARCH_DEPTH=full              # full | shallow | skip
SPEC_RESEARCH_SOURCES=official,community  # Comma-separated
SPEC_RESEARCH_CACHE_TTL=86400         # Cache duration (seconds)
```

**Best Practices**:
- Research runs automatically - no manual invocation needed
- Results cached (24hr default) to avoid redundant research
- ADRs document "why" for future reference
- Review research reports to understand trade-offs
- Override recommendations if team has specific expertise

---

### spec-analyzer

**Purpose**: Deep consistency validation across artifacts

**Full Agent Name**: `spec-analyzer`

**Invoked By**: `analyze phase` skill

**When Invoked**:
- User runs `/spec analyze` (manual validation)
- After update phase modifies requirements
- Before implement phase starts (pre-flight check)
- During orchestrate phase workflow (automatic checkpoints)

**Context Provided**:

Files passed to agent:
- `spec.md` (requirements specification)
- `plan.md` (technical design)
- `tasks.md` (implementation breakdown)
- `{config.paths.spec_root}/architecture-blueprint.md` (architecture standards)
- `{config.paths.memory}/decisions-log.md` (ADR history)
- `validation-config.md` (generated by analyze phase)
  - Validation depth (shallow | normal | strict)
  - Artifact scope (which files to check)
  - Issue severity thresholds

**Tools Available**:
- **Read**: Load all artifacts for analysis
- **Grep**: Search for terminology inconsistencies, missing references
- **Bash**: Run linters, validate JSON/YAML schemas
- **Write**: Generate validation report

**Validation Levels**:

1. **Terminology Consistency**:
   - Same concept called different names across artifacts
   - Example: "User" in spec.md, "Account" in plan.md → Flag as MEDIUM
   - Example: "Authentication" vs "Auth" vs "Login" → Flag as LOW

2. **Requirements Coverage**:
   - Every user story in spec.md has corresponding plan section
   - Every plan component has tasks in tasks.md
   - Example: US2.3 in spec missing from plan → Flag as HIGH

3. **Dependency Consistency**:
   - Task dependencies match plan architecture
   - Example: T005 depends on T008, but plan shows reverse order → Flag as CRITICAL
   - Circular dependencies → Flag as CRITICAL

4. **Priority Alignment**:
   - P1 user stories have P1 tasks
   - Critical path tasks marked appropriately
   - Example: P1 story only has P3 tasks → Flag as HIGH

5. **Acceptance Criteria Mapping**:
   - Each acceptance criterion has implementing tasks
   - Example: "User can reset password" criterion but no password reset tasks → Flag as HIGH

6. **Blueprint Compliance**:
   - Plan follows architecture standards
   - Technologies match approved list
   - Example: Plan uses MongoDB, blueprint mandates PostgreSQL → Flag as CRITICAL

**Output Format**:

The agent produces a validation report (`{config.paths.state}/validation-report.md`):

```markdown
# Validation Report: Feature 003-user-authentication

**Date**: 2025-11-02 14:30
**Validation Level**: Normal
**Artifacts Checked**: spec.md, plan.md, tasks.md, blueprint

---

## Summary

- **CRITICAL Issues**: 0
- **HIGH Priority**: 2
- **MEDIUM Priority**: 5
- **LOW Priority**: 3

**Overall Status**: ⚠️ Review Required (HIGH issues present)

---

## CRITICAL Issues (Must Fix Before Implementation)

_None found_

---

## HIGH Priority Issues (Should Fix)

### H-001: Missing Task Coverage for Acceptance Criterion
**Location**: spec.md:78, tasks.md
**Issue**: User story US2.3 acceptance criterion "User receives email confirmation" has no corresponding task
**Impact**: Feature incomplete, acceptance criterion not implemented
**Fix**: Add task: "T012 Implement email confirmation service"

### H-002: Priority Mismatch
**Location**: spec.md:45, tasks.md:89
**Issue**: User story US1.1 (P1) only has P3 tasks (T015-T018)
**Impact**: Critical functionality might be deprioritized
**Fix**: Upgrade T015-T018 to P1 or split US1.1 into P1 + P3 stories

---

## MEDIUM Priority Issues (Consider Fixing)

### M-001: Terminology Inconsistency
**Locations**: spec.md:23, plan.md:67, tasks.md:34
**Issue**: Concept called "User" (spec), "Account" (plan), "Member" (tasks)
**Impact**: Confusion, harder to trace requirements
**Fix**: Standardize on one term (recommend "User" - most common)

### M-002: Circular Dependency
**Location**: tasks.md:45-67
**Issue**: T008 → T010 → T012 → T008 (circular)
**Impact**: Cannot determine execution order
**Fix**: Reorder: T008 (no deps) → T010 → T012

### M-003: Missing ADR Reference
**Location**: plan.md:123
**Issue**: Technology decision "Use Redis for sessions" not documented as ADR
**Impact**: No rationale captured for future reference
**Fix**: Create ADR-006 documenting Redis decision

### M-004: Unresolved [CLARIFY] Tag
**Location**: spec.md:156
**Issue**: "[CLARIFY: Define 'fast' response time]" still present
**Impact**: Vague requirement, testing unclear
**Fix**: Run `/spec clarify` or define explicitly (e.g., "< 200ms p95")

### M-005: Blueprint Violation
**Location**: plan.md:89
**Issue**: Plan uses REST API, blueprint prefers GraphQL
**Impact**: Architectural inconsistency
**Fix**: Update plan to use GraphQL OR update blueprint to allow REST

---

## LOW Priority Issues (Optional)

### L-001: Minor Formatting Inconsistency
**Location**: tasks.md:12-45
**Issue**: Some task IDs have leading zeros (T001), others don't (T12)
**Impact**: Cosmetic only
**Fix**: Standardize on T001, T002, ... T012 format

### L-002: Missing Effort Estimate
**Location**: tasks.md:67
**Issue**: Task T009 has no effort estimate
**Impact**: Planning accuracy reduced
**Fix**: Add estimate (e.g., "Est: 2 hours")

### L-003: Outdated Reference
**Location**: plan.md:234
**Issue**: References deprecated library version
**Impact**: Minimal, caught during implementation
**Fix**: Update to current version

---

## Detailed Analysis

### Requirements Traceability Matrix

| User Story | Plan Section | Tasks | Status |
|------------|--------------|-------|--------|
| US1.1 (P1) | ✓ Section 3.1 | ✓ T001-T004 | ⚠️ Priority mismatch |
| US1.2 (P1) | ✓ Section 3.2 | ✓ T005-T007 | ✅ Complete |
| US2.1 (P2) | ✓ Section 4.1 | ✓ T008-T011 | ⚠️ Circular deps |
| US2.2 (P2) | ✓ Section 4.2 | ✗ Missing | ❌ No tasks |
| US2.3 (P2) | ✓ Section 4.3 | ⚠️ T012-T014 | ⚠️ Missing email task |

### Terminology Usage

| Term | spec.md | plan.md | tasks.md | Recommendation |
|------|---------|---------|----------|----------------|
| User | 24 uses | 12 uses | 18 uses | ✅ Keep |
| Account | 0 uses | 8 uses | 3 uses | ⚠️ Replace with "User" |
| Member | 0 uses | 0 uses | 5 uses | ⚠️ Replace with "User" |

---

## Recommendations

1. **Fix H-001 & H-002** (HIGH priority) before running `/spec implement`
2. **Consider M-001** (terminology) - improves clarity significantly
3. **Skip L-001 to L-003** (LOW priority) - cosmetic, fix during refactoring
4. **Re-run validation** after fixes: `/spec analyze`

---

**Next Steps**:
1. Edit spec.md, plan.md, tasks.md to address HIGH issues
2. Run: `/spec analyze` to verify fixes
3. Proceed: `/spec implement` once validation passes
```

**Failure Modes & Fallbacks**:

| Failure | Agent Response | User Action |
|---------|----------------|-------------|
| Artifact missing (spec.md) | Partial analysis, warn about missing file | Create missing artifact |
| Malformed artifact | Skip validation of malformed sections, flag error | Fix syntax errors |
| Too many issues (50+) | Prioritize CRITICAL/HIGH, truncate LOW | Fix top issues, re-run |
| Timeout (large codebase) | Return partial results, log timeout | Reduce validation scope |

**Control Mechanisms**:

**Command-line flags**:
```bash
/spec analyze                          # Normal validation
/spec analyze --strict                 # Stricter rules (more issues flagged)
/spec analyze --focus=terminology      # Check only terminology
/spec analyze --artifacts=spec,plan    # Skip tasks.md
```

**Configuration** (in claude.md):
```markdown
SPEC_ANALYZE_LEVEL=normal              # shallow | normal | strict
SPEC_ANALYZE_TERMINOLOGY=true          # Check naming consistency
SPEC_ANALYZE_COVERAGE=true             # Check requirements coverage
SPEC_ANALYZE_DEPENDENCIES=true         # Check task dependencies
SPEC_ANALYZE_BLUEPRINT=true            # Check blueprint compliance
```

**Best Practices**:
- Run after update phase (catch inconsistencies early)
- Run before implement phase (pre-flight check)
- Fix CRITICAL first, then HIGH, consider MEDIUM
- LOW issues can wait for refactoring phase
- Use `--strict` for enterprise/compliance projects

---

## Agent Invocation Patterns

### When Each Function Uses Agents vs Direct Execution

| Skill | Uses Agent? | Condition | Agent Used |
|-------|-------------|-----------|------------|
| `initialize phase` | ❌ Never | Simple directory creation | None |
| `discover phase` | ✅ Sometimes | Large codebase (500+ files) | spec-analyzer (brownfield mode) |
| `blueprint phase` | ❌ Never | Template generation | None |
| `generate phase` | ❌ Never | Template-based spec creation | None |
| `clarify phase` | ❌ Never | Interactive Q&A | None |
| `checklist phase` | ❌ Never | Checklist generation | None |
| `plan phase` | ✅ Always | Technology decisions needed | spec-researcher |
| `analyze phase` | ✅ Sometimes | 3+ artifacts to validate | spec-analyzer |
| `tasks phase` | ❌ Never | Task breakdown from plan | None |
| `implement phase` | ✅ Usually | 3+ tasks OR --parallel flag | spec-implementer |
| `update phase` | ❌ Never | Direct file editing | None |
| `metrics phase` | ❌ Never | State file aggregation | None |
| `orchestrate phase` | ✅ Transitively | Uses plan/analyze/implement | All agents (as needed) |

---

## Controlling Agent Behavior

### Configuration Variables

**Global Configuration** (in `claude.md` at project root):

```markdown
# Spec Agent Configuration

## spec-implementer Agent
SPEC_IMPLEMENT_MAX_PARALLEL=3          # Max concurrent tasks (1-10)
SPEC_IMPLEMENT_TEST_STRATEGY=tdd       # tdd | after | skip
SPEC_IMPLEMENT_RETRY_COUNT=3           # Retry attempts (0-5)
SPEC_IMPLEMENT_TIMEOUT=600             # Per-task timeout (seconds)
SPEC_IMPLEMENT_AUTO_COMMIT=false       # Git commit after each task

## spec-researcher Agent
SPEC_RESEARCH_DEPTH=full               # full | shallow | skip
SPEC_RESEARCH_SOURCES=official,community,benchmarks
SPEC_RESEARCH_CACHE_TTL=86400          # Cache duration (24h)
SPEC_RESEARCH_AUTO_ADR=true            # Auto-create ADRs

## spec-analyzer Agent
SPEC_ANALYZE_LEVEL=normal              # shallow | normal | strict
SPEC_ANALYZE_TERMINOLOGY=true          # Terminology consistency
SPEC_ANALYZE_COVERAGE=true             # Requirements coverage
SPEC_ANALYZE_DEPENDENCIES=true         # Dependency validation
SPEC_ANALYZE_BLUEPRINT=true            # Blueprint compliance
SPEC_ANALYZE_MAX_ISSUES=50             # Truncate after N issues
```

**Per-Feature Configuration** (in `{config.paths.spec_root}/config.json`):

```json
{
  "feature-003": {
    "implement": {
      "maxParallel": 5,
      "testStrategy": "after",
      "allowSkipTests": false
    },
    "research": {
      "depth": "shallow",
      "skipDomains": ["example.com"]
    },
    "analyze": {
      "level": "strict",
      "ignoreLowPriority": true
    }
  }
}
```

### Command-Line Flags

**implement phase flags**:
```bash
--parallel              # Enable parallel execution
--parallel=false        # Force serial execution
--continue              # Resume from checkpoint
--task=T005             # Start from specific task
--skip-tests            # Skip test execution
--dry-run               # Show execution plan without changes
```

**analyze phase flags**:
```bash
--strict                # Stricter validation rules
--focus=terminology     # Validate specific aspect only
--artifacts=spec,plan   # Check subset of artifacts
--ignore-low            # Skip LOW priority issues
```

**plan phase flags** (researcher configuration):
```bash
--research-depth=shallow    # Faster, less thorough
--skip-research             # Use cached knowledge only
--manual-adr                # Don't auto-generate ADRs
```

### Environment Variables

```bash
# Temporary overrides (session-only)
export SPEC_DEBUG=true                 # Verbose agent output
export SPEC_AGENT_TIMEOUT=1200         # Global agent timeout
export SPEC_SKIP_AGENTS=true           # Force direct execution
```

---

## Error Handling & Fallbacks

### What Happens When Agents Fail?

**Failure Cascade**:

1. **Agent-Level Retry** (automatic):
   - Retryable error (network, timeout) → Retry with exponential backoff (1s, 2s, 4s)
   - Max 3 attempts
   - If all retries fail → Return error to skill

2. **Skill-Level Graceful Degradation**:
   - Receive agent error
   - Attempt fallback strategy:
     - spec-implementer fails → Fall back to serial execution
     - spec-researcher fails → Use cached knowledge, log warning
     - spec-analyzer fails → Skip validation, warn user
   - Log degraded mode to `{config.paths.state}/warnings.log`

3. **User-Level Notification**:
   - Clear error message with context
   - Partial results preserved
   - Recovery instructions provided

**Error Scenarios & Responses**:

| Error | Agent | Fallback | User Impact |
|-------|-------|----------|-------------|
| Network timeout | spec-researcher | Cached knowledge | Warning in plan: "No current research" |
| File conflict (parallel) | spec-implementer | Serialize conflicting tasks | Slight slowdown, no data loss |
| Circular dependency | spec-analyzer | Report error, skip execution | User must fix tasks.md |
| Out of memory | spec-implementer | Reduce parallelism to 1 | Slower execution |
| Tool unavailable (Bash) | Any agent | Skip tool-dependent steps | Partial execution |
| Invalid configuration | Any agent | Use defaults | Logged warning |

**Recovery Procedures**:

**Scenario 1: spec-implementer fails during parallel execution**

```bash
# Error shown
Error: Task T005 failed after 3 retries
Parallel execution halted
2/10 tasks completed
Checkpoint saved to {config.paths.state}/checkpoints/2025-11-02-14-30.md

# User recovery
/spec status                # Check current state
# Review T005 error in {config.paths.state}/implementation-errors.log
# Fix the blocker manually
/spec implement --continue  # Resume from checkpoint
```

**Scenario 2: spec-researcher fails (no internet)**

```bash
# Warning shown
Warning: Web research unavailable
Creating plan using cached knowledge only
Note: Plan may not reflect latest best practices

# User recovery
# Option 1: Continue with cached knowledge
/spec plan  # Completes successfully

# Option 2: Wait for connectivity
# Fix network, then:
/spec plan --force  # Regenerate with current research
```

**Scenario 3: spec-analyzer detects CRITICAL issues**

```bash
# Error shown
Validation failed: 2 CRITICAL issues detected
Cannot proceed to implementation until resolved

CRITICAL Issues:
- C-001: Circular dependency T008 → T010 → T012 → T008
- C-002: Task T015 references non-existent file /src/fake.ts

# User recovery
# Edit tasks.md to fix issues
/spec analyze  # Re-validate
# Once CRITICAL issues clear:
/spec implement
```

---

## Best Practices

### When to Use Agents vs Direct Execution

**Use Agents When**:
- ✅ Task complexity high (3+ steps per task)
- ✅ Parallel execution beneficial (10+ independent tasks)
- ✅ Research required (new technology domain)
- ✅ Deep analysis needed (cross-artifact validation)
- ✅ Progress tracking important (long-running workflows)
- ✅ Error recovery critical (production implementations)

**Use Direct Execution When**:
- ✅ Single, simple task (update one file)
- ✅ Interactive workflow (clarify questions)
- ✅ Configuration changes (init, update settings)
- ✅ Quick validation (syntax check only)
- ✅ Prototyping (speed > robustness)

### Performance Considerations

**Agent Overhead**:
- Agent invocation: ~2-5 seconds
- Context loading: ~1-3 seconds
- Progress tracking: ~0.5 seconds per task
- Total overhead: ~5-10 seconds

**When overhead is worth it**:
- Tasks take > 30 seconds each (overhead < 20%)
- Parallel execution saves > 2x time
- Error recovery avoids manual intervention
- Research prevents wrong technology choice

**When to skip agents**:
- Simple tasks (< 10 seconds total)
- Single-task workflows
- Rapid prototyping phase

**Optimization Tips**:
```bash
# For quick prototype (skip agents)
SPEC_SKIP_AGENTS=true /spec implement

# For production (use agents)
/spec implement --parallel  # Let agents optimize
```

### Debugging Agent Issues

**Enable Debug Mode**:
```bash
export SPEC_DEBUG=true
/spec implement
```

**Debug Output Shows**:
- Agent invocation parameters
- Context files loaded
- Tool calls made by agent
- Decision points and reasoning
- Error details with stack traces

**Common Debug Scenarios**:

**Issue**: Agent seems stuck
```bash
# Check agent progress
cat {config.paths.state}/current-session.md

# View agent logs
tail -f {config.paths.state}/agent-execution.log

# If truly stuck (> 5 min no progress)
# Kill and restart
/spec implement --continue
```

**Issue**: Agent produces unexpected results
```bash
# Review agent's context
cat {config.paths.state}/implementation-context.md

# Check what agent saw
SPEC_DEBUG=true /spec implement --dry-run

# Verify configuration
cat claude.md | grep SPEC_
```

**Issue**: Agent fails repeatedly
```bash
# Check error log
cat {config.paths.state}/implementation-errors.log

# Validate inputs
/spec analyze

# Try with simpler configuration
SPEC_IMPLEMENT_MAX_PARALLEL=1 /spec implement
```

---

## Troubleshooting

### Agent Doesn't Start

**Symptoms**:
- Skill runs but agent never invoked
- Direct execution happens instead

**Diagnosis**:
```bash
# Check if agents are disabled
echo $SPEC_SKIP_AGENTS
# Should be empty or "false"

# Check task count (implementer needs 3+)
grep -c "^- \[ \]" {config.paths.features}/*/{config.naming.files.tasks}
# Should be 3 or more

# Check configuration
cat claude.md | grep SPEC_
```

**Fixes**:
```bash
# Enable agents
unset SPEC_SKIP_AGENTS

# Force agent invocation
/spec implement --parallel  # Forces implementer agent
```

---

### Agent Fails Mid-Execution

**Symptoms**:
- Agent starts successfully
- Completes some work
- Then fails with error

**Diagnosis**:
```bash
# Check error log
cat {config.paths.state}/implementation-errors.log

# Review checkpoint
cat {config.paths.state}/checkpoints/latest.md

# Check system resources
# Agent might be out of memory/disk space
```

**Fixes**:
```bash
# Resume from checkpoint
/spec implement --continue

# Reduce parallel tasks
SPEC_IMPLEMENT_MAX_PARALLEL=1 /spec implement

# Increase timeout
SPEC_IMPLEMENT_TIMEOUT=1200 /spec implement
```

---

### Agent Produces Unexpected Results

**Symptoms**:
- Agent completes without errors
- Output doesn't match expectations
- Files modified incorrectly

**Diagnosis**:
```bash
# Review what agent saw
cat {config.paths.state}/implementation-context.md

# Check agent's interpretation
SPEC_DEBUG=true /spec implement --dry-run

# Validate inputs
/spec analyze
```

**Fixes**:
```bash
# Clarify inputs (spec, plan, tasks)
# Edit artifacts to be more specific

# Regenerate with clearer context
/spec plan --force
/spec tasks --force
/spec implement --force

# Or manual intervention
# Fix files, then mark tasks complete
/spec implement --mark-complete=T001,T002
```

---

### Progress Not Updating

**Symptoms**:
- Agent running but progress bar frozen
- No status updates in session file

**Diagnosis**:
```bash
# Check if agent actually running
ps aux | grep claude

# View raw agent output
cat {config.paths.state}/agent-execution.log

# Check file permissions
ls -la {config.paths.state}/
```

**Fixes**:
```bash
# Refresh status
/spec status

# If truly stuck, kill and resume
# (Implementation checkpoint auto-saved)
/spec implement --continue

# Fix file permissions
chmod 644 {config.paths.state}/*
```

---

## Summary

**The Three Agents**:

| Agent | Purpose | Invoked By | Key Feature |
|-------|---------|------------|-------------|
| **spec-implementer** | Execute tasks in parallel with progress tracking | implement phase | Parallel execution, dependency resolution |
| **spec-researcher** | Research best practices and document decisions | plan phase | WebSearch, ADR generation |
| **spec-analyzer** | Validate consistency across artifacts | analyze phase | Deep cross-artifact validation |

**When Agents Activate**:
- Automatically when task complexity warrants
- Can be forced with command-line flags
- Can be disabled with environment variables

**Control Points**:
- Configuration files (claude.md, {config.paths.spec_root}/config.json)
- Command-line flags (--parallel, --strict, etc.)
- Environment variables (SPEC_DEBUG, SPEC_SKIP_AGENTS)

**Error Handling**:
- Agents retry automatically (3x)
- Skills fall back gracefully on agent failure
- Users get clear recovery instructions
- Progress preserved via checkpoints

**Best Practice**: Let agents do their job. They're designed to handle complexity, parallelism, and errors better than manual execution.

---

**Related Documentation**:
- **Quick Start**: `quick-start.md` - Get started with workflow
- **Error Recovery**: `error-recovery.md` - Troubleshooting guide
- **Individual Agent Docs**: `.claude/agents/spec-*/agent.md` - Deep dives per agent

---

*For agent-specific implementation details, see individual agent directories in `.claude/agents/`*
