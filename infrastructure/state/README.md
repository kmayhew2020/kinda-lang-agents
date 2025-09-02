# 🧠 Kinda-Lang Bot State Management System

## Overview
Each bot maintains persistent state between sessions to enable:
- **Memory of previous tasks and decisions**
- **Coordination between different bot types** 
- **Progress tracking across development cycles**
- **Learning from past successes and failures**

## State Architecture

### State File Structure
```
kinda-lang-agents/infrastructure/state/
├── coder-bot-state.json        # Coder bot persistent state
├── reviewer-bot-state.json     # Reviewer bot persistent state
├── pm-bot-state.json          # Project Manager bot state
├── shared-state.json          # Cross-bot coordination state
└── state-schema.json          # State validation schema
```

### State Categories

#### 1. **Current Task State**
- Active epic/issue being worked on
- Feature branch information
- Current development phase
- Blocking issues or dependencies

#### 2. **Historical Context**
- Recently completed tasks
- Past decision rationale
- Known issues and solutions
- Performance patterns

#### 3. **Coordination State**
- Handoffs between bots
- Review status and feedback
- Merge conflicts resolution
- CI/CD status tracking

#### 4. **Learning State**
- Successful patterns and approaches
- Failed attempts and lessons learned
- Code quality metrics
- Time estimation accuracy

## State Management Workflow

### Bot Startup Sequence
1. **Load persistent state** from JSON file
2. **Validate state integrity** against schema
3. **Merge with current environment** (git status, recent changes)
4. **Initialize working context** for current session
5. **Log startup state** for debugging

### Bot Completion Sequence
1. **Update task progress** and status
2. **Record decisions made** and rationale
3. **Note any blockers** or issues encountered
4. **Update coordination flags** for other bots
5. **Persist state to disk** atomically
6. **Validate state was saved** correctly

## Implementation Details

### State File Format (JSON)
```json
{
  "meta": {
    "bot_type": "coder",
    "last_updated": "2025-09-01T15:30:00Z",
    "session_count": 42,
    "schema_version": "1.0"
  },
  "current_task": {
    "epic_id": "124",
    "issue_number": 122,
    "branch_name": "feature/issue-122-record-replay",
    "phase": "implementation",
    "progress_percent": 75,
    "blockers": [],
    "next_steps": ["integrate with existing CLI", "add tests"]
  },
  "context": {
    "recent_commits": ["abc123", "def456"],
    "active_files": ["kinda/cli.py", "kinda/recorder.py"],
    "test_results": "passing",
    "ci_status": "green",
    "upstream_sync_needed": false
  },
  "coordination": {
    "waiting_for_review": false,
    "reviewer_feedback": [],
    "pm_approval_needed": false,
    "merge_ready": false
  },
  "history": {
    "completed_tasks": [121, 86, 123],
    "successful_patterns": ["TDD approach", "small incremental changes"],
    "failed_attempts": [],
    "lessons_learned": ["Always run full CI before PR"]
  }
}
```

### Shared State for Bot Coordination
```json
{
  "meta": {
    "last_updated": "2025-09-01T15:30:00Z",
    "active_bots": ["coder", "reviewer"]
  },
  "development_cycle": {
    "current_epic": "124",
    "epic_progress": 0.25,
    "target_completion": "2025-09-15",
    "active_branches": ["feature/issue-122-record-replay"]
  },
  "handoffs": {
    "coder_to_reviewer": {
      "pending": true,
      "pr_url": "https://github.com/kinda-lang-dev/kinda-lang/pull/42",
      "timestamp": "2025-09-01T15:15:00Z"
    }
  },
  "repository_status": {
    "main_branch_sha": "abc123def",
    "dev_branch_sha": "def456abc",
    "fork_sync_status": "current",
    "ci_health": "green"
  }
}
```

## Usage in Agent Prompts

### Startup Integration
```markdown
**MANDATORY STARTUP SEQUENCE:**
1. Load your persistent state from infrastructure/state/{bot-type}-state.json
2. Analyze current repository status vs. your saved context
3. Identify any changes since last session
4. Update your working context and priorities
5. Report startup status and current focus
```

### Completion Integration
```markdown
**MANDATORY COMPLETION SEQUENCE:**
1. Update your task progress and status
2. Record key decisions and rationale
3. Note any blockers or issues for next session
4. Update coordination flags for other bots
5. Save state atomically to infrastructure/state/{bot-type}-state.json
6. Verify state was persisted correctly
```

## Security and Reliability

### State File Security
- ✅ **Git-ignored**: State files never committed to repos
- ✅ **Local-only**: State stored only on development machine
- ✅ **Atomic writes**: State updates are atomic to prevent corruption
- ✅ **Backup rotation**: Keep last 3 state versions for recovery

### Error Handling
- **Invalid state**: Graceful degradation to clean slate
- **Corruption detection**: JSON schema validation on load
- **Recovery mechanisms**: State backup restoration
- **Logging**: Detailed state change logging for debugging

---

*Bot state management enables persistent memory and coordination across development sessions*