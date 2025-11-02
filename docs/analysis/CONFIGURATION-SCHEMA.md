# Spec Configuration Schema v1.0.0

## Overview

The Spec workflow configuration system provides a comprehensive, type-safe, and extensible configuration management approach with multiple levels of precedence, auto-detection, and validation. This document defines the complete configuration schema with all options, defaults, validation rules, and examples.

## Schema Version

```yaml
version: "1.0.0"
schema: "https://spec.dev/schemas/config/v1.0.0.json"
```

## Configuration Levels & Precedence

Configuration is resolved in the following order (highest to lowest precedence):

1. **Runtime Flags** - Command-line arguments
2. **User Config** - `~/.spec/config.yaml`
3. **Project Config** - `.spec/config.yaml`
4. **Workspace Config** - `.spec/workspace.yaml` (monorepo)
5. **Global Config** - `/etc/spec/config.yaml`
6. **Auto-Detected** - Smart defaults based on project
7. **Built-in Defaults** - Hardcoded fallbacks

## Complete Configuration Schema

```yaml
# Spec Configuration Schema v1.0.0
version: "1.0.0"
schema: "https://spec.dev/schemas/config/v1.0.0.json"

# Project Metadata
project:
  name: string                     # Project name (auto-detected from package.json/pom.xml)
  type: enum                       # Project type (auto-detected)
    - "application"
    - "library"
    - "service"
    - "monorepo"
    - "plugin"
    - "framework"
  language: enum                   # Primary language (auto-detected)
    - "typescript"
    - "javascript"
    - "python"
    - "java"
    - "go"
    - "rust"
    - "ruby"
    - "csharp"
    - "swift"
    - "kotlin"
    - "mixed"
  framework: string                # Framework name (auto-detected)
  description: string              # Project description
  version: semver                  # Project version
  repository: url                  # Repository URL (auto-detected from git)

# Directory Structure
paths:
  root: path                       # Spec root directory
    default: ".spec"
    validation: "must be relative to project root"

  features: path                   # Features directory
    default: "features"
    validation: "must be relative to project root"

  state: path                      # State directory
    default: ".spec-state"
    validation: "must be relative to project root"
    gitignore: true

  memory: path                     # Memory directory
    default: ".spec-memory"
    validation: "must be relative to project root"
    gitignore: false

  templates: path                  # Custom templates directory
    default: ".spec/templates"
    validation: "must exist if specified"

  scripts: path                    # Custom scripts directory
    default: ".spec/scripts"
    validation: "must exist if specified"

  artifacts: path                  # Generated artifacts directory
    default: ".spec/artifacts"
    validation: "created if not exists"

  # Naming patterns with variables
  naming:
    feature_dir: pattern           # Feature directory naming
      default: "{id}-{name}"       # e.g., "003-user-auth"
      variables: ["id", "name", "date", "author"]

    spec_file: pattern             # Specification file naming
      default: "spec.md"
      alternatives: ["specification.md", "{name}-spec.md"]

    plan_file: pattern             # Plan file naming
      default: "plan.md"
      alternatives: ["design.md", "technical-plan.md"]

    task_file: pattern             # Task file naming
      default: "tasks.md"
      alternatives: ["implementation.md", "breakdown.md"]

# Workflow Configuration
workflow:
  # Phase Configuration
  phases:
    initialize:
      enabled: boolean             # Enable initialization phase
        default: true
      auto_detect: boolean         # Auto-detect project structure
        default: true
      create_directories: boolean  # Create directory structure
        default: true
      generate_templates: boolean  # Generate initial templates
        default: true

    define:
      enabled: boolean
        default: true
      require_acceptance_criteria: boolean
        default: true
      require_user_stories: boolean
        default: true
      max_clarifications: integer
        default: 5
        min: 1
        max: 10

    design:
      enabled: boolean
        default: true
      require_adr: boolean         # Require Architecture Decision Records
        default: true
      require_diagrams: boolean    # Require architecture diagrams
        default: false
      validate_consistency: boolean
        default: true

    build:
      enabled: boolean
        default: true
      max_parallel_tasks: integer
        default: 3
        min: 1
        max: 10
      require_tests: boolean
        default: true
      auto_commit: boolean
        default: false

    track:
      enabled: boolean
        default: true
      checkpoint_frequency: enum
        default: "phase"
        values: ["never", "phase", "skill", "always"]
      metrics_enabled: boolean
        default: true
      update_on_complete: boolean
        default: true

  # Skill-Specific Configuration
  skills:
    init:
      brownfield_analysis: boolean # Analyze existing codebase
        default: true
      interactive_mode: boolean
        default: true

    generate:
      template: string             # Default template to use
        default: "standard"
      include_examples: boolean
        default: true
      priority_system: enum
        default: "moscow"
        values: ["moscow", "numeric", "fibonacci", "tshirt"]

    clarify:
      max_questions_per_round: integer
        default: 4
        min: 1
        max: 10
      auto_resolve_obvious: boolean
        default: false
      require_user_confirmation: boolean
        default: true

    plan:
      research_mode: enum
        default: "on_demand"
        values: ["always", "on_demand", "never"]
      include_alternatives: boolean
        default: true
      risk_assessment: boolean
        default: true

    tasks:
      breakdown_strategy: enum
        default: "functional"
        values: ["functional", "technical", "hybrid", "epic"]
      estimate_effort: boolean
        default: false
      dependency_tracking: enum
        default: "automatic"
        values: ["automatic", "manual", "none"]

    implement:
      execution_mode: enum
        default: "sequential"
        values: ["sequential", "parallel", "hybrid"]
      test_first: boolean          # TDD mode
        default: false
      auto_fix_tests: boolean
        default: true
      commit_strategy: enum
        default: "per_task"
        values: ["per_task", "per_feature", "manual"]

    orchestrate:
      mode: enum
        default: "interactive"
        values: ["interactive", "automatic", "supervised"]
      skip_phases: array[string]
        default: []
        allowed: ["clarify", "analyze"]
      pause_points: array[string]
        default: ["after_plan", "before_implement"]

    analyze:
      depth: enum
        default: "standard"
        values: ["shallow", "standard", "deep"]
      check_patterns: boolean
        default: true
      validate_naming: boolean
        default: true

    metrics:
      collect: array[string]
        default: ["velocity", "cycle_time", "defect_rate"]
      reporting_format: enum
        default: "markdown"
        values: ["markdown", "json", "csv", "html"]
      dashboard_enabled: boolean
        default: false

# Sub-Agent Configuration
agents:
  coordinator:
    strategy: enum                 # Coordination strategy
      default: "adaptive"
      values: ["sequential", "parallel", "hybrid", "adaptive"]
    max_concurrent: integer        # Max concurrent agents
      default: 3
      min: 1
      max: 10
    timeout_seconds: integer       # Agent timeout
      default: 300
      min: 60
      max: 3600
    retry_policy:
      max_attempts: integer
        default: 3
      backoff_strategy: enum
        default: "exponential"
        values: ["linear", "exponential", "fixed"]

  implementer:
    enabled: boolean
      default: true
    parallel_execution: boolean
      default: true
    progress_reporting: enum
      default: "detailed"
      values: ["none", "summary", "detailed"]
    error_handling: enum
      default: "pause"
      values: ["fail", "skip", "pause", "retry"]

  researcher:
    enabled: boolean
      default: true
    sources: array[string]
      default: ["web", "docs", "codebase"]
    max_search_depth: integer
      default: 3
    cache_results: boolean
      default: true

  analyzer:
    enabled: boolean
      default: true
    validation_level: enum
      default: "standard"
      values: ["minimal", "standard", "strict"]
    check_cross_references: boolean
      default: true
    suggest_improvements: boolean
      default: true

# Data Source Configuration
data_sources:
  mcp_servers:
    - name: string
      enabled: boolean
      endpoint: url
      authentication:
        type: enum
          values: ["none", "api_key", "oauth", "basic"]
        credentials: encrypted_string
      timeout: integer
        default: 30
      retry: integer
        default: 3
      cache:
        enabled: boolean
          default: true
        ttl_seconds: integer
          default: 3600

  apis:
    - name: string
      base_url: url
      version: string
      rate_limit:
        requests_per_minute: integer
        burst: integer
      headers: map[string, string]
      query_params: map[string, string]

  databases:
    - name: string
      type: enum
        values: ["postgresql", "mysql", "mongodb", "redis"]
      connection_string: encrypted_string
      pool_size: integer
        default: 10
      read_only: boolean
        default: true

# Integration Configuration
integrations:
  git:
    enabled: boolean
      default: true
    auto_branch: boolean           # Auto-create feature branches
      default: true
    branch_naming: pattern
      default: "feature/{id}-{name}"
    commit_format: enum
      default: "conventional"
      values: ["conventional", "angular", "custom"]
    sign_commits: boolean
      default: false

  jira:
    enabled: boolean
      default: false
    base_url: url
    project_key: string
    api_token: encrypted_string
    sync_mode: enum
      default: "manual"
      values: ["manual", "automatic", "bidirectional"]
    field_mapping:
      spec_id: string
        default: "customfield_10001"
      epic_link: string
        default: "customfield_10002"

  github:
    enabled: boolean
      default: true
    create_issues: boolean
      default: false
    create_prs: boolean
      default: true
    pr_template: string
    require_reviews: integer
      default: 1
    auto_merge: boolean
      default: false

  slack:
    enabled: boolean
      default: false
    webhook_url: encrypted_url
    channel: string
    notifications:
      on_phase_complete: boolean
        default: true
      on_error: boolean
        default: true
      on_feature_complete: boolean
        default: true

  confluence:
    enabled: boolean
      default: false
    base_url: url
    space_key: string
    parent_page_id: string
    api_token: encrypted_string
    auto_publish: boolean
      default: false
    template: string

# Template Configuration
templates:
  source: enum                     # Template source
    default: "built_in"
    values: ["built_in", "project", "remote", "mixed"]

  remote_repository: url           # Remote template repository

  customization:
    allow_override: boolean        # Allow project templates to override
      default: true
    merge_strategy: enum           # How to merge templates
      default: "overlay"
      values: ["replace", "overlay", "merge"]

  variables:                       # Template variables
    project_name: string
    company: string
    team: string
    author: string
    email: string
    custom: map[string, any]

  selection:
    auto_detect: boolean           # Auto-select based on project type
      default: true
    default_template: string       # Default template name
      default: "standard"
    by_project_type:               # Template mapping by project type
      application: string
        default: "web-app"
      library: string
        default: "library"
      service: string
        default: "microservice"
      monorepo: string
        default: "monorepo"

# Validation Configuration
validation:
  enabled: boolean
    default: true

  on_save: boolean                 # Validate before saving
    default: true

  on_phase_complete: boolean       # Validate at phase boundaries
    default: true

  strict_mode: boolean             # Fail on warnings
    default: false

  rules:
    spec:
      required_sections: array[string]
        default: ["overview", "user_stories", "acceptance_criteria"]
      min_user_stories: integer
        default: 1
      min_acceptance_criteria: integer
        default: 3

    plan:
      required_sections: array[string]
        default: ["approach", "architecture", "risks"]
      require_diagrams: boolean
        default: false
      require_estimates: boolean
        default: false

    tasks:
      max_task_size: string        # Max task size (XS, S, M, L, XL)
        default: "L"
      require_dependencies: boolean
        default: true
      require_assignments: boolean
        default: false

    naming:
      feature_pattern: regex
        default: "^[0-9]{3}-[a-z-]+$"
      file_pattern: regex
        default: "^[a-z-]+\\.md$"
      enforce: boolean
        default: true

# Performance Configuration
performance:
  cache:
    enabled: boolean
      default: true
    directory: path
      default: ".spec/.cache"
    ttl_seconds: integer
      default: 86400
    max_size_mb: integer
      default: 100

  parallel:
    enabled: boolean
      default: true
    max_workers: integer
      default: 4
    task_queue_size: integer
      default: 100

  optimization:
    lazy_loading: boolean          # Load resources on demand
      default: true
    progressive_disclosure: boolean
      default: true
    token_budget:
      skill: integer
        default: 1500
      with_examples: integer
        default: 6600
      with_reference: integer
        default: 11600

# Logging & Monitoring
logging:
  level: enum
    default: "info"
    values: ["debug", "info", "warning", "error", "critical"]

  destinations:
    console:
      enabled: boolean
        default: true
      format: enum
        default: "text"
        values: ["text", "json", "pretty"]

    file:
      enabled: boolean
        default: true
      path: path
        default: ".spec/logs/spec.log"
      rotation: enum
        default: "daily"
        values: ["never", "daily", "weekly", "size"]
      max_files: integer
        default: 7

    remote:
      enabled: boolean
        default: false
      endpoint: url
      api_key: encrypted_string
      batch_size: integer
        default: 100
      flush_interval: integer
        default: 60

# Security Configuration
security:
  encryption:
    enabled: boolean
      default: true
    algorithm: enum
      default: "aes256"
      values: ["aes256", "rsa4096", "chacha20"]
    key_storage: enum
      default: "system"
      values: ["system", "file", "env", "vault"]

  secrets:
    scan_on_save: boolean          # Scan for secrets before commit
      default: true
    patterns: array[regex]
      default:
        - "(?i)api[_-]?key"
        - "(?i)secret"
        - "(?i)password"
        - "(?i)token"
    exclude_paths: array[pattern]
      default:
        - "*.example"
        - "*.sample"
        - "docs/**"

  authentication:
    require_auth: boolean
      default: false
    providers: array[string]
      default: ["github", "gitlab", "bitbucket"]
    sso_enabled: boolean
      default: false

# Experimental Features
experimental:
  ai_suggestions:
    enabled: boolean
      default: false
    confidence_threshold: float
      default: 0.8
    auto_apply: boolean
      default: false

  smart_context:
    enabled: boolean
      default: false
    max_context_size: integer
      default: 100000
    relevance_scoring: boolean
      default: true

  workflow_learning:
    enabled: boolean
      default: false
    adapt_to_patterns: boolean
      default: true
    suggest_improvements: boolean
      default: true
```

