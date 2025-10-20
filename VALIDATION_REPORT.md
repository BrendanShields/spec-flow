# Claude Code Marketplace Validation Report

## 🎯 Executive Summary

Analyzing our implementation against official Claude Code documentation for:
- Plugin Marketplace structure
- Plugin organization
- Skills implementation
- Subagent structure
- Naming conventions

---

## ✅ CORRECT IMPLEMENTATIONS

### 1. Marketplace Structure ✓
**Status**: CORRECT

Our implementation:
```
.claude-marketplace/
├── manifest.json
├── registry.json
└── skills/
```

**Required by Claude Code**:
```
.claude-plugin/
└── marketplace.json
```

**Action**: Need to rename and restructure (see issues below)

### 2. Agent Naming Convention ✓
**Status**: CORRECT

Our agents use kebab-case:
- `flow-analyzer.agent.md`
- `flow-implementer.agent.md`
- `flow-researcher.agent.md`

**Documentation confirms**: Agent files should use kebab-case (e.g., `test-runner.md`, `code-reviewer.md`)

**✅ NO "flow:" prefix needed** - the user's initial instruction was incorrect. Agent names are just kebab-case filenames.

### 3. Plugin Structure Concept ✓
**Status**: MOSTLY CORRECT

We have plugins organized in `plugins/flow/` which aligns with marketplace pattern.

---

## ❌ CRITICAL ISSUES TO FIX

### Issue 1: Marketplace File Location
**Current**: `.claude-marketplace/manifest.json`
**Required**: `.claude-plugin/marketplace.json`

**Impact**: HIGH - Marketplace won't be recognized by Claude Code

**Fix Required**:
```bash
mv .claude-marketplace .claude-plugin
mv .claude-plugin/manifest.json .claude-plugin/marketplace.json
```

### Issue 2: Marketplace JSON Schema
**Current**: Custom schema
**Required**: Official Anthropic schema

**Required Format**:
```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "flow-marketplace",
  "version": "1.0.0",
  "description": "AI-powered specification-driven development",
  "owner": {
    "name": "Claude Code Marketplace",
    "email": "plugins@claudecode.dev"
  },
  "plugins": [
    {
      "name": "flow",
      "description": "Specification-driven development with AI",
      "source": "./plugins/flow",
      "category": "development",
      "version": "2.0.0"
    }
  ]
}
```

### Issue 3: Skills File Structure
**Current**: `plugins/flow/skills/specify.skill.md`
**Required**: Each skill should be a directory with `SKILL.md`

**Required Structure**:
```
plugins/flow/
└── .claude/
    └── skills/
        ├── flow-specify/
        │   └── SKILL.md
        ├── flow-plan/
        │   └── SKILL.md
        └── flow-implement/
            └── SKILL.md
```

**Impact**: CRITICAL - Skills won't load properly

### Issue 4: Subagent Location
**Current**: `plugins/flow/agents/*.agent.md`
**Required**: `plugins/flow/.claude/agents/*.md`

**Required Structure**:
```
plugins/flow/
└── .claude/
    └── agents/
        ├── flow-analyzer.md      # NOT .agent.md
        ├── flow-implementer.md
        └── flow-researcher.md
```

**Impact**: HIGH - Subagents won't be recognized

### Issue 5: Subagent File Extension
**Current**: `*.agent.md`
**Required**: `*.md` (no .agent suffix)

### Issue 6: Plugin Reference in Skills
**Current**: `"subagents": ["flow-researcher"]`
**Likely Correct**: Agents referenced by filename without extension

**But verify**: The agent ID in YAML frontmatter should match filename

---

## 📋 REQUIRED RESTRUCTURING

### Step 1: Fix Marketplace Location
```bash
# Rename marketplace directory
mv .claude-marketplace .claude-plugin

# Rename and restructure manifest
mv .claude-plugin/manifest.json .claude-plugin/marketplace.json

# Remove registry.json (not part of official structure)
rm .claude-plugin/registry.json
```

### Step 2: Create Proper marketplace.json
```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "flow-marketplace",
  "version": "1.0.0",
  "description": "AI-powered specification-driven development marketplace",
  "owner": {
    "name": "Claude Code Community",
    "email": "plugins@claudecode.dev",
    "url": "https://github.com/your-org/flow-marketplace"
  },
  "plugins": [
    {
      "name": "flow",
      "description": "Complete AI-powered workflow for spec-driven development with autonomous implementation",
      "source": "./plugins/flow",
      "category": "development",
      "version": "2.0.0",
      "author": {
        "name": "Claude Code Marketplace",
        "email": "plugins@claudecode.dev"
      }
    }
  ]
}
```

### Step 3: Restructure Plugin Directory
```bash
# Create .claude directory structure
mkdir -p plugins/flow/.claude/skills
mkdir -p plugins/flow/.claude/agents

# Move and restructure skills
mv plugins/flow/skills plugins/flow/skills-old
for skill in specify plan tasks implement clarify analyze checklist constitution init; do
  mkdir -p plugins/flow/.claude/skills/flow-${skill}
  # Each needs its own SKILL.md
done

# Move and rename agents
mv plugins/flow/agents/analyzer.agent.md plugins/flow/.claude/agents/flow-analyzer.md
mv plugins/flow/agents/implementer.agent.md plugins/flow/.claude/agents/flow-implementer.md
mv plugins/flow/agents/researcher.agent.md plugins/flow/.claude/agents/flow-researcher.md
rmdir plugins/flow/agents
```

