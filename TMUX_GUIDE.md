### Starting and Ending Sessions:

- **Starting a new session:**
  shCopy code
  `tmux`
  or
  shCopy code
  `tmux new -s session_name`
  The `-s` flag is used to specify a name for the session.
- **Listing all sessions:**
  shCopy code
  `tmux ls`
  or
  shCopy code
  `tmux list-sessions`

'greyedout-button'

- **Attaching to a session:**
  shCopy code
  `tmux a -t session_name`
  `tmux a -t jup`
  or
  shCopy code
  `tmux attach -t session_name`
- **Detaching from a session:** Press `Ctrl-b` followed by `d`.
- **Ending a session:** First, you must be attached to the session.
  shCopy code
  `tmux kill-session -t session_name`
  You can also exit a session by typing `exit` from within the session.

or kill by id
tmux kill-session -t 0

### Working with Windows and Panes:

- **Creating a new window:** Press `Ctrl-b` followed by `c`.
- **Switching between windows:** Press `Ctrl-b` followed by the window number (e.g., `Ctrl-b 0`, `Ctrl-b 1`, etc.).
- **Splitting the window into panes:**
  - Horizontal split: Press `Ctrl-b` followed by `%`.
  - Vertical split: Press `Ctrl-b` followed by `"`.
- **Switching between panes:** Press `Ctrl-b` followed by the arrow keys to navigate between panes.
- **Resizing panes:** Press `Ctrl-b` followed by `Ctrl` and the arrow keys to resize panes.
- **Closing a pane:** Type `exit` or press `Ctrl-d`.

### Miscellaneous:

- **Scrolling within a pane:** Press `Ctrl-b` followed by `[` to enter scroll mode. Use the arrow keys to scroll. Press `q` to exit scroll mode.
- **Renaming a session:** Press `Ctrl-b` followed by `$`.
- **Renaming a window:** Press `Ctrl-b` followed by `,`.

These commands provide a basic introduction to using `tmux`. For more advanced usage, refer to the `tmux` man page or other `tmux` resources.

## Practical Workflow

bash

```bash
# Setup multiple detached sessions
tmux new-session -d -s main -c ~/project/main
tmux new-session -d -s testing -c ~/project/tests
tmux new-session -d -s docs -c ~/project/docs

# List all sessions
tmux list-sessions
# or shorthand:
tmux ls

# Jump between them
tmux attach -t main
tmux attach -t testing
tmux attach -t docs
```

Splitting the terminals.

## Kill the Old Session & Start Fresh

bash

```bash
# Kill the existing integration_tests_port session
tmux kill-session -t integration_tests_port

# Create a new clean session in your current directory
tmux new -s integration_tests_port -c .
```

## Now Set Up Your Split Panes

bash

```bash
# Split window (npm top, work bottom)
tmux split-window -v -p 25

# Start npm in top pane
tmux send-keys -t 0 "npm run dev" Enter

# Focus bottom pane for your work
tmux select-pane -t 1
```

Video course

https://www.youtube.com/watch?v=OGiRb7LeIIM&t=164s

# tmux Session Persistence Guide

## The Problem

When your computer reboots, **all tmux sessions are lost** because:

- tmux sessions only exist in memory
- The tmux server process terminates on reboot
- No persistence exists by default

## The Solution: tmux-resurrect + tmux-continuum

**Two essential plugins:**

- **tmux-resurrect**: Manual save/restore of sessions
- **tmux-continuum**: Automatic saving + auto-restore on tmux startup

## Installation Process

### 1. Install TPM (Plugin Manager)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 2. Configure ~/.tmux.conf

```bash
# Mouse support
set -g mouse on

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Resurrect configuration
set -g @resurrect-processes 'ssh python3 python ipython jupyter-lab jupyter-notebook poetry pipenv npm "~poetry run" "~pipenv run"'
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-save-shell-history 'on'

# Continuum configuration (auto-save every 5 minutes)
set -g @continuum-restore 'on'
set -g @continuum-save-interval '5'

# Custom prefix (optional)
unbind-key C-b
set -g prefix C-a
bind-key C-a send-prefix

# Custom reload binding
bind r source-file ~/.tmux.conf \; display "Reloaded!"

# Initialize TMUX plugin manager (keep at bottom)
run '~/.tmux/plugins/tpm/tpm'
```

### 3. Install Plugins

1. Start tmux: `tmux`
2. Install plugins: `Prefix + I` (Ctrl-a + Shift-i or Ctrl-b + Shift-i)
3. Should see: "Installing plugins..." and "TMUX environment reloaded"

## Key Learnings & Troubleshooting

### Plugin Installation

- **Plugins install once globally** - available in all future sessions
- **Install FROM WITHIN tmux** but they become system-wide
- **No need to reinstall** after reboots or new sessions

### Common Issues

- **"command not found: run"** - Don't run tmux config commands in shell, put them in `~/.tmux.conf`
- **"No such file or directory"** when reloading - Start tmux first, THEN reload config
- **TPM not loading** - Check if `~/.tmux/plugins/tpm/tpm` exists and is executable
- **Custom prefix key** - Remember to use YOUR prefix (e.g., Ctrl-a instead of default Ctrl-b)

### Verification Commands

```bash
# Check plugins installed
ls ~/.tmux/plugins/
# Should show: tpm, tmux-resurrect, tmux-continuum

# Check plugin configuration
tmux show-options -g | grep resurrect
tmux show-options -g | grep continuum

# Find save files location
find ~ -name "*resurrect*" -type f -mtime -1 2>/dev/null
```

## How Session Persistence Works

### What Gets Saved ✅

- **All sessions** and their names
- **All windows** and their names
- **All panes** and split layouts
- **Working directories** for each pane
- **Active window/pane selections**
- **Running programs** (vim, python, ssh, etc. - configurable)
- **Some pane contents** (with capture-pane-contents)

### What Doesn't Get Saved ❌

- Command history/scrollback buffer
- All processes (only configured ones)
- Environment variables
- Shell state (activated virtual environments)

### Save Locations

- **Modern systems**: `~/.local/share/tmux/resurrect/`
- **Traditional**: `~/.tmux/resurrect/` (if explicitly configured)

### Key Files

- `tmux_resurrect_[timestamp].txt` - Session layout data
- `pane_contents.tar.gz` - Captured pane contents
- `last` - Symlink to most recent save

## Usage

### Manual Commands

- **Save**: `Prefix + Ctrl-s` → "Tmux environment saved!"
- **Restore**: `Prefix + Ctrl-r` → "Tmux restore complete!"

### Automatic Operation

- **Auto-saves every 5 minutes** (or configured interval)
- **Auto-restores on tmux startup** after reboot
- **No user intervention required**

### Testing the Setup

1. Create test sessions with splits
2. Save manually: `Prefix + Ctrl-s`
3. Kill tmux: `tmux kill-server`
4. Restart: `tmux` (should auto-restore)
5. Verify all sessions/windows/panes returned

## Verification of Working System

```bash
# Watch auto-saves happening
watch -n 30 'ls -lh ~/.local/share/tmux/resurrect/'

# Every 5 minutes should see:
# - pane_contents.tar.gz timestamp updates
# - Occasionally new tmux_resurrect_*.txt files
```

## Final Result

**Complete session persistence:**

- ✅ Survives computer reboots
- ✅ Automatic background saving
- ✅ Automatic restoration
- ✅ Manual save/restore available
- ✅ Preserves complex multi-session workflows

**No more lost work due to reboots or crashes!**
