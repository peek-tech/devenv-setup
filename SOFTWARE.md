# Software Installed by Macose

This document lists all software installed by the individual scripts in the Macose installer using the manifest-driven architecture.

## Core System Scripts (Required)

### preflight-checks.sh
**Purpose**: System validation and prerequisites
- Validates macOS system
- Checks network connectivity  
- Verifies disk space
- Ensures Xcode Command Line Tools are available

### git-setup.sh
**Purpose**: Git configuration and SSH keys (early setup)
- **Git** - Version control system (if not present)
- **GitHub CLI** - Official GitHub command line tool
- SSH key generation and GitHub configuration

### homebrew.sh
**Purpose**: Package manager setup
- **Homebrew** - macOS package manager

## Command Line Tools (20 Individual Scripts)

### tools/git.sh
- **Git** - Distributed version control system
- Git aliases (g, gs, ga, gc, gp, gl, gd, gco, gb)

### tools/gh.sh
- **GitHub CLI** - GitHub command line interface

### tools/jq.sh
- **jq** - JSON processor for structured data

### tools/wget.sh
- **wget** - Network downloader

### tools/tree.sh
- **tree** - Directory tree viewer

### tools/ripgrep.sh
- **ripgrep** - Fast text search
- Aliases: `grep="rg"`

### tools/fd.sh
- **fd** - User-friendly file search
- Aliases: `find="fd"`

### tools/bat.sh
- **bat** - Cat with syntax highlighting
- Aliases: `cat="bat"`

### tools/eza.sh
- **eza** - Modern ls replacement with icons
- Aliases: `ls="eza --icons"`, `ll="eza -l --icons"`, `la="eza -la --icons"`, `tree="eza --tree --icons"`

### tools/fzf.sh
- **fzf** - Fuzzy finder for commands/files
- Shell integration with key bindings

### tools/delta.sh
- **delta** - Better git diff with syntax highlighting

### tools/dust.sh
- **dust** - Visual disk usage analyzer
- Aliases: `du="dust"`

### tools/procs.sh
- **procs** - Enhanced process viewer
- Aliases: `ps="procs"`

### tools/sd.sh
- **sd** - Intuitive find and replace tool

### tools/tealdeer.sh
- **tealdeer** - Fast tldr client for command examples

### tools/hyperfine.sh
- **hyperfine** - Benchmarking tool for command performance

### tools/just.sh
- **just** - Modern task runner and command organizer

### tools/zoxide.sh
- **zoxide** - Smart directory navigation
- Shell integration and aliases: `cd="z"`

### tools/starship.sh
- **starship** - Cross-shell prompt with creative configuration
- Custom configuration with creative symbols (💡, 🎨, 🚀, 🐍✨)
- Shell integration for bash, zsh, and fish

## Programming Languages (5 Individual Scripts)

### languages/nvm.sh
- **nvm** - Node Version Manager
- **Node.js 20** - JavaScript runtime (installed via nvm)

### languages/pyenv.sh
- **pyenv** - Python Version Manager
- **Python 3.11.9** - Programming language (installed via pyenv)

### languages/poetry.sh
- **Poetry** - Python package manager and dependency management

### languages/go.sh
- **Go** - Go programming language
- Go workspace configuration

### languages/bun.sh
- **Bun** - Fast JavaScript runtime and package manager

## Developer Fonts (2 Individual Scripts)

### fonts/nerd-fonts.sh
- **Fira Code Nerd Font** - Coding font with ligatures and icons
- **Hack Nerd Font** - Monospace font with programming symbols
- **JetBrains Mono Nerd Font** - Font with ligatures and icons
- **Source Code Pro** - Adobe's coding font
- **Cascadia Code** - Microsoft's coding font

### fonts/fira-code.sh
- **Fira Code** - Coding font with ligatures

## Web Browsers (5 Individual Scripts)

### apps/google-chrome.sh
- **Google Chrome** - Web browser

### apps/firefox.sh
- **Mozilla Firefox** - Web browser

### apps/microsoft-edge.sh
- **Microsoft Edge** - Web browser

### apps/arc.sh
- **Arc** - Modern web browser

### apps/brave-browser.sh
- **Brave Browser** - Privacy-focused web browser

## Code Editors (2 Individual Scripts)

