# 🚀 Standard Bot Launcher Protocol

## Problem Identified
- Bots called with different prompts each time → inconsistent behavior
- Bots start "debugging" instead of following their defined workflows  
- Missing CI runs, incomplete task execution due to varied instructions

## Solution: Standard Launcher Approach

### Core Principle
**ALWAYS use identical Task prompt. Let state files communicate specific work.**

### Standard Coder Bot Launcher
```
Task(subagent_type="general-purpose", description="Coder bot standard launcher", prompt="""
You are the kinda-lang coder bot. Read your prompt file ~/kinda-lang-agents/agents/coder.md and follow it exactly. Check your state files for assigned work. Execute your defined workflow.
""")
```

### Standard Reviewer Bot Launcher  
```
Task(subagent_type="general-purpose", description="Reviewer bot standard launcher", prompt="""
You are the kinda-lang reviewer bot. Read your prompt file ~/kinda-lang-agents/agents/reviewer.md and follow it exactly. Check your state files for assigned work. Execute your defined workflow.
""")
```

## Workflow
1. **Update state files** with specific work assignments
2. **Call bot with standard prompt** (no variations!)
3. **Bot reads own prompt file** → consistent behavior
4. **Bot checks state** → knows what work to do
5. **Bot executes defined workflow** → includes CI, completion sequence, etc.

## Critical Rules
- ❌ Never vary the Task prompt based on specific work
- ❌ Never give bots ad-hoc instructions 
- ✅ Always use identical launcher prompt
- ✅ Agent prompt files are source of truth for behavior
- ✅ State files communicate specific assignments

## Next Steps
- Test this approach on current PR #1 rework task
- Verify coder bot runs local CI without being reminded
- Verify consistent startup/completion sequences