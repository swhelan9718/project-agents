# Git Worktree Guide for Agentic Development

This guide provides detailed instructions for using Git worktrees to manage multiple agent workspaces for the GlobalViz project.

## What are Git Worktrees?

Git worktrees allow you to have multiple working directories attached to the same repository. This is perfect for:
- Working on multiple branches simultaneously
- Running different agents on different features
- Avoiding the overhead of multiple full clones
- Sharing the same Git history and remote configuration

## Basic Worktree Commands

### Creating a Worktree

```bash
# Navigate to main repository
cd /Users/swhelan/Documents/workspace/project-agents/globalviz

# Create a new worktree with a new branch
git worktree add ../agent1 -b feature/new-feature

# Create a worktree from an existing branch
git worktree add ../agent2 existing-branch-name

# Create a worktree with a specific commit
git worktree add ../agent3 -b hotfix/urgent-fix HEAD~3
```

### Listing Worktrees

```bash
# Show all worktrees
git worktree list

# Show detailed information
git worktree list --verbose
```

### Removing Worktrees

```bash
# Remove a worktree (must be clean)
git worktree remove ../agent1

# Force remove (discards local changes)
git worktree remove ../agent1 --force

# Remove worktree and delete branch
git worktree remove ../agent1 --force
git branch -D feature/new-feature
```

## Worktree Workflows for Agents

### 1. Issue-Based Development

```bash
# Create worktree for specific issue
ISSUE_NUM=123
ISSUE_TITLE="fix-authentication-bug"
git worktree add ../agent-issue-$ISSUE_NUM -b fix/issue-$ISSUE_NUM-$ISSUE_TITLE

# Create context file
cat > ../agent-issue-$ISSUE_NUM/.agent-context.md << EOF
# Issue #$ISSUE_NUM: $ISSUE_TITLE

## GitHub Issue
https://github.com/yourorg/globalviz/issues/$ISSUE_NUM

## Task
[Copy issue description here]

## Acceptance Criteria
- [ ] Bug is reproducible with test
- [ ] Fix implemented
- [ ] All tests pass
- [ ] No regressions
EOF
```

### 2. Parallel Feature Development

```bash
# Set up multiple feature agents
git worktree add ../agent-feature-auth -b feature/improve-auth
git worktree add ../agent-feature-viz -b feature/new-viz
git worktree add ../agent-feature-api -b feature/api-v2
```

### 3. Testing and Quality Agents

```bash
# Playwright test agent
git worktree add ../agent-playwright -b test/playwright-coverage

# Unit test improvement agent
git worktree add ../agent-unit-tests -b test/improve-unit-coverage

# Performance testing agent
git worktree add ../agent-performance -b test/performance-suite
```

## Advanced Worktree Management

### Switching Branches in Worktrees

```bash
# Navigate to worktree
cd ../agent1

# Switch to different branch (if no local changes)
git checkout other-branch

# Create and switch to new branch
git checkout -b feature/another-feature
```

### Syncing with Remote

```bash
# In any worktree
cd ../agent1

# Fetch latest changes
git fetch origin

# Pull changes for current branch
git pull

# Push changes
git push -u origin feature/new-feature
```

### Worktree Maintenance

```bash
# Prune worktree information for deleted directories
git worktree prune

# Lock a worktree to prevent removal
git worktree lock ../agent-production

# Unlock a worktree
git worktree unlock ../agent-production
```

## Integration Strategies

### 1. Continuous Integration Worktree

```bash
# Create integration worktree
git worktree add ../integration -b integration/combined

# Script to merge all agent branches
cd ../integration
cat > merge-agents.sh << 'EOF'
#!/bin/bash
git checkout main
git pull origin main
git checkout -b integration/$(date +%Y%m%d-%H%M%S)

# Merge each agent branch
for branch in $(git branch -r | grep 'origin/feature/agent-'); do
    echo "Merging $branch..."
    git merge $branch --no-edit || {
        echo "Conflict in $branch - manual resolution needed"
        exit 1
    }
done

echo "All agent branches merged successfully"
EOF

chmod +x merge-agents.sh
```

### 2. Conflict Detection

```bash
# Check for potential conflicts between agent branches
cd ../integration
git checkout main
git pull

# Test merge without committing
git merge --no-commit --no-ff origin/feature/agent1
git merge --no-commit --no-ff origin/feature/agent2

# If conflicts, abort and investigate
git merge --abort
```

## Best Practices

### 1. Naming Conventions

```bash
# Feature agents
../agent-feat-<feature-name>

# Bug fix agents  
../agent-fix-<issue-number>

# Test agents
../agent-test-<test-type>

# Temporary agents
../agent-temp-<purpose>
```

### 2. Worktree Organization

```
project-agents/
├── globalviz/                    # Main repository
├── agents/
│   ├── active/                   # Currently active agents
│   │   ├── agent-feat-auth/
│   │   └── agent-fix-123/
│   └── archived/                 # Completed agent work
│       └── agent-feat-old/
└── integration/                  # Integration testing
```

### 3. Resource Management

```bash
# Monitor disk usage
du -sh ../agent-*

# Clean up old worktrees
for dir in ../agent-temp-*; do
    if [ -d "$dir" ]; then
        git worktree remove "$dir" --force
    fi
done
```

## Troubleshooting

### "Fatal: not a git repository"
```bash
# Ensure you're in the main repository
cd /Users/swhelan/Documents/workspace/project-agents/globalviz
git worktree list
```

### "Fatal: branch already exists"
```bash
# Use existing branch
git worktree add ../agent-new existing-branch

# Or create with different name
git worktree add ../agent-new -b feature/new-branch-name
```

### "Contains modified or untracked files"
```bash
# Check status in worktree
cd ../agent1
git status

# Stash or commit changes
git stash
# or
git commit -am "WIP: Save work before removing worktree"

# Then remove
cd ../globalviz
git worktree remove ../agent1
```

### Corrupted Worktree
```bash
# Force prune and recreate
git worktree prune
rm -rf ../agent-broken
git worktree add ../agent-fixed -b feature/fixed
```

## Automation Scripts

### Quick Agent Setup
```bash
# Save as setup-agent.sh
#!/bin/bash
AGENT_NAME=$1
BRANCH_TYPE=$2
DESCRIPTION=$3

if [ -z "$AGENT_NAME" ] || [ -z "$BRANCH_TYPE" ] || [ -z "$DESCRIPTION" ]; then
    echo "Usage: ./setup-agent.sh <agent-name> <branch-type> <description>"
    echo "Example: ./setup-agent.sh agent1 feature authentication"
    exit 1
fi

BRANCH_NAME="$BRANCH_TYPE/$DESCRIPTION"
WORKTREE_PATH="../$AGENT_NAME"

# Create worktree
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"

# Create context file
cat > "$WORKTREE_PATH/.agent-context.md" << EOF
# Agent: $AGENT_NAME
## Branch: $BRANCH_NAME
## Created: $(date)

## Task Description
[Add task description here]

## Success Criteria
- [ ] Implementation complete
- [ ] Tests written and passing
- [ ] No regressions
- [ ] Code reviewed

## Notes
[Add any additional notes]
EOF

echo "Agent workspace created at: $WORKTREE_PATH"
echo "Context file created at: $WORKTREE_PATH/.agent-context.md"
```

Make the script executable:
```bash
chmod +x setup-agent.sh
```