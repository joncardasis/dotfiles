```
   ██████   ██████  ████████ ███████ ██ ██      ███████ ███████ 
   ██   ██ ██    ██    ██    ██      ██ ██      ██      ██      
   ██   ██ ██    ██    ██    █████   ██ ██      █████   ███████ 
   ██   ██ ██    ██    ██    ██      ██ ██      ██           ██ 
██ ██████   ██████     ██    ██      ██ ███████ ███████ ███████ 
```

My personal configuration files for development workflow.

## Installation

```bash
git clone git@github.com:joncardasis/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run the installation script
./install.sh
```

## Structure

```
dotfiles
├── bin/               # Programs
├── zsh/               # zsh configuration
│   └── aliases.zsh    # Shared aliases
└── install.sh
```

## How it Works

The `install.sh` script is idempotent and safe to run multiple times.

It performs the following:
- Symlinks scripts from `bin/` to `~/.local/bin/` and adds the directory to PATH
- Adds `source ~/.dotfiles/zsh/aliases.zsh` to `~/.zshrc`

Changes to files in this repo are immediately available. Commit and push to sync across machines. 