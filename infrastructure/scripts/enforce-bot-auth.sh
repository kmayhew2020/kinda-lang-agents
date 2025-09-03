#!/bin/bash
# MANDATORY Bot Authentication Enforcement
# Ensures bots ONLY use their own PATs and cannot access user accounts

set -e

echo "🔒 ENFORCING Bot Authentication Isolation"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[ENFORCE]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Function to setup MANDATORY bot authentication
enforce_bot_auth() {
    local bot_type="$1"
    local repo_dir="$2"
    
    print_status "Enforcing $bot_type authentication..."
    
    # Load bot environment variables
    if [ ! -f "/home/kevin/kinda-lang-agents/infrastructure/.env.local" ]; then
        print_error "Bot environment file not found!"
        print_error "Expected: /home/kevin/kinda-lang-agents/infrastructure/.env.local"
        exit 1
    fi
    
    source "/home/kevin/kinda-lang-agents/infrastructure/.env.local"
    
    # Navigate to repository
    cd "$repo_dir" || {
        print_error "Cannot access repository: $repo_dir"
        exit 1
    }
    
    # Clear any existing user authentication
    print_status "Clearing user credentials..."
    git config --unset user.name 2>/dev/null || true
    git config --unset user.email 2>/dev/null || true
    git config --unset credential.helper 2>/dev/null || true
    
    # Clear any existing GH_TOKEN
    unset GH_TOKEN
    
    # Logout from any existing GitHub CLI session
    gh auth logout 2>/dev/null || true
    
    case "$bot_type" in
        "coder")
            if [ -z "$KINDA_CODER_PAT" ]; then
                print_error "KINDA_CODER_PAT not found!"
                print_error "Bot cannot proceed without proper authentication"
                exit 1
            fi
            
            # Set MANDATORY bot identity
            git config user.name "kinda-lang-coder"
            git config user.email "kinda-lang-coder@users.noreply.github.com"
            
            # Configure GitHub CLI with bot PAT
            export GH_TOKEN="$KINDA_CODER_PAT"
            echo "$KINDA_CODER_PAT" | gh auth login --with-token --hostname github.com
            
            # Configure git remote URLs to use PAT
            git remote set-url origin "https://kinda-lang-coder:$KINDA_CODER_PAT@github.com/kinda-lang-dev/kinda-lang.git"
            git remote set-url upstream "https://kinda-lang-coder:$KINDA_CODER_PAT@github.com/kmayhew2020/kinda-lang.git"
            
            print_success "Coder bot authentication ENFORCED"
            ;;
            
        "reviewer")
            if [ -z "$KINDA_REVIEWER_PAT" ]; then
                print_error "KINDA_REVIEWER_PAT not found!"
                print_error "Bot cannot proceed without proper authentication"
                exit 1
            fi
            
            # Set MANDATORY bot identity
            git config user.name "kinda-lang-reviewer"
            git config user.email "kinda-lang-reviewer@users.noreply.github.com"
            
            # Configure GitHub CLI with bot PAT
            export GH_TOKEN="$KINDA_REVIEWER_PAT"
            echo "$KINDA_REVIEWER_PAT" | gh auth login --with-token --hostname github.com
            
            # Configure git remote URLs to use PAT
            git remote set-url origin "https://kinda-lang-reviewer:$KINDA_REVIEWER_PAT@github.com/kinda-lang-dev/kinda-lang.git"
            git remote set-url upstream "https://kinda-lang-reviewer:$KINDA_REVIEWER_PAT@github.com/kmayhew2020/kinda-lang.git"
            
            print_success "Reviewer bot authentication ENFORCED"
            ;;
            
        *)
            print_error "Invalid bot type: $bot_type"
            print_error "Use: 'coder' or 'reviewer'"
            exit 1
            ;;
    esac
    
    # Verify the setup worked
    print_status "Verifying authentication setup..."
    current_user=$(git config user.name)
    current_email=$(git config user.email)
    
    print_success "Git Identity: $current_user <$current_email>"
    
    # Test GitHub access
    if gh auth status >/dev/null 2>&1; then
        gh_user=$(gh api user --jq .login)
        print_success "GitHub CLI: Authenticated as $gh_user"
        
        # Ensure this matches the expected bot account
        expected_user="kinda-lang-$bot_type"
        if [ "$gh_user" != "$expected_user" ]; then
            print_error "AUTHENTICATION MISMATCH!"
            print_error "Expected: $expected_user, Got: $gh_user"
            exit 1
        fi
    else
        print_error "GitHub CLI authentication failed!"
        exit 1
    fi
    
    print_success "✅ Bot authentication verification PASSED"
}

# Validate arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <bot_type> <repo_directory>"
    echo ""
    echo "Arguments:"
    echo "  bot_type        - 'coder' or 'reviewer'"
    echo "  repo_directory  - Path to kinda-lang repository"
    echo ""
    echo "Example:"
    echo "  $0 coder /home/kevin/kinda-lang"
    echo ""
    echo "This script ENFORCES bot authentication and prevents fallback to user credentials."
    exit 1
fi

BOT_TYPE="$1"
REPO_DIR="$2"

# Execute enforcement
enforce_bot_auth "$BOT_TYPE" "$REPO_DIR"

print_success "🔒 Bot authentication enforcement COMPLETE"
print_warning "Bot is now ISOLATED and can only use its own credentials"
echo "========================================"

exit 0