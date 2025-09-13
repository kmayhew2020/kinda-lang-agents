#!/bin/bash
# Bot Task Completion with State Persistence
# Handles state updates and cleanup when bot tasks complete

set -e

echo "🏁 Kinda-Lang Bot Task Completion"
echo "================================"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_MANAGER="$SCRIPT_DIR/state-manager.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[COMPLETE]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Check arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <bot-type> <status> [summary] [next-action]"
    echo ""
    echo "Bot types: coder, reviewer, pm"
    echo "Status: completed, blocked, in-progress, failed"
    echo ""
    echo "Examples:"
    echo "  $0 coder completed 'Implemented record/replay system' 'Create PR for review'"
    echo "  $0 reviewer blocked 'Waiting for CI to pass'"
    echo "  $0 pm in-progress 'Epic planning 75% complete'"
    exit 1
fi

BOT_TYPE="$1"
TASK_STATUS="$2"
TASK_SUMMARY="${3:-}"
NEXT_ACTION="${4:-}"

# Validate bot type
case "$BOT_TYPE" in
    "coder"|"reviewer"|"pm")
        ;;
    *)
        print_error "Invalid bot type: $BOT_TYPE"
        exit 1
        ;;
esac

# Validate status
case "$TASK_STATUS" in
    "completed"|"blocked"|"in-progress"|"failed")
        ;;
    *)
        print_error "Invalid status: $TASK_STATUS"
        print_status "Valid statuses: completed, blocked, in-progress, failed"
        exit 1
        ;;
esac

print_status "Processing $TASK_STATUS status for $BOT_TYPE bot..."

# Load environment
INFRASTRUCTURE_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$INFRASTRUCTURE_DIR/.env.local"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    print_error "Environment file not found: $ENV_FILE"
    exit 1
fi

# Navigate to repository
if [ -n "$KINDA_MAIN_REPO" ] && [ -d "$KINDA_MAIN_REPO" ]; then
    cd "$KINDA_MAIN_REPO"
else
    print_error "Main repository not found: $KINDA_MAIN_REPO"
    exit 1
fi

# Get current repository context
CURRENT_BRANCH=$(git branch --show-current)
GIT_STATUS=$(git status --porcelain)
LAST_COMMIT=$(git rev-parse HEAD)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Update bot state based on completion status
STATE_FILE="$INFRASTRUCTURE_DIR/state/${BOT_TYPE}-bot-state.json"

print_status "Updating bot state..."

case "$TASK_STATUS" in
    "completed")
        # Move current task to history and reset current task
        jq --arg summary "$TASK_SUMMARY" \
           --arg timestamp "$TIMESTAMP" \
           --arg commit "$LAST_COMMIT" \
           --arg next "$NEXT_ACTION" \
           '
           # Add to completed tasks history
           .history.completed_tasks += [.current_task + {
               "completion_summary": $summary,
               "completion_timestamp": $timestamp,
               "completion_commit": $commit
           }] |
           # Reset current task
           .current_task = {
               "epic_id": null,
               "issue_number": null,
               "branch_name": null,
               "phase": "idle",
               "progress_percent": 0,
               "blockers": [],
               "next_steps": ($next | if . != "" then [.] else [] end)
           } |
           # Update coordination state
           .coordination.waiting_for_review = false |
           .coordination.merge_ready = false
           ' \
           "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
        ;;
        
    "blocked")
        # Update current task with blocker information
        jq --arg summary "$TASK_SUMMARY" \
           --arg timestamp "$TIMESTAMP" \
           '.current_task.blockers += [$summary] |
            .current_task.phase = "blocked" |
            .meta.last_blocked = $timestamp' \
           "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
        ;;
        
    "in-progress")
        # Update progress and summary
        jq --arg summary "$TASK_SUMMARY" \
           --arg next "$NEXT_ACTION" \
           --arg timestamp "$TIMESTAMP" \
           '.current_task.phase = "in-progress" |
            .current_task.progress_summary = $summary |
            .current_task.next_steps = ($next | if . != "" then [.] else .current_task.next_steps end) |
            .meta.last_progress_update = $timestamp' \
           "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
        ;;
        
    "failed")
        # Record failure and lessons learned
        jq --arg summary "$TASK_SUMMARY" \
           --arg timestamp "$TIMESTAMP" \
           --arg commit "$LAST_COMMIT" \
           '.history.failed_attempts += [{
               "task": .current_task,
               "failure_reason": $summary,
               "timestamp": $timestamp,
               "commit": $commit
           }] |
           .current_task.phase = "failed" |
           .current_task.failure_reason = $summary' \
           "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
        ;;
