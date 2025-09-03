#!/bin/bash
# Secure Bot Launcher
# Ensures bots use proper authentication and fork workflow

set -e

echo "🚀 Secure Bot Launcher"
echo "======================"

# Validate arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <coder|reviewer>"
    echo ""
    echo "This script ensures bots:"
    echo "  - Use their own PAT authentication"
    echo "  - Work only in the fork repository"
    echo "  - Cannot access the main protected repo directly"
    exit 1
fi

BOT_TYPE="$1"

# Load environment
if [ ! -f ~/kinda-lang-agents/infrastructure/.env.local ]; then
    echo "❌ Bot environment file not found!"
    echo "Expected: ~/kinda-lang-agents/infrastructure/.env.local"
    exit 1
fi

source ~/kinda-lang-agents/infrastructure/.env.local

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_status() { echo -e "${BLUE}[BOT]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Setup bot authentication
setup_bot_auth() {
    local bot_type="$1"
    
    print_status "Setting up $bot_type authentication..."
    
    # Clear any existing authentication
    gh auth logout 2>/dev/null || true
    unset GH_TOKEN 2>/dev/null || true
    
    case "$bot_type" in
        "coder")
            if [ -z "$KINDA_CODER_PAT" ]; then
                print_error "KINDA_CODER_PAT not found!"
                exit 1
            fi
            
            export GH_TOKEN="$KINDA_CODER_PAT"
            git config user.name "kinda-lang-coder"
            git config user.email "kinda-lang-coder@users.noreply.github.com"
            
            print_success "Coder bot authenticated as kinda-lang-coder"
            ;;
            
        "reviewer")
            if [ -z "$KINDA_REVIEWER_PAT" ]; then
                print_error "KINDA_REVIEWER_PAT not found!"
                exit 1
            fi
            
            export GH_TOKEN="$KINDA_REVIEWER_PAT"  
            git config user.name "kinda-lang-reviewer"
            git config user.email "kinda-lang-reviewer@users.noreply.github.com"
            
            print_success "Reviewer bot authenticated as kinda-lang-reviewer"
            ;;
            
        *)
            print_error "Invalid bot type: $bot_type"
            exit 1
            ;;
    esac
    
    # Verify authentication
    if ! gh auth status >/dev/null 2>&1; then
        print_error "GitHub authentication failed!"
        exit 1
    fi
    
    # Verify correct bot identity
    actual_user=$(gh api user --jq .login)
    expected_user="kinda-lang-$bot_type"
    
    if [ "$actual_user" != "$expected_user" ]; then
        print_error "Authentication mismatch!"
        print_error "Expected: $expected_user, Got: $actual_user"
        exit 1
    fi
    
    print_success "Bot identity verified: $actual_user"
}

# Navigate to repository and setup authentication
cd ~/kinda-lang
setup_bot_auth "$BOT_TYPE"

# Setup Python environment variables (no sourcing needed)
VENV_DIR="$HOME/kinda-lang/venv"
if [ ! -d "$VENV_DIR" ]; then
    print_error "Python virtual environment not found!"
    print_status "Run setup-python-env.sh first"
    exit 1
fi

export KINDA_PYTHON="$VENV_DIR/bin/python"
export KINDA_PIP="$VENV_DIR/bin/pip" 
export KINDA_PYTEST="$VENV_DIR/bin/pytest"
export PATH="$VENV_DIR/bin:$PATH"

print_success "Python environment configured: $($KINDA_PYTHON --version)"

# Force GitHub CLI to use the fork repository
export GH_REPO="kinda-lang-dev/kinda-lang"

# Verify we can access the fork
if ! gh repo view kinda-lang-dev/kinda-lang >/dev/null 2>&1; then
    print_error "Cannot access fork repository: kinda-lang-dev/kinda-lang"
    print_error "Check bot PAT permissions"
    exit 1
fi

print_success "Repository verified: kinda-lang-dev/kinda-lang (fork)"

# Show current status
print_status "Current branch: $(git branch --show-current)"
print_status "Git identity: $(git config user.name) <$(git config user.email)>"
print_status "GitHub identity: $(gh api user --jq .login)"
print_status "Python: $($KINDA_PYTHON --version)"
print_status "Available: KINDA_PYTHON, KINDA_PIP, KINDA_PYTEST"

echo "======================"
print_success "🎉 $BOT_TYPE bot ready for secure operations!"
print_status "Bot is authenticated and limited to fork repository only"
echo "======================"