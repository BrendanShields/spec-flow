# Template Library Index

**Version**: 2.0.0 (Optimized - October 30, 2025)

## Quick Links to Documentation

### Getting Started
- **[README.md](README.md)** - Template library overview and quick start guide

### Optimization Details
- **[OPTIMIZATION-SUMMARY.md](OPTIMIZATION-SUMMARY.md)** - High-level summary of optimization work
- **[OPTIMIZATION-RESULTS.md](OPTIMIZATION-RESULTS.md)** - Detailed before/after comparison with metrics
- **[RECOMMENDATIONS.md](RECOMMENDATIONS.md)** - Deployment guide and maintenance plan

## Templates Directory

### Core Templates (`templates/`)

**Specification & Planning**:
1. **[spec-template.md](templates/spec-template.md)** (92 lines)
   - Purpose: Define feature requirements
   - When: Starting new feature work
   - Key Sections: User stories, requirements, success criteria

2. **[plan-template.md](templates/plan-template.md)** (76 lines)
   - Purpose: Technical design and implementation plan
   - When: Planning how to build the feature
   - Key Sections: Technical context, blueprint alignment, project structure

3. **[tasks-template.md](templates/tasks-template.md)** (100 lines)
   - Purpose: Break design into actionable tasks
   - When: Ready to implement
   - Key Sections: Phases, task organization, execution order

**Project-Level Templates**:
4. **[product-requirements-template.md](templates/product-requirements-template.md)** (83 lines)
   - Purpose: Define product vision and goals
   - When: Starting new product or major initiative
   - Key Sections: Vision, goals, personas, user stories, requirements

5. **[architecture-blueprint-template.md](templates/architecture-blueprint-template.md)** (94 lines)
   - Purpose: Document technical standards and patterns
   - When: Setting up project architecture
   - Key Sections: Principles, patterns, tech stack, API design, operations

**External & Reference**:
6. **[confluence-page.md](templates/confluence-page.md)** (57 lines)
   - Purpose: Public documentation summary
   - When: Syncing specs to Confluence/wiki
   - Key Sections: Summary, stories, technical, success

**Additional Templates**:
- [jira-story-template.md](templates/jira-story-template.md) - JIRA integration
- [checklist-template.md](templates/checklist-template.md) - Review checklists
- [agent-file-template.md](templates/agent-file-template.md) - Agent context files
- [openapi-template.yaml](templates/openapi-template.yaml) - API contracts

## Shared Standards Directory

### Reference Standards (`_shared/`)

1. **[user-story-format.md](_shared/user-story-format.md)** (38 lines)
   - Standard user story format (As a/I want/So that)
   - Acceptance criteria format (Given/When/Then)
   - Priority level definitions
   - Complete examples

2. **[metadata-frontmatter.md](_shared/metadata-frontmatter.md)** (45 lines)
   - Standard document header format
   - Metadata field definitions
   - Status values
   - Auto-generated fields

## Statistics

### File Sizes
| Category | Before | After | Reduction |
|----------|--------|-------|-----------|
| **All Templates** | 1,943 lines | 668 lines | 66% |
| **All Docs** | 52.5 KB | 12.2 KB | 77% |

### Individual Templates
| Template | Before | After | Reduction |
|----------|--------|-------|-----------|
| architecture-blueprint | 488 | 94 | 81% |
| confluence-page | 267 | 57 | 79% |
| product-requirements | 225 | 83 | 63% |
| plan | 187 | 76 | 59% |
| tasks | 251 | 100 | 60% |
| spec | 164 | 92 | 44% |

## How to Use This Library

### 1. Choose Your Template
Start with this decision tree:

```
What am I building?
├─ Defining feature requirements?
│  └─ Use: spec-template.md
├─ Planning implementation?
│  └─ Use: plan-template.md
├─ Breaking into tasks?
│  └─ Use: tasks-template.md
├─ Defining product goals?
│  └─ Use: product-requirements-template.md
├─ Setting tech standards?
│  └─ Use: architecture-blueprint-template.md
└─ Documenting publicly?
   └─ Use: confluence-page.md
```

### 2. Reference Standards
All templates reference these shared standards:
- **[user-story-format.md](_shared/user-story-format.md)** - How to write stories
- **[metadata-frontmatter.md](_shared/metadata-frontmatter.md)** - Document headers

### 3. Fill Placeholders
Replace `[PLACEHOLDERS]` with your content:
```markdown
# Feature Specification: [FEATURE NAME]
→ Feature Specification: User Authentication
```

