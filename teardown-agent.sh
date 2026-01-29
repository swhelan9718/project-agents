#!/bin/bash
#
# teardown-agent.sh - Remove agent worktrees and tmux sessions
#
# USAGE:
#   ./teardown-agent.sh <agent-name> [--force]
#   ./teardown-agent.sh --list
#   ./teardown-agent.sh --help
#
# EXAMPLES:
#   ./teardown-agent.sh merging_cdt_service --force   # Force remove worktree + kill tmux
#   ./teardown-agent.sh ag_grid_optimize              # Remove clean worktree + kill tmux
#   ./teardown-agent.sh --list                        # List all agents (worktrees + tmux sessions)
#   ./teardown-agent.sh --dry-run merging_cdt_service # Preview what would be removed
#
# VERIFICATION:
#   git worktree list                                 # Verify worktree removed
#   tmux ls                                           # Verify tmux session killed
#   ls -la ../                                        # Verify directory removed
#
# OPTIONS:
#   <agent-name>    Name of the agent to teardown
#   --force, -f     Force remove even with modified/untracked files
#   --list, -l      List available agents to teardown
#   --dry-run       Show what would be done without executing
#   --help, -h      Show this help message
#

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GLOBALVIZ_DIR="$SCRIPT_DIR/globalviz"

# Function to display usage
usage() {
    echo "Usage: $0 <agent-name> [options]"
    echo ""
    echo "Remove agent worktrees and their associated tmux sessions."
    echo ""
    echo "Arguments:"
    echo "  agent-name    Name of the agent to teardown (e.g., merging_cdt_service)"
    echo ""
    echo "Options:"
    echo "  -f, --force     Force remove worktree even with modified/untracked files"
    echo "  -l, --list      List available agents to teardown"
    echo "  --dry-run       Show what would be done without executing"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 merging_cdt_service --force    # Force remove worktree + kill tmux"
    echo "  $0 ag_grid_optimize               # Remove clean worktree + kill tmux"
    echo "  $0 --list                         # List all agents"
    echo "  $0 --dry-run merging_cdt_service  # Preview what would be removed"
    echo ""
    echo "Verification commands:"
    echo "  git worktree list                 # Verify worktree removed"
    echo "  tmux ls                           # Verify tmux session killed"
    exit 0
}

# Function to list agents
list_agents() {
    echo -e "${CYAN}=== Available Agents ===${NC}"
    echo ""

    # Get git worktrees
    echo -e "${BLUE}Git Worktrees:${NC}"
    if [ -d "$GLOBALVIZ_DIR" ]; then
        cd "$GLOBALVIZ_DIR"
        WORKTREES=$(git worktree list --porcelain | grep "^worktree" | sed 's/worktree //')

        if [ -n "$WORKTREES" ]; then
            while IFS= read -r worktree_path; do
                # Skip the main globalviz directory
                if [ "$worktree_path" = "$GLOBALVIZ_DIR" ]; then
                    continue
                fi

                # Get the agent name from the path
                agent_name=$(basename "$worktree_path")

                # Check for uncommitted changes
                if [ -d "$worktree_path" ]; then
                    cd "$worktree_path"
                    if git status --porcelain | grep -q .; then
                        echo -e "  ${YELLOW}$agent_name${NC} (has uncommitted changes)"
                    else
                        echo -e "  ${GREEN}$agent_name${NC}"
                    fi
                    cd "$GLOBALVIZ_DIR"
                else
                    echo -e "  ${RED}$agent_name${NC} (directory missing)"
                fi
            done <<< "$WORKTREES"
        else
            echo "  (no worktrees found)"
        fi
        cd "$SCRIPT_DIR"
    else
        echo -e "  ${RED}globalviz directory not found${NC}"
    fi

    echo ""
    echo -e "${BLUE}Tmux Sessions:${NC}"
    if command -v tmux &> /dev/null; then
        SESSIONS=$(tmux list-sessions -F "#{session_name}" 2>/dev/null || true)
        if [ -n "$SESSIONS" ]; then
            while IFS= read -r session; do
                echo -e "  ${GREEN}$session${NC}"
            done <<< "$SESSIONS"
        else
            echo "  (no tmux sessions found)"
        fi
    else
        echo "  (tmux not installed)"
    fi

    echo ""
    echo -e "${CYAN}=== Matching Agents ===${NC}"
    echo "(agents with both worktree and tmux session)"
    echo ""

    # Find agents that have both worktree and tmux session
    if [ -d "$GLOBALVIZ_DIR" ]; then
        cd "$GLOBALVIZ_DIR"
        WORKTREES=$(git worktree list --porcelain | grep "^worktree" | sed 's/worktree //')

        FOUND_MATCH=false
        while IFS= read -r worktree_path; do
            # Skip the main globalviz directory
            if [ "$worktree_path" = "$GLOBALVIZ_DIR" ]; then
                continue
            fi

            agent_name=$(basename "$worktree_path")
            # Convert hyphens to underscores for tmux session name
            tmux_name="${agent_name//-/_}"

            if tmux has-session -t "$tmux_name" 2>/dev/null; then
                echo -e "  ${GREEN}$agent_name${NC} → tmux: ${GREEN}$tmux_name${NC}"
                FOUND_MATCH=true
            fi
        done <<< "$WORKTREES"

        if [ "$FOUND_MATCH" = false ]; then
            echo "  (no matching agents found)"
        fi

        cd "$SCRIPT_DIR"
    fi

    exit 0
}

