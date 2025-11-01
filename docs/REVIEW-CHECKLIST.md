# Plugin Review Checklist

Use this checklist when reviewing plugin submissions to the marketplace.

## Pre-Review Setup

- [ ] PR has clear title and description
- [ ] Author has signed CLA (if required)
- [ ] CI checks are passing
- [ ] No merge conflicts

## Structure Review

### Required Files
- [ ] `README.md` exists and is comprehensive
- [ ] `LICENSE` file present and valid
- [ ] `.claude/` directory properly structured
- [ ] At least one command or skill defined

### Directory Structure
- [ ] Follows standard plugin layout
- [ ] No unnecessary files (`.DS_Store`, `node_modules/`, etc.)
- [ ] Appropriate `.gitignore` if needed

## Documentation Review

### README.md
- [ ] Clear description of functionality
- [ ] Installation instructions
- [ ] Usage examples
- [ ] Command/skill documentation
- [ ] Author information
- [ ] License mentioned

### Commands
- [ ] Each command has documentation
- [ ] Usage syntax is clear
- [ ] Options are documented
- [ ] Examples provided

### Skills
- [ ] Triggers clearly defined
- [ ] Workflow documented
- [ ] Integration points listed
- [ ] Error handling described

## Code Review

### Quality
- [ ] Code is clean and readable
- [ ] Appropriate error handling
- [ ] No obvious bugs
- [ ] Performance considerations addressed

### Security
- [ ] No hardcoded secrets or API keys
- [ ] Input validation present
- [ ] No malicious code
- [ ] Dependencies are safe
- [ ] No unnecessary permissions requested

### Best Practices
- [ ] Follows naming conventions
- [ ] Uses semantic versioning
- [ ] Appropriate logging (not excessive)
- [ ] Handles edge cases

## Marketplace Integration

### marketplace.json Entry
- [ ] Plugin name matches directory name
- [ ] Description is clear and concise
- [ ] Version follows semver
- [ ] Category is appropriate
- [ ] Keywords are relevant
- [ ] Author information complete
- [ ] License specified (SPDX format)

### Metadata
```json
{
  "name": "plugin-name",           ✓ Kebab-case
  "description": "Clear desc",     ✓ Under 200 chars
  "version": "1.0.0",              ✓ Semver
  "category": "development",       ✓ Valid category
  "source": "./plugins/name",      ✓ Correct path
  "author": {
    "name": "Name",                ✓ Present
    "email": "email@example.com"   ✓ Valid email
  },
  "keywords": ["relevant"],        ✓ 3-10 keywords
  "license": "MIT"                 ✓ SPDX identifier
}
```

## Testing

### Local Testing
- [ ] Plugin installs successfully
- [ ] Commands execute without errors
- [ ] Skills trigger appropriately
- [ ] No console errors or warnings

### Test Coverage
- [ ] Basic functionality tested
- [ ] Edge cases considered
- [ ] Error scenarios handled
- [ ] Documentation examples work

## Functionality Review

### Purpose
- [ ] Adds value to the ecosystem
- [ ] Doesn't duplicate existing plugins
- [ ] Solves a real problem
- [ ] Target audience is clear

### User Experience
- [ ] Intuitive to use
- [ ] Good error messages
- [ ] Responsive performance
- [ ] Consistent behavior

## Final Checks

### Legal
- [ ] License is appropriate
- [ ] No copyright violations
- [ ] Dependencies properly licensed
- [ ] Attribution provided where needed

### Maintenance
- [ ] Author committed to maintenance
- [ ] Contact information provided
- [ ] Issue reporting method clear
- [ ] Update process documented

## Approval Criteria

### Must Have (Blocking)
- ✅ Correct structure
- ✅ Working functionality
- ✅ No security issues
- ✅ Proper documentation
- ✅ Valid license

### Should Have (Important)
- ⚠️ Good code quality
- ⚠️ Comprehensive examples
- ⚠️ Test coverage
- ⚠️ Performance optimization

### Nice to Have (Bonus)
- 💡 Exceptional documentation
- 💡 Video tutorials
- 💡 Integration with other plugins
- 💡 Advanced features

## Review Comments Template

### Approval
```
✅ **Approved**

Great plugin! The [feature] is particularly well implemented.

**Strengths:**
- Point 1
- Point 2

**Minor suggestions (non-blocking):**
- Consider adding...
- Maybe improve...

Welcome to the marketplace! 🎉
```

### Request Changes
```
🔄 **Changes Requested**

Thanks for the submission! A few things need adjustment:

**Required changes:**
1. Issue 1 - [suggestion to fix]
2. Issue 2 - [suggestion to fix]

**Optional improvements:**
- Improvement 1
- Improvement 2

Please let me know if you need any clarification!
```

### Needs Major Work
```
⚠️ **Significant Changes Needed**

Thanks for your submission. The plugin needs some substantial work:

**Major issues:**
1. Critical issue - [explanation]
2. Blocking problem - [explanation]

**Recommendations:**
- Suggestion 1
- Suggestion 2

Consider reviewing our [plugin examples](link) for guidance. Happy to help if you have questions!
```

## Reviewer Notes

### Red Flags
- 🚩 Obfuscated code
- 🚩 Requests unnecessary permissions
- 🚩 Makes external calls without disclosure
- 🚩 Includes binary files without explanation
- 🚩 Dependencies with known vulnerabilities

### Green Flags
- ✅ Comprehensive test suite
- ✅ Excellent documentation
- ✅ Clean, maintainable code
- ✅ Thoughtful error handling
- ✅ Performance optimized

## Post-Approval

- [ ] Merge PR
- [ ] Tag release
- [ ] Update marketplace version
- [ ] Announce in community channels
- [ ] Add to showcase (if exceptional)