### 4. Customize as Needed
Templates are guides, not rules:
- Add or remove sections as needed
- Customize for your project type
- Follow standards, not structure

## Key Principles

### 1. Independent User Stories
Each story is:
- **Independently valuable** (delivers value alone)
- **Independently testable** (can be verified standalone)
- **Independently implementable** (can be coded separately)
- **Independently deployable** (can ship independently)

### 2. Single Source of Truth
Standards are centralized:
- User story format in `_shared/user-story-format.md`
- Metadata standards in `_shared/metadata-frontmatter.md`
- All templates reference these (no duplication)

### 3. Progressive Disclosure
Templates show:
- Essential fields first
- Examples available in shared files
- Links to detailed guidance
- Not everything upfront

### 4. Peer Artifact Model
- Templates are guidance, not law
- Architecture Blueprint guides, doesn't enforce
- Flat hierarchy, team consensus drives evolution
- Easy to adapt and customize

## Documentation Structure

```
plugins/specter/templates/
├── INDEX.md (this file)
├── README.md (complete overview)
├── OPTIMIZATION-SUMMARY.md (what changed)
├── OPTIMIZATION-RESULTS.md (detailed metrics)
├── RECOMMENDATIONS.md (deployment guide)
│
├── templates/ (6 optimized templates + 4 others)
│   ├── spec-template.md (92 lines)
│   ├── plan-template.md (76 lines)
│   ├── tasks-template.md (100 lines)
│   ├── product-requirements-template.md (83 lines)
│   ├── architecture-blueprint-template.md (94 lines)
│   ├── confluence-page.md (57 lines)
│   └── [4 other templates]
│
├── _shared/ (centralized standards)
│   ├── user-story-format.md
│   └── metadata-frontmatter.md
│
└── memory/
    └── constitution.md (project principles)
```

## Quick Reference

### Template Selection Matrix
| Task | Template | Size | Key Content |
|------|----------|------|------------|
| Feature requirements | spec-template.md | 92 lines | Stories, requirements, success criteria |
| Technical design | plan-template.md | 76 lines | Context, alignment, structure |
| Implementation tasks | tasks-template.md | 100 lines | Phases, dependencies, execution |
| Product vision | product-requirements-template.md | 83 lines | Vision, goals, entities |
| Tech standards | architecture-blueprint-template.md | 94 lines | Principles, patterns, stack |
| Public documentation | confluence-page.md | 57 lines | Summary, stories, metrics |

### Essential Links
- **Standards**: [user-story-format.md](_shared/user-story-format.md) | [metadata-frontmatter.md](_shared/metadata-frontmatter.md)
- **Getting Started**: [README.md](README.md)
- **Deployment**: [RECOMMENDATIONS.md](RECOMMENDATIONS.md)
- **Details**: [OPTIMIZATION-RESULTS.md](OPTIMIZATION-RESULTS.md)

## FAQ

**Q: Which template should I start with?**
A: Start with `spec-template.md` to define what you're building.

**Q: Do I need to use all sections?**
A: No. Sections are guides. Remove what doesn't apply to your project.

**Q: Where do I find examples?**
A: Check your project's `features/` directory for real completed specs.

**Q: Can I customize templates?**
A: Yes! Templates are starting points, customize as needed for your project.

**Q: What if I have questions about standards?**
A: Check `_shared/user-story-format.md` and `_shared/metadata-frontmatter.md`.

**Q: Can I still use old templates?**
A: Yes, they still exist. We recommend new templates for their clarity.

## Maintenance

### Monthly
- Review feedback
- Note pattern changes
- Plan refinements

### Quarterly
- Implement improvements
- Update standards if needed
- Communicate changes

### Annually
- Comprehensive review
- Team training
- Plan next version

## Status

- **Version**: 2.0.0 (Optimized)
- **Release Date**: October 30, 2025
- **Status**: Production Ready
- **Optimization**: 66% size reduction
- **Functionality**: 100% preserved

## Next Steps

1. **Read**: [README.md](README.md) for complete overview
2. **Review**: [OPTIMIZATION-RESULTS.md](OPTIMIZATION-RESULTS.md) for detailed changes
3. **Deploy**: Follow [RECOMMENDATIONS.md](RECOMMENDATIONS.md) for rollout
4. **Use**: Start creating specs with optimized templates
5. **Iterate**: Provide feedback monthly for improvements

---

**Start here**: [README.md](README.md)
**Learn more**: [OPTIMIZATION-RESULTS.md](OPTIMIZATION-RESULTS.md)
**Deploy**: [RECOMMENDATIONS.md](RECOMMENDATIONS.md)
