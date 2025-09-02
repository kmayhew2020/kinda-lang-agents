# 🤖 Kinda-Lang Bot Development Setup Guide

## Overview
This directory contains all bot infrastructure for kinda-lang development, keeping it separate from the main project repository.

## 📁 File Structure
```
kinda-lang-agents/
├── infrastructure/
│   ├── .env.local              # Bot PATs and environment (git-ignored)
│   ├── scripts/
│   │   ├── bot-setup.sh        # Load bot environment
│   │   ├── bot-auth.sh         # Configure git for specific bot
│   │   ├── fork-setup.sh       # Set up fork remotes
│   │   ├── sync-upstream.sh    # Sync fork with upstream
│   │   └── ci-local.sh         # Run full CI locally
│   └── BOT_SETUP_GUIDE.md      # This file
└── agents/                     # Agent prompt definitions
```

## 🚀 Quick Start

### 1. Configure Bot PATs
```bash
# Edit and add your actual bot PATs
nano infrastructure/.env.local

# Change from:
export KINDA_CODER_PAT="your_coder_bot_pat_here"
export KINDA_REVIEWER_PAT="your_reviewer_bot_pat_here"

# To your actual PATs:
export KINDA_CODER_PAT="ghp_xxxxxxxxxxxx"
export KINDA_REVIEWER_PAT="ghp_xxxxxxxxxxxx"
```

### 2. Set up development environment
```bash
cd /home/kevin/kinda-lang-agents
source infrastructure/scripts/bot-setup.sh
```

### 3. Configure fork (one-time setup)
```bash
infrastructure/scripts/fork-setup.sh
```

## 🔄 Daily Development Workflow

### Start Development Session
```bash
cd /home/kevin/kinda-lang-agents
source infrastructure/scripts/bot-setup.sh    # Load bot environment
cd /home/kevin/kinda-lang                     # Switch to main repo
```

### Coder Bot Workflow
```bash
# 1. Configure git as coder bot
/home/kevin/kinda-lang-agents/infrastructure/scripts/bot-auth.sh coder

# 2. Sync with upstream
/home/kevin/kinda-lang-agents/infrastructure/scripts/sync-upstream.sh

# 3. Create feature branch
git checkout -b feature/issue-122-record-replay

# 4. Make changes, then validate
/home/kevin/kinda-lang-agents/infrastructure/scripts/ci-local.sh

# 5. Push to fork and create PR
git push origin feature/issue-122-record-replay
```

### Reviewer Bot Workflow
```bash
# Configure git as reviewer bot
/home/kevin/kinda-lang-agents/infrastructure/scripts/bot-auth.sh reviewer

# Review and approve PRs on GitHub web interface
```

## 🔐 Security Features

- ✅ **Isolated PATs**: Bot credentials stored only in agents repo
- ✅ **Git-ignored**: `.env.local` never committed to any repo
- ✅ **Separate attribution**: Each bot has distinct git identity
- ✅ **Repository separation**: Main repo stays clean of bot infrastructure

## 🎯 Automation Targets

### Current (Manual)
- Bot authentication switching
- Feature branch development
- Local CI validation
- PR creation and review

### Future (Autonomous)
- Epic-based development cycles  
- Automated PR workflow
- Cross-agent coordination
- Continuous upstream sync

## ⚠️ Important Notes

1. **Never commit** `.env.local` or any file containing PATs
2. **Always run** `bot-setup.sh` before starting development
3. **Repository paths** are configured in `.env.local`
4. **Git identity** changes based on which bot is active

---

*Bot infrastructure separated from main kinda-lang repository*