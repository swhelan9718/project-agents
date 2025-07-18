# Project Agents - Agentic Development Environment

This directory contains the setup for multi-agent development on the GlobalViz project using Git worktrees and Claude Code.

## Quick Start

1. **Automated Setup** - Create a new agent workspace:
   ```bash
   ./setup-agent.sh agent1 feature new-dashboard-widget
   ./setup-agent.sh agent2 fix login-error --issue 456
   ./setup-agent.sh agent3 test improve-coverage
   ```

2. **Start Working** - Launch Claude Code in the agent workspace:
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
├── setup-agent.sh          # Automation script
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
cd globalviz && git worktree list
```

### Remove an Agent
```bash
cd globalviz && git worktree remove ../agent1
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
   cd ../globalviz
   git worktree remove ../agent-issue-123
   ```

## Tips

- Use `--template` flag with setup script to use predefined templates
- Run multiple agents in different terminal windows/tabs
- Check agent progress with `git status` in each worktree
- Use integration worktree to test combined changes