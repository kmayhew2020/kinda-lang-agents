# Task Breakdown Template

Use this template when the Project Manager creates implementation plans:

## Feature: [Feature Name]

### Requirements Analysis
- **User Request**: [Original user request]
- **Core Functionality**: [What the feature should do]
- **Integration Points**: [How it connects to existing code]
- **Success Criteria**: [How we know it's working]

### Architecture Decisions
- **Files to Modify**: 
  - `kinda/grammar/python/constructs.py` - [purpose]
  - `kinda/grammar/python/matchers.py` - [purpose] 
  - `kinda/langs/python/transformer.py` - [purpose]
- **New Files to Create**:
  - `tests/python/test_[feature].py` - [test coverage]
  - `examples/[feature]_example.py.knda` - [usage example]
- **Patterns to Follow**: [Reference existing similar features]

### TodoWrite Plan

```
Priority: HIGH | MEDIUM | LOW
Status: pending | in_progress | completed

1. [Task description] - Priority: [level]
   Success criteria: [how to know it's done]
   
2. [Task description] - Priority: [level]
   Success criteria: [how to know it's done]
   
[etc...]
```

### Handoff Message
"Use the kinda-lang coder agent to implement these tasks: [specific context and requirements]"

---

## Quality Gates
- [ ] All todos have clear success criteria
- [ ] Dependencies are identified
- [ ] Test requirements are specified
- [ ] Integration points are documented
- [ ] Handoff message provides full context