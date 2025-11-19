# Discovering Architecture - Technical Reference

## Complete Analysis Algorithms

### Tech Stack Detection Algorithm

**File Extension Mapping**:
```javascript
const LANGUAGE_MAP = {
  '.js': 'JavaScript',
  '.jsx': 'JavaScript (React)',
  '.ts': 'TypeScript',
  '.tsx': 'TypeScript (React)',
  '.py': 'Python',
  '.java': 'Java',
  '.kt': 'Kotlin',
  '.go': 'Go',
  '.rs': 'Rust',
  '.php': 'PHP',
  '.rb': 'Ruby',
  '.cs': 'C#',
  '.swift': 'Swift'
};
```

**Framework Detection via Package Files**:

**Node.js (package.json)**:
```javascript
// Detection logic
const packageJson = JSON.parse(readFile('package.json'));
const deps = {...packageJson.dependencies, ...packageJson.devDependencies};

const FRAMEWORK_SIGNATURES = {
  'react': { name: 'React', version: deps.react },
  'vue': { name: 'Vue.js', version: deps.vue },
  'angular': { name: 'Angular', version: deps['@angular/core'] },
  'express': { name: 'Express', version: deps.express },
  'next': { name: 'Next.js', version: deps.next },
  'nest': { name: 'NestJS', version: deps['@nestjs/core'] }
};
```

**Python (requirements.txt)**:
```python
# Detection logic
with open('requirements.txt') as f:
    requirements = f.read().splitlines()

FRAMEWORK_PATTERNS = {
    r'django': 'Django',
    r'flask': 'Flask',
    r'fastapi': 'FastAPI',
    r'tornado': 'Tornado',
    r'pyramid': 'Pyramid'
}

for line in requirements:
    for pattern, framework in FRAMEWORK_PATTERNS.items():
        if re.search(pattern, line, re.I):
            version = re.search(r'==(\S+)', line).group(1)
            detect(framework, version)
```

**Java (pom.xml)**:
```xml
<!-- Detection via Maven dependencies -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter</artifactId>
  <version>3.1.0</version>  <!-- Framework: Spring Boot 3.1.0 -->
</dependency>
```

**Build Tool Detection**:
```bash
# Check for config files
test -f webpack.config.js && echo "Webpack"
test -f vite.config.ts && echo "Vite"
test -f rollup.config.js && echo "Rollup"
test -f pom.xml && echo "Maven"
test -f build.gradle && echo "Gradle"
test -f Makefile && echo "Make"
```

---

### Architecture Pattern Detection

#### Pattern: Microservices

**Detection Heuristics** (confidence scoring):

| Indicator | Score | Max |
|-----------|-------|-----|
| Multiple independent directories with separate package.json/pom.xml | +40 | 40 |
| Docker Compose or Kubernetes config with multiple services | +30 | 30 |
| Service discovery config (Eureka, Consul, Kubernetes DNS) | +15 | 15 |
| API Gateway config (nginx, Spring Cloud Gateway) | +10 | 10 |
| Message queue usage (Kafka, RabbitMQ, SQS) | +5 | 5 |

**Algorithm**:
```python
def detect_microservices(codebase):
    score = 0

    # Check for multiple services
    services = find_directories_with_pattern('*/package.json') or \
               find_directories_with_pattern('*/pom.xml')
    if len(services) >= 3:
        score += 40

    # Check for containerization
    if os.path.exists('docker-compose.yml'):
        services_count = count_services_in_docker_compose('docker-compose.yml')
        if services_count >= 3:
            score += 30

    if os.path.exists('kubernetes/'):
        deployments = glob('kubernetes/**/deployment.yaml')
        if len(deployments) >= 3:
            score += 30

    # Check for service discovery
    if grep('eureka', '**/*.yml') or grep('consul', '**/*.yml'):
        score += 15

    # Check for API gateway
    if os.path.exists('api-gateway/') or grep('spring-cloud-gateway', '**/pom.xml'):
        score += 10

    # Check for message queues
    if grep('kafka|rabbitmq|aws-sqs', '**/*'):
        score += 5

    confidence = score / 100.0  # Normalize to 0-1
    return {
        'pattern': 'microservices',
        'confidence': confidence,
        'score': score
    }
```

