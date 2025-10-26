---
name: {skill-name}
description: {Sophisticated capability description for complex domain}. Use when: 1) {Primary enterprise use case}, 2) {Team collaboration scenario}, 3) {Automation trigger}, 4) {Integration request}, 5) {Complex workflow mentioned}. {Professional output with reporting}.
allowed-tools: {Carefully selected tool set}
---

# {Professional Skill Name}: {Domain Expertise}

{Executive summary of capability and business value}

## Overview

### What This Skill Does

- **{Core Function}**: {Detailed description}
- **{Integration}**: {How it connects with systems}
- **{Automation}**: {What it automates}
- **{Reporting}**: {Analytics and insights provided}
- **{Compliance}**: {Standards and requirements met}

### When to Use

1. **{Primary Scenario}**: {Detailed context}
2. **{Secondary Scenario}**: {Alternative use case}
3. **{Proactive Trigger}**: {Automatic activation condition}
4. **{Team Workflow}**: {Collaboration context}
5. **{Enterprise Need}**: {Organizational requirement}

## Architecture

### Components

```
{skill-name}/
├── Core Processing
│   ├── {Component 1}
│   ├── {Component 2}
│   └── {Component 3}
├── Integration Layer
│   ├── {System 1}
│   └── {System 2}
└── Output Generation
    ├── Reports
    ├── Dashboards
    └── Notifications
```

## Execution Flow

### Phase 1: Discovery & Analysis

#### 1.1 Requirements Gathering
- {Requirement check 1}
- {Requirement check 2}
- {Validation step}

#### 1.2 Environment Assessment
- {System check}
- {Dependency verification}
- {Resource availability}

### Phase 2: Implementation

#### 2.1 Preparation
1. {Setup step 1}
2. {Setup step 2}
3. {Configuration}

#### 2.2 Core Processing
1. {Processing step 1}
   - {Sub-step a}
   - {Sub-step b}
2. {Processing step 2}
3. {Decision tree}
   - If {condition}: {action}
   - Else: {alternative}

#### 2.3 Quality Assurance
- {Validation 1}
- {Validation 2}
- {Compliance check}

### Phase 3: Delivery & Reporting

1. **Generate Reports**
   - {Report type 1}
   - {Report type 2}

2. **Notifications**
   - {Stakeholder alerts}
   - {System updates}

3. **Documentation**
   - {Audit trail}
   - {Compliance records}

## Configuration

### Basic Configuration
```json
{
  "mode": "standard|advanced|enterprise",
  "reporting": {
    "format": "markdown|html|pdf",
    "frequency": "on-demand|scheduled",
    "recipients": []
  },
  "integration": {
    "systems": [],
    "authentication": "oauth|api-key|certificate"
  }
}
```

### Advanced Options
```yaml
advanced:
  parallel_processing: true
  batch_size: 100
  retry_policy:
    max_attempts: 3
    backoff: exponential
  monitoring:
    metrics: true
    alerts: true
  security:
    encryption: AES-256
    audit_log: true
```

## Integration Points

### API Endpoints
- `POST /api/v1/{skill-name}/execute`
- `GET /api/v1/{skill-name}/status/{id}`
- `GET /api/v1/{skill-name}/results/{id}`

### Webhooks
- `{event-1}`: {description}
- `{event-2}`: {description}

## Error Handling & Recovery

### Error Classification

| Error Type | Severity | Recovery Strategy | Notification |
|------------|----------|-------------------|--------------|
| {Type 1} | Critical | {Strategy} | Immediate |
| {Type 2} | Warning | {Strategy} | Batch |
| {Type 3} | Info | {Strategy} | Log only |

### Recovery Procedures

1. **Transient Failures**: Automatic retry with exponential backoff
2. **Data Issues**: Validation report and manual review queue
3. **System Failures**: Failover to backup system
4. **Permission Errors**: Escalation to admin

## Security & Compliance

### Security Measures
- Input sanitization
- Output encryption
- Audit logging
- Access control

### Compliance Standards
- {Standard 1} compliance
- {Standard 2} requirements
- {Regulatory framework}

## Performance Metrics

### KPIs
- Processing time: < {target} seconds
- Success rate: > {target}%
- Error rate: < {target}%
- Resource usage: < {target} CPU/Memory

### Monitoring
```bash
# Check performance
./scripts/monitor.sh --metrics

# View logs
./scripts/logs.sh --tail 100

# Generate report
./scripts/report.sh --format pdf
```

## Output Specifications

### Standard Output
```
=====================================
{SKILL NAME} EXECUTION REPORT
=====================================

Execution ID: {uuid}
Timestamp: {ISO-8601}
Status: {SUCCESS|PARTIAL|FAILED}

📊 Summary:
- Items Processed: {count}
- Success Rate: {percentage}%
- Duration: {time}

📋 Details:
{Detailed results table or list}

📈 Metrics:
{Performance metrics}

🔗 Resources:
- Full Report: {path/url}
- Logs: {path/url}
- Next Steps: {recommendations}
```

### Error Output
```
❌ ERROR REPORT
- Code: {error-code}
- Message: {user-friendly-message}
- Details: {technical-details}
- Recovery: {suggested-action}
- Support: {contact/documentation}
```

## Maintenance

### Update Procedures
1. Version check: `./scripts/version.sh`
2. Update: `./scripts/update.sh`
3. Validate: `./scripts/validate.sh`
4. Test: `./scripts/test.sh`

### Troubleshooting
- See `REFERENCE.md` for common issues
- Run `./scripts/diagnose.sh` for health check
- Contact support for enterprise issues

## Resources

- **Examples**: Load `EXAMPLES.md` for detailed scenarios
- **Reference**: Load `REFERENCE.md` for technical specifications
- **Templates**: Browse `templates/` for output formats
- **Scripts**: Execute from `scripts/` for automation
- **Support**: {documentation-url} or {support-contact}