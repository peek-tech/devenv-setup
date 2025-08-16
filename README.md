# Developer Environment Setup

Automated setup scripts for quickly configuring a complete developer environment.

## Quick Start

```bash
curl -fsSL https://peek-tech.github.io/devenv-setup/install.sh | bash
```

## What Gets Installed

- **Claude Code**: AI-powered coding assistant with agent orchestration
  - Claude desktop app and CLI tool
  - VS Code extension integration
  - Agent orchestration system setup

- **Core Development Tools**: Essential development utilities
  - VS Code with Python and Node.js extensions
  - Ghostty terminal integration
  - Modern CLI tools: ripgrep, fd, bat, exa, fzf, lazygit, delta
  - Development utilities: git, GitHub CLI, jq, wget, tree, htop, tmux, neovim
  - Curated Nerd Fonts collection (JetBrains Mono, Hack, etc.)

- **Programming Languages**: Latest versions via version managers
  - Python (latest via pyenv) + Poetry package manager
  - Node.js (latest stable via nvm) + Yarn package manager  
  - Go programming language
  - Bun fast JavaScript runtime

- **Web Browsers**: Modern browsers (macOS only)
  - Chrome, Firefox, Edge, Brave, Arc Browser

- **Design Tools**: Creative applications and utilities (macOS only)
  - Figma UI/UX design application
  - CLI tools: ImageMagick, GraphicsMagick, OptiPNG, JPEG optimization, FFmpeg
  - Developer fonts: Fira Code, Source Code Pro, Cascadia Code, Inter

- **AWS Development Tools**: AWS and infrastructure tools
  - AWS CLI v2, SAM CLI, CDK
  - AWS Session Manager Plugin
  - AWS Vault for credential management

- **Container Tools**: Podman with full Docker compatibility
  - Podman + Podman Desktop
  - Docker command compatibility (symlinks/aliases)
  - Docker Compose support via Podman Compose

- **Database Tools**: Development database tools and clients
  - GUI clients: DBeaver Community, MongoDB Compass
  - CLI tools: PostgreSQL 16, MongoDB Shell, LazySql
  - Optional database servers: MongoDB, PostgreSQL 16
  - Database service management aliases

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
   - **Utilities:** jq, wget, tree, htop, tmux
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

- macOS or Linux (Ubuntu 20.04+, CentOS 8+)
- Bash 4.0+
- Internet connection
- Admin/sudo access for some components (see below)

### Sudo Requirements

**macOS**: Homebrew installation requires sudo access to install to system directories. The installer will prompt for your password when needed.

**For automated/CI environments**, skip sudo prompts with:
```bash
curl -fsSL https://peek-tech.github.io/devenv-setup/install.sh | NONINTERACTIVE=1 bash
```

**Linux**: Package manager operations may require sudo for system package installation.

## License

MIT