# Omacy - macOS Developer Environment

Modular, reliable macOS developer environment installer inspired by Omarchy's architecture. Automatically sets up a complete development environment with modern tools, languages, and theming.

## Quick Start

```bash
curl -fsSL https://peek-tech.github.io/devenv-setup/install | bash
```

The installer automatically downloads the repository and runs modular installation scripts.

## Features

**🏗️ Modular Architecture**: 13 numbered installation scripts that run sequentially
**🎨 Advanced Theming**: 4 Catppuccin color schemes with CLI switching (`omacy theme`)
**🔄 Git-First Setup**: Early git configuration following Omarchy patterns
**📦 Auto-Download**: Downloads repository before installation (works with `curl | bash`)
**🍎 macOS Focused**: Optimized for macOS without Linux complexity

## Modular Installation Scripts

The installer runs these scripts in order:

1. **001-preflight-checks.sh** - System validation and prerequisites
2. **002-homebrew.sh** - Package manager setup
3. **003-git-setup.sh** - Git configuration and SSH keys (early setup)
4. **004-core-tools.sh** - Essential CLI tools and editors
5. **005-modern-cli-tools.sh** - Enhanced CLI utilities (bat, ripgrep, fzf, etc.)
6. **006-fonts.sh** - Developer fonts and Nerd Fonts
7. **007-languages.sh** - Python, Node.js, Go, Bun with version managers
8. **008-browsers.sh** - Chrome, Firefox, Edge, Brave, Arc
9. **009-design-tools.sh** - Figma, ImageMagick, FFmpeg
10. **010-claude-code.sh** - AI assistant and VS Code integration
11. **011-aws-tools.sh** - AWS CLI, SAM, CDK, Session Manager
12. **012-containers.sh** - Podman with Docker compatibility
13. **013-themes-system.sh** - Catppuccin theming system and CLI

## Theming System

Omacy includes a comprehensive theming system with 4 Catppuccin variants:

- **catppuccin-mocha** (dark, default)
- **catppuccin-macchiato** (dark, warm)
- **catppuccin-frappe** (dark, cool)
- **catppuccin-latte** (light)

### Theme Management

```bash
# List available themes
omacy theme list

# Show current theme
omacy theme current

# Switch themes
omacy theme set catppuccin-latte
omacy theme set catppuccin-mocha
```

### Themed Applications

Each theme configures:
- **Ghostty Terminal** - Colors and styling
- **VSCode** - Theme settings and terminal colors
- **Git Delta** - Diff highlighting
- **Bat** - Syntax highlighting
- **FZF** - Fuzzy finder colors
- **Neovim** - Colorscheme configurations

## Installation Options

The installer provides an interactive menu to select components:

### Quick Overview

1. **Full Installation** - Installs all components (recommended for new setups)
2. **Core Development Tools** - Homebrew, Git, VS Code, modern CLI tools, fonts
3. **Programming Languages** - Python, Node.js, Go, Bun with version managers
4. **Web Browsers** - Chrome, Firefox, Edge, Brave, Arc (macOS only)
5. **Design Tools** - Figma, image processing tools (macOS only)
6. **Claude Code** - AI assistant with agent orchestration
7. **AWS Development Tools** - CLI, SAM, CDK, Session Manager
8. **Container Tools** - Podman with Docker compatibility
9. **Database Tools** - DBeaver, MongoDB Compass, PostgreSQL, MongoDB
10. **Custom Selection** - Choose specific components to install

### Detailed Installation Scripts

Each option installs the following components:

1. **Full Installation** - Installs all components below (recommended for new setups)

2. **Core Development Tools**
   <details>
   <summary>Click to expand details</summary>
   
   - **Package Manager:** Homebrew
   - **Version Control:** Git, GitHub CLI
   - **Editors:** VS Code with extensions, Neovim
   - **Terminal:** Ghostty terminal
   - **API Client:** Bruno (REST, GraphQL, gRPC testing)
   - **File Sync:** Google Drive (cloud storage and collaboration)
   - **Modern CLI Tools:**
     - eza (better ls)
     - bat (better cat)
     - ripgrep (better grep)
     - fd (better find)
     - fzf (fuzzy finder)
     - delta (better git diff)
     - dust (better du)
     - procs (better ps)
     - sd (better sed)
     - tealdeer (better man)
     - glances (better top)
     - hyperfine (benchmarking)
     - lazygit (git TUI)
     - ncdu (disk usage)
     - just (command runner)
     - zoxide (smart cd)
   - **Fonts:**
     - Curated Nerd Fonts collection
     - Fira Code (coding font with ligatures)
     - Source Code Pro
     - Cascadia Code
     - Inter (modern UI font)
   - **Utilities:** jq, wget, tree, htop, tmux, mas (Mac App Store CLI)
   - **Development Environment:** Xcode (macOS development, command line tools)
   </details>

