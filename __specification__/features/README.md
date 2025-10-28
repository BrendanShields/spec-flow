# Features Directory

This directory contains all feature specifications, plans, and tasks for the Spec-Flow marketplace.

## Structure

Each feature gets its own directory:

```
features/
├── 001-feature-name/
│   ├── spec.md         # Feature specification with user stories
│   ├── plan.md         # Technical design and architecture
│   └── tasks.md        # Implementation task breakdown
│
├── 002-another-feature/
│   ├── spec.md
│   ├── plan.md
│   └── tasks.md
│
└── README.md           # This file
```

## Naming Convention

- Feature directories use format: `###-kebab-case-name`
- Numbers are zero-padded (001, 002, etc.)
- Names are descriptive but concise

## Workflow

1. **Create Specification**: `/flow-specify "Feature description"`
2. **Create Plan**: `/flow-plan`
3. **Generate Tasks**: `/flow-tasks`
4. **Implement**: `/flow-implement`
5. **Validate**: `/validate`

## Feature Status

Check `.flow-memory/WORKFLOW-PROGRESS.md` for current status of all features.

## Getting Started

Create your first feature:
```bash
/flow-specify "Your feature description here"
```

Flow will create the directory structure and guide you through the rest.