esac

# Update shared coordination state
print_status "Updating shared coordination state..."

case "$BOT_TYPE" in
    "coder")
        if [ "$TASK_STATUS" = "completed" ] && [ -n "$NEXT_ACTION" ]; then
            # Signal handoff to reviewer if PR created
            if [[ "$NEXT_ACTION" =~ "PR" || "$NEXT_ACTION" =~ "review" ]]; then
                "$STATE_MANAGER" update-shared "handoffs.coder_to_reviewer.pending" "true"
                "$STATE_MANAGER" update-shared "handoffs.coder_to_reviewer.timestamp" "$TIMESTAMP"
                "$STATE_MANAGER" update-shared "handoffs.coder_to_reviewer.branch_name" "$CURRENT_BRANCH"
                "$STATE_MANAGER" update-shared "handoffs.coder_to_reviewer.description" "$TASK_SUMMARY"
            fi
        fi
        ;;
        
    "reviewer")
        if [ "$TASK_STATUS" = "completed" ]; then
            # Signal completion back to PM
            "$STATE_MANAGER" update-shared "handoffs.reviewer_to_pm.pending" "true"
            "$STATE_MANAGER" update-shared "handoffs.reviewer_to_pm.timestamp" "$TIMESTAMP"
            "$STATE_MANAGER" update-shared "handoffs.reviewer_to_pm.approval_status" "approved"
        fi
        ;;
        
    "pm")
        if [ "$TASK_STATUS" = "completed" ] && [ -n "$NEXT_ACTION" ]; then
            # Signal new assignment to coder if needed
            if [[ "$NEXT_ACTION" =~ "assign" || "$NEXT_ACTION" =~ "implement" ]]; then
                "$STATE_MANAGER" update-shared "handoffs.pm_to_coder.pending" "true"
                "$STATE_MANAGER" update-shared "handoffs.pm_to_coder.timestamp" "$TIMESTAMP"
                "$STATE_MANAGER" update-shared "handoffs.pm_to_coder.assignment" "$TASK_SUMMARY"
            fi
        fi
        ;;
esac

# Save final state
print_status "Persisting state changes..."
if "$STATE_MANAGER" save "$BOT_TYPE"; then
    print_success "State saved successfully"
else
    print_error "Failed to save state"
    exit 1
fi

# Log completion to shared communication log
SHARED_FILE="$INFRASTRUCTURE_DIR/state/shared-state.json"
jq --arg bot "$BOT_TYPE" \
   --arg status "$TASK_STATUS" \
   --arg summary "$TASK_SUMMARY" \
   --arg timestamp "$TIMESTAMP" \
   '.communication_log += [{
       "timestamp": $timestamp,
       "from_bot": $bot,
       "to_bot": "system",
       "message_type": "completion",
       "content": "\($bot) bot task \($status): \($summary)"
   }] |
   .communication_log = (.communication_log | if length > 50 then .[25:] else . end)' \
   "$SHARED_FILE" > "$SHARED_FILE.tmp" && mv "$SHARED_FILE.tmp" "$SHARED_FILE"

# Show completion summary
echo "================================"
print_success "🎉 Task completion recorded!"
echo ""
print_status "Completion Summary:"
echo "  Bot: $BOT_TYPE"
echo "  Status: $TASK_STATUS"
echo "  Branch: $CURRENT_BRANCH"
echo "  Commit: ${LAST_COMMIT:0:8}"
if [ -n "$TASK_SUMMARY" ]; then
    echo "  Summary: $TASK_SUMMARY"
fi
if [ -n "$NEXT_ACTION" ]; then
    echo "  Next Action: $NEXT_ACTION"
fi
echo ""

# Show next steps based on status
case "$TASK_STATUS" in
    "completed")
        print_success "Task completed successfully!"
        if [ -n "$NEXT_ACTION" ]; then
            print_status "Recommended next action: $NEXT_ACTION"
        fi
        ;;
    "blocked")
        print_warning "Task is blocked - intervention needed"
        print_status "Blocker: $TASK_SUMMARY"
        ;;
    "in-progress")
        print_status "Task in progress - can resume later"
        ;;
    "failed")
        print_error "Task failed - review needed"
        print_status "Failure reason: $TASK_SUMMARY"
        ;;
esac

echo "================================"

exit 0