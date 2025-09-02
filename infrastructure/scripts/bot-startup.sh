#!/bin/bash
# Enhanced Bot Startup with State Management
# Integrates state loading with bot initialization

set -e

echo "🤖 Kinda-Lang Bot Startup with State Management"
echo "=============================================="

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_MANAGER="$SCRIPT_DIR/state-manager.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[STARTUP]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Check arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <bot-type> [task-context]"
    echo ""
    echo "Bot types:"
    echo "  coder      - Development and implementation bot"
    echo "  reviewer   - Code review and quality assurance bot"
    echo "  pm         - Project manager and architecture bot"
    echo ""
    echo "Example:"
    echo "  $0 coder 'Issue #122: Implement record/replay system'"
    echo "  $0 reviewer"
    echo "  $0 pm 'Plan Epic #124: Construct Self-definition'"
    exit 1
fi

BOT_TYPE="$1"
TASK_CONTEXT="${2:-}"

# Validate bot type
case "$BOT_TYPE" in
    "coder"|"reviewer"|"pm")
        ;;
    *)
        print_error "Invalid bot type: $BOT_TYPE"
        print_status "Valid types: coder, reviewer, pm"
        exit 1
        ;;
esac

print_status "Initializing $BOT_TYPE bot..."

# Step 1: Load environment
print_status "Loading bot environment..."
INFRASTRUCTURE_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$INFRASTRUCTURE_DIR/.env.local"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
    print_success "Environment loaded"
else
    print_error "Environment file not found: $ENV_FILE"
    exit 1
fi

# Step 2: Load persistent state
print_status "Loading persistent state..."
if "$STATE_MANAGER" load "$BOT_TYPE"; then
    print_success "State loaded successfully"
    
    # Show state summary
    "$STATE_MANAGER" show "$BOT_TYPE"
else
    print_warning "Started with fresh state"
fi

# Step 3: Analyze current repository context
print_status "Analyzing repository context..."
if [ -n "$KINDA_MAIN_REPO" ] && [ -d "$KINDA_MAIN_REPO" ]; then
    cd "$KINDA_MAIN_REPO"
    
    # Get current git status
    CURRENT_BRANCH=$(git branch --show-current)
    GIT_STATUS=$(git status --porcelain)
    
    print_status "Current branch: $CURRENT_BRANCH"
    
    if [ -z "$GIT_STATUS" ]; then
        print_success "Working directory clean"
    else
        print_warning "Working directory has changes:"
        git status --short | head -5
    fi
    
    # Check if upstream sync needed
    git fetch upstream >/dev/null 2>&1 || print_warning "Could not fetch upstream"
    
    BEHIND_COUNT=$(git rev-list --count HEAD..upstream/$CURRENT_BRANCH 2>/dev/null || echo "0")
    if [ "$BEHIND_COUNT" -gt 0 ]; then
        print_warning "Behind upstream by $BEHIND_COUNT commits"
    else
        print_success "Up to date with upstream"
    fi
    
else
    print_error "Main repository not found: $KINDA_MAIN_REPO"
    exit 1
fi

# Step 4: Update state with current context
print_status "Updating state with current context..."

# Update context in state file
STATE_FILE="$INFRASTRUCTURE_DIR/state/${BOT_TYPE}-bot-state.json"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

jq --arg branch "$CURRENT_BRANCH" \
   --arg timestamp "$TIMESTAMP" \
   --argjson clean "$([ -z "$GIT_STATUS" ] && echo true || echo false)" \
   --argjson behind "$BEHIND_COUNT" \
   '.context.current_branch = $branch |
    .context.working_directory_clean = $clean |
    .context.upstream_sync_needed = ($behind > 0) |
    .meta.startup_timestamp = $timestamp' \
   "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

# Step 5: Set task context if provided
if [ -n "$TASK_CONTEXT" ]; then
    print_status "Setting task context: $TASK_CONTEXT"
    
    # Extract issue number if present
    ISSUE_NUM=$(echo "$TASK_CONTEXT" | grep -o '#[0-9]\+' | head -1 | sed 's/#//')
    
    if [ -n "$ISSUE_NUM" ]; then
        jq --argjson issue "$ISSUE_NUM" \
           --arg context "$TASK_CONTEXT" \
           '.current_task.issue_number = $issue |
            .current_task.context = $context |
            .current_task.phase = "planning"' \
           "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi
fi

# Step 6: Configure git identity for bot
print_status "Configuring git identity..."
case "$BOT_TYPE" in
    "coder")
        git config user.name "kinda-lang-coder"
        git config user.email "kinda-lang-coder@users.noreply.github.com"
        ;;
    "reviewer")
        git config user.name "kinda-lang-reviewer"
        git config user.email "kinda-lang-reviewer@users.noreply.github.com"
        ;;
    "pm")
        git config user.name "kinda-lang-pm"
        git config user.email "kinda-lang-pm@users.noreply.github.com"
        ;;
esac

print_success "Git identity configured for $BOT_TYPE bot"

# Step 7: Update shared coordination state
print_status "Updating shared coordination state..."
"$STATE_MANAGER" update-shared "meta.active_bots" "[\"$BOT_TYPE\"]"
"$STATE_MANAGER" update-shared "repository_status.current_branch" "$CURRENT_BRANCH"

# Final summary
echo "=============================================="
print_success "🎉 $BOT_TYPE bot startup complete!"
echo ""
print_status "Context Summary:"
echo "  Bot Type: $BOT_TYPE"
echo "  Repository: $KINDA_MAIN_REPO"
echo "  Branch: $CURRENT_BRANCH"
echo "  Working Dir: $([ -z "$GIT_STATUS" ] && echo "Clean" || echo "Modified")"
echo "  Upstream: $([ "$BEHIND_COUNT" -gt 0 ] && echo "Behind by $BEHIND_COUNT" || echo "Up to date")"
if [ -n "$TASK_CONTEXT" ]; then
    echo "  Task: $TASK_CONTEXT"
fi
echo ""
print_status "State Files:"
echo "  Bot State: infrastructure/state/${BOT_TYPE}-bot-state.json"
echo "  Shared State: infrastructure/state/shared-state.json"
echo ""
print_status "Ready for $BOT_TYPE operations!"
echo "=============================================="

exit 0