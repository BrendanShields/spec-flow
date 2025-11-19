---
name: analyzing-codebase
description: Analyzes existing codebases (brownfield projects) to discover architecture patterns, technology stack, API designs, data models, code quality metrics, and technical debt. Activates when analyzing existing projects, onboarding to new codebases, understanding project structure, planning refactoring, assessing technical debt, or when user says 'analyze codebase', 'discover architecture', 'understand existing code', or 'brownfield analysis'.
allowed-tools: [Task]
---

# Analyzing Codebase

Analyzes existing codebases (brownfield projects) to discover architecture patterns, technology stack, API designs, data models, code quality metrics, and technical debt. Activates when analyzing existing projects, onboarding to new codebases, understanding project structure, planning refactoring, assessing technical debt, or when user says "analyze codebase", "discover architecture", "understand existing code", or "brownfield analysis".

## What This Skill Does

Delegates to the **codebase-analyzer** agent for autonomous brownfield codebase analysis. The agent performs comprehensive discovery including:

- Technology stack discovery (languages, frameworks, libraries, versions)
- Architecture pattern detection (microservices, monolith, layered, hexagonal)
- API pattern extraction (REST endpoints, GraphQL schemas, RPC services)
- Data model mapping (SQL, NoSQL, ORM entities, relationships)
- Code quality assessment (test coverage, technical debt, complexity)
- Dependency analysis (external services, integrations, third-party libraries)
- Discovery report generation (5 comprehensive markdown reports)

## When to Use

1. Starting work on existing project (brownfield onboarding)
2. New team member needs to understand codebase
3. Planning major refactoring or technology migration
4. Assessing technical debt before sprint planning
5. Before running orbit-lifecycle (Define branch) skill on existing code
6. Creating baseline architecture documentation
7. User says "analyze codebase", "discover architecture", or "brownfield analysis"

## Execution Flow

This skill is a thin wrapper that invokes the autonomous codebase-analyzer agent:

```markdown
<invoke-agent>
Agent: codebase-analyzer
Purpose: Autonomous brownfield codebase analysis

Task Description:
Analyze the codebase in the current project directory and generate comprehensive discovery reports.

Analysis Mode: {mode}
- quick: 5-10 min, sample 100 files, basic pattern matching
- standard: 15-30 min, full file tree scan, detailed analysis
- deep: 30-60 min, run test suites, dependency audits, comprehensive reports

Focus Areas: {focus}
- all: Complete analysis (default)
- tech-stack: Technology stack only
- architecture: Architecture patterns only
- api: API catalog only
- quality: Code quality assessment only

Output:
- discovery/project-overview.md (executive summary)
- discovery/technical-landscape.md (architecture details)
- discovery/api-catalog.md (API documentation)
- discovery/quality-assessment.md (code health metrics)
- discovery/onboarding-checklist.md (learning roadmap)

Next Steps:
- Review discovery reports
- Run orbit-planning (Architecture branch) skill to create architecture.md
- Document critical ADRs
- Address high-priority technical debt
</invoke-agent>
```

## Configuration

**Analysis mode** (from `claude.md` or environment):
- `SPEC_DISCOVER_MODE=quick` - Fast analysis (~5-10 min)
- `SPEC_DISCOVER_MODE=standard` - Default comprehensive analysis (~15-30 min)
- `SPEC_DISCOVER_MODE=deep` - Deep analysis with test runs (~30-60 min)

**Focus areas** (optional CLI flag):
```bash
/spec → "Analyze Codebase" --focus=tech-stack
/spec → "Analyze Codebase" --focus=api
```

## Output

The codebase-analyzer agent generates:

1. **discovery/project-overview.md**
   - Project age, team size estimate
   - Key metrics dashboard
   - Health score (0-100)
   - Critical findings

2. **discovery/technical-landscape.md**
   - Technology stack summary
   - Architecture pattern with confidence score
   - Module organization
   - Design patterns in use

3. **discovery/api-catalog.md**
   - REST endpoints table
   - GraphQL schema
   - Authentication methods

4. **discovery/quality-assessment.md**
   - Test coverage percentage
   - Technical debt summary
   - Complexity hotspots
   - Recommended improvements

5. **discovery/onboarding-checklist.md**
   - Week-by-week learning roadmap
   - Reference materials

## Integration Points

- **Triggers**: orbit-planning (Architecture branch) skill (uses discovery reports to create blueprint)
- **Updates**: `.spec/memory/activity-log.md` (logs discovery completion)
- **Suggests**: Running orbit-planning (Architecture branch) to formalize findings

## Progressive Disclosure

**For examples**, see [examples.md](./examples.md)
**For reference**, see [reference.md](./reference.md)

## Related Skills

- **orbit-planning (Architecture branch)**: Creates architecture.md from discovery findings
- **orbit-lifecycle (Initialize branch)**: Run before analyzing if .spec/ doesn't exist
- **orbit-lifecycle (Define branch)**: Uses architecture context for spec generation

---

**Agent**: codebase-analyzer
**Delegation Pattern**: Full autonomous execution
**Parallel Execution**: Yes (can run with consistency-analyzer, specification-analyzer)
**Token Budget**: ~50 lines (thin wrapper)