**Output**:
```
Pattern: Microservices
Confidence: 85%
Indicators:
  ✓ Multiple service directories (4 services) - 40 pts
  ✓ Docker Compose with 4 services - 30 pts
  ✓ Kafka message queue detected - 5 pts
  ✗ No API gateway config - 0 pts
Total: 85/100
```

#### Pattern: Layered Architecture

**Detection Heuristics**:

| Indicator | Score | Max |
|-----------|-------|-----|
| Directories named: presentation/api/controllers | +25 | 25 |
| Directories named: business/service/logic | +25 | 25 |
| Directories named: data/dal/repository | +25 | 25 |
| Database directory separate from business logic | +15 | 15 |
| Clear dependency direction (presentation → business → data) | +10 | 10 |

**Algorithm**:
```python
def detect_layered(codebase):
    score = 0
    layers = {'presentation': 0, 'business': 0, 'data': 0}

    # Check for presentation layer
    presentation_patterns = ['controllers', 'api', 'views', 'presentation', 'web']
    for pattern in presentation_patterns:
        if find_directory(pattern):
            score += 25
            layers['presentation'] = 1
            break

    # Check for business layer
    business_patterns = ['services', 'business', 'domain', 'logic', 'use-cases']
    for pattern in business_patterns:
        if find_directory(pattern):
            score += 25
            layers['business'] = 1
            break

    # Check for data layer
    data_patterns = ['repository', 'dal', 'data', 'models', 'entities']
    for pattern in data_patterns:
        if find_directory(pattern):
            score += 25
            layers['data'] = 1
            break

    # Check for database separation
    if os.path.exists('database/') or os.path.exists('migrations/'):
        score += 15

    # Check dependency direction (imports flow one way)
    if all(layers.values()) and check_import_direction(codebase):
        score += 10

    confidence = score / 100.0
    return {
        'pattern': 'layered',
        'confidence': confidence,
        'score': score,
        'layers_detected': sum(layers.values())
    }
```

#### Pattern: Monolith

**Detection (default if others fail)**:
```python
def detect_monolith(codebase):
    # If no strong indicators for microservices or modular
    if not detect_microservices(codebase) and \
       not detect_modular_monolith(codebase):

        # Check for spaghetti indicators
        spaghetti_score = 0

        # Large files (>500 lines)
        large_files = count_files_over_lines(500)
        if large_files > 10:
            spaghetti_score += 30

        # Mixed concerns (templates with business logic)
        if grep('sql.*SELECT', 'templates/**/*.html|*.php'):
            spaghetti_score += 20

        # Global functions file
        if os.path.exists('includes/functions.php') or \
           os.path.exists('lib/utils.js'):
            file_size = get_file_lines('includes/functions.php')
            if file_size > 500:
                spaghetti_score += 20

        # Determine sub-type
        if spaghetti_score > 50:
            subtype = 'spaghetti'
        else:
            subtype = 'structured'

        return {
            'pattern': 'monolith',
            'subtype': subtype,
            'confidence': 0.8 + (spaghetti_score / 500.0)
        }
```

---

## Pattern Detection Confidence Scores

### Confidence Levels

| Confidence | Meaning | Action |
|------------|---------|--------|
| 90-100% | Very high | Report as definitive pattern |
| 70-89% | High | Report with high confidence |
| 50-69% | Medium | Report with notes about ambiguity |
| 30-49% | Low | Report as "possibly" or "indicators suggest" |
| 0-29% | Very low | Do not report this pattern |

### Multi-Pattern Detection

Some codebases exhibit multiple patterns:

**Example: Modular Monolith**
- Monolith indicator: Single deployment unit (score: 60)
- Modular indicator: Clear module boundaries (score: 70)
- **Result**: "Modular Monolith" (70% confidence)

