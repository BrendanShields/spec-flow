# /flow-help

Context-aware help system for spec-flow workflow.

## Purpose
Provides intelligent, context-sensitive help based on your current position in the workflow, automatically detecting what you're trying to do and suggesting the most relevant commands and documentation.

## Usage
```
/flow-help                           # Auto-detect context and suggest
/flow-help flow:specify             # Get help for specific skill
/flow-help --examples               # Show usage examples
/flow-help --persona=solo           # Get persona-specific guidance
/flow-help --all                    # List all available skills
```

## Context Detection

The help system automatically detects your context:

| Context | Detection | Suggestion |
|---------|-----------|------------|
| No `__specification__/` directory | New project | Start with `flow:init` |
| Empty `features/` | Project initialized | Use `flow:specify` to add feature |
| In `spec.md` | Specification phase | Consider `flow:clarify` or `flow:plan` |
| In `plan.md` | Planning phase | Move to `flow:tasks` |
| In `tasks.md` | Task breakdown | Ready for `flow:implement` |
| Tasks incomplete | Implementation | Continue with `flow:implement --continue` |
| Errors present | Debugging needed | Try `/flow-debug` |

## Example Outputs

### Auto-Detection Mode
```
📚 Flow Help - Context: Implementation Phase
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current Context:
• Feature: 001-user-authentication
• Phase: Implementation (tasks.md exists)
• Progress: 3/15 tasks completed

Recommended Commands:
1. flow:implement --continue    Continue task implementation
2. /flow-status                 Check detailed progress
3. /flow-validate               Verify consistency

Available Actions:
• flow:update                   Update specifications
• flow:checklist                Run quality checks
• /flow-session save            Save progress checkpoint

Quick Tips:
• Tasks should be completed in order
• Mark tasks with [X] when complete
• Use [P] marker for parallel tasks

Need different help? Try:
• /flow-help flow:implement     Detailed implementation help
• /flow-help --examples         See real examples
• /flow-help --all             List all commands
```

### Specific Skill Help
```
/flow-help flow:specify
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 flow:specify - Create feature specification

Purpose:
Creates a structured specification for a new feature or project,
establishing clear requirements before implementation.

Usage:
flow:specify "Feature description"
flow:specify "Feature" --level=project
flow:specify "JIRA-123" --from-jira

Options:
--level=feature|project    Specification scope (default: feature)
--skip-validation         Skip quality checklist (POC mode)
--from-jira              Pull from JIRA issue

Process:
1. Analyzes your request
2. Creates structured specification
3. Generates user stories with priorities
4. Identifies clarification needs
5. Sets up feature directory

Output:
Creates features/###-name/spec.md with:
- User stories (P1, P2, P3)
- Success criteria
- Technical constraints
- Clarification markers {CLARIFY: ...}

Next Steps:
After specification:
1. Run flow:clarify to resolve ambiguities
2. Run flow:plan for technical design
3. Run flow:tasks to break down work

Examples:
flow:specify "Add user authentication with JWT"
flow:specify "Implement shopping cart" --level=feature
flow:specify "https://jira.../PROJ-123" --from-jira

Related:
- flow:clarify - Resolve ambiguities
- flow:plan - Create technical design
- flow:update - Modify existing spec
```

## Persona-Specific Guidance

### Solo Developer
```
/flow-help --persona=solo
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 Solo Developer Workflow

Recommended Workflow:
1. flow:init --type=greenfield
2. flow:blueprint (define your architecture)
3. flow:specify "Your project vision"
4. flow:plan (technical design)
5. flow:tasks (break down work)
6. flow:implement (build incrementally)

Your Optimizations:
• Skip flow:clarify (you know requirements)
• Use --minimal flags for quick iterations
• Skip flow:checklist for internal projects
• Use /flow-quickstart for rapid setup

Best Practices:
• Commit frequently with git
• Use /flow-session save before breaks
• Track decisions in DECISIONS-LOG.md
• Focus on P1 features first
```

## Help Topics

### List All Commands
```
/flow-help --all

Core Workflow Skills:
• flow:init - Initialize project
• flow:specify - Create specifications
• flow:clarify - Resolve ambiguities
• flow:plan - Technical design
• flow:tasks - Break down work
• flow:implement - Execute implementation
• flow:analyze - Check consistency
• flow:update - Modify specifications

Slash Commands:
• /flow-status - Check current state
• /flow-help - This help system
• /flow-session - Manage sessions
• /flow-validate - Validate workflow
• /flow-resume - Resume work
• /flow-quickstart - Quick setup
• /flow-debug - Debug issues
• /flow-report - Generate reports

Supporting Skills:
• flow:blueprint - Define architecture
• flow:checklist - Quality checks
• flow:metrics - Performance metrics
• flow:discover - Explore codebase
```

## Intelligent Suggestions

Based on common patterns:

| Situation | Suggestion |
|-----------|------------|
| First time user | Try `/flow-quickstart` for guided setup |
| Returning user | Use `/flow-resume` to continue |
| Confused about state | Run `/flow-status` for clarity |
| Hit an error | Use `/flow-debug` to diagnose |
| Need to stop | Run `/flow-session save` first |
| Requirements changed | Use `flow:update` to modify |
| Ready to ship | Run `flow:checklist` for quality |

## Options

- `--examples`: Show real usage examples
- `--persona=PERSONA`: Get persona-specific help (poc/solo/team/enterprise)
- `--all`: List all available commands
- `--verbose`: Show detailed information
- `--json`: Output as JSON for tooling

## Error Messages

If skill not found:
```
❌ Unknown command: flow:invalid

Did you mean:
• flow:init
• flow:specify
• flow:implement

Use /flow-help --all to see all commands
```

## Learning Path

For new users:
1. Start with `/flow-help` (context detection)
2. Run `/flow-quickstart` (guided setup)
3. Use `/flow-help SKILL` as needed
4. Check `/flow-status` regularly
5. Save with `/flow-session save`

## Related Commands

- `/flow-status` - Check workflow state
- `/flow-quickstart` - Guided workflow setup
- `/flow-validate` - Check for issues
- `flow:orchestrate` - Run full workflow