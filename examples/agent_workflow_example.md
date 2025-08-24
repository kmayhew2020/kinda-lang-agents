# Agent Workflow Example: Adding ~maybe Construct

This example shows how the three kinda-lang agents work together to implement a new feature.

## User Request
*"I want to add a ~maybe construct that executes code with a 60% probability"*

---

## 1. 🏗️ Project Manager Analysis

**Agent Invocation**: *"Use the kinda-lang project manager agent to plan adding a ~maybe construct"*

### PM Agent Actions:
```
1. Uses Task tool to analyze the requirement
2. Uses Read to understand existing constructs (~sorta, ~sometimes, ~kinda)
3. Uses LS and Grep to survey the codebase structure
4. Creates comprehensive TodoWrite plan
```

### TodoWrite Plan Created:
```markdown
## ~maybe Construct Implementation Plan

**Priority: HIGH**
1. Research existing probabilistic constructs - Status: pending
   Success: Understand ~sorta and ~sometimes patterns

2. Design ~maybe syntax and behavior - Status: pending  
   Success: Clear specification of ~maybe [condition] syntax with 60% probability

3. Implement ~maybe in constructs.py - Status: pending
   Success: Add pattern and runtime function following existing patterns

4. Add ~maybe parsing in matchers.py - Status: pending
   Success: Proper regex matching and content extraction

5. Add ~maybe transformer logic - Status: pending
   Success: Integration with transformer.py following ~sometimes pattern

**Priority: MEDIUM** 
6. Create comprehensive tests - Status: pending
   Success: tests/python/test_maybe.py with full coverage

7. Add usage example - Status: pending
   Success: examples/maybe_example.py.knda

8. Update documentation - Status: pending
   Success: README includes ~maybe in syntax table
```

### Handoff:
*"Use the kinda-lang coder agent to implement these ~maybe construct tasks. Follow the patterns from ~sometimes for probabilistic behavior and ensure 60% execution probability."*

---

## 2. 💻 Coder Implementation

**Agent Invocation**: Received from PM Agent

### Coder Agent Actions:
```
1. Reads TodoWrite to understand tasks
2. Uses Read to examine existing constructs for patterns
3. Uses Edit to implement changes in constructs.py, matchers.py, transformer.py
4. Uses Write to create comprehensive tests
5. Uses Bash to run tests and verify functionality
6. Updates TodoWrite progress
```

### Implementation Steps:

**Step 1: Research (Read existing code)**
```python
# Examined kinda/grammar/python/constructs.py
# Found pattern: ~sorta has 80% probability, ~sometimes has 50%
# Decision: ~maybe will have 60% probability
```

**Step 2: Add to constructs.py (Edit)**
```python
"maybe_construct": {
    "type": "conditional", 
    "pattern": re.compile(r'~maybe\s+(.+)'),
    "description": "Execute with ~60% probability",
    "body": (
        "def maybe_execute(condition_code):\n"
        "    import random\n"
        "    if random.random() < 0.6:\n"
        "        exec(condition_code)\n"
        "    else:\n"
        "        pass  # Maybe not this time\n"
    )
}
```

**Step 3: Add to matchers.py (Edit)**
```python 
# Added ~maybe handling following ~sometimes pattern
# Handles balanced parentheses and nested expressions
```

**Step 4: Add to transformer.py (Edit)**  
```python
def transform_maybe(self, line):
    # Implementation following ~sometimes pattern
    # Returns appropriate Python code with 60% probability execution
```

**Step 5: Create tests (Write)**
```python
# Created tests/python/test_maybe.py
class TestMaybeConstruct:
    def test_maybe_basic_functionality(self):
        # Test ~maybe executes approximately 60% of the time
        
    def test_maybe_with_complex_conditions(self):
        # Test nested expressions work
        
    def test_maybe_error_handling(self):
        # Test invalid syntax handling
```

**Step 6: Verify with Bash**
```bash
python -m pytest tests/python/test_maybe.py -v
python -m pytest tests/ -v  # Full suite
# All tests pass ✅
```

**Step 7: Update TodoWrite**
```markdown
✅ Research existing probabilistic constructs - COMPLETED
✅ Design ~maybe syntax and behavior - COMPLETED
✅ Implement ~maybe in constructs.py - COMPLETED  
✅ Add ~maybe parsing in matchers.py - COMPLETED
✅ Add ~maybe transformer logic - COMPLETED
✅ Create comprehensive tests - COMPLETED
⏳ Add usage example - IN_PROGRESS
⏳ Update documentation - PENDING
```

### Handoff:
*"Use the kinda-lang code reviewer agent to review this ~maybe construct implementation. All tests pass and functionality is complete."*

---

## 3. 🔍 Code Review

**Agent Invocation**: Received from Coder Agent

### Reviewer Agent Actions:
```
1. Reads TodoWrite to understand what was implemented  
2. Uses Read to examine all changed files thoroughly
3. Uses Grep to check for security issues and consistency
4. Uses Bash to run full test suite and verify quality
5. Makes approval decision and updates TodoWrite
```

### Review Process:

**Step 1: Code Quality Review (Read)**
```
✅ Code follows existing patterns (~sometimes structure)
✅ Error handling is appropriate
✅ Naming conventions are consistent
✅ Comments are clear and helpful
```

**Step 2: Security Analysis (Grep)**
```bash
grep -r "exec\|eval" kinda/  # Check for unsafe code execution
# Result: Found safe exec() usage in controlled context ✅

grep -r "import.*random" kinda/  # Check random usage consistency  
# Result: Consistent with other probabilistic features ✅
```

**Step 3: Test Verification (Bash)**
```bash
python -m pytest tests/ -v
# Result: All 67 tests pass ✅

python -m pytest tests/python/test_maybe.py -v --cov
# Result: 100% coverage of new ~maybe functionality ✅
```

**Step 4: Integration Testing (Bash)**
```bash  
kinda run examples/unified_syntax.py.knda  # Test CLI integration
# Result: Works correctly ✅

python -c "from kinda.langs.python.transformer import PythonTransformer; ..." 
# Result: Integration works ✅
```

### Review Decision: **APPROVED** ✅

### TodoWrite Update:
```markdown
✅ Research existing probabilistic constructs - COMPLETED
✅ Design ~maybe syntax and behavior - COMPLETED  
✅ Implement ~maybe in constructs.py - COMPLETED
✅ Add ~maybe parsing in matchers.py - COMPLETED
✅ Add ~maybe transformer logic - COMPLETED
✅ Create comprehensive tests - COMPLETED
✅ CODE REVIEW - APPROVED ✅
📋 Add usage example - ASSIGNED TO CODER
📋 Update documentation - ASSIGNED TO CODER  
```

### Final Handoff:
*"Implementation approved! Use the kinda-lang coder agent to complete the remaining documentation tasks."*

---

## Result

The ~maybe construct is successfully implemented with:
- ✅ 60% execution probability
- ✅ Full test coverage  
- ✅ Security review passed
- ✅ Integration with existing codebase
- ✅ Following kinda-lang patterns and philosophy

**Usage:**
```kinda
~maybe (x > 5) {
    ~sorta print("x is probably greater than 5!")
}
```

This workflow demonstrates how the three agents coordinate to deliver high-quality features efficiently while maintaining project standards.