3. **Programming Languages**
   <details>
   <summary>Click to expand details</summary>
   
   - **Python:** Latest via pyenv + Poetry package manager
   - **Node.js:** Latest stable via nvm + Yarn package manager
   - **Go:** Latest stable version
   - **Bun:** Fast JavaScript runtime and package manager
   - **Version Managers:** pyenv, nvm
   </details>

4. **Web Browsers (macOS only)**
   <details>
   <summary>Click to expand details</summary>
   
   - Google Chrome
   - Mozilla Firefox
   - Microsoft Edge
   - Brave Browser
   - Arc Browser
   </details>

5. **Design Tools (macOS only)**
   <details>
   <summary>Click to expand details</summary>
   
   - **Design Applications:** Figma
   - **Image Processing:**
     - ImageMagick
     - GraphicsMagick
     - OptiPNG
     - JPEG optimization tools
     - FFmpeg (video processing)
   </details>

6. **Claude Code + Agent Orchestration**
   <details>
   <summary>Click to expand details</summary>
   
   - **AI Assistant:** Claude desktop app and CLI tool
   - **VS Code Integration:** Official Claude extension
   - **Agent System:** Multi-agent orchestration capabilities
   - **Features:**
     - Intelligent code assistance
     - Automated workflows
     - Project understanding
     - Code generation and review
   </details>

7. **AWS Development Tools**
   <details>
   <summary>Click to expand details</summary>
   
   - **Core AWS Tools:**
     - AWS CLI v2
     - AWS SAM CLI (Serverless Application Model)
     - AWS CDK (Cloud Development Kit)
     - Session Manager Plugin
     - AWS Vault (credential management)
   - **Infrastructure as Code:** CDK, SAM templates
   - **Serverless Development:** Lambda, API Gateway, DynamoDB
   </details>

8. **Container Tools**
   <details>
   <summary>Click to expand details</summary>
   
   - **Container Runtime:** Podman + Podman Desktop
   - **Docker Compatibility:**
     - Docker command aliases
     - Docker Compose via Podman Compose
     - Compatible API and CLI
   - **Features:**
     - Rootless containers
     - Kubernetes YAML support
     - Pod management
     - Security-focused design
   </details>

9. **Database Tools**
   <details>
   <summary>Click to expand details</summary>
   
   - **GUI Clients:**
     - DBeaver Community (universal database tool)
     - MongoDB Compass (MongoDB GUI)
   - **CLI Tools:**
     - PostgreSQL 16 client tools
     - MongoDB Shell (mongosh)
     - LazySql (terminal UI for SQL databases)
   - **Database Servers (installed by default):**
     - PostgreSQL 16
     - MongoDB Community
   - **Service Management:** Optional auto-start at boot via Homebrew services
   </details>

10. **Custom Selection** - Choose specific components to install from the above options

## Configuration

Set environment variables before running:

```bash
# For automated/non-interactive installation
export NONINTERACTIVE=1

# For CI environments
export CI=1

# For private repository access (Claude agents)
export GITHUB_CLIENT_ID=your_oauth_app_client_id

# For AWS configuration
export AWS_PROFILE=development
```

## Requirements

- **macOS only** (macOS 12+ recommended)
- Internet connection
- Admin access for Homebrew installation
- Git (automatically installed if missing)

## Architecture

Omacy follows Omarchy's reliable installation patterns:

1. **Repository Download**: Clones full repository to `~/.omacy` before running scripts
2. **Modular Execution**: Runs numbered scripts in sequence with error handling
3. **Early Git Setup**: Configures git and SSH early in the process
4. **Comprehensive Theming**: Applies consistent colors across all development tools
5. **CLI Management**: Provides `omacy` command for theme switching and future TUI

## License

MIT