## JSON Schema Definition

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://spec.dev/schemas/config/v1.0.0.json",
  "title": "Spec Configuration Schema",
  "description": "Configuration schema for Spec workflow system",
  "type": "object",
  "required": ["version"],
  "additionalProperties": false,
  "properties": {
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$",
      "description": "Configuration schema version"
    },
    "project": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 100
        },
        "type": {
          "type": "string",
          "enum": ["application", "library", "service", "monorepo", "plugin", "framework"]
        },
        "language": {
          "type": "string",
          "enum": ["typescript", "javascript", "python", "java", "go", "rust", "ruby", "csharp", "swift", "kotlin", "mixed"]
        },
        "framework": {
          "type": "string"
        },
        "description": {
          "type": "string",
          "maxLength": 500
        },
        "version": {
          "type": "string",
          "pattern": "^\\d+\\.\\d+\\.\\d+(-[a-zA-Z0-9]+)?(\\+[a-zA-Z0-9]+)?$"
        },
        "repository": {
          "type": "string",
          "format": "uri"
        }
      }
    },
    "paths": {
      "type": "object",
      "properties": {
        "root": {
          "type": "string",
          "default": ".spec"
        },
        "features": {
          "type": "string",
          "default": "features"
        },
        "state": {
          "type": "string",
          "default": ".spec-state"
        },
        "memory": {
          "type": "string",
          "default": ".spec-memory"
        },
        "templates": {
          "type": "string",
          "default": ".spec/templates"
        },
        "scripts": {
          "type": "string",
          "default": ".spec/scripts"
        },
        "artifacts": {
          "type": "string",
          "default": ".spec/artifacts"
        },
        "naming": {
          "type": "object",
          "properties": {
            "feature_dir": {
              "type": "string",
              "default": "{id}-{name}"
            },
            "spec_file": {
              "type": "string",
              "default": "spec.md"
            },
            "plan_file": {
              "type": "string",
              "default": "plan.md"
            },
            "task_file": {
              "type": "string",
              "default": "tasks.md"
            }
          }
        }
      }
    }
  }
}
```

## Configuration Examples

### Minimal Configuration

```yaml
# .spec/config.yaml - Minimal configuration
version: "1.0.0"
```

### Standard Web Application

```yaml
# .spec/config.yaml - Web application
version: "1.0.0"