**Example: Microservices in Transition**
- Microservices indicators: 2 extracted services (score: 50)
- Monolith indicators: Main app still monolithic (score: 80)
- **Result**: "Monolith with Emerging Microservices" (80% confidence on monolith)

---

## Output File Format Specifications

### discovery/project-overview.md

**Markdown Template**:
```markdown
# {Project Name} - Discovery Report

**Analyzed**: {ISO 8601 timestamp}
**Codebase Age**: {X.Y years} (first commit: {date})
**Contributors**: {N developers} ({M active in last 6 months})
**Health Score**: {0-100}/100 {stars emoji}

## Key Metrics
- **Lines of Code**: {number with commas}
- **Files**: {number}
- **Languages**: {primary language} ({X}%), {secondary} ({Y}%)
- **Test Coverage**: {percentage}%
- **Technical Debt**: {count} items

## Technology Stack
{Bulleted list of frameworks, libraries, tools}

## Architecture Pattern
**Pattern**: {pattern name} ({confidence}% confidence)
{Brief description of architecture}

## Health Assessment
{Color-coded health indicators}
- ✅ Green: {aspects in good shape}
- ⚠️  Yellow: {aspects needing attention}
- ❌ Red: {critical issues}

## Recommendations
1. {Immediate actions}
2. {Short-term improvements}
3. {Long-term strategies}
```

### discovery/technical-landscape.json

**JSON Schema**:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "project": {
      "type": "object",
      "properties": {
        "name": {"type": "string"},
        "analyzed_at": {"type": "string", "format": "date-time"},
        "health_score": {"type": "number", "minimum": 0, "maximum": 100},
        "age_years": {"type": "number"},
        "contributors": {"type": "number"},
        "active_contributors": {"type": "number"}
      }
    },
    "tech_stack": {
      "type": "object",
      "properties": {
        "languages": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "name": {"type": "string"},
              "percentage": {"type": "number"},
              "files": {"type": "number"},
              "loc": {"type": "number"}
            }
          }
        },
        "frameworks": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "name": {"type": "string"},
              "version": {"type": "string"},
              "category": {"type": "string", "enum": ["frontend", "backend", "fullstack"]}
            }
          }
        },
        "databases": {"type": "array", "items": {"type": "string"}},
        "infrastructure": {"type": "array", "items": {"type": "string"}}
      }
    },
    "architecture": {
      "type": "object",
      "properties": {
        "pattern": {"type": "string"},
        "subtype": {"type": "string"},
        "confidence": {"type": "number", "minimum": 0, "maximum": 1},
        "indicators": {"type": "array", "items": {"type": "string"}},
        "layers": {"type": "array", "items": {"type": "string"}},
        "services": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "name": {"type": "string"},
              "purpose": {"type": "string"},
              "port": {"type": "number"},
              "dependencies": {"type": "array", "items": {"type": "string"}},
              "endpoints": {"type": "number"},
              "test_coverage": {"type": "number"}
            }
          }
        }
      }
    },
    "quality": {
      "type": "object",
      "properties": {
        "test_coverage": {"type": "number", "minimum": 0, "maximum": 1},
        "technical_debt_count": {"type": "number"},
        "complexity_hotspots": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "file": {"type": "string"},
              "lines": {"type": "number"},
              "complexity": {"type": "number"}
            }
          }
        },
        "security_vulnerabilities": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "severity": {"type": "string", "enum": ["critical", "high", "medium", "low"]},
              "description": {"type": "string"},
              "location": {"type": "string"}
            }
          }
        }
      }
    }
  }
}
```

---

## Performance Optimization for Large Codebases

### Sampling Strategy (>100k LOC)

**Problem**: Full analysis of massive codebases (100k+ lines) takes too long

**Solution**: Stratified random sampling

**Algorithm**:
```python
def sample_large_codebase(all_files, target_sample_size=1000):
    """
    Sample files proportionally by directory to maintain representative structure
    """
    # Group files by directory
    by_directory = {}
    for file in all_files:
        dir = os.path.dirname(file)
        if dir not in by_directory:
            by_directory[dir] = []
        by_directory[dir].append(file)

    # Calculate sample size per directory (proportional)
    total_files = len(all_files)
    samples = []

    for dir, files in by_directory.items():
        dir_proportion = len(files) / total_files
        dir_sample_size = int(target_sample_size * dir_proportion)
        dir_sample = random.sample(files, min(dir_sample_size, len(files)))
        samples.extend(dir_sample)

    return samples
