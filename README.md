# Developer Environment Setup

Automated setup scripts for quickly configuring a complete developer environment.

## Quick Start

```bash
curl -fsSL https://peek-tech.github.io/devenv-setup/install.sh | bash
```

## What Gets Installed

- **Claude Code**: AI-powered coding assistant with agent orchestration
- **Development Tools**: Git, Docker, Node.js, Python, etc.
- **Cloud Tools**: AWS CLI, Terraform, kubectl
- **Editor Configurations**: VS Code extensions and settings

## Individual Components

Install specific components:

```bash
# Claude Code with agent orchestration
curl -fsSL https://peek-tech.github.io/devenv-setup/scripts/setup-claude.sh | bash

# AWS development tools
curl -fsSL https://peek-tech.github.io/devenv-setup/scripts/setup-aws.sh | bash

# Container tools (Docker, kubectl)
curl -fsSL https://peek-tech.github.io/devenv-setup/scripts/setup-containers.sh | bash
```

## Configuration

Set environment variables before running:

```bash
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
- Admin/sudo access for some components

## License

MIT