#!/bin/bash
# Mandatory Reviewer Bot Startup Sequence
# This script MUST run before any reviewer bot operations

set -e

echo "🔍 Initializing Reviewer Bot Environment..."

# 1. Navigate to project directory
cd ~/kinda-lang || {
    echo "❌ ERROR: Cannot access ~/kinda-lang"
    exit 1
}

# 2. Load environment variables
if [ -f ~/kinda-lang-agents/infrastructure/.env.local ]; then
    source ~/kinda-lang-agents/infrastructure/.env.local
    echo "✅ Loaded .env.local"
else
    echo "❌ ERROR: .env.local not found"
    exit 1
fi

# 3. Set GitHub authentication
if [ -n "$KINDA_REVIEWER_PAT" ]; then
    export GH_TOKEN="$KINDA_REVIEWER_PAT"
    export GH_REPO="kinda-lang-dev/kinda-lang"
    echo "✅ GitHub token configured"
else
    echo "❌ ERROR: KINDA_REVIEWER_PAT not set in .env.local"
    exit 1
fi

# 4. Configure git identity
git config user.name "kinda-lang-reviewer"
git config user.email "kinda-lang-reviewer@users.noreply.github.com"
echo "✅ Git identity configured"

# 5. Verify authentication
if gh auth status >/dev/null 2>&1; then
    GITHUB_USER=$(gh api user --jq .login 2>/dev/null || echo "unknown")
    echo "✅ GitHub authenticated as: $GITHUB_USER"
else
    echo "❌ ERROR: GitHub authentication failed"
    exit 1
fi

# 6. Load persistent state
STATE_FILE="~/kinda-lang-agents/infrastructure/state/reviewer-bot-state.json"
if [ -f "$STATE_FILE" ]; then
    echo "✅ Persistent state available"
    # Could add state summary here if needed
else
    echo "⚠️  No persistent state found (first run?)"
fi

echo "🎯 Reviewer Bot Environment Ready!"
echo "   Working Directory: $(pwd)"
echo "   GitHub User: $(gh api user --jq .login 2>/dev/null || echo 'Not authenticated')"
echo "   Git Branch: $(git branch --show-current)"
echo "   Python: $(python --version)"
echo ""

# Execute any additional commands passed to this script
if [ $# -gt 0 ]; then
    echo "📋 Executing: $*"
    exec "$@"
fi