```

**Application**:
- **Quick mode**: 10% sample (max 1,000 files)
- **Standard mode**: 20% sample (max 5,000 files)
- **Deep mode**: 50% sample or full scan if <50k LOC

### Progressive Scanning

**Technique**: Analyze in phases with early exit

1. **Phase 1: Package Files** (fast, <10 seconds)
   - Read package.json, pom.xml, requirements.txt
   - Detect frameworks and dependencies
   - If user only wants tech stack (--focus=tech-stack), exit here

2. **Phase 2: Directory Structure** (fast, <30 seconds)
   - Analyze directory tree
   - Detect architecture pattern
   - If user only wants architecture (--focus=architecture), exit here

3. **Phase 3: API Endpoints** (medium, 1-2 minutes)
   - Grep for route definitions
   - Extract endpoint catalog
   - If user only wants API (--focus=api), exit here

4. **Phase 4: Code Quality** (slow, 5-10 minutes)
   - Run test coverage
   - Analyze complexity
   - Scan for vulnerabilities

**Benefits**:
- Faster feedback for focused queries
- User can interrupt and refine scope
- Avoids wasting time on unused analysis

### Caching Strategy

**Cache discovered patterns** between runs:

```bash
# Cache location
.spec/cache/discovery-{hash}.json

# Hash = SHA256 of relevant files (package.json, directory structure)
# If hash unchanged, reuse cached results
```

**What to cache**:
- Tech stack detection results
- Architecture pattern confidence scores
- File count and LOC metrics

**What NOT to cache**:
- Code quality (changes frequently)
- API endpoints (routes added/removed)
- JIRA data (live external data)

**Cache invalidation**:
- If package.json modified → Invalidate tech stack cache
- If directory structure changed → Invalidate architecture cache
- If >7 days old → Invalidate all

---

## JIRA Integration Patterns

### MCP-Based JIRA Access

**Prerequisites**:
1. JIRA MCP server installed
2. Environment variables set:
   - `JIRA_SERVER_URL`
   - `JIRA_API_TOKEN`
   - `JIRA_USER_EMAIL`

**MCP Tool Usage**:
```javascript
// Pseudo-code for MCP JIRA integration
const jira_mcp = getMCPTool('jira');

// Search issues
const issues = await jira_mcp.invoke('search_issues', {
  jql: 'project = PROJ AND status != Done ORDER BY priority DESC',
  max_results: 100,
  fields: ['summary', 'status', 'priority', 'assignee', 'sprint', 'labels']
});

// Get sprint data
const sprints = await jira_mcp.invoke('get_board_sprints', {
  board_id: 123,
  state: 'active,closed',
  max_results: 10
});

// Calculate velocity
const velocity = sprints.map(sprint => ({
  name: sprint.name,
  completed_points: sprint.completed_issues.reduce((sum, issue) =>
    sum + (issue.story_points || 0), 0
  )
}));
```

### Backlog Analysis Algorithm

**Velocity Calculation**:
```python
def calculate_velocity(sprints):
    """
    Calculate team velocity from last N sprints
    """
    velocity_data = []

    for sprint in sprints:
        completed_issues = [i for i in sprint.issues if i.status == 'Done']
        completed_points = sum(i.story_points or 0 for i in completed_issues)

        velocity_data.append({
            'sprint': sprint.name,
            'planned': sprint.planned_points,
            'completed': completed_points,
            'velocity_percentage': (completed_points / sprint.planned_points * 100)
                                   if sprint.planned_points > 0 else 0
        })

    avg_velocity = sum(v['completed'] for v in velocity_data) / len(velocity_data)

    return {
        'sprints': velocity_data,
        'average': avg_velocity,
        'trend': calculate_trend(velocity_data)
    }

