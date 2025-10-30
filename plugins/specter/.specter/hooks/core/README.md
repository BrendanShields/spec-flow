# Core Specter Hooks

Built-in hooks that maintain Specter state consistency.

## Hooks

- **post-command.sh**: Updates session state after commands
- **on-task-complete.sh**: Updates progress when tasks complete
- **pre-commit.sh**: Validates state before git commits
- **post-merge.sh**: Synchronizes state after git merges

Do not modify these files directly. To customize behavior, create hooks in `../custom/`.
