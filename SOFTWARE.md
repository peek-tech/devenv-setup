# Software Installed by Omacy

This document lists all software installed by each modular script in the Omacy installer.

## 001-preflight-checks.sh
**Purpose**: System validation and prerequisites
- Validates macOS system
- Checks network connectivity
- Verifies disk space
- Ensures Xcode Command Line Tools are available

## 002-homebrew.sh
**Purpose**: Package manager setup
- **Homebrew** - macOS package manager

## 003-git-setup.sh
**Purpose**: Git configuration and SSH keys (early setup)
- **Git** - Version control system (if not present)
- **GitHub CLI** - Official GitHub command line tool
- SSH key generation and GitHub configuration

## 004-cli-tools.sh
**Purpose**: Essential CLI tools and editors
- **curl** - Data transfer tool
- **wget** - File downloader
- **jq** - JSON processor
- **tree** - Directory tree viewer
- **htop** - Interactive process viewer
- **tmux** - Terminal multiplexer
- **neovim** - Modern Vim-based editor
- **ripgrep** - Fast text search
- **fd** - Fast file finder
- **bat** - Enhanced cat with syntax highlighting
- **eza** - Modern ls replacement
- **fzf** - Fuzzy finder
- **delta** - Enhanced git diff viewer
- **dust** - Disk usage analyzer
- **procs** - Modern ps replacement
- **sd** - Find and replace tool
- **tealdeer** - Fast tldr client
- **glances** - System monitoring
- **hyperfine** - Benchmarking tool
- **lazygit** - Git terminal UI
- **ncdu** - Disk usage analyzer
- **just** - Command runner
- **zoxide** - Smart cd command

## 005-fonts.sh
**Purpose**: Developer fonts and Nerd Fonts
- **JetBrains Mono** - Coding font with ligatures
- **Hack** - Coding font
- **Fira Code** - Coding font with ligatures
- **Source Code Pro** - Adobe's coding font
- **Cascadia Code** - Microsoft's coding font
- **Inter** - Modern UI font
- **SF Mono** - Apple's monospace font
- Additional Nerd Fonts variants

## 006-completions.sh
**Purpose**: Shell completions and environment setup
- Configures completions for installed tools
- Sets up shell integration
- Configures environment variables

## 007-development-apps.sh
**Purpose**: Development applications and languages
- **Visual Studio Code** - Code editor
- **Python** (latest via pyenv) - Programming language
- **Poetry** - Python package manager
- **Node.js** (latest stable via nvm) - JavaScript runtime
- **Yarn** - Node.js package manager
- **Go** - Programming language
- **Bun** - Fast JavaScript runtime
- **pyenv** - Python version manager
- **nvm** - Node.js version manager

## 008-design-apps.sh
**Purpose**: Design and creative tools
- **Figma** - UI/UX design application
- **ImageMagick** - Image processing library
- **GraphicsMagick** - Image processing toolkit
- **OptiPNG** - PNG optimizer
- **JPEG tools** - JPEG optimization utilities
- **FFmpeg** - Video/audio processing

## 009-browsers.sh
**Purpose**: Web browsers
- **Google Chrome** - Web browser
- **Mozilla Firefox** - Web browser
- **Microsoft Edge** - Web browser
- **Brave Browser** - Privacy-focused browser
- **Arc Browser** - Modern browser

## 010-vscode.sh
**Purpose**: VS Code setup and extensions
- **Claude extension** - AI assistant integration
- **Python extension** - Python development support
- **Node.js extensions** - JavaScript/TypeScript development

## 011-ghostty.sh
**Purpose**: Terminal emulator
- **Ghostty** - Modern terminal emulator

## 012-themes.sh
**Purpose**: Additional theming components
- Theme configuration files
- Color palette setup

## 013-themes-system.sh
**Purpose**: Catppuccin theming system and CLI
- **Omacy CLI tool** (`omacy`) - Theme management
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

## Optional Components

The following may be optionally installed depending on user selection:

### AWS Development Tools
- **AWS CLI v2** - AWS command line interface
- **AWS SAM CLI** - Serverless application development
- **AWS CDK** - Infrastructure as code
- **AWS Session Manager Plugin** - EC2 session management
- **AWS Vault** - Credential management

### Container Tools
- **Podman** - Container runtime
- **Podman Desktop** - Container management GUI
- **Podman Compose** - Docker Compose compatibility
- Docker command aliases for compatibility

### Database Tools
- **DBeaver Community** - Universal database client
- **MongoDB Compass** - MongoDB GUI client
- **PostgreSQL 16** - Database server and client tools
- **MongoDB Community** - Document database
- **mongosh** - MongoDB shell
- **LazySql** - Terminal UI for SQL databases

## Total Software Count

**Core Installation**: ~50+ tools and applications
**With All Options**: ~70+ tools and applications

All software is installed via Homebrew for consistent package management and easy updates.