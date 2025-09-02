#!/bin/bash
# Claude Code Assistant State Sync
# Helps Claude resume context and maintain continuity across sessions

set -e

echo "🧠 Claude Code Assistant State Sync"
echo "=================================="

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$(dirname "$SCRIPT_DIR")/state"
CLAUDE_STATE="$STATE_DIR/claude-assistant-state.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[CLAUDE]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Function to update session count
update_session_count() {
    if [ -f "$CLAUDE_STATE" ]; then
        local count=$(python3 -c "import json; data=json.load(open('$CLAUDE_STATE')); print(data.get('meta', {}).get('session_count', 0))")
        count=$((count + 1))
        
        python3 -c "
import json
from datetime import datetime, timezone

with open('$CLAUDE_STATE', 'r') as f:
    data = json.load(f)

data['meta']['session_count'] = $count
data['meta']['last_updated'] = datetime.now(timezone.utc).isoformat()

with open('$CLAUDE_STATE', 'w') as f:
    json.dump(data, f, indent=2)
"
        print_success "Session count updated to $count"
    fi
}

# Function to show current context summary
show_context_summary() {
    if [ -f "$CLAUDE_STATE" ]; then
        print_status "Claude Assistant Context Summary:"
        echo ""
        
        python3 -c "
import json
data = json.load(open('$CLAUDE_STATE'))

print(f\"  📊 Sessions: {data.get('meta', {}).get('session_count', 0)}\")
print(f\"  🎯 Project: {data.get('current_context', {}).get('active_project', 'unknown')}\")
print(f\"  📍 Phase: {data.get('current_context', {}).get('current_phase', 'unknown')}\")
print(f\"  🌿 Branch: {data.get('current_context', {}).get('current_branch', 'unknown')}\")
print(f\"  📝 Last Task: {data.get('current_context', {}).get('last_task', 'unknown')}\")
print()

priorities = data.get('development_status', {}).get('current_priorities', [])
if priorities:
    print('  🎯 Current Priorities:')
    for i, priority in enumerate(priorities[:3], 1):
        print(f'    {i}. {priority}')
    print()

completed = data.get('development_status', {}).get('completed_phases', [])
if completed:
    print('  ✅ Recently Completed:')
    for phase in completed[-3:]:
        print(f'    • {phase}')
    print()
"
    else
        print_warning "No existing Claude state found - starting fresh"
    fi
}

# Function to update current task
update_current_task() {
    local task="$1"
    if [ -n "$task" ] && [ -f "$CLAUDE_STATE" ]; then
        python3 -c "
import json
from datetime import datetime, timezone

with open('$CLAUDE_STATE', 'r') as f:
    data = json.load(f)

data['current_context']['last_task'] = '$task'
data['meta']['last_updated'] = datetime.now(timezone.utc).isoformat()

with open('$CLAUDE_STATE', 'w') as f:
    json.dump(data, f, indent=2)
"
        print_success "Current task updated: $task"
    fi
}

# Function to add learning or decision
add_learning() {
    local type="$1"  # "pattern", "lesson", or "decision"
    local content="$2"
    
    if [ -n "$content" ] && [ -f "$CLAUDE_STATE" ]; then
        python3 -c "
import json
from datetime import datetime, timezone

with open('$CLAUDE_STATE', 'r') as f:
    data = json.load(f)

if '$type' == 'pattern':
    if 'successful_patterns' not in data['learning_history']:
        data['learning_history']['successful_patterns'] = []
    data['learning_history']['successful_patterns'].append('$content')
elif '$type' == 'lesson':
    if 'lessons_learned' not in data['learning_history']:
        data['learning_history']['lessons_learned'] = []
    data['learning_history']['lessons_learned'].append('$content')
elif '$type' == 'decision':
    if 'architecture_decisions' not in data['project_knowledge']:
        data['project_knowledge']['architecture_decisions'] = []
    decision = {
        'decision': '$content',
        'date': datetime.now(timezone.utc).date().isoformat(),
        'rationale': 'Added via claude-sync'
    }
    data['project_knowledge']['architecture_decisions'].append(decision)

data['meta']['last_updated'] = datetime.now(timezone.utc).isoformat()

with open('$CLAUDE_STATE', 'w') as f:
    json.dump(data, f, indent=2)
"
        print_success "Added $type: $content"
    fi
}

# Main command handling
case "${1:-show}" in
    "show"|"status")
        show_context_summary
        ;;
    "start"|"startup")
        print_status "Starting Claude session..."
        update_session_count
        show_context_summary
        ;;
    "task")
        update_current_task "$2"
        ;;
    "learn")
        add_learning "$2" "$3"
        ;;
    "help"|*)
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  show                    Show current context summary"
        echo "  start                   Initialize new Claude session"
        echo "  task <description>      Update current task"
        echo "  learn pattern <text>    Add successful pattern"
        echo "  learn lesson <text>     Add lesson learned"
        echo "  learn decision <text>   Add architectural decision"
        echo ""
        echo "Examples:"
        echo "  $0 start"
        echo "  $0 task 'implementing state management'"
        echo "  $0 learn pattern 'step-by-step verification works well'"
        echo "  $0 learn lesson 'always check file paths before operations'"
        ;;
esac

echo "=================================="
exit 0