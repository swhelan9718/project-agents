#!/bin/bash

# Agentic Code Setup Script for GlobalViz
# This script automates the creation of agent worktrees with proper context
#
#
# ./setup-agent.sh fix-stats-job-handle-ints fix sw/fix-stats-job-handle-ints --existing
#
#
# # Fix the stats job issue
# ./setup-agent.sh agent-stats-fix fix stats-job-handle-ints --issue 123

# # New feature work  
# ./setup-agent.sh agent-auth feature user-authentication

# # Debug performance
# ./setup-agent.sh agent-perf debug slow-queries

# # Test new feature
# ./setup-agent.sh agent-test test new-feature-test

# # Fix bug
# ./setup-agent.sh agent-fix fix login-bug --issue 123


set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
MAIN_REPO_DIR="globalviz"
TEMPLATES_DIR="agent-templates"

# Function to display usage
usage() {
    echo "Usage: $0 <agent-name> <type> <description> [options]"
    echo ""
    echo "Arguments:"
    echo "  agent-name    Name for the agent workspace (e.g., agent1, agent-auth)"
    echo "  type          Type of work: feature|fix|test|debug"
    echo "  description   Brief description (will be used in branch name)"
    echo ""
    echo "Options:"
    echo "  -i, --issue NUMBER     Link to GitHub issue number"
    echo "  -t, --template FILE    Use specific template file"
    echo "  -b, --base-branch NAME Use specific base branch (default: main)"
    echo "  -e, --existing         Use existing branch from origin (don't create new)"
    echo ""
    echo "Examples:"
    echo "  $0 agent1 feature authentication"
    echo "  $0 agent2 fix login-bug --issue 123"
    echo "  $0 agent3 test playwright-coverage"
    echo "  $0 agent4 debug performance-issue"
    echo "  $0 fix-stats-job-handle-ints fix sw/fix-stats-job-handle-ints --existing"
    exit 1
}

# Function to create agent context
create_context() {
    local workspace=$1
    local agent_name=$2
    local branch_type=$3
    local description=$4
    local issue_number=$5
    local template=$6

    local context_file="$workspace/.agent-context.md"
    
    if [ -n "$template" ] && [ -f "$TEMPLATES_DIR/$template" ]; then
        # Use specified template
        cp "$TEMPLATES_DIR/$template" "$context_file"
        
        # Replace placeholders
        sed -i.bak "s/\[ISSUE_NUMBER\]/$issue_number/g" "$context_file" 2>/dev/null || true
        sed -i.bak "s/\[ISSUE_TITLE\]/$description/g" "$context_file" 2>/dev/null || true
        sed -i.bak "s/\[FEATURE_NAME\]/$description/g" "$context_file" 2>/dev/null || true
        rm -f "${context_file}.bak"
    else
        # Create basic context
        cat > "$context_file" << EOF
# Agent Context: $agent_name

## Branch: $branch_type/$description
## Created: $(date)
## Type: $branch_type

EOF

        # Add type-specific content
        case $branch_type in
            feature)
                cat >> "$context_file" << 'EOF'
## Feature Development Task

### Description
Implement $description functionality

### Acceptance Criteria
- [ ] Feature implemented according to requirements
- [ ] Unit tests written and passing
- [ ] Integration tests added
- [ ] Documentation updated
- [ ] No regression in existing functionality

### Implementation Areas
- [ ] Backend logic
- [ ] Frontend UI
- [ ] API endpoints
- [ ] Database changes

### Testing Requirements
```bash
# Run tests
pytest tests/
pytest tests/playwright/ --headed
```
EOF
                ;;
            fix)
                if [ -n "$issue_number" ]; then
                    cat >> "$context_file" << EOF
## Bug Fix Task

### Issue: #$issue_number
### Link: https://github.com/[org]/globalviz/issues/$issue_number

### Bug Description
[Add issue description here]

### Reproduction Steps
1. [Add steps]

### Root Cause
[To be determined]

### Fix Approach
[To be determined]

