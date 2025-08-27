# Archived Agents

This directory contains kinda-lang Claude Code agents that were designed for more complex workflows but aren't needed for the streamlined You → Reviewer workflow.

## Archived Agents:

### 💻 Coder Agent (`coder.md`)
- **Original Purpose**: Full implementation and feature development
- **Why Archived**: You can handle implementation directly with Claude Code, providing better control and understanding
- **Still Useful For**: Reference for comprehensive implementation patterns and git workflows

### 🏗️ Project Manager Agent (`project_manager.md`)
- **Original Purpose**: Strategic planning, task assignment, and architectural decisions
- **Why Archived**: Direct workflow between you and code reviewer is more efficient for solo development
- **Still Useful For**: Reference for comprehensive project planning patterns and roadmap management

### 🏃‍♂️ Scrum Master Agent (`scrum_master.md`) 
- **Original Purpose**: Workflow coordination and agent orchestration
- **Why Archived**: Adds coordination overhead without coding value; simplified workflow handles coordination naturally
- **Still Useful For**: Reference for complex multi-agent coordination patterns

## When You Might Want These:

- **Large Teams**: If you have multiple developers working with these agents
- **Complex Coordination**: If you need sophisticated workflow orchestration
- **Training**: If you want to understand comprehensive Claude Code agent design patterns

## Current Workflow:
The active workflow uses just one agent:
1. **Code Reviewer** - Quality gates and PR management
2. **You + Claude Code** - Direct implementation with full context and planning

This provides the same quality and automation with much simpler coordination.