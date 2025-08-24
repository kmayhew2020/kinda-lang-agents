# 🤖 Kinda-Lang Agent Coordination Guidelines

## 🌳 Git Branching Model (All Agents)

### Unified Branch Strategy
```
All kinda-lang agents MUST follow this git workflow:

main branch:           Production-ready code, protected, requires PR approval
feature/ branches:     All development work, one branch per task/issue
hotfix/ branches:      Critical production fixes (rare)

Flow: feature/task-X-description → PR → Review → Merge to main
Policy: NEVER commit directly to main
```

### Branch Naming Convention (MANDATORY)
```
Format: feature/task-{number}-{kebab-case-description}

Examples:
✅ feature/task-37-sorta-print-parsing
✅ feature/task-38-test-coverage-improvement
✅ feature/issue-42-unicode-support
✅ hotfix/critical-security-patch

❌ feature/sorta-print (missing task number)
❌ task-37 (missing feature/ prefix)
❌ feature/Task_37_Sorta_Print (wrong case)
```

### Commit Message Standards (All Agents)
```
Format: {type}: {description}

Types:
- feat: New feature implementation  
- fix: Bug fixes
- test: Test additions or improvements
- refactor: Code restructuring without behavior change
- docs: Documentation updates
- chore: Maintenance tasks

Examples:
✅ feat: implement robust ~sorta print parsing
✅ test: add comprehensive parsing edge case tests
✅ fix: handle unclosed parentheses gracefully
```

## Agent Communication Protocol

When working with multiple kinda-lang agents, follow these coordination patterns:

### 1. Task Handoffs

**Project Manager → Coder:**
```
Project Manager creates task breakdown:
- Use TodoWrite to create implementation plan with branch strategy
- Specify branch name: feature/task-{number}-{description}
- Specify files to modify, tests to write, standards to follow
- Hand off with: "Use the kinda-lang coder agent to implement Task #X"
```

**Coder → Code Reviewer:**
```  
Coder completes implementation:
- Push feature branch and create PR
- Update TodoWrite to mark implementation tasks complete
- Create new todo for code review with PR number
- Hand off with: "Use the kinda-lang code reviewer agent to review PR #X"
```

**Code Reviewer → Project Manager/Coder:**
```
Code Reviewer provides feedback:
- Update TodoWrite with review status and PR number
- If approved: Mark review complete, PR ready for merge
- If changes needed: Create todos for specific improvements on same branch
- Hand off with: "Use kinda-lang coder agent to address PR #X feedback"
```

### 2. Shared Context

**All agents should:**
- Always read the current TodoWrite status first
- Update todos as work progresses  
- Use consistent task IDs and descriptions
- Leave clear handoff messages

### 3. Tool Usage Patterns

**Project Manager:**
- `Task` - Analyze complex requirements
- `TodoWrite` - Create and manage project todos  
- `Read` - Understand existing codebase
- `LS/Grep` - Survey project structure

**Coder:**
- `Read` - Understand existing code
- `Write/Edit/MultiEdit` - Implement features
- `Bash` - Run tests and verify functionality
- `Grep/Glob` - Find patterns and files

**Code Reviewer:** 
- `Read` - Examine code changes
- `Grep` - Check for patterns, security issues
- `Bash` - Run test suites and quality checks
- `TodoWrite` - Track review status

### 4. Quality Gates

Each handoff must include:
1. **Clear status update** in TodoWrite
2. **Context for next agent** (what was done, what's needed next)
3. **Quality verification** (tests pass, standards met)
4. **Explicit handoff message** with specific agent to use

### 5. Error Handling

If an agent encounters issues:
1. Update TodoWrite with blocked status
2. Create specific todo for the problem
3. Hand back to appropriate agent with context

## Example Workflow

```
User: "Add a new ~maybe construct to kinda-lang"

PM Agent: 
- Analyzes requirement using Task tool
- Creates TodoWrite plan with architecture decisions
- "Use kinda-lang coder agent to implement ~maybe construct"

Coder Agent:
- Reads existing construct implementations  
- Implements ~maybe in grammar, matchers, transformer
- Writes comprehensive tests
- "Use kinda-lang code reviewer agent to review ~maybe implementation"

Reviewer Agent:
- Reviews code quality, test coverage, security
- Runs full test suite
- Either approves or creates improvement todos
- Updates TodoWrite with final status
```

This ensures smooth handoffs and maintains project quality throughout the development workflow.