### Testing
- [ ] Create test that reproduces the bug
- [ ] Implement fix
- [ ] Verify test passes
- [ ] Run regression tests
EOF
                else
                    cat >> "$context_file" << EOF
## Bug Fix Task

### Description
Fix $description

### Testing Requirements
- [ ] Identify and fix the issue
- [ ] Add tests to prevent regression
- [ ] Verify no side effects
EOF
                fi
                ;;
            test)
                cat >> "$context_file" << 'EOF'
## Testing Improvement Task

### Objective
Improve test coverage for $description

### Goals
- [ ] Increase test coverage
- [ ] Add missing test cases
- [ ] Fix any failing tests
- [ ] Improve test performance

### Test Types
- [ ] Unit tests
- [ ] Integration tests
- [ ] End-to-end tests

### Commands
```bash
# Run with coverage
pytest --cov --cov-report=html

# Run specific tests
pytest tests/ -k "$description"
```
EOF
                ;;
            debug)
                cat >> "$context_file" << 'EOF'
## Debugging Investigation Task

### Problem
Investigate $description

### Investigation Steps
- [ ] Reproduce the issue
- [ ] Identify root cause
- [ ] Document findings
- [ ] Propose solution
- [ ] Estimate effort

### Tools
```bash
# Check logs
tail -f logs/*.log

# Profile performance
python -m cProfile manage.py runserver

# Database queries
python manage.py debugsqlshell
```

### Findings
[Document findings here]
EOF
                ;;
        esac

        cat >> "$context_file" << 'EOF'

## Notes
[Add any additional notes or constraints here]

## Success Criteria
- [ ] Task completed as described
- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Documentation updated
EOF
    fi
}

# Parse arguments
if [ $# -lt 3 ]; then
    usage
fi

AGENT_NAME=$1
BRANCH_TYPE=$2
DESCRIPTION=$3
shift 3

# Default values
ISSUE_NUMBER=""
TEMPLATE=""
BASE_BRANCH="development"
USE_EXISTING=false

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--issue)
            ISSUE_NUMBER="$2"
            shift 2
            ;;
        -t|--template)
            TEMPLATE="$2"
            shift 2
            ;;
        -b|--base-branch)
            BASE_BRANCH="$2"
            shift 2
            ;;
        -e|--existing)
            USE_EXISTING=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Validate branch type
case $BRANCH_TYPE in
    feature|fix|test|debug)
        ;;
    *)
        echo -e "${RED}Invalid type: $BRANCH_TYPE${NC}"
        echo "Valid types are: feature, fix, test, debug"
        exit 1
        ;;
esac

# Check if we're in the project-agents directory
if [ ! -d "$MAIN_REPO_DIR" ]; then
    echo -e "${RED}Error: Must run from project-agents directory${NC}"
    echo "Current directory: $(pwd)"
    echo "Looking for: $MAIN_REPO_DIR/"
    exit 1
fi

# Create or use branch name
if [ "$USE_EXISTING" = true ]; then
    # When using existing branch, DESCRIPTION is the full branch name
    BRANCH_NAME="$DESCRIPTION"
else
    # Create new branch name
    if [ -n "$ISSUE_NUMBER" ]; then
        BRANCH_NAME="$BRANCH_TYPE/issue-$ISSUE_NUMBER-$DESCRIPTION"
    else
        BRANCH_NAME="$BRANCH_TYPE/$DESCRIPTION"
    fi
fi

WORKSPACE_PATH="../$AGENT_NAME"

# Check if workspace already exists
if [ -d "$WORKSPACE_PATH" ]; then
    echo -e "${YELLOW}Warning: Workspace $WORKSPACE_PATH already exists${NC}"
    read -p "Remove and recreate? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$MAIN_REPO_DIR"
        # Use absolute path for worktree removal
        git worktree remove "$(realpath "$WORKSPACE_PATH")" --force || true
        cd ..
    else
        exit 1
    fi
fi

# Create worktree
echo -e "${GREEN}Creating worktree...${NC}"
cd "$MAIN_REPO_DIR"

# Fetch latest changes
git fetch origin