def calculate_trend(velocity_data):
    """
    Detect if velocity is increasing, stable, or declining
    """
    if len(velocity_data) < 2:
        return 'insufficient_data'

    recent = velocity_data[-3:]  # Last 3 sprints
    velocities = [v['completed'] for v in recent]

    # Simple linear regression
    slope = (velocities[-1] - velocities[0]) / len(velocities)

    if slope > 2:
        return 'increasing'
    elif slope < -2:
        return 'declining'
    else:
        return 'stable'
```

**Bug Distribution Analysis**:
```python
def analyze_bug_distribution(issues):
    """
    Categorize bugs by severity and identify patterns
    """
    bugs = [i for i in issues if i.issue_type == 'Bug']

    by_severity = {
        'critical': [b for b in bugs if b.priority == 'Highest'],
        'high': [b for b in bugs if b.priority == 'High'],
        'medium': [b for b in bugs if b.priority == 'Medium'],
        'low': [b for b in bugs if b.priority == 'Low']
    }

    # Identify hotspots (labels that appear frequently in bugs)
    label_counts = {}
    for bug in bugs:
        for label in bug.labels:
            label_counts[label] = label_counts.get(label, 0) + 1

    hotspots = sorted(label_counts.items(), key=lambda x: x[1], reverse=True)[:5]

    return {
        'total_bugs': len(bugs),
        'by_severity': {k: len(v) for k, v in by_severity.items()},
        'critical_bugs': by_severity['critical'],
        'hotspots': hotspots,  # Most common labels in bugs
        'age_distribution': {
            '0-7_days': len([b for b in bugs if days_old(b) <= 7]),
            '8-30_days': len([b for b in bugs if 8 <= days_old(b) <= 30]),
            '31-90_days': len([b for b in bugs if 31 <= days_old(b) <= 90]),
            '90+_days': len([b for b in bugs if days_old(b) > 90])
        }
    }
```

### Correlating JIRA with Code

**Map Issues to Modules**:
```python
def correlate_jira_to_code(issues, codebase):
    """
    Link JIRA issues to code modules via commit messages
    """
    # Get git commits mentioning JIRA issues
    commits = run_command('git log --all --pretty=format:"%H %s"')

    issue_to_files = {}

    for issue in issues:
        issue_key = issue.key  # e.g., PROJ-123

        # Find commits mentioning this issue
        related_commits = [c for c in commits if issue_key in c]

        # For each commit, get changed files
        files = []
        for commit_hash in related_commits:
            changed = run_command(f'git diff-tree --no-commit-id --name-only -r {commit_hash}')
            files.extend(changed.splitlines())

        # Group files by module (top-level directory)
        modules = {}
        for file in files:
            module = file.split('/')[0]
            modules[module] = modules.get(module, 0) + 1

        issue_to_files[issue_key] = {
            'files_changed': len(files),
            'modules_affected': modules
        }

    return issue_to_files
```

---

## Troubleshooting Guide

### Issue: Discovery Fails with "Permission Denied"

**Symptom**:
```
❌ Failed to read directory: src/
Permission denied
```

**Cause**: Insufficient read permissions on project files

**Solution**:
```bash
# Check permissions
ls -la src/

