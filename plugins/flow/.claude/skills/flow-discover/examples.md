# Flow Discover: Examples

## Example 1: New Developer Onboarding

### Scenario
A new developer joins an established team working on a large e-commerce platform.

### Usage
```bash
flow:discover
```

### Output
```
🔍 Discovering Project: E-Commerce Platform
=============================================

Analyzing JIRA...
✓ 3 Epics in progress
✓ 47 Stories in backlog
✓ 12 Bugs (3 critical)
✓ Average velocity: 45 points/sprint

Analyzing Codebase...
✓ 2,341 files analyzed
✓ React + Node.js + PostgreSQL stack
✓ 73% test coverage
✓ 5 microservices detected

Analyzing Team Activity...
✓ 6 active contributors
✓ 23 open PRs
✓ 156 commits last 30 days

📊 Key Insights:
- High Priority: Payment processing refactor (PROJ-234)
- Tech Debt: Legacy authentication system needs update
- Quick Win: 5 "good first issues" identified
- Team Focus: Currently working on checkout optimization

📋 Generated Reports:
- discovery/project-overview.md
- discovery/backlog-analysis.md
- discovery/technical-landscape.md
- discovery/onboarding-checklist.md

Recommended First Task: PROJ-456 (Add loading states to checkout)
Estimated Time to Productivity: 3-5 days
```

## Example 2: Sprint Planning Discovery

### Scenario
Team lead preparing for sprint planning needs to understand capacity and priorities.

### Usage
```bash
flow:discover --focus sprint-planning
```

### Output
```
📅 Sprint Planning Intelligence
================================

Current Sprint Status:
- 8/12 stories complete (67%)
- 2 stories at risk
- 2 stories blocked

Velocity Analysis (Last 6 Sprints):
Sprint 15: 42 points ✓
Sprint 16: 38 points ✓
Sprint 17: 45 points ✓
Sprint 18: 41 points ✓
Sprint 19: 44 points ✓
Sprint 20: 35 points (current)

Average: 42 points
Recommended Capacity: 40-44 points

Ready for Next Sprint:
1. PROJ-501: User Profile Redesign (8 points)
2. PROJ-502: API Rate Limiting (5 points)
3. PROJ-503: Search Optimization (13 points)
4. PROJ-504: Mobile Responsive Updates (8 points)
5. PROJ-505: Analytics Dashboard (13 points)

Dependencies Identified:
⚠️ PROJ-503 blocks PROJ-506
⚠️ PROJ-504 requires design approval

Suggested Sprint Composition:
- PROJ-501 (8) + PROJ-502 (5) + PROJ-504 (8) + Buffer (5) = 42 points
- Addresses: UX improvement + Performance + Mobile
- Risk: Low (no blocking dependencies)
```

## Example 3: Technical Debt Assessment

### Scenario
Engineering manager needs to justify time for technical debt reduction.

### Usage
```bash
flow:discover --focus tech-debt
```

### Output
```
🔧 Technical Debt Analysis
===========================

Debt Inventory:
===============

Critical (Immediate Action):
1. Authentication System (Legacy OAuth 1.0)
   - Risk: Security vulnerability
   - Effort: 15 days
   - Impact: All users
   - JIRA: TECH-101

2. Database Connection Pooling
   - Risk: Performance bottleneck
   - Effort: 5 days
   - Impact: 30% slower queries
   - JIRA: TECH-89

High Priority:
- Payment Service Refactor (20 days)
- Test Coverage Gaps (10 days)
- Deprecated Dependencies (8 days)

Code Quality Metrics:
- Files with complexity > 20: 47
- Files without tests: 134
- TODO/FIXME comments: 89
- Deprecated API usage: 23 instances

Cost Analysis:
- Total Debt: ~73 developer days
- Monthly Interest: ~5 days (maintenance overhead)
- ROI if addressed: 40% reduction in bug rate

Recommendations:
1. Address authentication in next sprint (security risk)
2. Allocate 20% capacity for ongoing debt reduction
3. Create debt budget: 1 story per sprint

Generated: discovery/tech-debt-report.md
```

## Example 4: Merger/Acquisition Discovery

### Scenario
Company acquires a startup and needs to understand the codebase and backlog.

### Usage
```bash
flow:discover --comprehensive
```

### Output
```
🏢 Comprehensive Project Discovery
====================================

Project: AcquiredStartup
Repository Age: 3 years
Total Commits: 4,567

Technology Stack:
- Frontend: Vue.js 3.2, Tailwind CSS
- Backend: Python/FastAPI
- Database: MongoDB, Redis
- Infrastructure: AWS, Docker, K8s

Codebase Metrics:
- Total LOC: 145,000
- Languages: Python (45%), JavaScript (30%), TypeScript (25%)
- Test Coverage: 61%
- Build Time: 4.5 minutes

JIRA Analysis:
- Total Issues: 234
- Epics: 8 (3 in progress)
- Unestimated: 67 stories
- Bug Backlog: 45 (12 critical)

Team & Culture:
- Contributors: 12 (4 active last 30 days)
- Commit Style: Conventional commits
- PR Size: Avg 250 lines
- Review Time: Avg 4 hours

Business Logic Discovered:
- Core Domains: User Management, Billing, Analytics, Reporting
- Integrations: Stripe, SendGrid, Segment, Datadog
- API Endpoints: 87
- Database Collections: 23

Risks Identified:
🔴 Critical: No disaster recovery plan
🟠 High: Single points of failure in auth service
🟡 Medium: Inconsistent error handling
🟡 Medium: Missing API documentation

Migration Readiness:
- Containerized: ✅ Yes
- CI/CD: ✅ GitHub Actions
- Monitoring: ⚠️ Basic (needs improvement)
- Documentation: ⚠️ Partial

Integration Opportunities:
- Authentication: Can integrate with parent company SSO
- Payment: Can consolidate Stripe accounts
- Analytics: Can merge with existing data warehouse

Estimated Integration Timeline: 3-4 months
Full Report: discovery/acquisition-assessment.md
```

## Example 5: Continuous Discovery (Weekly)

### Scenario
Team runs weekly discovery to track project evolution.

### Usage
```bash
flow:discover --mode update --since "1 week ago"
```

### Output
```
📊 Weekly Discovery Update
==========================
Week of: Oct 14-21, 2024

Progress This Week:
✓ 8 stories completed (34 story points)
✓ 3 bugs fixed (2 critical)
✓ 1 epic completed (User Dashboard)

New Additions:
+ 5 new stories added to backlog
+ 2 new bugs reported
+ 1 tech debt item identified

Velocity Trend: ↑ +15% (improving)

Code Changes:
- 42 PRs merged
- 1,234 lines added, 567 removed
- 3 new features deployed
- Test coverage: 73% → 75% ↑

Team Highlights:
🏆 Top contributor: developer1 (12 PRs)
🎯 Most improved: developer2 (first critical bug fix)
🚀 Fastest PR: 45 minutes (PROJ-234)

Upcoming Risks:
⚠️ PROJ-567 blocked on design (3 days)
⚠️ Sprint capacity at 95%
⚠️ 2 developers on PTO next week

Recommendations:
1. Unblock PROJ-567 priority
2. Plan for reduced capacity
3. Celebrate epic completion

Delta Report: discovery/weekly-update-2024-10-21.md
```