if [ "$USE_EXISTING" = true ]; then
    # Check if branch exists on origin
    if git ls-remote --heads origin "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
        echo -e "${GREEN}Using existing branch: origin/$BRANCH_NAME${NC}"
        
        # Check if local branch already exists
        if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
            echo -e "${YELLOW}Local branch '$BRANCH_NAME' already exists, using it${NC}"
            git worktree add "$WORKSPACE_PATH" "$BRANCH_NAME"
        else
            # Create a local branch that tracks the remote branch
            git worktree add "$WORKSPACE_PATH" -b "$BRANCH_NAME" --track "origin/$BRANCH_NAME"
        fi
    else
        echo -e "${RED}Error: Branch 'origin/$BRANCH_NAME' does not exist${NC}"
        exit 1
    fi
else
    # Create new branch from base branch
    echo -e "${GREEN}Creating new branch: $BRANCH_NAME from origin/$BASE_BRANCH${NC}"
    
    # Check if local branch already exists
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
        echo -e "${YELLOW}Local branch '$BRANCH_NAME' already exists${NC}"
        # Delete the local branch first
        git branch -D "$BRANCH_NAME"
        echo -e "${GREEN}Deleted existing local branch and creating new one${NC}"
    fi
    
    git worktree add "$WORKSPACE_PATH" -b "$BRANCH_NAME" "origin/$BASE_BRANCH"
fi

cd ..

# Create context file
echo -e "${GREEN}Creating context file...${NC}"
create_context "$AGENT_NAME" "$AGENT_NAME" "$BRANCH_TYPE" "$DESCRIPTION" "$ISSUE_NUMBER" "$TEMPLATE"

# Setup development environment
echo -e "${GREEN}Setting up development environment...${NC}"
cd "$AGENT_NAME"

# Install Python dependencies with poetry
if command -v poetry &> /dev/null; then
    echo -e "${GREEN}Installing Python dependencies with poetry...${NC}"
    if poetry install --no-interaction; then
        echo -e "${GREEN}Poetry dependencies installed successfully${NC}"
        
        # Install development dependencies if pyproject.toml has them
        if grep -q "\[tool.poetry.group.dev\]" pyproject.toml 2>/dev/null || grep -q "\[tool.poetry.dev-dependencies\]" pyproject.toml 2>/dev/null; then
            echo -e "${GREEN}Installing development dependencies...${NC}"
            poetry install --with dev --no-interaction || poetry install --dev --no-interaction
        fi
    else
        echo -e "${YELLOW}Warning: Poetry installation failed. You may need to run 'poetry install' manually.${NC}"
        echo -e "${YELLOW}Common fixes: poetry env use python3, poetry install --no-dev${NC}"
    fi
else
    echo -e "${YELLOW}Warning: poetry not found. Skipping Python dependency installation.${NC}"
    echo -e "${YELLOW}To install poetry, run: curl -sSL https://install.python-poetry.org | python3 -${NC}"
fi

# Install Node dependencies and build webpack
if [ -f "package.json" ]; then
    if command -v npm &> /dev/null; then
        echo -e "${GREEN}Installing Node dependencies...${NC}"
        npm install
        
        echo -e "${GREEN}Building webpack assets...${NC}"
        npm run build
        
        echo -e "${YELLOW}Note: You'll need to run 'npm run dev' in a separate terminal for hot-reloading during development${NC}"
    else
        echo -e "${YELLOW}Warning: npm not found. Skipping Node dependency installation.${NC}"
    fi
fi

cd ..

# Create a quick start script
cat > "$AGENT_NAME/start-agent.sh" << 'EOF'
#!/bin/bash
echo "Starting agent in $(pwd)"
echo "Branch: $(git branch --show-current)"
echo ""
echo "Context file: .agent-context.md"
echo ""

# Check if poetry is installed and activate environment
if command -v poetry &> /dev/null; then
    echo -e "\033[0;32mActivating poetry environment...\033[0m"
    eval "$(poetry env info --path)/bin/activate" 2>/dev/null || poetry shell
fi

