# 🤖 Kinda-Lang Agent Coordination Guidelines

## Agent Communication Protocol

When working with multiple kinda-lang agents, follow these coordination patterns:

### 1. Task Handoffs

**Project Manager → Coder:**
```
Project Manager creates task breakdown:
- Use TodoWrite to create implementation plan
- Specify files to modify, tests to write, standards to follow
- Hand off with: "Use the kinda-lang coder agent to implement these tasks"
```

**Coder → Code Reviewer:**
```  
Coder completes implementation:
- Update TodoWrite to mark implementation tasks complete
- Create new todo for code review
- Hand off with: "Use the kinda-lang code reviewer agent to review this implementation"
```

**Code Reviewer → Project Manager/Coder:**
```
Code Reviewer provides feedback:
- Update TodoWrite with review status
- If approved: Mark review complete
- If changes needed: Create todos for specific improvements
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