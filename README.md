# Omamacy - macOS Developer Environment Setup

Automated and opinionated macOS developer environment installer with **70+ development tools** and applications. Sets up a complete development workstation with modern CLI tools, programming languages, editors, browsers, and productivity apps using a manifest-driven architecture.

## Quick Start

```bash
curl -fsSL https://peek-tech.github.io/devenv-setup/install | bash
```

The installer downloads the repository to `~/.local/share/omamacy` and executes installation scripts automatically based on a JSON manifest.

## ⚠️ Interactive Installation Required

**This is NOT a hands-off installation.** You must be present during the process for:

- **Multiple sudo password prompts** throughout installation
- **System UI popups** that appear outside the terminal window
- **User configuration prompts** for git, editors, and optional features
- **Authentication dialogs** for various applications

### System Popups You'll See

1. **Xcode Command Line Tools**: Graphical installer popup (required)
2. **Homebrew Installation**: Multiple password prompts in terminal
3. **macOS Security Dialogs**: App installation permissions
4. **Application-Specific Setup**: VSCode, Neovim, Claude Code configuration prompts

**Installation Time**: 15-30 minutes depending on your internet connection and choices made during configuration.

## What Gets Installed

The installer runs **70+ scripts** organized into these categories:

### Core System Setup
- **System Validation**: macOS compatibility and prerequisite checks
- **Git Configuration**: Global git setup with SSH key generation for GitHub
- **macOS System Defaults**: Dark mode, Finder settings, developer-friendly system preferences

### Command Line Tools (21 tools)
- **Modern Replacements**: `bat` (cat), `eza` (ls), `fd` (find), `ripgrep` (grep), `dust` (du), `procs` (ps)
- **Development Tools**: Git with aliases, GitHub CLI, fuzzy finder (fzf), smart directory navigation (zoxide)
- **Performance Tools**: Hyperfine benchmarking, Just task runner
- **Text Processing**: Delta git diff, sd find/replace, TealDeer quick help
- **Shell Enhancement**: Starship cross-shell prompt with creative configuration

### Programming Languages & Runtimes
- **Node.js**: NVM with Node 20 and npm
- **Python**: pyenv with Poetry package management
- **Go**: Latest Go programming language
- **Bun**: Fast JavaScript runtime and package manager

### Developer Fonts
- **Nerd Fonts**: Programming fonts with icons and symbols
- **Fira Code**: Coding font with ligatures

### Web Browsers (5 browsers)
- Google Chrome, Firefox, Microsoft Edge, Arc, Brave Browser

### Code Editors
- **Visual Studio Code**: Full IDE with extensions and configuration
- **Neovim**: Modern vim editor with distribution choices (LazyVim, AstroNvim, NvChad, LunarVim, or custom git URL)

### AI Development Tools
- **Claude**: AI assistant desktop application
- **Claude Code**: AI-powered CLI tool with optional custom agent/MCP server configuration

### Terminal Applications (7 TUIs)
- **Process Management**: htop (system monitor), Glances (advanced system stats)
- **File Management**: ncdu (disk usage analyzer)
- **Development**: LazyGit (git TUI), LazSQL (database client), tmux (terminal multiplexer with session management)
- **Container Management**: Oxker (Docker/Podman TUI)

### Productivity Applications (6 apps)
- **Window Management**: Rectangle for macOS window organization
- **API Development**: Bruno for REST, GraphQL, and gRPC testing
- **Communication**: Slack team collaboration
- **File Sync**: Google Drive
- **Clipboard**: Maccy lightweight clipboard manager
- **Presentations**: KeyCastr keystroke visualizer

### Networking Tools
- **Twingate**: Zero Trust Network Access platform
- **ngrok**: Secure tunnels to localhost for development

### Design Tools
- **Figma**: UI/UX design application

### Container Platform
- **Podman**: Docker-compatible container runtime with desktop GUI
- **Podman Desktop**: Container management interface

### Terminal Emulator
- **Ghostty**: Modern terminal emulator

### Theming & Workspace
- **Catppuccin Theme System**: Consistent theming across all supported applications
- **Workspace Setup**: Development directory structure and repository cloning
- **Font Management**: CLI tool for font configuration across applications

## Interactive Configuration Options

Several scripts will prompt you for choices during installation:

### Git Setup
- Name and email configuration
- SSH key generation for GitHub
- GitHub authentication setup

### Neovim Configuration
- Choose from popular distributions: LazyVim, AstroNvim, NvChad, LunarVim
- Provide custom git URL for your own configuration (must contain `neovim/` directory)
- Custom configs automatically enhanced with tmux navigation
- Falls back to NvChad if invalid choice

### macOS System Defaults
- Opt-in to apply developer-friendly system settings
- Includes dark mode, Finder enhancements, security settings

### tmux Terminal Multiplexer
- Optional auto-start/attach when opening new terminals
- Session management plugins: save/restore sessions across reboots
- Continuous automatic session saving (every 15 minutes)
- Enhanced session management commands and navigation
- Seamless navigation between tmux panes and Neovim splits

### Starship Prompt
- Choose whether to use Starship as your shell prompt
- Adds creative configuration with emoji and symbols

### Claude Code
- Optional configuration with custom agents and MCP servers
- Provide git repository URL for advanced AI tool setup

## Command Line Integration

The installer adds helpful aliases and integrations:

- **Modern Commands**: `ll` (eza), `cat` (bat), `find` (fd), `grep` (rg), `du` (dust), `ps` (procs)
- **Git Shortcuts**: Common git aliases for faster development
- **Development Shortcuts**: `lg` (lazygit), `sql` (lazysql), `top` (glances)
- **Smart Navigation**: `z` command for intelligent directory jumping
- **Enhanced Search**: `fzf` integration for command history and file finding
- **Unified Navigation**: `Ctrl+h/j/k/l` works seamlessly between tmux panes and Neovim splits

## Theme Management

Includes the `omamacy` CLI tool for centralized theme and font management:

```bash
# Theme management
omamacy theme list           # Show available themes
omamacy theme set <theme>    # Switch themes across all apps
omamacy theme current        # Show current theme

# Font management  
omamacy font list           # Open Font Book for browsing
omamacy font set "Font"     # Set font across supported apps
```

## File Structure

```
~/.local/share/omamacy/     # Repository and scripts
~/.config/omamacy/          # User configuration and themes
~/.local/omamacy/           # Claude Code configurations (if used)
```

## Manual Script Execution

All scripts can be run individually:

```bash
cd ~/.local/share/omamacy/scripts
bash apps/neovim.sh         # Install and configure Neovim
bash tools/starship.sh      # Install Starship prompt
bash languages/nvm.sh       # Install Node.js via NVM
```

## System Requirements

- **macOS only** (Intel or Apple Silicon)
- **Internet connection** for downloading packages
- **Administrator access** for system modifications
- **User presence** for interactive configuration

## Updates

Re-run the installer to update to the latest version:

```bash
curl -fsSL https://peek-tech.github.io/devenv-setup/install | bash
```

The installer automatically pulls the latest repository version and updates existing installations.

## Acknowledgments

This project was inspired by:

- **[Omarchy](https://github.com/basecamp/omarchy)** - DHH's opinionated Arch Linux + Hyprland setup that inspired the single-command installation approach. Thanks to the contributors for the ideas and motivation.
- **[Homebrew](https://brew.sh)** - The package manager that powers most installations in this project. Thanks to the developers of Homebrew for making macOS package management possible.

---

**Note**: This installer modifies system settings and installs numerous applications. Review the [script manifest](scripts/manifest.json) for complete details of what will be installed.