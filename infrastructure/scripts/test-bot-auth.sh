#!/bin/bash
# Simple Bot Authentication Test
# Tests if bots can authenticate properly with GitHub CLI

set -e

echo "🧪 Testing Bot Authentication"
echo "============================="

# Load environment
source ~/kinda-lang-agents/infrastructure/.env.local

# Test function
test_bot_auth() {
    local bot_type="$1"
    local pat_var="$2"
    
    echo "Testing $bot_type authentication..."
    
    # Clear existing auth
    gh auth logout 2>/dev/null || true
    
    # Set up bot authentication
    export GH_TOKEN="${!pat_var}"
    
    # Test GitHub CLI access
    if gh auth status 2>&1 | grep -q "Logged in"; then
        user=$(gh api user --jq .login 2>/dev/null || echo "FAILED")
        echo "✅ $bot_type authenticated as: $user"
        
        # Verify it's the right bot account
        expected="kinda-lang-$bot_type"
        if [ "$user" = "$expected" ]; then
            echo "✅ Correct bot identity verified"
        else
            echo "❌ WRONG IDENTITY: Expected $expected, got $user"
            return 1
        fi
    else
        echo "❌ $bot_type authentication FAILED"
        return 1
    fi
    
    # Test repository access
    if gh repo view kinda-lang-dev/kinda-lang >/dev/null 2>&1; then
        echo "✅ Fork repository access confirmed"
    else
        echo "❌ Fork repository access FAILED"
        return 1
    fi
    
    echo ""
    return 0
}

# Test both bots
echo "Testing Coder Bot..."
if test_bot_auth "coder" "KINDA_CODER_PAT"; then
    echo "🎉 Coder Bot authentication: PASS"
else
    echo "💥 Coder Bot authentication: FAIL"
fi

echo ""
echo "Testing Reviewer Bot..."
if test_bot_auth "reviewer" "KINDA_REVIEWER_PAT"; then
    echo "🎉 Reviewer Bot authentication: PASS"
else
    echo "💥 Reviewer Bot authentication: FAIL"
fi

# Clean up
unset GH_TOKEN
gh auth logout 2>/dev/null || true

echo ""
echo "============================="
echo "Bot authentication test complete"