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
  - Interactive selection: Figma, Sketch, Adobe Creative Cloud, Canva, Pixelmator Pro
  - Development tools: ImageOptim, Color Oracle, IconJar
  - CLI tools: ImageMagick, GraphicsMagick, OptiPNG, JPEG optimization, FFmpeg
  - Developer fonts: Fira Code, Source Code Pro, Cascadia Code, Inter

- **Cloud Tools**: AWS and infrastructure tools
  - AWS CLI, SAM CLI, CDK
  - AWS Vault for credential management
  - Terraform for infrastructure as code

- **Container Tools**: Podman with full Docker compatibility
  - Podman + Podman Desktop
  - Docker command compatibility (symlinks/aliases)
  - Docker Compose support via Podman Compose

## Individual Components

Install specific components:

```bash
# Core development tools (VS Code, CLI tools, Nerd Fonts - cross-platform)
curl -fsSL https://peek-tech.github.io/devenv-setup/scripts/setup-core.sh | bash

# Programming languages (Latest Python via pyenv, Node.js via nvm, Go, Bun - cross-platform)
curl -fsSL https://peek-tech.github.io/devenv-setup/scripts/setup-languages.sh | bash

# Web browsers (Chrome, Firefox, Edge, Brave, Arc + testing tools - macOS only)
curl -fsSL https://peek-tech.github.io/devenv-setup/scripts/setup-browsers.sh | bash

# Design tools (Interactive selection of apps + CLI tools - macOS only)
curl -fsSL https://peek-tech.github.io/devenv-setup/scripts/setup-design.sh | bash

# Claude Code with agent orchestration
curl -fsSL https://peek-tech.github.io/devenv-setup/scripts/setup-claude.sh | bash

# AWS development tools (CLI, SAM, CDK, Vault, Terraform - cross-platform)
curl -fsSL https://peek-tech.github.io/devenv-setup/scripts/setup-aws.sh | bash

# Container tools (Podman with Docker compatibility - cross-platform)
curl -fsSL https://peek-tech.github.io/devenv-setup/scripts/setup-containers.sh | bash
```

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

## Documentation

- [Installation Guide](docs/installation.md)
- [Component Details](docs/components.md)
- [Troubleshooting](docs/troubleshooting.md)

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