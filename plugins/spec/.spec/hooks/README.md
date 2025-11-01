# Spec Hooks

This directory contains hooks that automatically trigger on workflow events.

## Structure

```
hooks/
├── core/           # Built-in Spec hooks
├── custom/         # User-defined hooks
└── config.json     # Hook configuration
```

## Core Hooks

- **post-command.sh**: Runs after every `/spec` command
- **on-task-complete.sh**: Runs when a task is marked complete
- **pre-commit.sh**: Runs before git commit (validation)
- **post-merge.sh**: Runs after git pull/merge (synchronization)

## Custom Hooks

Users can add custom hooks in the `custom/` directory. See `CUSTOM-HOOKS-API.md` for details.

## Configuration

Edit `config.json` to enable/disable hooks or adjust settings.
