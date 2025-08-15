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
        
        # Always use non-interactive mode to avoid TTY issues
        print_info "Running Homebrew installation in non-interactive mode"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        print_status "Homebrew already installed"
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
        "neovim"       # Neovim editor
        "ripgrep"      # Better grep
        "fd"           # Better find
        "bat"          # Better cat
        "exa"          # Better ls
        "fzf"          # Fuzzy finder
        "lazygit"      # Terminal UI for git
        "delta"        # Better git diff
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
        "ghostty"      # Modern terminal
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
    # Read input from /dev/tty if stdin is piped
    if [ ! -t 0 ]; then
        if read -p "Enter your name for git commits: " git_name </dev/tty 2>/dev/null; then
            :
        else
            print_warning "No TTY available, skipping git name configuration"
            return 0
        fi
    else
        read -p "Enter your name for git commits: " git_name
    fi
    git config --global user.name "$git_name"
fi

if [ -z "$(git config --global user.email)" ]; then
    print_info "Git email not configured"
    # Read input from /dev/tty if stdin is piped
    if [ ! -t 0 ]; then
        if read -p "Enter your email for git commits: " git_email </dev/tty 2>/dev/null; then
            :
        else
            print_warning "No TTY available, skipping git email configuration"
            return 0
        fi
    else
        read -p "Enter your email for git commits: " git_email
    fi
    git config --global user.email "$git_email"
fi

# Install specific Nerd Fonts
install_nerd_fonts() {
    print_info "Installing specific Nerd Fonts via Homebrew..."
    
    # Tap the fonts cask if not already tapped
    if ! brew tap | grep -q "homebrew/cask-fonts"; then
        print_info "Adding Homebrew font repository..."
        brew tap homebrew/cask-fonts
    fi
    
    # Define Nerd Font casks to install
    local nerd_fonts=(
        "font-open-dyslexic-nerd-font"
        "font-jetbrains-mono-nerd-font"
        "font-hack-nerd-font"
        "font-symbols-only-nerd-font"
        "font-code-new-roman-nerd-font"
    )
    
    for font in "${nerd_fonts[@]}"; do
        if brew list --cask "$font" &>/dev/null 2>&1; then
            print_status "$font already installed"
        else
            print_info "Installing $font..."
            if brew install --cask "$font" 2>/dev/null; then
                print_status "$font installed successfully"
            else
                print_warning "Failed to install $font (may not be available)"
            fi
        fi
    done
    
    print_status "Nerd Fonts installation complete"
}

# Setup useful git aliases
print_info "Setting up git aliases..."
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Configure Ghostty terminal with OpenDyslexic font
configure_ghostty() {
    print_info "Configuring Ghostty terminal..."
    
    # Create Ghostty config directory
    local ghostty_config_dir="$HOME/.config/ghostty"
    local ghostty_config_file="$ghostty_config_dir/config"
    
    mkdir -p "$ghostty_config_dir"
    
    # Check if config already exists
    if [ -f "$ghostty_config_file" ]; then
        # Backup existing config
        cp "$ghostty_config_file" "$ghostty_config_file.backup"
        print_info "Existing Ghostty config backed up to config.backup"
    fi
    
    # Create Ghostty configuration with OpenDyslexic font
    cat > "$ghostty_config_file" << 'EOF'
# Ghostty Configuration

# Font Configuration - OpenDyslexic for better readability
font-family = "OpenDyslexicM Nerd Font"
font-size = 14

# Fallback fonts in case OpenDyslexic isn't available
font-family-bold = "OpenDyslexicM Nerd Font Bold"
font-family-italic = "OpenDyslexicM Nerd Font Italic"
font-family-bold-italic = "OpenDyslexicM Nerd Font Bold Italic"

# Alternative font stack (will fall back if OpenDyslexic not found)
# You can uncomment these if you prefer a different font:
# font-family = "JetBrainsMono Nerd Font"
# font-family = "Hack Nerd Font"

# Window Configuration
window-decoration = true
window-padding-x = 10
window-padding-y = 10

# Theme Configuration (optional - add your preferred theme)
# theme = "dark"

# Performance
gpu-renderer = auto

# Cursor
cursor-style = block
cursor-blink = true

# Scrollback
scrollback-limit = 10000

# Bell
audible-bell = false
visual-bell = true

# MacOS specific settings
macos-option-as-alt = true
EOF
    
    print_status "Ghostty configured with OpenDyslexic font as default"
    print_info "Configuration file: $ghostty_config_file"
}

# Configure VS Code extensions and settings
configure_vscode() {
    if ! command -v code &> /dev/null; then
        print_warning "VS Code not found, skipping extension installation"
        return
    fi
    
    print_info "Installing VS Code extensions..."
    
    # Essential extensions
    local extensions=(
        # Claude Code
        "Anthropic.claude-dev"
        
        # Python development
        "ms-python.python"
        "ms-python.black-formatter"
        "ms-python.pylint"
        "ms-python.isort"
        "ms-toolsai.jupyter"
        "ms-toolsai.vscode-jupyter-cell-tags"
        "ms-toolsai.vscode-jupyter-slideshow"
        
        # Node.js/JavaScript development
        "ms-vscode.vscode-typescript-next"
        "bradlc.vscode-tailwindcss"
        "esbenp.prettier-vscode"
        "dbaeumer.vscode-eslint"
        "ms-vscode.vscode-json"
        "formulahendry.auto-rename-tag"
        "christian-kohler.path-intellisense"
        
        # General development
        "ms-vscode.vscode-git-graph"
        "eamodio.gitlens"
        "ms-vsliveshare.vsliveshare"
        "ms-vscode-remote.remote-containers"
        "ms-vscode-remote.remote-ssh"
        "ms-vscode-remote.remote-wsl"
        
        # Productivity
        "ms-vscode.vscode-todo-highlight"
        "streetsidesoftware.code-spell-checker"
        "ms-vscode.theme-github-plus"
    )
    
    for extension in "${extensions[@]}"; do
        print_info "Installing $extension..."
        if code --install-extension "$extension" --force &>/dev/null; then
            print_status "$extension installed"
        else
            print_warning "Failed to install $extension"
        fi
    done
    
    print_status "VS Code extensions installation complete"
}


