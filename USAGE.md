# 🤖 Using Kinda-Lang Claude Code Agents

## Quick Start

These agents are designed to be used directly in Claude Code conversations. Simply invoke them by name when you need specialized help with kinda-lang development.

## Agent Invocations

### 🏗️ Project Manager Agent
```
"Use the kinda-lang project manager agent to plan implementing [feature]"
"Use the kinda-lang project manager agent to analyze this requirement"
"Use the kinda-lang project manager agent to break down this complex task"
```

**When to use**: For planning, architecture decisions, and task breakdown.

### 💻 Coder Agent
```  
"Use the kinda-lang coder agent to implement these tasks"
"Use the kinda-lang coder agent to fix this bug"
"Use the kinda-lang coder agent to add tests for this feature"
```

**When to use**: For implementation, coding, testing, and development work.

### 🔍 Code Reviewer Agent
```
"Use the kinda-lang code reviewer agent to review this implementation"
"Use the kinda-lang code reviewer agent to check this PR"
"Use the kinda-lang code reviewer agent to verify this code quality"
```

**When to use**: For code review, quality assurance, and final verification.

## Example Workflows

### Simple Feature Request
```
You: "I want to add a new ~definitely construct that always executes"

1. "Use the kinda-lang project manager agent to plan the ~definitely construct"
   → PM creates TodoWrite plan and specifications

2. PM hands off: "Use the kinda-lang coder agent to implement these tasks"
   → Coder implements, tests, and verifies functionality

3. Coder hands off: "Use the kinda-lang code reviewer agent to review this"
   → Reviewer checks quality, security, tests, and approves
```

### Bug Fix Request
```
You: "There's a bug where ~sorta print doesn't handle nested parentheses"

1. "Use the kinda-lang project manager agent to analyze this bug"
   → PM investigates, creates fix plan

2. "Use the kinda-lang coder agent to fix this parsing issue"  
   → Coder implements fix and regression tests

3. "Use the kinda-lang code reviewer agent to verify the fix"
   → Reviewer ensures fix works and doesn't break anything
```

## Agent Files Reference

- `agents/project_manager.md` - Project Manager agent prompt and instructions
- `agents/coder.md` - Coder agent prompt and instructions  
- `agents/reviewer.md` - Code Reviewer agent prompt and instructions
- `agents/coordinator.md` - Inter-agent coordination guidelines
- `templates/` - Templates for common workflows
- `examples/` - Example agent interactions

## Best Practices

1. **Always start with Project Manager** for new features or complex changes
2. **Use TodoWrite** to track progress across agent handoffs
3. **Be explicit** about which agent you want to use
4. **Provide context** when handing off between agents
5. **Follow the workflow** - PM → Coder → Reviewer for quality assurance

## Tips

- Agents will automatically coordinate using TodoWrite
- Each agent has specific expertise - use the right tool for the job
- Agents understand kinda-lang patterns and will maintain consistency
- All agents prioritize code quality and comprehensive testing

---

*Ready to build some kinda awesome features? 🎲*