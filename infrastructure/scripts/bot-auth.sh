#!/bin/bash
# Bot Authentication Setup for Kinda-Lang Development
# Configures git with bot credentials for automated commits and PRs

set -e

echo "🤖 Kinda-Lang Bot Authentication Setup"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[AUTH]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Function to setup bot credentials
setup_bot() {
    local bot_name="$1"
    local bot_email="$2"
    local pat_var="$3"
    
    print_status "Setting up $bot_name credentials..."
    
    # Check if PAT is provided
    if [ -z "${!pat_var}" ]; then
        print_warning "PAT not found in environment variable: $pat_var"
        print_status "Please set the PAT manually:"
        print_status "  export $pat_var='your_pat_here'"
        return 1
    fi
    
    # Configure git for this bot
    git config user.name "$bot_name"
    git config user.email "$bot_email"
    
    # Configure git to use PAT for HTTPS
    git config credential.helper store
    
    # Set up the credential for the fork remote
    echo "https://${!pat_var}@github.com" > ~/.git-credentials-temp
    git config credential.helper "store --file ~/.git-credentials-temp"
    
    print_success "$bot_name authentication configured"
    return 0
}

# Show usage if no arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 [coder|reviewer]"
    echo ""
    echo "Environment variables needed:"
    echo "  KINDA_CODER_PAT    - Personal Access Token for kinda-lang-coder"
    echo "  KINDA_REVIEWER_PAT - Personal Access Token for kinda-lang-reviewer"
    echo ""
    echo "Example:"
    echo "  export KINDA_CODER_PAT='ghp_xxxxxxxxxxxx'"
    echo "  $0 coder"
    exit 1
fi

BOT_TYPE="$1"

case "$BOT_TYPE" in
    "coder")
        setup_bot "kinda-lang-coder" "kinda-lang-coder@users.noreply.github.com" "KINDA_CODER_PAT"
        ;;
    "reviewer")
        setup_bot "kinda-lang-reviewer" "kinda-lang-reviewer@users.noreply.github.com" "KINDA_REVIEWER_PAT"
        ;;
    *)
        print_error "Invalid bot type: $BOT_TYPE"
        print_status "Use 'coder' or 'reviewer'"
        exit 1
        ;;
esac

print_status "Current git configuration:"
echo "  Name:  $(git config user.name)"
echo "  Email: $(git config user.email)"

echo "====================================="
print_success "🎉 Bot authentication ready!"
print_warning "Remember: This sets git config for the current repository only"
echo "====================================="

exit 0