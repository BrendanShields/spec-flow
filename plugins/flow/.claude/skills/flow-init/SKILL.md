---
name: flow:init
description: Initialize a new project with Flow workflow configuration, choosing between greenfield or brownfield, and optionally setting up integrations.
---

# Flow Init

Initialize a Flow project with configuration and structure setup.

## Usage

```
flow:init
flow:init --type greenfield
flow:init --type brownfield --integrations jira,confluence
```

## What It Does

1. Detects or sets project type (greenfield/brownfield)
2. Creates `.specify/` directory structure
3. Optionally configures JIRA/Confluence integration
4. Sets up templates and scripts
5. Creates initial configuration file
