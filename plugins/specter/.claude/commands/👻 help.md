# /specter-help

Context-aware help system for specter workflow.

## Purpose

Provides intelligent, context-sensitive help based on your current position in the workflow, automatically detecting what you're trying to do and suggesting the most relevant commands.

## Usage

```
/specter-help                           # Auto-detect context and suggest
/specter-help specter:specify             # Get help for specific skill
/specter-help --examples               # Show usage examples
/specter-help --persona=solo           # Get persona-specific guidance
/specter-help --all                    # List all available skills
```

## Context Detection

| Context | Detection | Suggestion |
|---------|-----------|------------|
| New project | No `.specter/` directory | Start with `specter:init` |
| Initialized | Empty `features/` | Use `specter:specify` for feature |
| Spec phase | In `spec.md` | Consider `specter:clarify` or `specter:plan` |
| Planning phase | In `plan.md` | Move to `specter:tasks` |
| Task phase | In `tasks.md` | Ready for `specter:implement` |
| Implementation | Tasks incomplete | Continue with `specter:implement --continue` |
| Error state | Issues detected | Try `/flow-debug` |

## Example Outputs

See [help-example.md](./examples/help-example.md) for full examples.

**Auto-detection mode:**
```
📚 Flow Help - Context: Implementation Phase
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current Context:
• Feature: 001-user-authentication
• Phase: Implementation (tasks.md exists)
• Progress: 3/15 tasks completed

Recommended Commands:
1. specter:implement --continue    Continue task implementation
2. /specter-status                 Check detailed progress
3. /specter-validate               Verify consistency
```

## Persona-Specific Guidance

**Solo Developer:**
```
/specter-help --persona=solo

Recommended Workflow:
1. specter:init --type=greenfield
2. specter:blueprint (define architecture)
3. specter:specify "Your project vision"
4. specter:plan (technical design)
5. specter:tasks (break down work)
6. specter:implement (build incrementally)

Your Optimizations:
• Skip specter:clarify (you know requirements)
• Use --minimal flags for quick iterations
• Use /flow-quickstart for rapid setup
```

## Help Topics

### List All Commands
```
/specter-help --all

Core Workflow Skills:
• specter:init, specify, clarify, plan, tasks, implement, analyze, update

Slash Commands:
• /specter-status, help, session, validate, resume

Supporting Skills:
• specter:blueprint, checklist, metrics, discover
```

## Intelligent Suggestions

| Situation | Suggestion |
|-----------|------------|
| First time | Try `/flow-quickstart` |
| Returning | Use `/specter-resume` |
| Confused | Run `/specter-status` |
| Error | Use `/flow-debug` |
| Before stopping | Run `/specter-session save` |
| Spec changed | Use `specter:update` |
| Ready to ship | Run `specter:checklist` |

## Options

- `--examples`: Show real usage examples
- `--persona=PERSONA`: Help for poc/solo/team/enterprise
- `--all`: List all commands
- `--verbose`: Show detailed information
- `--json`: Output as JSON

## Error Messages

Unknown command:
```
❌ Unknown command: flow:invalid

Did you mean:
• specter:init
• specter:specify
• specter:implement

Use /specter-help --all to see all commands
```

## Learning Path

For new users:
1. `/specter-help` (context detection)
2. `/flow-quickstart` (guided setup)
3. `/specter-help SKILL` (as needed)
4. `/specter-status` (check progress)
5. `/specter-session save` (save work)

## Related Commands

- `/specter-status` - Check workflow state
- `/flow-quickstart` - Guided setup
- `/specter-validate` - Check for issues
- `specter:orchestrate` - Run full workflow

---

**Next:** Run `/specter-help` for context-aware assistance.