### apps/visual-studio-code.sh
- **Visual Studio Code** - Code editor

### apps/neovim.sh
- **Neovim** - Modern Vim-based editor

## AI Tools (2 Individual Scripts)

### apps/claude.sh
- **Claude** - AI assistant desktop application

### apps/claude-code.sh
- **Claude Code** - AI assistant command line tool

## Terminal Applications (7 Individual Scripts)

### apps/htop.sh
- **htop** - Interactive process viewer

### apps/tmux.sh
- **tmux** - Terminal multiplexer
- Complete configuration based on hamvocke.com guide
- Custom key bindings (Ctrl-a prefix, | and - for splits)
- Mouse mode and enhanced status bar

### apps/glances.sh
- **glances** - System monitoring TUI
- Aliases: `top="glances"`

### apps/ncdu.sh
- **ncdu** - Interactive disk usage analyzer

### apps/lazygit.sh
- **lazygit** - Git TUI
- Aliases: `lg="lazygit"`

### apps/lazysql.sh
- **lazysql** - Database TUI client
- Aliases: `sql="lazysql"`

### apps/oxker.sh
- **oxker** - TUI for Docker/container management

## Productivity Tools (4 Individual Scripts)

### apps/rectangle.sh
- **Rectangle** - Window management tool for macOS

### apps/bruno.sh
- **Bruno** - API client for testing REST, GraphQL, and gRPC

### apps/google-drive.sh
- **Google Drive** - File sync and collaboration

### apps/slack.sh
- **Slack** - Team communication and collaboration platform

## Design Tools (1 Individual Script)

### apps/figma.sh
- **Figma** - UI/UX design application

## Container Tools (2 Individual Scripts)

### apps/podman.sh
- **Podman** - Container runtime with Docker compatibility
- Podman machine setup and configuration
- Docker aliases: `docker="podman"`, `docker-compose="podman compose"`

### apps/podman-desktop.sh
- **Podman Desktop** - Container management GUI

## Workspace & Theming (3 Scripts)

### workspaces.sh
- **Workspace directory creation** - Personal, Work, Learning, Sandbox
- **CSV-based repository cloning** - Clone repos from multiple CSV URLs
- Repository organization by workspace

### ghostty.sh
- **Ghostty** - Modern terminal emulator
- Terminal configuration

### themes.sh
- **Macose CLI tool** (`macose`) - Theme management
- **Catppuccin themes** - 4 color variants:
  - catppuccin-mocha (dark, default)
  - catppuccin-macchiato (dark, warm)  
  - catppuccin-frappe (dark, cool)
  - catppuccin-latte (light)
- Theme configurations for:
  - Ghostty Terminal
  - VSCode
  - Git Delta
  - Bat
  - FZF
  - Neovim

## Optional Configuration (2 Scripts)

### nvim-config.sh
- **Neovim configuration setup** (optional)
- Framework choices: LazyVim, AstroNvim, NvChad, LunarVim, or custom

### vscode-config.sh
- **VS Code configuration setup** (optional)
- Extensions and settings configuration

## Total Software Count

**Individual Scripts**: 50+ granular installation scripts
**Core Installation**: ~60+ tools and applications  
**With All Options**: ~70+ tools and applications

## Installation Method

All software is installed via **Homebrew** for consistent package management and easy updates. The manifest-driven architecture allows for:

- **Granular control** - Install exactly what you need
- **Smart dependencies** - Scripts only run when dependencies are met
- **Logical grouping** - Tools organized by function and type
- **Future extensibility** - Easy to add new tools and applications

## Manifest Groups

The installation is organized into logical groups:
- **core** (3 scripts) - Required system setup
- **tools** (20 scripts) - Command line utilities
- **languages** (5 scripts) - Programming languages and managers
- **fonts** (2 scripts) - Developer fonts
- **browsers** (5 scripts) - Web browsers
- **editors** (2 scripts) - Code editors
- **ai-tools** (2 scripts) - AI assistants
- **terminal-tools** (7 scripts) - TUI applications
- **productivity** (4 scripts) - Workflow tools
- **design** (1 script) - Design applications
- **containers** (2 scripts) - Container tools
- **workspace** (3 scripts) - Environment setup
- **config** (2 scripts) - Optional configurations