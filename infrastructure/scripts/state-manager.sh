#!/bin/bash
# State Management Utilities for Kinda-Lang Bots
# Handles loading, saving, and validating bot persistent state

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$(dirname "$SCRIPT_DIR")/state"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[STATE]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Function to validate JSON
validate_json() {
    local file="$1"
    if ! jq empty "$file" 2>/dev/null; then
        return 1
    fi
    return 0
}

# Function to backup state file
backup_state() {
    local bot_type="$1"
    local state_file="$STATE_DIR/${bot_type}-bot-state.json"
    
    if [ -f "$state_file" ]; then
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local backup_file="$STATE_DIR/backups/${bot_type}-bot-state-${timestamp}.json"
        
        mkdir -p "$STATE_DIR/backups"
        cp "$state_file" "$backup_file"
        
        # Keep only last 3 backups
        ls -t "$STATE_DIR/backups/${bot_type}-bot-state-"*.json 2>/dev/null | tail -n +4 | xargs -r rm
        
        print_status "State backed up: $(basename "$backup_file")"
    fi
}

# Function to load bot state
load_state() {
    local bot_type="$1"
    local state_file="$STATE_DIR/${bot_type}-bot-state.json"
    
    print_status "Loading state for $bot_type bot..."
    
    if [ ! -f "$state_file" ]; then
        print_warning "No state file found for $bot_type bot"
        print_status "Creating fresh state file..."
        echo "{}" > "$state_file"
        return 1
    fi
    
    if ! validate_json "$state_file"; then
        print_error "State file corrupted for $bot_type bot"
        
        # Try to restore from backup
        local latest_backup=$(ls -t "$STATE_DIR/backups/${bot_type}-bot-state-"*.json 2>/dev/null | head -1)
        if [ -n "$latest_backup" ]; then
            print_warning "Restoring from backup: $(basename "$latest_backup")"
            cp "$latest_backup" "$state_file"
            if validate_json "$state_file"; then
                print_success "State restored from backup"
                return 0
            fi
        fi
        
        print_error "Cannot restore state - starting fresh"
        echo "{}" > "$state_file"
        return 1
    fi
    
    print_success "State loaded for $bot_type bot"
    
    # Update session count
    local session_count=$(jq -r '.meta.session_count // 0' "$state_file")
    session_count=$((session_count + 1))
    
    jq --argjson count "$session_count" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '.meta.session_count = $count | .meta.last_updated = $timestamp' \
       "$state_file" > "$state_file.tmp" && mv "$state_file.tmp" "$state_file"
    
    return 0
}

# Function to save bot state
save_state() {
    local bot_type="$1"
    local state_file="$STATE_DIR/${bot_type}-bot-state.json"
    
    print_status "Saving state for $bot_type bot..."
    
    # Backup current state
    backup_state "$bot_type"
    
    # Update timestamp
    jq --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '.meta.last_updated = $timestamp' \
       "$state_file" > "$state_file.tmp"
    
    # Atomic save
    if validate_json "$state_file.tmp"; then
        mv "$state_file.tmp" "$state_file"
        print_success "State saved for $bot_type bot"
        return 0
    else
        print_error "Invalid state data - save aborted"
        rm -f "$state_file.tmp"
        return 1
    fi
}

# Function to update shared state
update_shared_state() {
    local key="$1"
    local value="$2"
    local shared_file="$STATE_DIR/shared-state.json"
    
    print_status "Updating shared state: $key"
    
    # Backup shared state
    if [ -f "$shared_file" ]; then
        cp "$shared_file" "$shared_file.backup"
    fi
    
    # Update shared state
    jq --arg key "$key" --arg value "$value" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       'setpath($key | split("."); $value) | .meta.last_updated = $timestamp' \
       "$shared_file" > "$shared_file.tmp"
    
    if validate_json "$shared_file.tmp"; then
        mv "$shared_file.tmp" "$shared_file"
        print_success "Shared state updated: $key"
        return 0
    else
        print_error "Invalid shared state update - aborted"
        rm -f "$shared_file.tmp"
        return 1
    fi
}

# Function to get state value
get_state() {
    local bot_type="$1"
    local key="$2"
    local state_file="$STATE_DIR/${bot_type}-bot-state.json"
    
    if [ -f "$state_file" ]; then
        jq -r "$key // \"null\"" "$state_file"
    else
        echo "null"
    fi
}

# Function to show state summary
show_state() {
    local bot_type="$1"
    local state_file="$STATE_DIR/${bot_type}-bot-state.json"
    
    if [ ! -f "$state_file" ]; then
        print_warning "No state file for $bot_type bot"
        return 1
    fi
    
    print_status "$bot_type bot state summary:"
    echo "  Last updated: $(jq -r '.meta.last_updated // "never"' "$state_file")"
    echo "  Sessions: $(jq -r '.meta.session_count // 0' "$state_file")"
    
    if [ "$bot_type" = "coder" ]; then
        echo "  Current task: $(jq -r '.current_task.issue_number // "none"' "$state_file")"
        echo "  Branch: $(jq -r '.current_task.branch_name // "none"' "$state_file")"
        echo "  Progress: $(jq -r '.current_task.progress_percent // 0' "$state_file")%"
    elif [ "$bot_type" = "reviewer" ]; then
        echo "  Pending reviews: $(jq -r '.current_task.pending_reviews | length' "$state_file")"
        echo "  Review queue: $(jq -r '.context.review_queue_length // 0' "$state_file")"
    elif [ "$bot_type" = "pm" ]; then
        echo "  Current epic: $(jq -r '.current_epic.epic_id // "none"' "$state_file")"
        echo "  Epic progress: $(jq -r '.current_epic.progress_percent // 0' "$state_file")%"
    fi
}

# Main command handling
case "${1:-help}" in
    "load")
        load_state "$2"
        ;;
    "save")
        save_state "$2"
        ;;
    "show")
        show_state "$2"
        ;;
    "update-shared")
        update_shared_state "$2" "$3"
        ;;
    "get")
        get_state "$2" "$3"
        ;;
    "help"|*)
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  load <bot-type>           Load and initialize bot state"
        echo "  save <bot-type>           Save current bot state"
        echo "  show <bot-type>           Show state summary"
        echo "  get <bot-type> <key>      Get specific state value"
        echo "  update-shared <key> <val> Update shared coordination state"
        echo ""
        echo "Bot types: coder, reviewer, pm"
        echo ""
        echo "Examples:"
        echo "  $0 load coder"
        echo "  $0 show reviewer"
        echo "  $0 get coder '.current_task.issue_number'"
        echo "  $0 update-shared 'development_cycle.current_epic' '124'"
        ;;
esac