# Flow Commands Directory

This directory contains slash commands for the Flow workflow system.

## Command Categories

### Core Workflow Commands
- `flow-init.md` - Initialize Flow in project
- `flow-specify.md` - Create feature specification
- `flow-plan.md` - Create technical design (to be added)
- `flow-tasks.md` - Generate task breakdown (to be added)
- `flow-implement.md` - Execute implementation

### Utility Commands
- `status.md` - Check workflow state
- `help.md` - Context-aware help
- `session.md` - Session management
- `resume.md` - Resume interrupted work
- `validate.md` - Consistency checking

### Advanced Commands
- `flow-update.md` - Modify specifications (to be added)
- `flow-clarify.md` - Resolve ambiguities (to be added)
- `flow-blueprint.md` - Architecture definition (to be added)
- `flow-analyze.md` - Deep consistency check (to be added)

## Command Format

Each command file follows this structure:

```markdown
# command-name Command

Brief description.

## TLDR
Quick usage examples

## What It Does
Detailed description

## When to Use
Use cases

## Execution
How it works

## Options
Available parameters

## Example Usage
Real examples

## Output
What gets created

## Next Steps
What to do after

## Troubleshooting
Common issues

## Related Commands
See also
```

## Usage

Commands are invoked by typing `/command-name` in Claude Code.

Example:
```
/flow-init --type=greenfield
/flow-specify "Add user authentication"
/status
```

## Creating New Commands

1. Create new `.md` file in this directory
2. Follow the command format template
3. Add TLDR section for quick reference
4. Include examples and troubleshooting
5. Document state updates if applicable

See `WORKFLOW-EXPANSION-GUIDE.md` for detailed instructions.

## State Integration

Commands should update state files when appropriate:

- `__specification__-state/current-session.md` - Current session state
- `__specification__-memory/WORKFLOW-PROGRESS.md` - Progress tracking
- `__specification__-memory/DECISIONS-LOG.md` - Decision history

See `../skills/SKILL-STATE-INTEGRATION.md` for integration patterns.

## Testing

Test commands with:
```bash
/command-name --dry-run        # Preview without executing
/command-name --verbose        # Detailed output
```

## Documentation

- Full command reference: `COMMANDS-QUICK-REFERENCE.md`
- User guide: `USER-GUIDE.md`
- Expansion guide: `WORKFLOW-EXPANSION-GUIDE.md`

---

**Adding a new command?** Copy an existing command as template, modify for your needs.
