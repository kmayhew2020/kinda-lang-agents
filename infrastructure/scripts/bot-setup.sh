#!/bin/bash
# Bot Development Environment Setup for Kinda-Lang
# Loads bot credentials and configures development environment

echo "🤖 Kinda-Lang Bot Development Setup"
echo "=================================="

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRASTRUCTURE_DIR="$(dirname "$SCRIPT_DIR")"
AGENTS_ROOT="$(dirname "$INFRASTRUCTURE_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[BOT]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Load environment variables
ENV_FILE="$INFRASTRUCTURE_DIR/.env.local"
if [ -f "$ENV_FILE" ]; then
    print_status "Loading bot environment variables..."
    source "$ENV_FILE"
    print_success "Environment loaded from $ENV_FILE"
else
    print_error ".env.local not found at $ENV_FILE"
    print_status "Create it with your bot PATs:"
    print_status "  cp $ENV_FILE.template $ENV_FILE"
    print_status "  # Edit and add your actual PATs"
    exit 1
fi

# Verify PATs are configured
if [ -z "$KINDA_CODER_PAT" ] || [ "$KINDA_CODER_PAT" = "your_coder_bot_pat_here" ]; then
    print_error "Coder bot PAT not configured"
    PAT_MISSING=true
fi

if [ -z "$KINDA_REVIEWER_PAT" ] || [ "$KINDA_REVIEWER_PAT" = "your_reviewer_bot_pat_here" ]; then
    print_error "Reviewer bot PAT not configured" 
    PAT_MISSING=true
fi

if [ "$PAT_MISSING" = true ]; then
    print_error "Please configure PATs in $ENV_FILE"
    exit 1
fi

print_success "✅ Coder bot PAT configured"
print_success "✅ Reviewer bot PAT configured"

# Verify kinda-lang repo exists
if [ -n "$KINDA_MAIN_REPO" ] && [ -d "$KINDA_MAIN_REPO" ]; then
    print_success "Main repo found: $KINDA_MAIN_REPO"
    cd "$KINDA_MAIN_REPO"
else
    print_error "Main kinda-lang repo not found"
    print_status "Set KINDA_MAIN_REPO in .env.local or run from correct directory"
    exit 1
fi

# Verify git remotes are configured
if git remote | grep -q "upstream" && git remote | grep -q "origin"; then
    print_success "Git remotes configured (upstream + origin/fork)"
else
    print_warning "Git remotes not configured. Run fork-setup first:"
    print_status "  $AGENTS_ROOT/infrastructure/scripts/fork-setup.sh"
fi

echo "=================================="
print_success "🎉 Bot environment ready!"
print_status "Available commands:"
print_status "  $SCRIPT_DIR/bot-auth.sh coder     # Configure git as coder bot"
print_status "  $SCRIPT_DIR/bot-auth.sh reviewer  # Configure git as reviewer bot"
print_status "  $SCRIPT_DIR/ci-local.sh           # Run full CI locally"
print_status "  $SCRIPT_DIR/sync-upstream.sh      # Sync fork with upstream"
echo "=================================="

exit 0