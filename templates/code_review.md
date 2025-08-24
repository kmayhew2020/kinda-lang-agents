# Code Review Template

Use this template when the Code Reviewer evaluates implementations:

## Review for: [Feature/Change Name]

### Implementation Overview
- **Files Changed**: [list of modified files]
- **Lines Changed**: [approximate scope]
- **Test Files**: [new/modified test files]
- **Complexity**: [Simple/Medium/Complex]

### Code Quality Review ✅❌

#### Functionality
- [ ] Feature works as specified
- [ ] Handles edge cases appropriately  
- [ ] Error handling is robust
- [ ] Integration with existing code is smooth

#### Code Style & Standards
- [ ] Follows existing naming conventions
- [ ] Code is readable and well-structured
- [ ] Appropriate comments and documentation
- [ ] Consistent with kinda-lang patterns

#### Kinda-Lang Specific
- [ ] Uses ~tilde syntax appropriately
- [ ] Embraces uncertainty/fuzziness correctly
- [ ] Error messages have appropriate personality
- [ ] Follows probabilistic behavior patterns

### Security Analysis ✅❌

```bash
# Security checks performed:
grep -r "eval\|exec" [changed_files]
grep -r "subprocess\|os\.system" [changed_files]  
grep -r "open.*w" [changed_files]
# Results: [findings]
```

- [ ] No unsafe code execution
- [ ] Input validation is proper
- [ ] File operations are safe
- [ ] No injection vulnerabilities

### Testing Verification ✅❌

```bash
# Test execution:
python -m pytest tests/ -v
python -m pytest tests/python/test_[feature].py -v
# Results: [test results]
```

- [ ] All existing tests still pass
- [ ] New tests cover the feature comprehensively
- [ ] Edge cases are tested
- [ ] Integration tests work correctly
- [ ] Test quality is high (not just coverage)

### Performance & Integration ✅❌
- [ ] No performance regressions
- [ ] Memory usage is reasonable
- [ ] CLI integration works correctly
- [ ] Examples run successfully
- [ ] Documentation is updated if needed

### Review Decision

**APPROVED** ✅ / **CHANGES REQUIRED** ❌

#### If Approved:
```
TodoWrite Update:
- Mark implementation review as completed
- Create documentation todo if needed
- Ready for merge
```

#### If Changes Required:
```
TodoWrite Updates:
1. Fix [specific issue] - Priority: HIGH
   Details: [specific requirements]
   
2. Improve [specific area] - Priority: MEDIUM  
   Details: [specific requirements]
   
3. Add [missing tests] - Priority: HIGH
   Details: [what tests are needed]
```

**Handoff Message**: 
"Use the kinda-lang coder agent to address these review findings: [specific context]"

---

## Review Quality Gates
- [ ] All code has been examined
- [ ] Security analysis is complete  
- [ ] All tests have been run
- [ ] Decision is clearly documented
- [ ] Feedback is specific and actionable