# Function to perform teardown
teardown_agent() {
    local agent_name=$1
    local force=$2
    local dry_run=$3

    # Convert hyphens to underscores for tmux session name (matches setup-agent.sh)
    local tmux_session="${agent_name//-/_}"
    local worktree_path="$SCRIPT_DIR/$agent_name"

    echo -e "${CYAN}=== Teardown Agent: $agent_name ===${NC}"
    echo ""

    # Safety check: prevent removal of globalviz directory
    if [ "$agent_name" = "globalviz" ]; then
        echo -e "${RED}Error: Cannot teardown the main globalviz directory!${NC}"
        exit 1
    fi

    # Check what exists
    local worktree_exists=false
    local tmux_exists=false
    local has_changes=false

    # Check worktree
    if [ -d "$GLOBALVIZ_DIR" ]; then
        cd "$GLOBALVIZ_DIR"
        if git worktree list | grep -q "$worktree_path"; then
            worktree_exists=true

            # Check for uncommitted changes
            if [ -d "$worktree_path" ]; then
                cd "$worktree_path"
                if git status --porcelain | grep -q .; then
                    has_changes=true
                fi
                cd "$GLOBALVIZ_DIR"
            fi
        fi
        cd "$SCRIPT_DIR"
    fi

    # Check tmux session
    if command -v tmux &> /dev/null && tmux has-session -t "$tmux_session" 2>/dev/null; then
        tmux_exists=true
    fi

    # Report what was found
    echo -e "${BLUE}Status:${NC}"
    if [ "$worktree_exists" = true ]; then
        if [ "$has_changes" = true ]; then
            echo -e "  Worktree: ${YELLOW}exists (has uncommitted changes)${NC}"
        else
            echo -e "  Worktree: ${GREEN}exists (clean)${NC}"
        fi
    else
        echo -e "  Worktree: ${YELLOW}not found${NC}"
    fi

    if [ "$tmux_exists" = true ]; then
        echo -e "  Tmux session '$tmux_session': ${GREEN}exists${NC}"
    else
        echo -e "  Tmux session '$tmux_session': ${YELLOW}not found${NC}"
    fi
    echo ""

    # Nothing to do
    if [ "$worktree_exists" = false ] && [ "$tmux_exists" = false ]; then
        echo -e "${YELLOW}Nothing to teardown for agent '$agent_name'${NC}"
        exit 0
    fi

    # Dry run mode
    if [ "$dry_run" = true ]; then
        echo -e "${BLUE}Dry run - would perform:${NC}"
        if [ "$worktree_exists" = true ]; then
            if [ "$force" = true ]; then
                echo "  git worktree remove \"$worktree_path\" --force"
            else
                echo "  git worktree remove \"$worktree_path\""
            fi
        fi
        if [ "$tmux_exists" = true ]; then
            echo "  tmux kill-session -t \"$tmux_session\""
        fi
        echo ""
        echo -e "${YELLOW}No changes made (dry run)${NC}"
        exit 0
    fi

    # Check if force is needed
    if [ "$has_changes" = true ] && [ "$force" = false ]; then
        echo -e "${YELLOW}Warning: Worktree has uncommitted changes!${NC}"
        echo ""
        echo "Changes in $agent_name:"
        cd "$worktree_path"
        git status --short
        cd "$SCRIPT_DIR"
        echo ""
        echo -e "${YELLOW}Use --force to remove anyway, or commit/stash changes first.${NC}"
        exit 1
    fi

    # Perform teardown
    echo -e "${BLUE}Performing teardown:${NC}"

    # Remove worktree
    if [ "$worktree_exists" = true ]; then
        echo -n "  Removing worktree... "
        cd "$GLOBALVIZ_DIR"
        if [ "$force" = true ]; then
            if git worktree remove "$worktree_path" --force 2>/dev/null; then
                echo -e "${GREEN}done${NC}"
            else
                echo -e "${RED}failed${NC}"
                echo -e "${YELLOW}  Trying alternative removal method...${NC}"
                # Try removing the directory manually and pruning
                rm -rf "$worktree_path"
                git worktree prune
                echo -e "${GREEN}  Removed via prune${NC}"
            fi
        else
            if git worktree remove "$worktree_path" 2>/dev/null; then
                echo -e "${GREEN}done${NC}"
            else
                echo -e "${RED}failed${NC}"
                echo -e "${YELLOW}Hint: Use --force to remove worktrees with changes${NC}"
                cd "$SCRIPT_DIR"
                exit 1
            fi
        fi
        cd "$SCRIPT_DIR"
    fi

    # Kill tmux session
    if [ "$tmux_exists" = true ]; then
        echo -n "  Killing tmux session '$tmux_session'... "
        if tmux kill-session -t "$tmux_session" 2>/dev/null; then
            echo -e "${GREEN}done${NC}"
        else
            echo -e "${RED}failed${NC}"
        fi
    fi

    echo ""
    echo -e "${GREEN}✓ Agent '$agent_name' teardown complete${NC}"
    echo ""
    echo "Verification commands:"
    echo "  git worktree list    # Should not show $agent_name"
    echo "  tmux ls              # Should not show $tmux_session"
}

# Parse arguments
AGENT_NAME=""
FORCE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -l|--list)
            list_agents
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            if [ -z "$AGENT_NAME" ]; then
                AGENT_NAME=$1
            else
                echo -e "${RED}Error: Multiple agent names provided${NC}"
                echo "Use --help for usage information"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate
if [ -z "$AGENT_NAME" ]; then
    echo -e "${RED}Error: No agent name provided${NC}"
    echo ""
    echo "Usage: $0 <agent-name> [--force] [--dry-run]"
    echo "       $0 --list"
    echo "       $0 --help"
    exit 1
fi

# Check if globalviz directory exists
if [ ! -d "$GLOBALVIZ_DIR" ]; then
    echo -e "${RED}Error: globalviz directory not found${NC}"
    echo "Expected at: $GLOBALVIZ_DIR"
    echo "Make sure you're running this from the project-agents directory"
    exit 1
fi

# Perform teardown
teardown_agent "$AGENT_NAME" "$FORCE" "$DRY_RUN"
