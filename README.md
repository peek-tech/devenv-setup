# Omacy - macOS Developer Environment

Modular, reliable macOS developer environment installer with **individual app control**. Automatically sets up a complete development environment with modern tools, languages, and theming using a manifest-driven architecture.

## Quick Start

```bash
curl -fsSL https://peek-tech.github.io/devenv-setup/install | bash
```

The installer automatically downloads the repository and runs installation scripts based on a **smart manifest system**.

## Features

**🎯 Granular Control**: 50+ individual scripts for complete customization
**📋 Manifest-Driven**: JSON-based execution with logical grouping and dependencies
**🎨 Advanced Theming**: 4 Catppuccin color schemes with CLI switching (`omacy theme`)
**🔄 Git-First Setup**: Early git configuration following Omarchy patterns
**📦 Auto-Download**: Downloads repository before installation (works with `curl | bash`)
**🍎 macOS Focused**: Optimized for macOS without Linux complexity

## Individual Script Architecture

Omacy uses a **manifest-driven architecture** with individual scripts organized into logical groups:

### Core System (Required)
- **preflight-checks.sh** - System validation and prerequisites
- **git-setup.sh** - Git configuration and SSH keys
- **homebrew.sh** - Package manager setup

### Command Line Tools (20 tools)
- **Modern CLI replacements**: `bat` (cat), `eza` (ls), `ripgrep` (grep), `fd` (find)
- **Development tools**: `git`, `gh`, `jq`, `delta`, `fzf`, `starship`
- **System utilities**: `htop`, `dust`, `procs`, `zoxide`, `hyperfine`
- **Task runners**: `just`, `tealdeer`, `sd`, `tree`, `wget`

### Programming Languages (5 managers)
- **nvm.sh** - Node.js 20 via version manager
- **pyenv.sh** - Python 3.11 via version manager  
- **poetry.sh** - Python package manager
- **go.sh** - Go programming language
- **bun.sh** - Fast JavaScript runtime

### Developer Fonts (2 collections)
- **nerd-fonts.sh** - Programming fonts with icons (71 fonts)
- **fira-code.sh** - Coding font with ligatures

### Web Browsers (5 browsers)
- **google-chrome.sh**, **firefox.sh**, **microsoft-edge.sh**
- **arc.sh**, **brave-browser.sh**

### Code Editors (2 editors)
- **visual-studio-code.sh** - VS Code editor
- **neovim.sh** - Modern Vim-based editor

### AI Tools (2 tools)
- **claude.sh** - AI assistant desktop app
- **claude-code.sh** - AI CLI tool

### Terminal Applications (7 TUIs)
- **htop.sh**, **tmux.sh** (with hamvocke.com config), **glances.sh**
- **ncdu.sh**, **lazygit.sh**, **lazysql.sh**, **oxker.sh**

### Productivity Tools (4 apps)
- **rectangle.sh** - Window management
- **bruno.sh** - API client (REST/GraphQL/gRPC)
- **google-drive.sh** - File sync and collaboration
- **slack.sh** - Team communication

### Design Tools (1 app)
- **figma.sh** - UI/UX design application

### Container Tools (2 tools)
- **podman.sh** - Container runtime with Docker compatibility
- **podman-desktop.sh** - Container management GUI

### Workspace & Theming (3 scripts)
- **workspaces.sh** - CSV-based repository cloning
- **ghostty.sh** - Terminal configuration
- **themes.sh** - Catppuccin theming system

### Optional Configuration (2 scripts)
- **nvim-config.sh** - Neovim framework setup (LazyVim, AstroNvim, etc.)
- **vscode-config.sh** - VS Code extensions and settings

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

## Manifest-Driven Architecture

Omacy follows Omarchy's reliable installation patterns with modern enhancements:

1. **Repository Download**: Clones full repository to `~/.omacy` before running scripts
2. **Manifest Execution**: JSON-based script ordering with dependency management
3. **Individual Scripts**: 50+ granular scripts for complete customization control
4. **Smart Dependencies**: Scripts only run when their dependencies are satisfied
5. **Early Git Setup**: Configures git and SSH early in the process
6. **Comprehensive Theming**: Applies consistent colors across all development tools
7. **CLI Management**: Provides `omacy` command for theme switching and future TUI

### Manifest Structure
```json
{
  "groups": {
    "tools": ["tools/starship.sh", "tools/fzf.sh", ...],
    "browsers": ["apps/chrome.sh", "apps/firefox.sh", ...],
    "productivity": ["apps/slack.sh", "apps/rectangle.sh", ...]
  },
  "scripts": [
    {"name": "tools/starship.sh", "depends": ["homebrew.sh"], "group": "tools"}
  ]
}
```

## Future Improvements

### Script Execution Order Management
Currently, scripts are executed based on their numeric prefixes (001-, 002-, etc.) determined by `ls` sorting. A better approach would be to use a manifest file (e.g., `scripts/manifest.txt` or `scripts/order.json`) that explicitly defines the execution order. This would:
- Eliminate the need to renumber files when reordering scripts
- Make dependencies and execution order explicit and version-controllable
- Allow conditional execution based on configuration
- Support parallel execution of independent scripts

Example manifest structure:
```json
{
  "scripts": [
    {"name": "preflight-checks.sh", "required": true},
    {"name": "git-setup.sh", "required": true},
    {"name": "homebrew.sh", "required": true},
    {"name": "fonts.sh", "required": false},
    {"name": "cli-tools.sh", "required": false, "depends": ["homebrew.sh"]},
    {"name": "languages.sh", "required": false, "depends": ["homebrew.sh"]},
    {"name": "workspaces.sh", "required": false},
    {"name": "apps.sh", "required": false, "depends": ["homebrew.sh"]},
    {"name": "ghostty.sh", "required": false},
    {"name": "nvim-config.sh", "optional": true},
    {"name": "vscode-config.sh", "optional": true},
    {"name": "themes.sh", "required": false}
  ]
}
```

## License

MIT