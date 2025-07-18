# Agentic Code Setup for GlobalViz

This guide helps you set up a multi-agent development environment for the GlobalViz project using Git worktrees, allowing multiple Claude Code agents to work on different branches simultaneously.

## Overview

The agentic coding approach allows you to:
- Run multiple Claude Code agents in parallel on different features/fixes
- Isolate work on separate branches without conflicts
- Focus agents on specific tasks (testing, features, debugging)
- Maintain a clean separation between different development efforts

## Directory Structure

```
project-agents/
├── globalviz/              # Main repository clone
├── agent1/                 # Worktree for agent 1
├── agent2/                 # Worktree for agent 2
├── agent-issue-XXX/        # Issue-specific worktrees
├── agent-testing/          # Dedicated testing agent
└── agent-integration/      # Integration testing agent
```

## Quick Start

### 1. Initial Setup

Navigate to your project-agents directory:
```bash
cd /Users/swhelan/Documents/workspace/project-agents
```

### 2. Create Worktrees for Agents

From the main globalviz repository, create worktrees:

```bash
cd globalviz

# Create worktree for first agent working on a feature
git worktree add ../agent1 -b feature/agent1-task

# Create worktree for second agent working on tests
git worktree add ../agent2 -b test/improve-coverage

# Create worktree for specific issue
git worktree add ../agent-issue-123 -b fix/issue-123
```

### 3. Set Up Agent Context

For each agent workspace, create a context file that clearly defines the agent's task:

```bash
# Example: Setting up context for agent1
cat > ../agent1/.agent-context.md << 'EOF'
# Agent Context: Feature Development

## Task
Implement new dashboard visualization feature

## Scope
- Work only in the stats/ and templates/ directories
- Focus on adding new visualization components
- Ensure all existing tests pass

## Constraints
- Do not modify authentication or database models
- Follow existing code patterns in stats/views/
- Add comprehensive tests for new features

## Testing Requirements
- Run: pytest stats/tests/
- Ensure no regressions in existing functionality
EOF
```

### 4. Working with Agents

When starting a Claude Code session for each agent:

```bash
# Terminal 1 - Agent 1
cd /Users/swhelan/Documents/workspace/project-agents/agent1
claude-code

# Terminal 2 - Agent 2
cd /Users/swhelan/Documents/workspace/project-agents/agent2
claude-code
```

## Agent Types and Use Cases

### 1. Feature Development Agents
- Work on new features in isolation
- Branch naming: `feature/agent-description`
- Focus: Implementation and unit tests

### 2. Testing Agents
- Improve test coverage
- Fix failing tests
- Branch naming: `test/description`
- Focus: Playwright integration tests, unit tests

### 3. Bug Fix Agents
- Address specific GitHub issues
- Branch naming: `fix/issue-NUMBER`
- Focus: Reproduce, fix, and test

### 4. Debugging Agents
- Investigate complex issues
- Branch naming: `debug/description`
- Focus: Analysis and documentation

## Best Practices

### 1. Clear Context Files
Always create `.agent-context.md` files with:
- Specific task description
- Files/directories to focus on
- Testing requirements
- Constraints and boundaries

### 2. Branch Management
- Use descriptive branch names
- Keep branches focused on single concerns
- Regular commits with clear messages

### 3. Agent Coordination
- Review agent work before merging
- Check for conflicts between parallel work
- Use integration worktree to test combined changes

### 4. Testing Strategy
- Each agent should run relevant tests
- Dedicate agents specifically for test improvements
- Always verify no regressions before merging

## Common Commands

### List All Worktrees
```bash
cd globalviz
git worktree list
```

### Remove a Worktree
```bash
git worktree remove ../agent1
```

### Check Agent Status
```bash
cd agent1
git status
git log --oneline -10
```

### Integration Testing
```bash
# Create integration worktree
git worktree add ../integration integration-test

# Merge all agent branches for testing
cd ../integration
git merge origin/feature/agent1-task
git merge origin/test/improve-coverage
```

## Troubleshooting

### Worktree Already Exists
If you get an error about a worktree already existing:
```bash
git worktree remove ../agent1 --force
git worktree add ../agent1 -b new-branch
```

### Merge Conflicts
When agents work on overlapping code:
1. Use the integration worktree to identify conflicts early
2. Coordinate between agents or serialize their work
3. Have one agent resolve conflicts in their branch

### Resource Management
- Limit concurrent agents based on system resources
- Monitor memory/CPU usage per agent
- Consider using resource limits if needed

## Next Steps

1. See `WORKTREE_GUIDE.md` for detailed Git worktree commands
2. Use `setup-agent.sh` script for automated agent setup
3. Review example context templates in `agent-templates/`