project:
  type: "application"
  framework: "react"

workflow:
  phases:
    design:
      require_diagrams: true
    build:
      require_tests: true
      auto_commit: true

integrations:
  github:
    enabled: true
    create_prs: true
```

### Microservice Configuration

```yaml
# .spec/config.yaml - Microservice
version: "1.0.0"

project:
  type: "service"
  language: "go"

paths:
  features: "specs"
  naming:
    feature_dir: "{name}"
    spec_file: "{name}.spec.yaml"

workflow:
  skills:
    plan:
      research_mode: "always"
      include_alternatives: true
    implement:
      test_first: true

agents:
  coordinator:
    strategy: "parallel"
    max_concurrent: 5

integrations:
  github:
    enabled: true
  slack:
    enabled: true
    notifications:
      on_phase_complete: true
```

### Monorepo Configuration

```yaml
# .spec/workspace.yaml - Monorepo root
version: "1.0.0"

project:
  type: "monorepo"

paths:
  root: ".workspace/spec"
  features: "specs/features"

workflow:
  phases:
    initialize:
      auto_detect: true
    build:
      max_parallel_tasks: 8

agents:
  coordinator:
    strategy: "adaptive"
    max_concurrent: 8

# Package-specific overrides
packages:
  - path: "packages/ui"
    config:
      project:
        type: "library"
        framework: "react"
      workflow:
        skills:
          implement:
            test_first: true

  - path: "services/api"
    config:
      project:
        type: "service"
        language: "python"
        framework: "fastapi"
