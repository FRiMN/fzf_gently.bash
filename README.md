# fzf_gently.bash

> A lightweight modular framework for integrating [fzf](https://github.com/junegunn/fzf) with Bash

## Features

- **🤝 Does not conflict with `bash_completion`** — works via separate key bindings without intercepting `Tab`
- **📦 Modular architecture** — load only the modules you need
- **🎯 Context-dependent** — fzf activates only for supported commands
- **⚡ Does not interfere with tab completion** — standard `Tab` works as usual

## How it works with `bash_completion`

**fzf_gently.bash**:

- Uses **separate key bindings** (e.g., `Ctrl+Space`, `Ctrl+F`)
- Checks the current command in `READLINE_LINE` before activation
- Allows using `Tab` for standard `bash_completion` without modifications
- Activates fzf only when the cursor is in the context of a supported command

```bash
# Example: you are typing a command
git checkout fea<TAB>        # ← Standard bash_completion works
git checkout fea<C-Space>    # ← fzf opens for branch selection
```

## How It Works

### The `any_f` Function

The core of fzf_gently.bash is the `fzf_gently__any_f` function. It implements **short-circuit evaluation** (like logical OR):

```bash
fzf_gently__any_f \
    fzf_gently__fzf_git_branch \
    fzf_gently__fzf_flatpak_app \
    fzf_gently__fzf_cd
```

**How it works:**
1. Executes functions in order from first to last
2. **Stops immediately** when any function returns exit code `0` (success)
3. Returns `0` if at least one function succeeded
4. Returns `1` only if **all** functions failed

### Module Pattern Matching

Each module follows this pattern:

```bash
fzf_gently__fzf_module_name() {
    # Check if current command matches this module's pattern
    if [[ "$READLINE_LINE" =~ ^pattern$ ]]; then
        # Launch fzf and set result to READLINE_LINE
        return 0  # Success - stop processing other modules
    else
        return 1  # Not our command - try next module
    fi
}
```

**Example flow for `git checkout <C-f>`:**

1. `fzf_gently__fzf_git_branch` checks: "Does this match `git checkout`?" → **Yes!** → Launches fzf → Returns `0` → Stop

2. `fzf_gently__fzf_flatpak_app` never runs (short-circuit)

3. `fzf_gently__fzf_cd` never runs (short-circuit)

**Example flow for `flatpak run <C-f>`:**

1. `fzf_gently__fzf_git_branch` checks: "Does this match?" → No → Returns `1` → Continue

2. `fzf_gently__fzf_flatpak_app` checks: "Does this match?" → **Yes!** → Launches fzf → Returns `0` → Stop

3. `fzf_gently__fzf_cd` never runs

This approach ensures **only the first matching module** handles the command.

### The `cmd_matches` Function

The `fzf_gently___cmd_matches` function simplifies pattern matching for command parsing:

```bash
# Basic command without subcommands
fzf_gently___cmd_matches "cd" "" prefix query || return 1
# Matches: "cd <query>"

# Command with multiple subcommands (OR logic)
fzf_gently___cmd_matches "git" "checkout branch" prefix query || return 1
# Matches: "git checkout <query>" or "git branch <query>"
```

**Parameters:**
- `cmd` — main command name (e.g., "git", "cd")
- `subcmds` — space-separated subcommands (e.g., "checkout branch", empty string for none)
- `prefix_var` — nameref variable to store matched prefix (cmd + subcmd)
- `query_var` — nameref variable to store user input after the command

**Returns:**
- `0` if READLINE_LINE matches the pattern (variables set)
- `1` if no match (continue to next module)

## Installation

### Requirements

- Bash 4.0+
- [fzf](https://github.com/junegunn/fzf#installation)

### Quick Install

```bash
# Clone the repository
git clone https://github.com/FRiMN/fzf_gently.bash.git ~/.config/fzf_gently.bash
```

Add to ~/.bashrc:
```bash
# Load fzf_gently code
source ~/.config/fzf_gently.bash/init.sh

# Activate all fzf_gently context-dependent functionality
bind -x '"\C-f": fzf_gently__all_context_dependent'
# Activate fzf_gently history functionality
bind -x '"\C-r": fzf_gently__fzf_history'
```

## Key Bindings Configuration

Add to `~/.bashrc` after the `source`:

```bash
# Activate fzf_gently for the current command (main binding)
bind -x '"\C-f": fzf_gently__all_context_dependent'

# Or use alternative combinations:
bind -x '"\C-@": fzf_gently__all_context_dependent'    # Ctrl+Space
bind -x '"\C-t": fzf_gently__all_context_dependent'    # Ctrl+T

# Individual modules (optional)
bind -x '"\C-g": fzf_gently__fzf_git_branch'   # Git only
bind -x '"\C-r": fzf_gently__fzf_history'      # Command history
```

### Custom Module Combinations

You can create your own function with a custom set of modules:

```bash
_fzf_smart() {
    fzf_gently__any_f \
    fzf_gently__fzf_git_branch \
    fzf_gently__fzf_flatpak_app \
    fzf_gently__fzf_cd
}
bind -x '"\C-f": _fzf_smart'
```

**Important:** `fzf_gently__any_f` must always be the **first** argument, followed by the list of modules you want to check. The function will try each module in order and stop at the first one that matches the current command.

## Modules

| Module | Description | Activation Command |
|--------|-------------|-------------------|
| `cd` | Interactive directory selection | `cd <C-f>` |
| `git_branch` | Git branch selection | `git checkout <C-f>` or `git branch <C-f>` |
| `flatpak_app` | Flatpak application selection | `flatpak run <C-f>` |
| `history` | Command history search | At any time |

> **Note:** The `history` module is not included in `fzf_gently__all_commands()` and must be bound separately (e.g., to `Ctrl+R`).

## Project Structure

```
fzf_gently.bash/
├── init.sh           # Entry point, loads all modules
├── common.sh         # Common functions (any_f, strip, cmd_matches, set_readline)
├── modules/
│   ├── cd.sh         # Directory navigation
│   ├── git_branch.sh # Git branch operations
│   ├── flatpak_app.sh# Launching Flatpak applications
│   └── history.sh    # History search
└── README.md
```

## Creating a Custom Module

### Basic Module (single command)

```bash
# ~/.config/fzf_gently.bash/modules/my_module.sh

fzf_gently__fzf_my_feature() {
    local prefix query selected
    
    # Check if the current line matches our command
    fzf_gently___cmd_matches "mycommand" "" prefix query || return 1
    
    # Launch fzf with the query pre-filled
    selected=$(my_data_source | \
        fzf --prompt='Select: ' -1 --query="${query}" \
            --height=40% --border) && \
    fzf_gently___fzf_set_readline "$prefix" "$selected"
}
```

### Advanced Module (multiple subcommands)

```bash
fzf_gently__fzf_docker() {
    local prefix query selected
    
    # Matches: "docker start <query>" or "docker stop <query>"
    fzf_gently___cmd_matches "docker" "start stop" prefix query || return 1
    
    selected=$(docker ps --format '{{.Names}}' | \
        fzf --prompt='Container: ' -1 --query="${query}" \
            --height=40% --border) && \
    fzf_gently___fzf_set_readline "$prefix" "$selected"
}
```

**Key points:**
1. Always declare `local prefix query selected` at the start
2. Use `fzf_gently___cmd_matches` to parse READLINE_LINE
3. Return 1 immediately if no match (`|| return 1`)
4. Use `fzf_gently___fzf_set_readline` to set the result

### Register your module

Add to `init.sh`:

```bash
fzf_gently__all_context_dependent() {
    fzf_gently__any_f \
    fzf_gently__fzf_my_feature \  # ← Your new module
    fzf_gently__fzf_docker \
    fzf_gently__fzf_git_branch \
    fzf_gently__fzf_flatpak_app \
    fzf_gently__fzf_cd
}
```

## License

MIT License - see file [LICENSE](LICENSE)

## Acknowledgments

- [junegunn/fzf](https://github.com/junegunn/fzf) — amazing fuzzy finder
- Bash Community — for the powerful readline mechanism
