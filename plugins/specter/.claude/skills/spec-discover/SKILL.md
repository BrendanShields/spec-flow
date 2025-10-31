---
name: spec:discover
description: Use when 1) Analyzing existing project/brownfield codebase, 2) User says "analyze/understand/discover codebase", 3) Onboarding to new project, 4) Planning refactoring, 5) Assessing JIRA backlog, 6) Sprint planning needs - generates discovery reports with architecture, patterns, tech stack, dependencies, technical debt, and JIRA analysis.
allowed-tools: Read, Grep, Bash
---

# Spec Discover

Analyze existing codebases for brownfield project onboarding. Discovers architecture patterns, tech stack, API patterns, dependencies, and integrates with JIRA backlog analysis.

## What This Skill Does

- Discovers technology stack (languages, frameworks, libraries)
- Identifies architecture patterns (microservices, monolith, layered)
- Extracts API patterns (REST, GraphQL, RPC endpoints)
- Maps data models and database schemas
- Analyzes dependencies (external services, integrations)
- Assesses code quality (test coverage, technical debt)
- Analyzes JIRA backlog (via MCP if available)
- Generates comprehensive discovery report
- Suggests architecture blueprint based on findings

## When to Use

1. Starting work on existing project (brownfield)
2. New team member onboarding
3. Need understanding of project structure
4. Planning major refactoring or migration
5. Assessing technical debt before sprint planning
6. Before running spec:generate on existing code
7. Need JIRA backlog analysis and prioritization

## Execution Flow

### Phase 1: Initialize Discovery

1. Check if project is brownfield (has existing code)
2. Load discovery configuration from CLAUDE.md
3. Determine focus areas (full analysis or specific aspect)
4. Initialize spec:analyzer subagent

### Phase 2: Technology Stack Discovery

Uses spec:analyzer subagent to:
- Scan file structure for language indicators
- Detect frameworks from package files (package.json, requirements.txt, pom.xml)
- Identify build tools and runtime environments
- Map external dependencies and versions

### Phase 3: Architecture Pattern Detection

Analyzes codebase structure:
- Directory organization patterns
- Layer separation (frontend, backend, data)
- Module boundaries and responsibilities
- Design patterns (MVC, Repository, Factory, etc.)
- Service architecture (monolith, microservices, serverless)

### Phase 4: API and Data Model Analysis

Discovers integration points:
- REST endpoints from route definitions
- GraphQL schemas and resolvers
- RPC/gRPC service definitions
- Database schemas (SQL, NoSQL)
- ORM models and entity relationships

### Phase 5: Code Quality Assessment

Evaluates codebase health:
- Test coverage metrics
- Technical debt indicators (TODO, FIXME, HACK comments)
- Code complexity hotspots
- Outdated dependencies
- Security vulnerabilities

### Phase 6: JIRA Backlog Analysis (Optional)

If `SPECTER_ATLASSIAN_SYNC=enabled` and MCP available:
- Extract epics and their progress
- Analyze user stories by status
- Identify blocked items and dependencies
- Review bug distribution and priorities
- Calculate velocity and sprint trends

### Phase 7: Generate Discovery Report

Creates comprehensive documentation:
- `discovery/project-overview.md` - Executive summary with key metrics
- `discovery/technical-landscape.md` - Architecture and patterns
- `discovery/backlog-analysis.md` - JIRA insights (if enabled)
- `discovery/onboarding-checklist.md` - Week-by-week learning path

### Phase 8: Architecture Blueprint Suggestion

Recommends blueprint creation:
- Extract discovered patterns into blueprint template
- Document conventions and standards
- Identify reusable components
- Suggest improvements based on industry practices

See [EXAMPLES.md](./EXAMPLES.md) for concrete scenarios.

## Command Options

**`--focus [AREA]`** - Analyze specific area only:
- `tech-stack`: Technology and dependencies only
- `architecture`: Structure and patterns only
- `api`: API endpoints and contracts only
- `quality`: Code quality and debt only
- `backlog`: JIRA analysis only (requires MCP)

**`--mode [MODE]`** - Analysis depth:
- `quick`: Basic metrics (5-10 min)
- `standard`: Comprehensive analysis (default, 15-30 min)
- `deep`: Full analysis with recommendations (30-60 min)

**`--output [FORMAT]`** - Report format:
- `markdown`: Human-readable reports (default)
- `json`: Machine-readable structured data
- `both`: Generate both formats

**`--skip-jira`** - Skip JIRA analysis (codebase only)

**`--skip-codebase`** - Skip code analysis (JIRA only)

## Error Handling

**Large codebase**: Progressive scanning with sampling for repos >100k LOC
**Missing dependencies**: Reports what couldn't be analyzed and why
**JIRA unavailable**: Gracefully skips backlog analysis
**Partial failures**: Generates report with available data, marks missing sections

## Output Format

Discovery report structure:
```
discovery/
├── project-overview.md          # Summary, metrics, health score
├── technical-landscape.md       # Architecture, stack, patterns
├── api-catalog.md              # Discovered endpoints and schemas
├── quality-assessment.md       # Coverage, debt, hotspots
├── backlog-analysis.md         # JIRA insights (if enabled)
├── onboarding-checklist.md     # Learning roadmap
└── suggested-blueprint.md      # Extracted architecture template
```

Key metrics included:
- Project age and team size estimate
- Technology stack summary
- Architecture pattern (with confidence score)
- Code quality score (0-100)
- Technical debt ratio
- Test coverage percentage
- JIRA velocity and burndown (if available)

## Integration with Specter Workflow

Typical brownfield workflow:
```bash
spec:discover                        # Analyze existing project
spec:init --type brownfield          # Initialize Specter
spec:blueprint --from-discovery      # Create blueprint from findings
spec:generate "New Feature"          # Add features informed by discovery
```

Updates workflow state in `.specter-memory/WORKFLOW-PROGRESS.md` with discovery phase completion.

## Configuration

Set in CLAUDE.md:
```markdown
SPECTER_DISCOVER_MODE=standard           # quick|standard|deep
SPECTER_DISCOVER_INCLUDE_TESTS=true
SPECTER_DISCOVER_ANALYZE_GIT=true
SPECTER_DISCOVER_DETECT_HOTSPOTS=true
SPECTER_ATLASSIAN_SYNC=enabled           # For JIRA analysis
```

## Reference Documentation

See [REFERENCE.md](./REFERENCE.md) for:
- Complete analysis algorithms
- Pattern detection confidence scores
- Output file format specifications
- Performance optimization details
- JIRA integration patterns
- Troubleshooting guide

## Related Skills

- **spec:init**: Initialize Specter after discovery
- **spec:blueprint**: Extract architecture from discovery data
- **spec:generate**: Create specs informed by findings
- **spec:analyze**: Validate specs against discovered patterns

## Subagents Used

- **spec:analyzer**: Performs deep codebase scanning and pattern extraction