```

### Enterprise Configuration

```yaml
# .spec/config.yaml - Enterprise with full integrations
version: "1.0.0"

project:
  type: "application"
  name: "enterprise-app"

workflow:
  phases:
    define:
      require_acceptance_criteria: true
      max_clarifications: 10
    design:
      require_adr: true
      require_diagrams: true
    track:
      checkpoint_frequency: "skill"
      metrics_enabled: true

agents:
  coordinator:
    strategy: "hybrid"
    timeout_seconds: 600
  researcher:
    sources: ["web", "docs", "confluence", "jira"]

integrations:
  jira:
    enabled: true
    base_url: "https://company.atlassian.net"
    project_key: "PROJ"
    sync_mode: "bidirectional"

  confluence:
    enabled: true
    base_url: "https://company.atlassian.net/wiki"
    space_key: "ENG"
    auto_publish: true

  github:
    enabled: true
    require_reviews: 2

  slack:
    enabled: true
    channel: "#dev-team"

validation:
  strict_mode: true
  rules:
    spec:
      min_user_stories: 3
      min_acceptance_criteria: 5
    plan:
      require_diagrams: true
      require_estimates: true

security:
  secrets:
    scan_on_save: true
  authentication:
    require_auth: true
    sso_enabled: true
```

### Test-Driven Development Configuration

```yaml
# .spec/config.yaml - TDD focused
version: "1.0.0"

