#!/bin/bash

# Core Development Tools Setup
# Installs essential development tools and utilities

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠️${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ️${NC} $1"; }

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Darwin*) OS_TYPE="macos";;
    Linux*) OS_TYPE="linux";;
    *) print_error "Unsupported OS: ${OS}"; exit 1;;
esac

echo ""
echo -e "${BLUE}📦 Core Development Tools Setup${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# macOS setup
if [ "$OS_TYPE" = "macos" ]; then
    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    print_info "Installing core tools via Homebrew..."
    
    # Core tools
    tools=(
        "git"
        "gh"           # GitHub CLI
        "jq"           # JSON processor
        "wget"
        "tree"
        "htop"
        "tmux"
        "ripgrep"      # Better grep
        "fd"           # Better find
        "bat"          # Better cat
        "exa"          # Better ls
        "fzf"          # Fuzzy finder
    )
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            print_status "$tool already installed"
        else
            print_info "Installing $tool..."
            brew install "$tool"
        fi
    done
    
    # Install useful casks
    casks=(
        "visual-studio-code"
        "iterm2"
        "rectangle"    # Window management
    )
    
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            print_status "$cask already installed"
        else
            print_info "Installing $cask..."
            brew install --cask "$cask"
        fi
    done
fi

# Linux setup
if [ "$OS_TYPE" = "linux" ]; then
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        PKG_MGR="apt-get"
        PKG_UPDATE="sudo apt-get update"
        PKG_INSTALL="sudo apt-get install -y"
    elif command -v yum &> /dev/null; then
        PKG_MGR="yum"
        PKG_UPDATE="sudo yum check-update"
        PKG_INSTALL="sudo yum install -y"
    else
        print_error "No supported package manager found"
        exit 1
    fi
    
    print_info "Updating package lists..."
    $PKG_UPDATE || true
    
    print_info "Installing core tools..."
    
    # Core tools for Linux
    tools=(
        "git"
        "curl"
        "wget"
        "jq"
        "htop"
        "tmux"
        "tree"
        "build-essential"
        "software-properties-common"
    )
    
    for tool in "${tools[@]}"; do
        print_info "Installing $tool..."
        $PKG_INSTALL "$tool"
    done
    
    # Install GitHub CLI
    if ! command -v gh &> /dev/null; then
        print_info "Installing GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
    fi
    
    # Install ripgrep
    if ! command -v rg &> /dev/null; then
        print_info "Installing ripgrep..."
        curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
        sudo dpkg -i ripgrep_13.0.0_amd64.deb
        rm ripgrep_13.0.0_amd64.deb
    fi
fi

# Configure git (if not already configured)
if [ -z "$(git config --global user.name)" ]; then
    print_info "Git user name not configured"
    read -p "Enter your name for git commits: " git_name
    git config --global user.name "$git_name"
fi

if [ -z "$(git config --global user.email)" ]; then
    print_info "Git email not configured"
    read -p "Enter your email for git commits: " git_email
    git config --global user.email "$git_email"
fi

# Setup useful git aliases
print_info "Setting up git aliases..."
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Create common directories
print_info "Creating common development directories..."
mkdir -p ~/Development
mkdir -p ~/Scripts
mkdir -p ~/.config

print_status "Core development tools setup complete!"
echo ""
echo "Installed tools:"
echo "  • Git with useful aliases"
echo "  • GitHub CLI (gh)"
echo "  • JSON processor (jq)"
echo "  • Enhanced terminal tools"
if [ "$OS_TYPE" = "macos" ]; then
    echo "  • VS Code"
    echo "  • iTerm2"
fi