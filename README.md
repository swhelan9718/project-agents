# Project Agents - Agentic Development Environment

This directory contains the setup for multi-agent development on the GlobalViz project using Git worktrees and Claude Code.

## Quick Start

1. **Automated Setup** - Create a new agent workspace with tmux session:
   ```bash
   ./setup-agent.sh agent1 feature new-dashboard-widget
   ./setup-agent.sh agent2 fix login-error --issue 456
   ./setup-agent.sh agent3 test improve-coverage
   ```
   
   This automatically:
   - Creates a Git worktree for the agent
   - Sets up Python dependencies with Poetry
   - Installs Node packages and builds webpack
   - **Creates a tmux session with `npm run dev` running**

2. **Attach to Tmux Session** - Access your development environment:
   ```bash
   # Attach to the automatically created tmux session
   tmux attach -t agent1
   
   # The session has:
   # - Top pane (25%): npm run dev (already running)
   # - Bottom pane (75%): Ready for your work
   ```

3. **Start Working** - Launch Claude Code in the agent workspace:
   ```bash
   cd agent1
   ./start-agent.sh
   ```

## Documentation

- **[AGENTIC_SETUP.md](AGENTIC_SETUP.md)** - Complete guide to setting up agentic development
- **[WORKTREE_GUIDE.md](WORKTREE_GUIDE.md)** - Detailed Git worktree commands and workflows
- **[agent-templates/](agent-templates/)** - Context templates for different agent types

## Directory Structure

```
project-agents/
├── globalviz/              # Main repository
├── agent1/                 # Agent worktrees
├── agent2/
├── agent-templates/        # Context templates
│   ├── bug-fix-template.md
│   ├── feature-development-template.md
│   ├── testing-improvement-template.md
│   └── debugging-investigation-template.md
├── setup-agent.sh          # Create agent workspace
├── teardown-agent.sh       # Remove agent workspace
└── [Documentation files]
```

## Common Tasks

### Create a Bug Fix Agent
```bash
./setup-agent.sh agent-fix-auth fix authentication-error --issue 123
```

### Create a Testing Agent
```bash
./setup-agent.sh agent-test-e2e test playwright-coverage
```

### Create a Feature Agent
```bash
./setup-agent.sh agent-feat-api feature api-v2-endpoints
```

### List All Agents
```bash
./teardown-agent.sh --list
# Or manually:
cd globalviz && git worktree list
```

### Remove an Agent
```bash
# Automated teardown (removes worktree + kills tmux session)
./teardown-agent.sh agent1

# Force remove (even with uncommitted changes)
./teardown-agent.sh agent1 --force

# Preview what would be removed
./teardown-agent.sh agent1 --dry-run
```

## Best Practices

1. **One Task Per Agent** - Keep agents focused on single objectives
2. **Clear Context Files** - Always update `.agent-context.md` with specific instructions
3. **Regular Commits** - Agents should commit frequently with clear messages
4. **Test Before Merge** - Always verify agent work before merging
5. **Clean Up** - Remove worktrees after merging branches

## Workflow Example

1. Create agent for issue #123:
   ```bash
   ./setup-agent.sh agent-issue-123 fix user-profile-bug --issue 123
   ```

2. Edit the context file to add specific details:
   ```bash
   cd agent-issue-123
   vi .agent-context.md
   ```

3. Start Claude Code:
   ```bash
   ./start-agent.sh
   ```

4. After agent completes work, review and push:
   ```bash
   git log --oneline
   git push -u origin HEAD
   ```

5. Create pull request and clean up:
   ```bash
   gh pr create
   cd ..
   ./teardown-agent.sh agent-issue-123
   ```

## Tmux Session Features

The setup script automatically creates tmux sessions for each agent:

- **Auto-named sessions** - Session name matches the agent folder (e.g., `agent1`, `fix_stats_job`)
- **Pre-configured layout** - Split window with npm (25% top) and workspace (75% bottom)
- **npm auto-start** - `npm run dev` starts automatically in the top pane
- **Detached sessions** - Runs in background, attach when ready
- **Persistent** - Survives terminal disconnections

### Tmux Quick Commands

```bash
# List all sessions
tmux ls

# Attach to agent session
tmux attach -t agent1

# Detach from session
# Press: Ctrl+B, then D

# Switch panes
# Press: Ctrl+B, then arrow keys

# Kill session
tmux kill-session -t agent1
```

## Teardown Script

The `teardown-agent.sh` script automates cleanup of agent workspaces:

### Features
- **Removes git worktree** - Cleans up the worktree from the repository
- **Kills tmux session** - Terminates the associated tmux session
- **Safety checks** - Warns about uncommitted changes before removal
- **Dry run mode** - Preview actions without executing

### Commands
```bash
# List all agents and their status
./teardown-agent.sh --list

# Remove an agent (worktree must be clean)
./teardown-agent.sh agent1

# Force remove (even with uncommitted changes)
./teardown-agent.sh agent1 --force

# Preview what would be removed
./teardown-agent.sh agent1 --dry-run

# Show help
./teardown-agent.sh --help
```

### What Gets Removed
1. **Git worktree** - The agent directory and its git tracking
2. **Tmux session** - The associated tmux session (uses underscore naming)
3. **All local changes** - When using `--force`, uncommitted work is lost

### Safety Features
- Detects uncommitted changes and requires `--force` to proceed
- Shows detailed status before any action
- Prevents accidental removal of the main `globalviz` directory
- Dry run mode lets you preview before executing

## Tips

- Use `--template` flag with setup script to use predefined templates
- Run multiple agents in different terminal windows/tabs
- Check agent progress with `git status` in each worktree
- Use integration worktree to test combined changes
- Tmux sessions persist even if you close your terminal
- Each agent gets its own isolated tmux session with webpack running