workflow:
  phases:
    build:
      require_tests: true
  skills:
    implement:
      test_first: true
      auto_fix_tests: true
      execution_mode: "sequential"

validation:
  rules:
    tasks:
      max_task_size: "M"
      require_dependencies: true
```

## Environment Variable Overrides

All configuration options can be overridden via environment variables:

```bash
# Format: SPEC_<SECTION>_<SUBSECTION>_<KEY>
export SPEC_WORKFLOW_PHASES_BUILD_MAX_PARALLEL_TASKS=5
export SPEC_INTEGRATIONS_GITHUB_ENABLED=true
export SPEC_PATHS_ROOT=.specification
export SPEC_LOGGING_LEVEL=debug
```

## Configuration Validation

### Validation Rules

1. **Type Validation**: All values must match their defined types
2. **Enum Validation**: Enum values must be from allowed list
3. **Range Validation**: Numbers must be within min/max bounds
4. **Pattern Validation**: Strings must match regex patterns
5. **Path Validation**: Paths must be valid and relative
6. **URL Validation**: URLs must be well-formed
7. **Dependency Validation**: Required dependencies must be satisfied

### Validation Command

```bash
# Validate configuration
spec config validate

# Validate with verbose output
spec config validate --verbose

# Validate specific file
spec config validate --file .spec/config.yaml
```

### Error Messages

```yaml
# Example validation errors
errors:
  - field: "workflow.phases.build.max_parallel_tasks"
    value: 20
    error: "Value exceeds maximum of 10"

  - field: "project.type"
    value: "webapp"
    error: "Value must be one of: application, library, service, monorepo, plugin, framework"

  - field: "paths.features"
    value: "/absolute/path"
    error: "Path must be relative to project root"
```

## Migration & Compatibility

### Version Compatibility Matrix

| Schema Version | Spec Version | Breaking Changes |
|----------------|--------------|------------------|
| 1.0.0          | 3.0.0+       | Initial release  |
| 0.9.0          | 2.1.0-2.9.9  | Legacy format    |

### Migration Tool

```bash
# Migrate from old format
spec config migrate

# Dry run migration
spec config migrate --dry-run

# Migrate specific file
spec config migrate --input old-config.json --output .spec/config.yaml
```

## Default Values Summary

| Setting | Default | Description |
|---------|---------|-------------|
| paths.root | `.spec` | Spec root directory |
| paths.features | `features` | Features directory |
| paths.state | `.spec-state` | Session state |
| paths.memory | `.spec-memory` | Persistent memory |
| workflow.phases.build.max_parallel_tasks | `3` | Parallel task limit |
| workflow.skills.clarify.max_questions_per_round | `4` | Questions per round |
| workflow.skills.implement.execution_mode | `sequential` | Task execution |
| agents.coordinator.strategy | `adaptive` | Coordination strategy |
| validation.enabled | `true` | Enable validation |
| validation.strict_mode | `false` | Fail on warnings |
| logging.level | `info` | Log level |
| performance.cache.enabled | `true` | Enable caching |

---

**Version**: 1.0.0
**Last Updated**: 2024-11-02
**Status**: Draft
**Next Review**: 2024-12-01