# Configure VS Code to use Ghostty as integrated terminal
configure_vscode_terminal_default() {
    local vscode_settings_dir="$HOME/Library/Application Support/Code/User"
    local settings_file="$vscode_settings_dir/settings.json"
    
    mkdir -p "$vscode_settings_dir"
    
    # Check if Ghostty is installed
    local ghostty_path="/Applications/Ghostty.app/Contents/MacOS/ghostty"
    local use_ghostty=false
    
    if [ -f "$ghostty_path" ]; then
        use_ghostty=true
        print_info "Ghostty found, configuring as VS Code default terminal"
    else
        print_warning "Ghostty not found, using default terminal configuration"
    fi
    
    # Backup existing settings if they exist
    if [ -f "$settings_file" ]; then
        cp "$settings_file" "$settings_file.backup"
        print_info "Existing VS Code settings backed up to settings.json.backup"
    fi
    
    # Create VS Code settings with conditional Ghostty configuration
    if [ "$use_ghostty" = true ]; then
        cat > "$settings_file" << 'EOF'
{
    "terminal.integrated.defaultProfile.osx": "ghostty",
    "terminal.integrated.profiles.osx": {
        "ghostty": {
            "path": "/Applications/Ghostty.app/Contents/MacOS/ghostty",
            "args": [],
            "icon": "terminal"
        },
        "zsh": {
            "path": "zsh",
            "args": ["-l"],
            "icon": "terminal-bash"
        },
        "bash": {
            "path": "bash",
            "args": ["-l"],
            "icon": "terminal-bash"
        }
    },
    "terminal.external.osxExec": "Ghostty.app",
    "python.defaultInterpreterPath": "python",
    "python.formatting.provider": "black",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "files.associations": {
        "*.json": "jsonc"
    },
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "workbench.startupEditor": "welcomePageInEmptyWorkbench"
}
EOF
    else
        # Fallback configuration without Ghostty
        cat > "$settings_file" << 'EOF'
{
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.profiles.osx": {
        "zsh": {
            "path": "zsh",
            "args": ["-l"],
            "icon": "terminal-bash"
        },
        "bash": {
            "path": "bash",
            "args": ["-l"],
            "icon": "terminal-bash"
        }
    },
    "python.defaultInterpreterPath": "python",
    "python.formatting.provider": "black",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "files.associations": {
        "*.json": "jsonc"
    },
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "workbench.startupEditor": "welcomePageInEmptyWorkbench"
}
EOF
    fi
    
    print_status "VS Code terminal configuration complete"
}

# Install specific Nerd Fonts (macOS only)
if [ "$OS_TYPE" = "macos" ]; then
    install_nerd_fonts
    # Configure Ghostty after fonts are installed
    configure_ghostty
fi

# Configure VS Code
configure_vscode

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
echo "  • Enhanced terminal tools (ripgrep, fd, bat, exa, fzf, lazygit, delta)"
echo "  • Neovim editor"
if [ "$OS_TYPE" = "macos" ]; then
    echo "  • VS Code with extensions:"
    echo "    - Claude Code (Anthropic.claude-dev)"
    echo "    - Python development (Python, Black, Pylint, Jupyter)"
    echo "    - Node.js development (TypeScript, Prettier, ESLint, Tailwind)"
    echo "    - Git tools (GitLens, Git Graph)"
    echo "    - Remote development (Containers, SSH)"
    echo "  • Ghostty terminal (OpenDyslexic font configured, VS Code integrated)"
    echo "  • Rectangle (window management)"
    echo "  • Specific Nerd Fonts (OpenDyslexic, JetBrains Mono, Hack, CodeNewRoman, Symbols)"
fi
echo ""
echo "Next steps:"
echo "  • Restart your terminal to use new tools"
if [ "$OS_TYPE" = "macos" ]; then
    echo "  • Open VS Code - Ghostty is configured as the integrated terminal"
    echo ""
    echo "🚀 Ghostty Terminal Features:"
    echo "  • Quick Terminal: Press ⌘ + \` (Command + Backtick) for instant access"
    echo "  • Right-click context menu: 'Services > New Ghostty Tab/Window here'"
    echo "  • Configuration: ~/.config/ghostty/config (OpenDyslexic font preconfigured)"
    echo "  • Font: OpenDyslexic Nerd Font for improved readability"
    echo ""
    echo "📝 To set Ghostty as your system-wide default terminal (optional):"
    echo "  • Currently requires manual setup - no automated way available"
    echo "  • Use Ghostty's Services menu integration for most terminal tasks"
    echo "  • VS Code integration is already configured automatically"
fi