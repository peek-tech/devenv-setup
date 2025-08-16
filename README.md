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

- **Web Browsers**: Modern browsers with testing tools (macOS only)
  - Chrome, Firefox, Edge, Brave, Arc Browser
  - ChromeDriver and GeckoDriver for Selenium testing

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

1. **Full Installation** - Installs all components (recommended)
2. **Core Development Tools** - Homebrew, Git, Neovim, VS Code, etc.
3. **Programming Languages** - Python, Node.js, Go, Bun with version managers
4. **Web Browsers** - Chrome, Firefox, Edge, Brave, Arc (macOS only)
5. **Design Tools** - Figma, image tools, fonts (macOS only)
6. **Claude Code** - AI assistant with agent orchestration
7. **AWS Development Tools** - CLI, SAM, CDK, Session Manager
8. **Container Tools** - Podman with Docker compatibility
9. **Database Tools** - DBeaver, MongoDB Compass, PostgreSQL, MongoDB
10. **Custom Selection** - Choose specific components to install

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