# Fix if needed (ensure you have read access)
chmod -R u+r .
```

### Issue: Tech Stack Detection Incomplete

**Symptom**:
```
⚠️  Detected languages: Unknown (78%)
```

**Cause**: Codebase uses uncommon file extensions or framework

**Solution**:
1. Check file extensions: `find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn`
2. Add custom language mapping in claude.md:
   ```markdown
   SPEC_DISCOVER_LANGUAGE_MAP=".foo:FooLang,.bar:BarLang"
   ```

### Issue: Architecture Pattern Confidence Low

**Symptom**:
```
Architecture: Unknown (35% confidence)
```

**Cause**: Codebase doesn't fit standard patterns, or unusual structure

**Solution**:
1. Review generated indicators in discovery/technical-landscape.md
2. Manually annotate architecture in claude.md:
   ```markdown
   SPEC_PROJECT_ARCHITECTURE="Hexagonal Architecture"
   ```
3. Discovery will skip detection and use provided value

### Issue: JIRA Analysis Skipped

**Symptom**:
```
⚠️  JIRA integration not available
Skipping backlog analysis
```

**Cause**: MCP not installed or configured

**Solution**:
1. Install JIRA MCP: `npm install -g @anthropic-ai/mcp-server-jira`
2. Configure in `.claude/mcp.json`:
   ```json
   {
     "servers": {
       "jira": {
         "command": "npx",
         "args": ["-y", "@anthropic-ai/mcp-server-jira"],
         "env": {
           "JIRA_URL": "https://your-org.atlassian.net",
           "JIRA_EMAIL": "your.email@example.com",
           "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
         }
       }
     }
   }
   ```
3. Set environment variable: `export JIRA_API_TOKEN=your_token_here`
4. Re-run discovery

### Issue: Large Codebase Analysis Timeout

**Symptom**:
```
⚠️  Analysis timeout after 10 minutes
Partial results available
```

**Cause**: Codebase too large, full scan exceeds timeout

**Solution**:
1. Use quick mode: `--mode=quick`
2. Focus on specific area: `--focus=architecture`
3. Increase timeout in claude.md:
   ```markdown
   SPEC_DISCOVER_TIMEOUT=1800  # 30 minutes
   ```

### Issue: Test Coverage Shows 0%

**Symptom**:
```
Test Coverage: 0% (no tests found)
```

**Possible Causes**:
1. **No tests exist**: Add tests to codebase
2. **Test runner not configured**: Install Jest, pytest, etc.
3. **Coverage tool missing**: Install nyc, coverage.py, JaCoCo

**Solution**:
```bash
# For Node.js
npm install --save-dev jest
npm test -- --coverage

# For Python
pip install pytest pytest-cov
pytest --cov=src

# Re-run discovery after coverage tool is set up
```

---

## Related Algorithms

### Git History Analysis

**Extract Project Age and Contributors**:
```bash
# First commit date
git log --reverse --format="%ai" | head -1
# → 2022-03-15 10:30:00 +0000

# Unique contributors (all time)
git log --format="%aN" | sort -u | wc -l
# → 24

# Active contributors (last 6 months)
git log --since="6 months ago" --format="%aN" | sort -u | wc -l
# → 12

# Commit frequency
git log --format="%ai" | awk '{print $1}' | uniq -c
# → Activity heatmap by date
```

### Complexity Hotspot Detection

**Cyclomatic Complexity (via static analysis)**:
```bash
# JavaScript/TypeScript (using ESLint with complexity rule)
npx eslint --rule 'complexity: [error, {max: 10}]' src/**/*.js

# Python (using radon)
pip install radon
radon cc src/ -a -nc
# → Shows complexity scores per function

# Java (using PMD)
pmd check -d src/ -R category/java/design.xml -f text
```

**File Churn Analysis** (frequently changed files):
```bash
# Files changed most often in last 6 months
git log --since="6 months ago" --name-only --pretty=format: | \
  grep -v '^$' | sort | uniq -c | sort -rn | head -20

# High churn = potential hotspot for bugs/refactoring
```

---

**Document Version**: 1.0.0 (for workflow v2 skills migration)
**Last Updated**: 2025-11-18
**Related Skills**: orbit-lifecycle (Initialize branch), orbit-planning (Architecture branch), orbit-lifecycle (Define branch)
