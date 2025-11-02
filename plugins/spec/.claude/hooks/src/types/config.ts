/**
 * Type definitions for .spec-config.yml configuration
 */

export interface SpecConfig {
  version: string;
  paths: SpecPaths;
  naming: NamingConventions;
  project: ProjectInfo;
  agents: AgentConfig;
  integrations: Integrations;
  workflow: WorkflowPreferences;
}

export interface SpecPaths {
  spec_root: string;
  features: string;
  state: string;
  memory: string;
}

export interface NamingConventions {
  feature_directory: string;
  feature_singular: string;
  feature_plural: string;
  files: {
    spec: string;
    plan: string;
    tasks: string;
  };
}

export interface ProjectInfo {
  type: 'app' | 'library' | 'monorepo' | 'microservice';
  language: string;
  framework: string | null;
  build_tool: string | null;
}

export interface AgentConfig {
  implementer: {
    strategy: 'parallel' | 'sequential' | 'adaptive' | 'dag';
    max_parallel: number;
    timeout: number;
    retry_attempts: number;
    dependency_aware?: boolean;
    critical_path_optimization?: boolean;
  };
  researcher: {
    confidence_threshold: number;
    cache_ttl: number;
  };
  analyzer: {
    validation_depth: 'quick' | 'standard' | 'deep';
    auto_fix: boolean;
  };
  coordination?: CoordinationConfig;
}

export interface CoordinationConfig {
  default_pattern: 'sequential' | 'parallel' | 'hierarchical' | 'dag' | 'group_chat' | 'event_driven';
  sequential?: {
    enabled: boolean;
    handoff_mode: 'synchronous' | 'asynchronous';
    checkpoint_between_agents: boolean;
  };
  parallel?: {
    enabled: boolean;
    max_concurrent_agents: number;
    collect_strategy: 'all' | 'first' | 'any' | 'majority';
    timeout_per_agent: number;
  };
  hierarchical?: {
    enabled: boolean;
    supervisor_model: 'sonnet' | 'opus' | 'haiku';
    worker_model: 'sonnet' | 'opus' | 'haiku';
    max_delegation_depth: number;
    supervisor_reviews_work: boolean;
  };
  dag?: {
    enabled: boolean;
    auto_detect_dependencies: boolean;
    critical_path_first: boolean;
    parallel_non_dependent: boolean;
    visualization: boolean;
  };
  group_chat?: {
    enabled: boolean;
    max_agents: number;
    chat_manager_model: 'sonnet' | 'opus' | 'haiku';
    max_rounds: number;
    speaker_selection: 'auto' | 'round_robin' | 'random' | 'manual';
  };
  event_driven?: {
    enabled: boolean;
    event_bus: 'memory' | 'redis' | 'kafka';
    retry_on_failure: boolean;
    dead_letter_queue: boolean;
  };
}

export interface Integrations {
  jira?: {
    enabled: boolean;
    project_key: string;
    server_url: string;
  };
  confluence?: {
    enabled: boolean;
    space_key: string;
    root_page_id: string;
  };
}

export interface WorkflowPreferences {
  auto_checkpoint: boolean;
  validate_on_save: boolean;
  progressive_disclosure: boolean;
  tdd?: TDDConfig;
  auto_detect_hooks?: AutoDetectHooksConfig;
}

export interface TDDConfig {
  enabled: boolean;
  mode: 'strict' | 'flexible' | 'advisory';
  enforce_test_first: boolean;
  block_implementation_without_tests: boolean;
  min_coverage_per_task: number;
  min_coverage_overall: number;
  fail_on_missing_tests: boolean;
  test_frameworks?: {
    unit: string;
    integration: string;
    e2e: string;
  };
  steps?: Array<{
    name: string;
    prompt_template: string;
    validation: string;
  }>;
  test_generation?: {
    auto_generate_tests: boolean;
    test_naming_convention: string;
    test_location: 'alongside' | 'separate' | 'mirror';
    include_edge_cases: boolean;
    include_error_cases: boolean;
    mock_external_deps: boolean;
  };
  coverage?: {
    tool: string;
    report_format: string;
    exclude_patterns: string[];
  };
}

export interface AutoDetectHooksConfig {
  enabled: boolean;
  detect?: {
    linters: boolean;
    formatters: boolean;
    type_checkers: boolean;
    build_tools: boolean;
    test_runners: boolean;
    package_managers: boolean;
    git_hooks: boolean;
  };
  auto_create_hooks?: {
    pre_commit: boolean;
    pre_push: boolean;
    post_checkout: boolean;
    pre_build: boolean;
    post_build: boolean;
  };
  hook_templates?: Record<string, {
    event: string;
    condition: string;
    script: string;
  }>;
  prompt_before_create: boolean;
  show_preview: boolean;
}