### Step 4: Update Subagent YAML Frontmatter
Each agent file needs proper frontmatter:

```yaml
---
name: flow-analyzer
description: Deep codebase analysis with pattern extraction and architecture discovery. Use PROACTIVELY for brownfield projects.
tools: Read, Glob, Grep, Bash
model: sonnet
---

System prompt content here...
```

### Step 5: Create Proper SKILL.md Files
Each skill directory needs:

```yaml
---
name: flow:specify
description: Generate comprehensive specifications from natural language descriptions with AI-powered analysis
---

# Flow Specify

Instructions for Claude on how to execute this skill...
```

---

## 🔍 AGENT NAMING ANALYSIS

### ✅ CORRECT: Kebab-Case Filenames
- `flow-analyzer.md` ✓
- `flow-implementer.md` ✓
- `flow-researcher.md` ✓

### ✅ CORRECT: Agent IDs in plugin.json
```json
"subagents": ["flow-analyzer", "flow-implementer", "flow-researcher"]
```

### ❌ INCORRECT: File Extension
- Should be `.md` not `.agent.md`

### ❌ INCORRECT: Location
- Should be in `.claude/agents/` not `agents/`

---

## 📊 COMPATIBILITY MATRIX

| Component | Current | Required | Status | Priority |
|-----------|---------|----------|--------|----------|
| Marketplace location | `.claude-marketplace/` | `.claude-plugin/` | ❌ | CRITICAL |
| Marketplace file | `manifest.json` | `marketplace.json` | ❌ | CRITICAL |
| Marketplace schema | Custom | Official Anthropic | ❌ | HIGH |
| Skills location | `skills/` | `.claude/skills/` | ❌ | CRITICAL |
| Skills structure | `*.skill.md` | `dir/SKILL.md` | ❌ | CRITICAL |
| Agent location | `agents/` | `.claude/agents/` | ❌ | HIGH |
| Agent extension | `.agent.md` | `.md` | ❌ | MEDIUM |
| Agent naming | `kebab-case` | `kebab-case` | ✅ | N/A |
| Agent prefix | No prefix | No prefix | ✅ | N/A |
| Hooks location | `hooks/` | `.claude/hooks/` | ❌ | MEDIUM |

---

## 🎯 INSTALLATION FLOW

### How Users Will Install
```bash
# Add marketplace
/plugin marketplace add your-github-user/flow-marketplace

# Install flow plugin
/plugin install flow
```

### What Happens
1. Claude Code reads `.claude-plugin/marketplace.json`
2. Finds `flow` plugin at `./plugins/flow`
3. Loads skills from `plugins/flow/.claude/skills/*/SKILL.md`
4. Loads agents from `plugins/flow/.claude/agents/*.md`
5. Loads hooks from `plugins/flow/.claude/hooks/*.js`

### Current Issues
- ❌ Marketplace not at correct location
- ❌ Skills not in proper structure
- ❌ Agents not in correct location
- ❌ File extensions incorrect

---

## 🔨 RECOMMENDED FIXES (In Order)

### Priority 1: CRITICAL (Blocks Installation)
1. Rename `.claude-marketplace/` → `.claude-plugin/`
2. Create proper `marketplace.json` with official schema
3. Restructure skills: `skills/` → `.claude/skills/*/SKILL.md`
4. Move agents: `agents/` → `.claude/agents/`

### Priority 2: HIGH (Affects Functionality)
1. Rename agent files: `*.agent.md` → `*.md`
2. Update agent YAML frontmatter
3. Move hooks: `hooks/` → `.claude/hooks/`
4. Remove `plugin.json` (not needed, marketplace.json defines plugins)

### Priority 3: MEDIUM (Polish)
1. Update documentation references
2. Add examples to SKILL.md files
3. Create reference.md for complex skills
4. Add templates directory per skill

---

## ✅ VALIDATION CHECKLIST

After fixes, verify:

- [ ] `.claude-plugin/marketplace.json` exists with official schema
- [ ] `marketplace.json` includes `$schema` field
- [ ] All skills in `.claude/skills/*/SKILL.md` format
- [ ] All agents in `.claude/agents/*.md` (not .agent.md)
- [ ] Agent YAML frontmatter includes name, description
- [ ] Skills reference agents by filename (without .md)
- [ ] Hooks in `.claude/hooks/` if used
- [ ] Templates in appropriate skill directories

---

## 📚 DOCUMENTATION REFERENCES

Based on official Claude Code docs:

1. **Marketplace Format**: `.claude-plugin/marketplace.json` with Anthropic schema
2. **Skills**: Directory per skill with `SKILL.md` + optional supporting files
3. **Subagents**: `.claude/agents/*.md` with YAML frontmatter
4. **Naming**: kebab-case for files, no special prefixes
5. **Installation**: `/plugin marketplace add user/repo`

---

## 🎉 NEXT STEPS

1. Run the restructuring commands above
2. Test locally with `/plugin marketplace add ./`
3. Verify skills load with `/skills`
4. Verify agents load with `/agents`
5. Push to GitHub
6. Test installation from GitHub: `/plugin marketplace add user/repo`