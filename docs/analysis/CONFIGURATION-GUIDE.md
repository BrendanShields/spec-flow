# Spec Configuration Guide

A comprehensive guide to customizing and optimizing Spec workflow for your project.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Configuration Basics](#configuration-basics)
3. [Common Configurations](#common-configurations)
4. [Advanced Customization](#advanced-customization)
5. [Project Type Templates](#project-type-templates)
6. [Integration Setup](#integration-setup)
7. [Performance Tuning](#performance-tuning)
8. [Troubleshooting](#troubleshooting)
9. [Migration Guide](#migration-guide)
10. [Best Practices](#best-practices)

## Quick Start

### Zero Configuration

Spec works out of the box with sensible defaults:

```bash
# Initialize with auto-detection
spec init

# Spec automatically detects:
# - Project type (web app, service, library)
# - Language and framework
# - Existing tooling (git, npm, docker)
# - Optimal workflow settings
```

### Basic Configuration

Create `.spec/config.yaml` for basic customization:

```yaml
version: "1.0.0"

# Customize workflow behavior
workflow:
  phases:
    build:
      require_tests: true      # Enforce test requirement
      auto_commit: true        # Auto-commit after tasks

# Enable GitHub integration
integrations:
  github:
    enabled: true
    create_prs: true
```

### Check Current Configuration

```bash
# View effective configuration
spec config show

# Show configuration with source
spec config show --with-source

# Show only differences from defaults
spec config diff
```

## Configuration Basics

### Configuration Hierarchy

Spec resolves configuration from multiple sources (highest to lowest priority):

1. **Command Flags** → `spec generate --template=advanced`
2. **User Settings** → `~/.spec/config.yaml`
3. **Project Config** → `.spec/config.yaml`
4. **Workspace Config** → `.spec/workspace.yaml` (monorepos)
5. **Auto-Detected** → Smart defaults based on your project
6. **Built-in Defaults** → Spec's default settings

### File Formats

Spec supports multiple configuration formats:

```yaml
# YAML (recommended)
version: "1.0.0"
workflow:
  phases:
    build:
      max_parallel_tasks: 5
```

```json
// JSON
{
  "version": "1.0.0",
  "workflow": {
    "phases": {
      "build": {
        "max_parallel_tasks": 5
      }
    }
  }
}
```

```toml
# TOML
version = "1.0.0"

[workflow.phases.build]
max_parallel_tasks = 5
```

### Environment Variables

Override any setting via environment variables:

```bash
# Format: SPEC_<SECTION>_<KEY>
export SPEC_WORKFLOW_PHASES_BUILD_MAX_PARALLEL_TASKS=5
export SPEC_PATHS_FEATURES=specifications
export SPEC_LOGGING_LEVEL=debug

spec generate "New feature"  # Uses env overrides
```

## Common Configurations

### Test-Driven Development

```yaml
version: "1.0.0"

workflow:
  skills:
    implement:
      test_first: true         # Write tests before code
      auto_fix_tests: true     # Auto-fix failing tests

  phases:
    build:
      require_tests: true      # Block completion without tests

validation:
  rules:
    tasks:
      max_task_size: "M"       # Keep tasks small
```

### Continuous Integration

```yaml
version: "1.0.0"

workflow:
  phases:
    track:
      checkpoint_frequency: "skill"  # Checkpoint after each skill

integrations:
  git:
    auto_branch: true          # Create feature branches
    commit_format: "conventional"  # Use conventional commits

  github:
    create_prs: true           # Auto-create pull requests
    require_reviews: 2         # Require 2 reviews
```

### Team Collaboration

```yaml
version: "1.0.0"

workflow:
  skills:
    clarify:
      require_user_confirmation: true  # Require approval
      max_questions_per_round: 5       # Batch questions

integrations:
  slack:
    enabled: true
    notifications:
      on_phase_complete: true   # Notify on phase completion
      on_error: true            # Alert on errors

  jira:
    enabled: true
    sync_mode: "bidirectional" # Two-way sync with Jira
```

### Documentation Focus

```yaml
version: "1.0.0"

workflow:
  phases:
    define:
      require_acceptance_criteria: true
      require_user_stories: true

    design:
      require_adr: true         # Architecture Decision Records
      require_diagrams: true    # Include diagrams

integrations:
  confluence:
    enabled: true
    auto_publish: true          # Auto-publish to Confluence
```

## Advanced Customization

### Custom Directory Structure

```yaml
version: "1.0.0"

paths:
  root: ".specification"        # Rename spec directory
  features: "requirements"      # Rename features directory
  state: ".spec-session"        # Rename state directory

  naming:
    feature_dir: "{name}"       # Simple names (no ID prefix)
    spec_file: "requirements.md"
    plan_file: "design.md"
    task_file: "implementation.md"
```

### Multi-Agent Configuration

```yaml
version: "1.0.0"

agents:
  coordinator:
    strategy: "adaptive"        # Adaptive coordination
    max_concurrent: 5          # Allow 5 concurrent agents

  implementer:
    parallel_execution: true
    error_handling: "pause"     # Pause on errors

  researcher:
    sources: ["web", "docs", "codebase"]
    max_search_depth: 5        # Deep research

  analyzer:
    validation_level: "strict"  # Strict validation
    suggest_improvements: true
```

### Progressive Disclosure Control

```yaml
version: "1.0.0"

performance:
  optimization:
    lazy_loading: true         # Load on demand
    progressive_disclosure: true
    token_budget:
      skill: 1500              # Base skill tokens
      with_examples: 6600      # With examples
      with_reference: 11600    # With full reference
```

### Custom Validation Rules

```yaml
version: "1.0.0"

validation:
  strict_mode: true            # Fail on warnings

  rules:
    spec:
      required_sections:
        - "overview"
        - "user_stories"
        - "acceptance_criteria"
        - "non_functional_requirements"
      min_user_stories: 3
      min_acceptance_criteria: 5

    plan:
      require_diagrams: true
      require_estimates: true

    naming:
      feature_pattern: "^[A-Z]+-[0-9]+$"  # JIRA-style
      enforce: true
```

### Template Customization

```yaml
version: "1.0.0"

templates:
  source: "mixed"              # Use both built-in and custom

  customization:
    allow_override: true       # Override built-in templates
    merge_strategy: "overlay"  # Merge custom with built-in

  variables:                   # Template variables
    company: "Acme Corp"
    team: "Platform Team"
    author: "${USER}"
    email: "${USER}@acme.com"

  selection:
    by_project_type:
      application: "enterprise-app"
      service: "microservice"
      library: "component-library"
```

## Project Type Templates

### Web Application

```yaml
# .spec/config.yaml for React/Vue/Angular apps
version: "1.0.0"

project:
  type: "application"
  framework: "react"           # or vue, angular

workflow:
  skills:
    implement:
      test_first: true         # Component tests first

templates:
  selection:
    default_template: "web-app"

integrations:
  github:
    create_prs: true
    pr_template: "web-app"
```

### Microservice

```yaml
# .spec/config.yaml for microservices
version: "1.0.0"

project:
  type: "service"
  language: "go"               # or python, java

workflow:
  phases:
    design:
      require_adr: true        # Architecture decisions

    build:
      max_parallel_tasks: 1    # Sequential for dependencies

agents:
  researcher:
    sources: ["docs", "openapi", "grpc"]

templates:
  selection:
    default_template: "microservice"
```

### Library/Package

```yaml
# .spec/config.yaml for libraries
version: "1.0.0"

project:
  type: "library"
  language: "typescript"

workflow:
  phases:
    define:
      require_api_docs: true   # API documentation

    build:
      require_tests: true      # 100% test coverage

validation:
  rules:
    spec:
      required_sections:
        - "api_surface"
        - "breaking_changes"
        - "migration_guide"
```

### Monorepo

```yaml
# .spec/workspace.yaml at monorepo root
version: "1.0.0"

project:
  type: "monorepo"

paths:
  root: ".workspace/spec"
  features: "specs"

workflow:
  phases:
    build:
      max_parallel_tasks: 8    # Parallel package builds

# Package-specific overrides
packages:
  - path: "packages/ui"
    config:
      workflow:
        skills:
          implement:
            test_first: true

  - path: "services/api"
    config:
      integrations:
        github:
          require_reviews: 2
```

## Integration Setup

### GitHub Integration

```yaml
version: "1.0.0"

integrations:
  github:
    enabled: true
    create_issues: true        # Create issues from specs
    create_prs: true          # Auto-create PRs
    pr_template: |
      ## Summary
      ${description}

      ## Spec
      [View Specification](${spec_url})

      ## Tasks
      ${task_list}

      ## Testing
      ${test_plan}
    require_reviews: 1
    auto_merge: false         # Manual merge
```

### Jira Integration

```yaml
version: "1.0.0"

integrations:
  jira:
    enabled: true
    base_url: "https://company.atlassian.net"
    project_key: "PROJ"
    api_token: "${JIRA_API_TOKEN}"  # From environment
    sync_mode: "bidirectional"       # Two-way sync

    field_mapping:
      spec_id: "customfield_10001"
      epic_link: "customfield_10002"
      story_points: "customfield_10003"
```

### Slack Notifications

```yaml
version: "1.0.0"

integrations:
  slack:
    enabled: true
    webhook_url: "${SLACK_WEBHOOK}"  # From environment
    channel: "#dev-team"

    notifications:
      on_phase_complete: true
      on_error: true
      on_feature_complete: true

    message_format: |
      :rocket: *${event_type}*
      Feature: ${feature_name}
      Phase: ${phase}
      Status: ${status}
      ${details}
```

### Confluence Documentation

```yaml
version: "1.0.0"

integrations:
  confluence:
    enabled: true
    base_url: "https://company.atlassian.net/wiki"
    space_key: "ENG"
    parent_page_id: "123456"
    api_token: "${CONFLUENCE_TOKEN}"

    auto_publish: true        # Auto-publish specs
    template: "technical-spec"

    page_hierarchy:
      - "Product Specs"
      - "${project_name}"
      - "${feature_name}"
```

## Performance Tuning

### Token Optimization

```yaml
version: "1.0.0"

performance:
  optimization:
    lazy_loading: true        # Load only what's needed
    progressive_disclosure: true

    token_budget:
      skill: 1000            # Reduce base tokens
      with_examples: 5000    # Limit examples

  cache:
    enabled: true
    ttl_seconds: 7200       # 2-hour cache
    max_size_mb: 50         # Limit cache size
```

### Parallel Execution

```yaml
version: "1.0.0"

workflow:
  phases:
    build:
      max_parallel_tasks: 8   # Increase parallelism

agents:
  coordinator:
    strategy: "parallel"      # Parallel by default
    max_concurrent: 8

performance:
  parallel:
    enabled: true
    max_workers: 8
    task_queue_size: 200
```

### Resource Limits

```yaml
version: "1.0.0"

agents:
  coordinator:
    timeout_seconds: 600      # 10-minute timeout
    retry_policy:
      max_attempts: 2         # Reduce retries

performance:
  cache:
    max_size_mb: 100         # Cache limit

logging:
  file:
    max_files: 3             # Limit log files
    rotation: "size"         # Rotate by size
```

## Troubleshooting

### Common Issues

#### Configuration Not Loading

```bash
# Check configuration loading
spec config show --debug

# Validate configuration
spec config validate

# Show configuration sources
spec config sources
```

#### Integration Authentication Failures

```yaml
# Use environment variables for secrets
integrations:
  github:
    api_token: "${GITHUB_TOKEN}"  # From environment

  jira:
    api_token: "${JIRA_TOKEN}"    # From environment
```

```bash
# Set environment variables
export GITHUB_TOKEN="ghp_..."
export JIRA_TOKEN="..."
```

#### Performance Issues

```yaml
# Reduce token usage
performance:
  optimization:
    lazy_loading: true
    token_budget:
      skill: 1000            # Minimal tokens

# Reduce parallelism
workflow:
  phases:
    build:
      max_parallel_tasks: 2  # Less parallel work
```

#### Validation Errors

```bash
# Show validation errors
spec config validate --verbose

# Show specific field
spec config get workflow.phases.build

# Test with dry run
spec generate --dry-run --config=test-config.yaml
```

### Debug Mode

```yaml
version: "1.0.0"

logging:
  level: "debug"             # Enable debug logging
  destinations:
    console:
      enabled: true
      format: "pretty"       # Readable format
    file:
      enabled: true
      path: ".spec/debug.log"
```

```bash
# Run with debug output
SPEC_LOGGING_LEVEL=debug spec generate "Feature"

# Check debug log
tail -f .spec/debug.log
```

## Migration Guide

### From Version 2.x to 3.0

```bash
# Auto-migrate configuration
spec config migrate

# Dry run migration
spec config migrate --dry-run

# Manual migration
spec config migrate --input=old-config.json --output=.spec/config.yaml
```

### From Other Tools

#### From Jira-based Workflow

```yaml
# Map Jira concepts to Spec
version: "1.0.0"

integrations:
  jira:
    enabled: true
    sync_mode: "bidirectional"

paths:
  naming:
    feature_dir: "{jira_key}-{name}"  # PROJ-123-feature

workflow:
  skills:
    generate:
      template: "jira-story"          # Jira-compatible
```

#### From GitHub Issues Workflow

```yaml
# Map GitHub Issues to Spec
version: "1.0.0"

integrations:
  github:
    enabled: true
    create_issues: true
    import_issues: true       # Import existing issues

templates:
  selection:
    default_template: "github-issue"
```

## Best Practices

### Start Simple

Begin with minimal configuration and add as needed:

```yaml
# Start with this
version: "1.0.0"

# Add configuration as you learn what you need
workflow:
  phases:
    build:
      require_tests: true    # Add when ready for TDD
```

### Use Environment Variables for Secrets

Never commit secrets to configuration files:

```yaml
# Good
integrations:
  github:
    api_token: "${GITHUB_TOKEN}"

# Bad (never do this)
integrations:
  github:
    api_token: "ghp_ActualTokenHere"  # DON'T DO THIS
```

### Version Control Configuration

```bash
# Always commit configuration
git add .spec/config.yaml
git commit -m "Add Spec configuration"

# Ignore state but keep memory
echo ".spec-state/" >> .gitignore
# .spec-memory/ is committed for history
```

### Team Consistency

Share configuration across team:

```yaml
# Team-wide settings in ~/.spec/config.yaml
version: "1.0.0"

templates:
  variables:
    company: "Acme Corp"
    team: "Platform Team"

integrations:
  slack:
    channel: "#platform-team"
```

### Progressive Enhancement

Enable features gradually:

```yaml
# Week 1: Basic workflow
version: "1.0.0"

# Week 2: Add testing
workflow:
  phases:
    build:
      require_tests: true

# Week 3: Add integrations
integrations:
  github:
    enabled: true

# Week 4: Add metrics
workflow:
  phases:
    track:
      metrics_enabled: true
```

### Monitor and Adjust

```bash
# Check metrics
spec metrics show

# Analyze workflow efficiency
spec metrics analyze

# Adjust configuration based on data
spec config recommend
```

## Configuration Commands

### Essential Commands

```bash
# Show current configuration
spec config show

# Validate configuration
spec config validate

# Show configuration source
spec config show --with-source

# Get specific value
spec config get workflow.phases.build

# Set specific value
spec config set workflow.phases.build.max_parallel_tasks 5

# Reset to defaults
spec config reset
```

### Advanced Commands

```bash
# Show effective configuration for a command
spec config effective --command="spec generate"

# Export configuration
spec config export --format=json > config.json

# Import configuration
spec config import --file=config.json

# Diff configurations
spec config diff --file1=old.yaml --file2=new.yaml

# Generate configuration from project analysis
spec config generate --analyze

# Get configuration recommendations
spec config recommend

# Validate against schema
spec config validate --schema=v1.0.0
```

## Quick Reference

### Most Common Settings

| Setting | Default | Common Values | Description |
|---------|---------|---------------|-------------|
| `workflow.phases.build.max_parallel_tasks` | 3 | 1-8 | Parallel task execution |
| `workflow.phases.build.require_tests` | false | true | Require tests |
| `workflow.phases.build.auto_commit` | false | true | Auto-commit changes |
| `workflow.skills.implement.test_first` | false | true | TDD mode |
| `integrations.github.create_prs` | false | true | Auto-create PRs |
| `integrations.slack.enabled` | false | true | Slack notifications |
| `validation.strict_mode` | false | true | Strict validation |
| `logging.level` | info | debug, error | Log level |

### Configuration File Locations

| File | Purpose | Version Control |
|------|---------|-----------------|
| `.spec/config.yaml` | Project configuration | ✅ Commit |
| `~/.spec/config.yaml` | User preferences | ❌ Don't commit |
| `.spec/workspace.yaml` | Monorepo config | ✅ Commit |
| `.env` | Secrets | ❌ Don't commit |

---

**Version**: 1.0.0
**Last Updated**: 2024-11-02
**More Info**: See [CONFIGURATION-SCHEMA.md](./CONFIGURATION-SCHEMA.md) for complete schema reference