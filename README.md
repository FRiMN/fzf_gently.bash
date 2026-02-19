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

## Installation

### Requirements

- Bash 4.0+
- [fzf](https://github.com/junegunn/fzf#installation)

### Quick Install

```bash
# Clone the repository
git clone https://github.com/FRiMN/fzf_gently.bash.git ~/.config/fzf_gently.bash

# Add to ~/.bashrc
source ~/.config/fzf_gently.bash/init.sh
```

## Key Bindings Configuration

Add to `~/.bashrc` after the `source`:

```bash
# Activate fzf_gently for the current command (main binding)
bind -x '"\C-f": fzf_gently__all_commands'

# Or use alternative combinations:
bind -x '"\C-@": fzf_gently__all_commands'    # Ctrl+Space
bind -x '"\C-t": fzf_gently__all_commands'    # Ctrl+T

# Individual modules (optional)
bind -x '"\C-g": fzf_gently__fzf_git_branch'   # Git only
bind -x '"\C-r": fzf_gently__fzf_history'      # Command history
```

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
├── common.sh         # Common functions (any_f, strip, set_readline)
├── modules/
│   ├── cd.sh         # Directory navigation
│   ├── git_branch.sh # Git branch operations
│   ├── flatpak_app.sh# Launching Flatpak applications
│   └── history.sh    # History search
└── README.md
```

## Creating a Custom Module

```bash
# ~/.config/fzf_gently.bash/modules/my_module.sh

fzf_gently__fzf_my_feature() {
    local prefix query selected
    
    # Check if the current line matches our pattern
    if [[ "$READLINE_LINE" =~ ^([[:space:]]*mycommand)[[:space:]]+(.*)$ ]]; then
        prefix=$(fzf_gently__strip "${BASH_REMATCH[1]}")
        query=$(fzf_gently__strip "${BASH_REMATCH[2]}")
    else
        return 1  # Not our command, pass control forward
    fi
    
    # Launch fzf
    selected=$(my_data_source | \
        fzf --prompt='Select: ' -1 --query="${query}" \
            --height=40% --border) && \
    fzf_gently___fzf_set_readline "$prefix" "$selected"
}
```

Add to `init.sh`:

```bash
fzf_gently__all_commands() {
    fzf_gently__any_f \
    fzf_gently__fzf_my_feature \  # ← Your new module
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
