# Kinda-Lang 5-Agent Development Workflow Protocol

## Overview
This document establishes the standard workflow for development cycles using the 5-agent system with verification checkpoints to ensure quality and completeness at each phase.

## Agent Roles
- **Coder Agent**: Implements features, resolves conflicts, ensures 100% CI pass
- **Reviewer Agent**: Quality gates, comprehensive review, approval/feedback
- **Project Manager Agent**: Merge execution, roadmap management, next cycle planning
- **Verification Controller** (You): Validates each agent's work before proceeding

## Standard 3-Phase Development Cycle

### Phase 1: Implementation (Coder Agent)
**Responsibilities**:
- **FIRST: Synchronize with dev branch** (`git fetch origin dev && git merge origin/dev`)
- Resolve any merge conflicts early in the development process
- Implement features per specifications
- **Regularly sync with dev** during long development cycles to avoid conflicts
- Achieve 100% local CI pass using `~/kinda-lang-agents/infrastructure/scripts/ci-local.sh`
- Commit and push all changes
- Prepare PR for review

**Deliverables**:
- Clean, mergeable feature branch
- 100% passing ci-local.sh results
- All changes committed and pushed
- GitHub CI running and passing

**Tools**:
- Standard launcher: `~/kinda-lang-agents/agents/coder.md`
- CI validation: `~/kinda-lang-agents/infrastructure/scripts/ci-local.sh`

### Phase 2: Quality Review (Reviewer Agent)
**Responsibilities**:
- Run ci-local.sh validation
- Comprehensive code quality review
- Security and performance assessment
- Functional completeness validation
- Provide approval or specific change requests

**Deliverables**:
- Complete review with ci-local.sh validation
- Detailed quality assessment
- Clear approval OR specific actionable feedback
- Decision rationale documented

**Tools**:
- Standard launcher: `~/kinda-lang-agents/agents/reviewer.md`
- CI validation: `~/kinda-lang-agents/infrastructure/scripts/ci-local.sh`

### Phase 3: Merge & Planning (Project Manager Agent)
**Responsibilities**:
- Execute approved PR merge
- Update version/tags if needed
- Update strategic state files
- Plan and assign next development cycle
- Update roadmap status

**Deliverables**:
- Successfully merged PR
- Updated strategic state
- Next cycle assignment ready
- Roadmap reflects current status

**Tools**:
- Standard launcher: `~/kinda-lang-agents/agents/project_manager.md`
- Merge execution: `gh pr merge`
- State management: `~/kinda-lang-agents/state/`

## Verification Checkpoints

### After Phase 1 (Coder → Reviewer)
**Verification Tasks**:
1. **Conflict Resolution**: Check no conflict markers, branch is mergeable
2. **CI Validation**: Run ci-local.sh myself, verify 100% pass
3. **Completeness**: Confirm all changes committed, GitHub CI passing
4. **Quality**: Basic smoke test that implementation works

**Pass Criteria**: ALL verification tasks pass
**Fail Action**: Send back to Coder with specific issues to fix

### After Phase 2 (Reviewer → PM)
**Verification Tasks**:
1. **Review Completeness**: Verify reviewer ran ci-local.sh and provided thorough feedback
2. **Decision Validation**: Check approval/rejection aligns with actual PR state
3. **Quality Gate**: Spot-check critical issues reviewer should have caught
4. **Re-verification**: Run ci-local.sh myself to double-check

**Pass Criteria**: Review quality meets standards AND ci-local.sh passes
**Fail Action**:
- If APPROVED but issues found: Send back to Coder via Reviewer
- If REJECTED: Verify feedback is actionable, send to Coder

### After Phase 3 (PM Completion)
**Verification Tasks**:
1. **Merge Validation**: Confirm PR merged to correct branch, no breakage
2. **State Validation**: Check strategic state files updated correctly
3. **Planning Validation**: Verify next assignment is accurate and ready
4. **Roadmap Sync**: Confirm roadmap reflects current status

**Pass Criteria**: All deliverables complete and accurate
**Fail Action**: Request PM to fix specific issues

## Merge Conflict Prevention Protocol

### Early Dev Synchronization (CRITICAL)
**Problem**: Merge conflicts at the end of development cycles cause significant delays and complexity.

**Solution**: Synchronize with dev branch EARLY and REGULARLY during development:

1. **Phase 1 Start**: Coder Agent MUST begin with:
   ```bash
   git fetch origin dev
   git merge origin/dev
   ```
   Resolve any conflicts BEFORE starting feature work.

2. **Long Development Cycles**: For multi-day work, sync with dev every 24-48 hours:
   ```bash
   git fetch origin dev
   git merge origin/dev
   ```

3. **Before PR Creation**: Final sync check:
   ```bash
   git fetch origin dev
   git merge origin/dev
   ```
   Ensure PR will merge cleanly.

### Conflict Resolution Ownership
- **Coder Agent**: Responsible for ALL technical merge conflict resolution
- **PM Agent**: Diagnoses merge issues, hands off to Coder for resolution
- **Verification Controller**: Ensures proper handoff protocol followed

## Standard Operating Procedures

### Agent Launchers
Always use standard launcher protocol from `STANDARD_BOT_LAUNCHER.md`:
```
Task(subagent_type="general-purpose", description="[Agent] bot standard launcher", prompt="""
You are the kinda-lang [agent] bot. Read your prompt file ~/kinda-lang-agents/agents/[agent].md and follow it exactly. Check your state files for assigned work. Execute your defined workflow.
""")
```

### GitHub Authentication
**CRITICAL**: Each agent has specific GitHub token requirements:
- **Coder Agent**: `export GITHUB_TOKEN=$(cat ~/.config/coder-token.txt)`
- **Reviewer Agent**: `export GITHUB_TOKEN=$(cat ~/.config/reviewer-token.txt)` (DIFFERENT token)
- **Project Manager Agent**: `export GITHUB_TOKEN=$(cat ~/.config/coder-token.txt)` (same as coder)

All agents MUST set their appropriate token before any `gh` CLI operations.

### CI Standardization
ALL agents must use: `~/kinda-lang-agents/infrastructure/scripts/ci-local.sh`
- Exactly matches GitHub Actions CI
- Enhanced local testing (seeds, chaos levels, personalities)
- 100% local pass = 100% GitHub pass confidence

### Communication Protocol
**Handoff Messages**:
- Coder → Verification: "Task complete - ci-local.sh passing 100%"
- Verification → Reviewer: "Coder work verified - ready for quality review"
- Reviewer → Verification: "Review complete - [APPROVED/CHANGES REQUESTED]"
- Verification → PM: "Review verified and approved - ready for merge"

### Quality Standards
**Non-Negotiable Requirements**:
- 100% passing ci-local.sh before any handoff
- All merge conflicts resolved before review
- Specific, actionable feedback for change requests
- Complete strategic state updates after merge

## Failure Recovery
**If Agent Fails Verification**:
1. Document specific issues found
2. Send agent back with clear requirements
3. Re-verify before proceeding
4. Escalate to user if repeated failures

**If Process Breaks Down**:
1. Stop workflow immediately
2. Identify root cause
3. Fix process issues
4. Restart from appropriate phase

## Success Metrics
- **Quality**: Zero defects making it past verification checkpoints
- **Efficiency**: Smooth handoffs between agents
- **Reliability**: Consistent 100% CI pass rates
- **Completeness**: All deliverables present and accurate

This protocol ensures systematic quality control while maintaining development velocity through the 5-agent workflow system.

---
*Created: 2025-09-13*
*For: Kinda-Lang Development Team*
*Version: 1.0*