# Check if npm run dev is needed
if [ -f "package.json" ] && ! [ -f "webpack-stats.json" ]; then
    echo -e "\033[1;33mWarning: webpack-stats.json not found!\033[0m"
    echo "You need to run 'npm run dev' in a separate terminal to generate webpack assets."
    echo ""
    echo "In another terminal, run:"
    echo "  cd $(pwd)"
    echo "  npm run dev"
    echo ""
    echo "Or use tmux/screen to keep it running in the background."
    echo ""
fi

echo "Useful commands:"
echo "  poetry shell            - Activate Python virtual environment"
echo "  poetry run python manage.py runserver - Start Django dev server"
echo "  npm run dev             - Start webpack dev server (run in separate terminal)"
echo "  npm run build           - Build webpack assets for production"
echo ""
echo "  git status              - Check current status"
echo "  git add -A              - Stage all changes"
echo "  git commit -m 'msg'     - Commit changes"
echo "  git push -u origin HEAD - Push to remote"
echo ""
echo "  poetry run pytest tests/ - Run Python tests"
echo "  npm test                - Run JavaScript tests"
echo ""
echo "Starting Claude Code..."
claude-code
EOF
chmod +x "$AGENT_NAME/start-agent.sh"

# Create tmux session if tmux is available
if command -v tmux &> /dev/null; then
    # Create tmux session name from agent name (replace hyphens with underscores for tmux compatibility)
    TMUX_SESSION_NAME=$(echo "$AGENT_NAME" | tr '-' '_')
    
    # Check if session already exists
    if tmux has-session -t "$TMUX_SESSION_NAME" 2>/dev/null; then
        echo -e "${YELLOW}Tmux session '$TMUX_SESSION_NAME' already exists. Killing it...${NC}"
        tmux kill-session -t "$TMUX_SESSION_NAME"
    fi
    
    echo -e "${GREEN}Creating tmux session '$TMUX_SESSION_NAME'...${NC}"
    
    # Create new tmux session in the worktree directory without attaching
    tmux new-session -d -s "$TMUX_SESSION_NAME" -c "$WORKSPACE_PATH"
    
    # Split window horizontally (25% top for npm, 75% bottom for work)
    tmux split-window -t "$TMUX_SESSION_NAME:0" -v -p 25
    
    # Start npm run dev in top pane (pane 0)
    if [ -f "$WORKSPACE_PATH/package.json" ]; then
        tmux send-keys -t "$TMUX_SESSION_NAME:0.0" "npm run dev" Enter
    fi
    
    # Select bottom pane (pane 1) for main work
    tmux select-pane -t "$TMUX_SESSION_NAME:0.1"
    
    # Make the bottom pane active
    tmux select-window -t "$TMUX_SESSION_NAME:0"
    
    echo -e "${GREEN}✓ Tmux session '$TMUX_SESSION_NAME' created and ready${NC}"
    echo ""
fi

# Summary
echo ""
echo -e "${GREEN}✓ Agent workspace created successfully!${NC}"
echo ""
echo "Workspace: $WORKSPACE_PATH"
echo "Branch: $BRANCH_NAME"
echo "Context: $WORKSPACE_PATH/.agent-context.md"
echo ""
if command -v tmux &> /dev/null && tmux has-session -t "$TMUX_SESSION_NAME" 2>/dev/null; then
    echo -e "${GREEN}Tmux session ready:${NC}"
    echo "  tmux attach -t $TMUX_SESSION_NAME"
    echo ""
    echo "The session has:"
    echo "  - Top pane (25%): npm run dev (running)"
    echo "  - Bottom pane (75%): Ready for your work"
    echo ""
fi
echo "To start working:"
echo "  cd $AGENT_NAME"
echo "  ./start-agent.sh"
echo ""
echo "Or manually:"
echo "  cd $AGENT_NAME"
echo "  claude-code"
echo ""
if [ -f "$AGENT_NAME/package.json" ] && ! command -v tmux &> /dev/null; then
    echo -e "${YELLOW}Remember: Run 'npm run dev' in a separate terminal for webpack hot-reloading${NC}"
fi