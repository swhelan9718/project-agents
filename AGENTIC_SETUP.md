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

## Tmux Session Management (NEW)

The `setup-agent.sh` script now automatically creates a tmux session for each agent workspace with the following configuration:

### Automatic Tmux Setup

When you run the setup script, it will:

1. **Create a named tmux session** - Using the agent name (hyphens converted to underscores)
2. **Split the window** - 25% top pane for `npm run dev`, 75% bottom pane for work
3. **Start npm automatically** - The top pane runs `npm run dev` immediately
4. **Focus the work pane** - Bottom pane is selected and ready for development
5. **Detached by default** - Session runs in background, attach when ready

### Tmux Session Names

The session name matches your agent folder name with adjustments for tmux compatibility:

- `integration_tests_port` → tmux session: `integration_tests_port`
- `fix-stats-job` → tmux session: `fix_stats_job`
- `agent-auth-feature` → tmux session: `agent_auth_feature`

### Working with Tmux Sessions

```bash
# Attach to your agent's tmux session
tmux attach -t integration_tests_port

# List all tmux sessions
tmux ls

# Detach from current session
# Press: Ctrl+B, then D

# Switch between panes in tmux
# Press: Ctrl+B, then arrow keys

# Kill a tmux session (if needed)
tmux kill-session -t integration_tests_port
```

### Tmux Layout

Each session has:
- **Top pane (25%)**: Running `npm run dev` for webpack hot-reloading
- **Bottom pane (75%)**: Your main workspace for development

### Benefits of Tmux Integration

1. **No manual npm setup** - Webpack dev server starts automatically
2. **Persistent sessions** - Survives terminal disconnections
3. **Organized workspace** - Each agent has its own named session
4. **Easy switching** - Jump between agents with tmux commands
5. **Background operation** - Sessions run without keeping terminals open

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

## More details on creating the worktree

``setup-agent.sh` has been updated.

⏺ The script has been updated! Here's what I added:

1. Automatic poetry install - After creating the worktree, it runs poetry install to set up Python dependencies
2. Automatic npm install and build - It runs npm install and npm run build to set up Node dependencies and build initial webpack
   assets
3. Enhanced start-agent.sh - The generated script now checks for webpack-stats.json and warns if npm run dev needs to be running

Regarding your question about tmux and npm run dev:

Yes, you need to keep npm run dev running for each worktree during development. The webpack-stats.json file is generated by the
webpack dev server and is needed for Django to know which webpack bundles to load. Here are your options:

1. Tmux/Screen approach (recommended):
   tmux new-session -s fix-stats-webpack
   npm run dev

# Ctrl+B, D to detach

2. Background process:
   npm run dev &

# But this is harder to manage

3. Two terminal approach:


    - Terminal 1: npm run dev
    - Terminal 2: Your development work

The updated script now automatically runs poetry install, npm install, and npm run build when creating a new worktree, so you'll
have a working environment ready to go. You'll just need to start npm run dev separately for hot-reloading during development.
