#!/bin/bash

# Developer Environment Setup - Consolidated Installer
# Usage: curl -fsSL https://peek-tech.github.io/devenv-setup/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
VERSION="2.0.0"

# Helper functions
print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           Developer Environment Setup v${VERSION}           ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

print_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
        OS_TYPE="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        OS_TYPE="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
        else
            DISTRO="unknown"
        fi
    else
        OS="unsupported"
        DISTRO="unknown"
        OS_TYPE="unsupported"
    fi
}

# Check prerequisites
check_prerequisites() {
    local missing_tools=()
    
    # Check for required tools
    command -v curl &> /dev/null || missing_tools+=("curl")
    command -v git &> /dev/null || missing_tools+=("git")
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_info "Please install them first and run this script again."
        exit 1
    fi
}

# Request sudo access upfront for macOS installations
request_sudo() {
    if [[ "$OS_TYPE" == "macos" ]]; then
        print_info "This installer requires sudo access for Homebrew installation"
        print_info "Please enter your password when prompted"
        
        if ! sudo -v; then
            print_error "Sudo access is required for installation"
            print_info "Please run with appropriate permissions or contact your system administrator"
            exit 1
        fi
        
        print_status "Sudo access granted"
    fi
}

# Detect user's shell and return appropriate config file
get_shell_config_file() {
    local user_shell="$(basename "$SHELL")"
    local config_file=""
    
    case "$user_shell" in
        zsh)
            if [ "$OS_TYPE" = "macos" ]; then
                config_file="$HOME/.zprofile"
            else
                config_file="$HOME/.zshrc"
            fi
            ;;
        bash)
            if [ "$OS_TYPE" = "macos" ]; then
                config_file="$HOME/.bash_profile"
            else
                config_file="$HOME/.bashrc"
            fi
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            ;;
        csh|tcsh)
            config_file="$HOME/.cshrc"
            ;;
        ksh)
            config_file="$HOME/.kshrc"
            ;;
        *)
            # Default fallback
            if [ "$OS_TYPE" = "macos" ]; then
                config_file="$HOME/.profile"
            else
                config_file="$HOME/.bashrc"
            fi
            ;;
    esac
    
    echo "$config_file"
}

# Add content to shell config with shell-specific syntax
add_to_shell_config() {
    local content="$1"
    local description="$2"
    local user_shell="$(basename "$SHELL")"
    local config_file="$(get_shell_config_file)"
    
    if [ -z "$config_file" ]; then
        print_warning "Could not determine shell configuration file for $user_shell"
        return 1
    fi
    
    # Create config file if it doesn't exist
    mkdir -p "$(dirname "$config_file")"
    touch "$config_file"
    
    # Check if content already exists
    if grep -q "$description" "$config_file" 2>/dev/null; then
        print_status "$description already configured in $config_file"
        return 0
    fi
    
    print_info "Adding $description to $config_file..."
    
    # Add shell-specific content
    case "$user_shell" in
        fish)
            # Fish shell has different syntax
            echo "" >> "$config_file"
            echo "# $description" >> "$config_file"
            # Convert bash syntax to fish syntax if needed
            echo "$content" | sed 's/export \([^=]*\)=\(.*\)/set -gx \1 \2/' >> "$config_file"
            ;;
        csh|tcsh)
            # C shell syntax
            echo "" >> "$config_file"
            echo "# $description" >> "$config_file"
            echo "$content" | sed 's/export \([^=]*\)=\(.*\)/setenv \1 \2/' >> "$config_file"
            ;;
        *)
            # POSIX-compatible shells (bash, zsh, ksh, etc.)
            echo "" >> "$config_file"
            echo "# $description" >> "$config_file"
            echo "$content" >> "$config_file"
            ;;
    esac
    
    print_status "$description added to $config_file"
}

# Refresh environment to make newly installed tools available
refresh_environment() {
    local user_shell="$(basename "$SHELL")"
    local config_file="$(get_shell_config_file)"
    
    # Source common shell configuration files to pick up PATH changes
    if [ "$OS_TYPE" = "macos" ]; then
        # Source Homebrew environment for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]] && [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        # Source profile files based on shell
        case "$user_shell" in
            zsh)
                [ -f ~/.zprofile ] && source ~/.zprofile 2>/dev/null || true
                [ -f ~/.zshrc ] && source ~/.zshrc 2>/dev/null || true
                ;;
            bash)
                [ -f ~/.bash_profile ] && source ~/.bash_profile 2>/dev/null || true
                [ -f ~/.bashrc ] && source ~/.bashrc 2>/dev/null || true
                ;;
            fish)
                # Fish doesn't use traditional sourcing
                ;;
            *)
                [ -f ~/.profile ] && source ~/.profile 2>/dev/null || true
                ;;
        esac
    else
        # Linux - source based on shell
        case "$user_shell" in
            zsh)
                [ -f ~/.zshrc ] && source ~/.zshrc 2>/dev/null || true
                ;;
            bash)
                [ -f ~/.bashrc ] && source ~/.bashrc 2>/dev/null || true
                ;;
            fish)
                # Fish doesn't use traditional sourcing
                ;;
            *)
                [ -f ~/.profile ] && source ~/.profile 2>/dev/null || true
                ;;
        esac
    fi
    
    # Refresh PATH for local bin
    export PATH="$HOME/.local/bin:$PATH"
    
    # Source pyenv if available
    if [ -d "$HOME/.pyenv" ]; then
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        command -v pyenv >/dev/null && eval "$(pyenv init -)" 2>/dev/null || true
    fi
    
    # Source nvm if available
    if [ -d "$HOME/.nvm" ]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
    fi
    
    # Source bun if available
    if [ -d "$HOME/.bun" ]; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    fi
}

#=============================================================================
# CORE DEVELOPMENT TOOLS INSTALLATION
#=============================================================================

install_core_tools() {
    print_section "Installing Core Development Tools"
    
    if [ "$OS_TYPE" = "macos" ]; then
        install_homebrew
        refresh_environment
        install_macos_core_tools
        install_nerd_fonts
        configure_ghostty
        configure_vscode
        configure_vscode_terminal_default
    else
        install_linux_core_tools
    fi
    
    configure_git
    setup_git_aliases
    create_development_directories
    
    print_status "Core development tools installation complete!"
}

install_homebrew() {
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
}

install_macos_core_tools() {
    print_info "Installing core tools via Homebrew..."
    
    # Core tools
    local tools=(
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
    local casks=(
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
}

install_linux_core_tools() {
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
        return 1
    fi
    
    print_info "Updating package lists..."
    $PKG_UPDATE || true
    
    print_info "Installing core tools..."
    
    # Core tools for Linux
    local tools=(
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
}

configure_git() {
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
}

install_nerd_fonts() {
    if [ "$OS_TYPE" != "macos" ]; then
        return 0
    fi
    
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

setup_git_aliases() {
    print_info "Setting up git aliases..."
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
}

configure_ghostty() {
    if [ "$OS_TYPE" != "macos" ]; then
        return 0
    fi
    
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

configure_vscode_terminal_default() {
    if [ "$OS_TYPE" != "macos" ]; then
        return 0
    fi
    
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

create_development_directories() {
    print_info "Creating common development directories..."
    mkdir -p ~/Development
    mkdir -p ~/Scripts
    mkdir -p ~/.config
}

#=============================================================================
# PROGRAMMING LANGUAGES INSTALLATION
#=============================================================================

install_programming_languages() {
    print_section "Installing Programming Languages"
    
    install_pyenv
    refresh_environment
    install_nvm
    refresh_environment
    install_go
    refresh_environment
    install_bun
    refresh_environment
    setup_language_directories
    
    # Install specific language versions
    print_info "Installing specific language versions..."
    install_python_versions  # Python 3.11 as default
    install_node_versions    # Node.js 20, 22 with 20 as default
    
    print_status "Programming languages installation complete!"
}

install_pyenv() {
    if command -v pyenv &> /dev/null; then
        print_status "pyenv already installed: $(pyenv --version)"
        return 0
    fi
    
    print_info "Installing pyenv..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew install pyenv
                
                # Install Python build dependencies
                brew install openssl readline sqlite3 xz zlib tcl-tk
            else
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        linux)
            # Install dependencies first
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
                    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
                    libffi-dev liblzma-dev
            elif command -v yum &> /dev/null; then
                sudo yum groupinstall -y "Development Tools"
                sudo yum install -y zlib-devel bzip2 bzip2-devel readline-devel sqlite \
                    sqlite-devel openssl-devel tk-devel libffi-devel xz-devel
            fi
            
            # Install pyenv using installer
            curl https://pyenv.run | bash
            ;;
    esac
    
    # Add to shell configuration
    add_pyenv_to_shell
    
    print_status "pyenv installed successfully"
}

add_pyenv_to_shell() {
    local user_shell="$(basename "$SHELL")"
    local pyenv_config
    
    case "$user_shell" in
        fish)
            pyenv_config='set -gx PYENV_ROOT "$HOME/.pyenv"
fish_add_path "$PYENV_ROOT/bin"
pyenv init - | source'
            ;;
        csh|tcsh)
            pyenv_config='setenv PYENV_ROOT "$HOME/.pyenv"
setenv PATH "$PYENV_ROOT/bin:$PATH"
eval "`pyenv init -`"'
            ;;
        *)
            pyenv_config='export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"'
            ;;
    esac
    
    add_to_shell_config "$pyenv_config" "pyenv"
    
    # Source for current session (only works for POSIX shells)
    if [[ "$user_shell" != "fish" && "$user_shell" != "csh" && "$user_shell" != "tcsh" ]]; then
        export PYENV_ROOT="$HOME/.pyenv"
        command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)" 2>/dev/null || true
    fi
}

install_nvm() {
    if [ -d "$HOME/.nvm" ] || command -v nvm &> /dev/null; then
        print_status "nvm already installed"
        return 0
    fi
    
    print_info "Installing nvm..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew install nvm
                # Create nvm directory for Homebrew version
                mkdir -p ~/.nvm
            else
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        linux)
            # Download and install nvm
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
            ;;
    esac
    
    # Source nvm for current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    print_status "nvm installed successfully"
}

install_go() {
    if command -v go &> /dev/null; then
        print_status "Go already installed: $(go version)"
        return 0
    fi
    
    print_info "Installing Go..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew install go
            else
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        linux)
            # Get latest Go version
            GO_VERSION=$(curl -s https://go.dev/VERSION?m=text)
            GO_TARBALL="${GO_VERSION}.linux-amd64.tar.gz"
            
            print_info "Downloading Go ${GO_VERSION}..."
            wget "https://go.dev/dl/${GO_TARBALL}" -O "/tmp/${GO_TARBALL}"
            
            # Remove existing Go installation
            sudo rm -rf /usr/local/go
            
            # Extract new Go
            sudo tar -C /usr/local -xzf "/tmp/${GO_TARBALL}"
            rm "/tmp/${GO_TARBALL}"
            
            # Add to PATH
            add_go_to_shell
            ;;
    esac
    
    print_status "Go installed successfully"
}

add_go_to_shell() {
    local user_shell="$(basename "$SHELL")"
    local go_config
    
    case "$user_shell" in
        fish)
            go_config='fish_add_path "/usr/local/go/bin"
set -gx GOPATH "$HOME/go"
fish_add_path "$GOPATH/bin"'
            ;;
        csh|tcsh)
            go_config='setenv PATH "$PATH:/usr/local/go/bin"
setenv GOPATH "$HOME/go"
setenv PATH "$PATH:$GOPATH/bin"'
            ;;
        *)
            go_config='export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin'
            ;;
    esac
    
    add_to_shell_config "$go_config" "Go"
    
    # Source for current session (only works for POSIX shells)
    if [[ "$user_shell" != "fish" && "$user_shell" != "csh" && "$user_shell" != "tcsh" ]]; then
        export PATH=$PATH:/usr/local/go/bin
        export GOPATH=$HOME/go
        export PATH=$PATH:$GOPATH/bin
    fi
}

install_python_versions() {
    if ! command -v pyenv &> /dev/null; then
        print_warning "pyenv not available, skipping Python version installation"
        return
    fi
    
    print_info "Installing Python 3.11..."
    
    # Install Python 3.11 (latest patch version)
    local python_version="3.11.10"
    
    if pyenv versions | grep -q "$python_version"; then
        print_status "Python $python_version already installed"
    else
        print_info "Installing Python $python_version..."
        pyenv install "$python_version"
    fi
    
    # Set Python 3.11 as global default
    pyenv global "$python_version"
    print_status "Set Python $python_version as system default"
    
    # Install Poetry for dependency management
    install_poetry
}

install_poetry() {
    if command -v poetry &> /dev/null; then
        print_status "Poetry already installed: $(poetry --version)"
        return 0
    fi
    
    print_info "Installing Poetry..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew install poetry
            else
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        linux)
            # Install Poetry using the official installer
            curl -sSL https://install.python-poetry.org | python3 -
            # Add Poetry to PATH
            add_poetry_to_shell
            ;;
    esac
    
    print_status "Poetry installed successfully"
}

add_poetry_to_shell() {
    local user_shell="$(basename "$SHELL")"
    local poetry_config
    
    case "$user_shell" in
        fish)
            poetry_config='fish_add_path "$HOME/.local/bin"'
            ;;
        csh|tcsh)
            poetry_config='setenv PATH "$HOME/.local/bin:$PATH"'
            ;;
        *)
            poetry_config='export PATH="$HOME/.local/bin:$PATH"'
            ;;
    esac
    
    add_to_shell_config "$poetry_config" "Poetry"
    
    # Source for current session (only works for POSIX shells)
    if [[ "$user_shell" != "fish" && "$user_shell" != "csh" && "$user_shell" != "tcsh" ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

install_node_versions() {
    # Source nvm if available
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    if ! command -v nvm &> /dev/null; then
        print_warning "nvm not available, skipping Node.js version installation"
        return
    fi
    
    print_info "Installing Node.js versions..."
    
    # Install specific Node.js versions
    local node_versions=("20" "22")
    
    for version in "${node_versions[@]}"; do
        if nvm list | grep -q "v$version"; then
            print_status "Node.js $version already installed"
        else
            print_info "Installing Node.js $version..."
            nvm install "$version"
        fi
    done
    
    # Set Node.js 20 as default
    nvm use 20
    nvm alias default 20
    print_status "Set Node.js 20 as system default"
    
    # Install Yarn for dependency management
    install_yarn
}

install_yarn() {
    # Make sure we're using the default Node.js version
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm use default 2>/dev/null || true
    
    if command -v yarn &> /dev/null; then
        print_status "Yarn already installed: $(yarn --version)"
        return 0
    fi
    
    print_info "Installing Yarn..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew install yarn
            else
                # Install via npm as fallback
                npm install -g yarn
            fi
            ;;
        linux)
            # Install via npm
            npm install -g yarn
            ;;
    esac
    
    print_status "Yarn installed successfully"
}

install_bun() {
    if command -v bun &> /dev/null; then
        print_status "Bun already installed: $(bun --version)"
        return 0
    fi
    
    print_info "Installing Bun..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew tap oven-sh/bun
                brew install bun
            else
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        linux)
            # Install Bun using the official installer
            curl -fsSL https://bun.sh/install | bash
            # Source bun for current session
            export BUN_INSTALL="$HOME/.bun"
            export PATH="$BUN_INSTALL/bin:$PATH"
            # Add to shell configuration
            add_bun_to_shell
            ;;
    esac
    
    print_status "Bun installed successfully"
}

add_bun_to_shell() {
    local user_shell="$(basename "$SHELL")"
    local bun_config
    
    case "$user_shell" in
        fish)
            bun_config='set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"'
            ;;
        csh|tcsh)
            bun_config='setenv BUN_INSTALL "$HOME/.bun"
setenv PATH "$BUN_INSTALL/bin:$PATH"'
            ;;
        *)
            bun_config='export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"'
            ;;
    esac
    
    add_to_shell_config "$bun_config" "Bun"
    
    # Source for current session (only works for POSIX shells)
    if [[ "$user_shell" != "fish" && "$user_shell" != "csh" && "$user_shell" != "tcsh" ]]; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    fi
}

setup_language_directories() {
    print_info "Creating language development directories..."
    
    mkdir -p ~/Development/python
    mkdir -p ~/Development/javascript
    mkdir -p ~/Development/go
    
    # Create Go workspace
    mkdir -p ~/go/{bin,src,pkg}
    
    print_status "Development directories created"
}

#=============================================================================
# WEB BROWSERS INSTALLATION
#=============================================================================

install_web_browsers() {
    print_section "Installing Web Browsers"
    
    if [[ "$OS_TYPE" != "macos" ]]; then
        print_error "Browser installation is designed for macOS only"
        return 1
    fi
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew not found. Please install core tools first."
        return 1
    fi
    
    # Browser casks to install
    local browsers=(
        "google-chrome:Google Chrome"
        "firefox:Mozilla Firefox"
        "microsoft-edge:Microsoft Edge"
        "brave-browser:Brave Browser"
        "arc:Arc Browser"
    )
    
    print_info "Available browsers to install:"
    echo ""
    for i in "${!browsers[@]}"; do
        IFS=':' read -r cask name <<< "${browsers[$i]}"
        echo "  $((i+1))) $name"
    done
    echo "  0) Install all browsers"
    echo ""
    
    # Read input from /dev/tty if stdin is piped
    if [ ! -t 0 ]; then
        if read -p "Select browsers to install (e.g., 1 3 4 or 0 for all): " -a selections </dev/tty 2>/dev/null; then
            :
        else
            print_warning "No TTY available, installing all browsers by default"
            selections=("0")
        fi
    else
        read -p "Select browsers to install (e.g., 1 3 4 or 0 for all): " -a selections
    fi
    
    if [[ "${selections[0]}" == "0" ]]; then
        # Install all browsers
        print_info "Installing all browsers..."
        for browser_info in "${browsers[@]}"; do
            IFS=':' read -r cask name <<< "$browser_info"
            install_browser_app "$cask" "$name"
        done
    else
        # Install selected browsers
        for selection in "${selections[@]}"; do
            if [[ $selection -ge 1 && $selection -le ${#browsers[@]} ]]; then
                IFS=':' read -r cask name <<< "${browsers[$((selection-1))]}"
                install_browser_app "$cask" "$name"
            else
                print_warning "Invalid selection: $selection"
            fi
        done
    fi
    
    # Install browser development tools
    install_browser_dev_tools
    
    print_status "Browser installation complete!"
}

install_browser_app() {
    local cask="$1"
    local name="$2"
    
    if brew list --cask "$cask" &>/dev/null; then
        print_status "$name already installed"
    else
        print_info "Installing $name..."
        if brew install --cask "$cask"; then
            print_status "$name installed successfully"
        else
            print_warning "Failed to install $name"
        fi
    fi
}

install_browser_dev_tools() {
    print_info "Installing browser development tools..."
    
    local dev_tools=(
        "chromedriver:ChromeDriver for Selenium"
        "geckodriver:GeckoDriver for Firefox"
    )
    
    for tool_info in "${dev_tools[@]}"; do
        IFS=':' read -r formula name <<< "$tool_info"
        
        if brew list "$formula" &>/dev/null; then
            print_status "$name already installed"
        else
            print_info "Installing $name..."
            if brew install "$formula"; then
                print_status "$name installed successfully"
            else
                print_warning "Failed to install $name"
            fi
        fi
    done
}

#=============================================================================
# DESIGN TOOLS INSTALLATION
#=============================================================================

install_design_tools() {
    print_section "Installing Design and Creative Tools"
    
    if [[ "$OS_TYPE" != "macos" ]]; then
        print_error "Design tools installation is designed for macOS only"
        return 1
    fi
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew not found. Please install core tools first."
        return 1
    fi
    
    # Design applications
    local design_apps=(
        "figma:Figma (UI/UX Design)"
    )
    
    # Development design tools (currently empty but preserved for structure)
    local dev_design_tools=(
        
    )
    
    print_info "Available design applications:"
    echo ""
    for i in "${!design_apps[@]}"; do
        IFS=':' read -r cask name <<< "${design_apps[$i]}"
        echo "  $((i+1))) $name"
    done
    echo ""
    
    print_info "Available development design tools:"
    echo ""
    for i in "${!dev_design_tools[@]}"; do
        IFS=':' read -r cask name <<< "${dev_design_tools[$i]}"
        echo "  $((i+${#design_apps[@]}+1))) $name"
    done
    echo ""
    echo "  0) Install essential design tools (Figma + dev tools)"
    echo ""
    
    # Read input from /dev/tty if stdin is piped
    if [ ! -t 0 ]; then
        if read -p "Select tools to install (e.g., 1 3 4 or 0 for essentials): " -a selections </dev/tty 2>/dev/null; then
            :
        else
            print_warning "No TTY available, installing essential design tools by default"
            selections=("0")
        fi
    else
        read -p "Select tools to install (e.g., 1 3 4 or 0 for essentials): " -a selections
    fi
    
    if [[ "${selections[0]}" == "0" ]]; then
        # Install essential design tools
        print_info "Installing essential design tools..."
        
        # Essential apps
        install_design_app "figma" "Figma"
        
        # All dev design tools
        for tool_info in "${dev_design_tools[@]}"; do
            IFS=':' read -r cask name <<< "$tool_info"
            install_design_app "$cask" "$name"
        done
    else
        # Install selected tools
        local total_apps=$((${#design_apps[@]} + ${#dev_design_tools[@]}))
        
        for selection in "${selections[@]}"; do
            if [[ $selection -ge 1 && $selection -le ${#design_apps[@]} ]]; then
                # Design app selection
                IFS=':' read -r cask name <<< "${design_apps[$((selection-1))]}"
                install_design_app "$cask" "$name"
            elif [[ $selection -gt ${#design_apps[@]} && $selection -le $total_apps ]]; then
                # Dev tool selection
                local index=$((selection - ${#design_apps[@]} - 1))
                IFS=':' read -r cask name <<< "${dev_design_tools[$index]}"
                install_design_app "$cask" "$name"
            else
                print_warning "Invalid selection: $selection"
            fi
        done
    fi
    
    # Install command-line design tools
    install_design_cli_tools
    
    # Install fonts
    install_design_fonts
    
    print_status "Design and creative tools installation complete!"
}

install_design_app() {
    local cask="$1"
    local name="$2"
    
    if brew list --cask "$cask" &>/dev/null 2>&1; then
        print_status "$name already installed"
    else
        print_info "Installing $name..."
        if brew install --cask "$cask" 2>/dev/null; then
            print_status "$name installed successfully"
        else
            print_warning "Failed to install $name (may not be available or require payment)"
        fi
    fi
}

install_design_cli_tools() {
    print_info "Installing command-line design tools..."
    
    local cli_tools=(
        "imagemagick:ImageMagick (Image Processing)"
        "graphicsmagick:GraphicsMagick (Image Processing)"
        "optipng:OptiPNG (PNG Optimization)"
        "jpegoptim:JPEG Optimization"
        "ffmpeg:FFmpeg (Video/Audio Processing)"
    )
    
    for tool_info in "${cli_tools[@]}"; do
        IFS=':' read -r formula name <<< "$tool_info"
        
        if brew list "$formula" &>/dev/null 2>&1; then
            print_status "$name already installed"
        else
            print_info "Installing $name..."
            if brew install "$formula"; then
                print_status "$name installed successfully"
            else
                print_warning "Failed to install $name"
            fi
        fi
    done
}

install_design_fonts() {
    print_info "Installing developer-friendly fonts..."
    
    local fonts=(
        "font-fira-code"
        "font-source-code-pro"
        "font-cascadia-code"
        "font-inter"
    )
    
    # Tap font cask if not already tapped
    if ! brew tap | grep -q "homebrew/cask-fonts"; then
        print_info "Adding Homebrew font repository..."
        brew tap homebrew/cask-fonts
    fi
    
    for font in "${fonts[@]}"; do
        if brew list --cask "$font" &>/dev/null 2>&1; then
            print_status "$font already installed"
        else
            print_info "Installing $font..."
            if brew install --cask "$font"; then
                print_status "$font installed successfully"
            else
                print_warning "Failed to install $font"
            fi
        fi
    done
}

#=============================================================================
# CLAUDE CODE INSTALLATION
#=============================================================================

install_claude_code() {
    print_section "Installing Claude Code and Agent Orchestration"
    
    # Configuration
    local AGENTS_REPO="https://github.com/peek-tech/claude_code_config.git"
    
    # Install Claude applications
    install_claude_applications
    
    # Setup agent orchestration
    setup_claude_agents "$AGENTS_REPO"
    
    print_status "Claude Code installation complete!"
}

install_claude_applications() {
    print_info "Installing Claude applications..."
    
    case "${OS_TYPE}" in
        macos)
            print_info "Detected macOS"
            if ! command -v brew &> /dev/null; then
                print_error "Homebrew not found. Please install core tools first."
                return 1
            fi
            
            # Install Claude desktop app (chat interface)
            print_info "Installing Claude desktop app..."
            if brew list --cask claude &>/dev/null 2>&1; then
                print_status "Claude desktop app already installed"
            else
                if brew install --cask claude 2>/dev/null; then
                    print_status "Claude desktop app installed successfully"
                else
                    print_warning "Claude desktop app not available via Homebrew cask"
                    print_info "You can download it manually from https://claude.ai"
                fi
            fi
            
            # Install Claude Code CLI
            install_claude_cli_macos
            ;;
        linux)
            print_info "Detected Linux"
            install_claude_cli_linux
            
            # Desktop app for Linux
            print_info "For Claude desktop app, please visit https://claude.ai in your browser"
            ;;
        *)
            print_error "Unsupported operating system: ${OS_TYPE}"
            return 1
            ;;
    esac
}

install_claude_cli_macos() {
    print_info "Installing Claude Code CLI..."
    if command -v claude &> /dev/null; then
        print_status "Claude Code CLI already installed: $(claude --version 2>/dev/null || echo 'version unknown')"
    else
        # Try to install via Homebrew first
        if brew install claude-code 2>/dev/null; then
            print_status "Claude Code CLI installed via Homebrew"
        else
            print_info "Claude Code CLI not available via Homebrew"
            print_info "Downloading Claude Code CLI manually..."
            
            # Create a directory for Claude Code
            local CLAUDE_DIR="$HOME/.local/bin"
            mkdir -p "$CLAUDE_DIR"
            
            # Download based on architecture
            local ARCH=$(uname -m)
            local CLAUDE_URL
            if [[ "$ARCH" == "arm64" ]]; then
                CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-macos-arm64"
            else
                CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-macos-x64"
            fi
            
            print_info "Downloading from $CLAUDE_URL..."
            if curl -fsSL "$CLAUDE_URL" -o "$CLAUDE_DIR/claude" 2>/dev/null; then
                chmod +x "$CLAUDE_DIR/claude"
                
                # Add to PATH if not already there
                if [[ ":$PATH:" != *":$CLAUDE_DIR:"* ]]; then
                    local claude_config
                    local user_shell="$(basename "$SHELL")"
                    
                    case "$user_shell" in
                        fish)
                            claude_config='fish_add_path "$HOME/.local/bin"'
                            ;;
                        csh|tcsh)
                            claude_config='setenv PATH "$HOME/.local/bin:$PATH"'
                            ;;
                        *)
                            claude_config='export PATH="$HOME/.local/bin:$PATH"'
                            ;;
                    esac
                    
                    add_to_shell_config "$claude_config" "Claude Code CLI"
                    export PATH="$HOME/.local/bin:$PATH"
                fi
                
                print_status "Claude Code CLI installed to $CLAUDE_DIR/claude"
            else
                print_warning "Failed to download Claude Code CLI"
                print_info "Please download manually from https://claude.ai/code"
            fi
        fi
    fi
}

install_claude_cli_linux() {
    print_info "Installing Claude Code CLI..."
    if command -v claude &> /dev/null; then
        print_status "Claude Code CLI already installed"
    else
        local CLAUDE_DIR="$HOME/.local/bin"
        mkdir -p "$CLAUDE_DIR"
        
        local ARCH=$(uname -m)
        local CLAUDE_URL
        if [[ "$ARCH" == "aarch64" ]]; then
            CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-linux-arm64"
        else
            CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-linux-x64"
        fi
        
        print_info "Downloading Claude Code CLI..."
        if curl -fsSL "$CLAUDE_URL" -o "$CLAUDE_DIR/claude" 2>/dev/null; then
            chmod +x "$CLAUDE_DIR/claude"
            
            # Add to PATH
            if [[ ":$PATH:" != *":$CLAUDE_DIR:"* ]]; then
                local claude_config
                local user_shell="$(basename "$SHELL")"
                
                case "$user_shell" in
                    fish)
                        claude_config='fish_add_path "$HOME/.local/bin"'
                        ;;
                    csh|tcsh)
                        claude_config='setenv PATH "$HOME/.local/bin:$PATH"'
                        ;;
                    *)
                        claude_config='export PATH="$HOME/.local/bin:$PATH"'
                        ;;
                esac
                
                add_to_shell_config "$claude_config" "Claude Code CLI"
                export PATH="$HOME/.local/bin:$PATH"
            fi
            
            print_status "Claude Code CLI installed"
        else
            print_warning "Failed to download Claude Code CLI"
            print_info "Please download manually from https://claude.ai/code"
        fi
    fi
}

setup_claude_agents() {
    local AGENTS_REPO="$1"
    
    print_info "Setting up agent orchestration system..."
    
    # Ask user for setup preference
    echo ""
    echo "Choose installation location for agents:"
    echo "1) Current project (.claude folder)"
    echo "2) Global installation (~/.claude)"
    echo "3) Skip agent installation"
    
    # Read input from /dev/tty if stdin is piped
    if [ ! -t 0 ]; then
        if read -p "Enter choice (1-3): " choice </dev/tty 2>/dev/null; then
            :
        else
            print_warning "No TTY available, skipping agent installation"
            choice="3"
        fi
    else
        read -p "Enter choice (1-3): " choice
    fi
    
    case $choice in
        1)
            # Install to current project
            if [ -d ".claude" ]; then
                print_warning ".claude directory exists. Backing up to .claude.backup"
                mv .claude .claude.backup
            fi
            
            print_info "Attempting to clone agent repository..."
            if git clone --quiet "$AGENTS_REPO" .claude 2>/dev/null; then
                print_status "Agents installed to current project"
                
                # Copy CLAUDE.md if it exists
                if [ -f ".claude/CLAUDE.md" ]; then
                    cp .claude/CLAUDE.md ./
                    print_status "CLAUDE.md copied to project root"
                fi
            else
                print_warning "Repository appears to be private. Please ensure you have access to: $AGENTS_REPO"
                print_info "You can manually clone it later with: git clone $AGENTS_REPO .claude"
            fi
            ;;
            
        2)
            # Install globally
            local GLOBAL_DIR
            if [ -d ~/.claude ]; then
                print_warning "Global ~/.claude directory exists. Creating ~/.claude-agents instead"
                GLOBAL_DIR=~/.claude-agents
            else
                GLOBAL_DIR=~/.claude
            fi
            
            print_info "Attempting to clone agent repository..."
            if git clone --quiet "$AGENTS_REPO" "$GLOBAL_DIR" 2>/dev/null; then
                print_status "Agents installed globally to $GLOBAL_DIR"
            else
                print_warning "Repository appears to be private. Please ensure you have access to: $AGENTS_REPO"
                print_info "You can manually clone it later with: git clone $AGENTS_REPO $GLOBAL_DIR"
            fi
            ;;
            
        3)
            print_info "Skipping agent installation"
            ;;
            
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
}

#=============================================================================
# AWS DEVELOPMENT TOOLS INSTALLATION
#=============================================================================

install_aws_tools() {
    print_section "Installing AWS Development Tools"
    
    local ARCH="$(uname -m)"
    
    install_aws_cli
    refresh_environment
    install_session_manager
    refresh_environment
    install_sam_cli
    refresh_environment
    install_aws_cdk
    refresh_environment
    install_additional_aws_tools
    configure_aws_cli
    
    print_status "AWS development tools installation complete!"
}

install_aws_cli() {
    if command -v aws &> /dev/null; then
        print_status "AWS CLI already installed: $(aws --version)"
    else
        print_info "Installing AWS CLI v2..."
        
        case "${OS_TYPE}" in
            macos)
                if command -v brew &> /dev/null; then
                    brew install awscli
                else
                    print_error "Homebrew not found. Please install core tools first."
                    return 1
                fi
                ;;
            linux)
                local ARCH="$(uname -m)"
                curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "awscliv2.zip"
                unzip -q awscliv2.zip
                sudo ./aws/install
                rm -rf aws awscliv2.zip
                ;;
        esac
        
        print_status "AWS CLI installed: $(aws --version)"
    fi
}

install_session_manager() {
    print_info "Installing AWS Session Manager Plugin..."
    
    case "${OS_TYPE}" in
        macos)
            if command -v brew &> /dev/null; then
                brew install --cask session-manager-plugin
            else
                print_error "Homebrew not found. Please install core tools first."
                return 1
            fi
            ;;
        linux)
            curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
            sudo dpkg -i session-manager-plugin.deb
            rm session-manager-plugin.deb
            ;;
    esac
    
    print_status "Session Manager Plugin installed"
}

install_sam_cli() {
    if command -v sam &> /dev/null; then
        print_status "AWS SAM CLI already installed: $(sam --version)"
    else
        print_info "Installing AWS SAM CLI..."
        
        case "${OS_TYPE}" in
            macos)
                if command -v brew &> /dev/null; then
                    brew install aws-sam-cli
                else
                    print_error "Homebrew not found. Please install core tools first."
                    return 1
                fi
                ;;
            linux)
                wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
                unzip -q aws-sam-cli-linux-x86_64.zip -d sam-installation
                sudo ./sam-installation/install
                rm -rf sam-installation aws-sam-cli-linux-x86_64.zip
                ;;
        esac
        
        print_status "AWS SAM CLI installed"
    fi
}

install_aws_cdk() {
    if command -v cdk &> /dev/null; then
        print_status "AWS CDK already installed: $(cdk --version)"
    else
        print_info "Installing AWS CDK..."
        
        # Check if npm is installed
        if ! command -v npm &> /dev/null; then
            print_warning "npm not found. Installing Node.js first..."
            
            case "${OS_TYPE}" in
                macos)
                    brew install node
                    ;;
                linux)
                    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                    ;;
            esac
            refresh_environment
        fi
        
        npm install -g aws-cdk
        print_status "AWS CDK installed: $(cdk --version)"
    fi
}

install_additional_aws_tools() {
    print_info "Installing additional AWS tools..."
    
    # Install aws-vault for secure credential storage
    case "${OS_TYPE}" in
        macos)
            if command -v brew &> /dev/null; then
                if brew list --cask aws-vault &>/dev/null 2>&1; then
                    print_status "aws-vault already installed"
                else
                    brew install --cask aws-vault
                    print_status "aws-vault installed"
                fi
            fi
            ;;
        linux)
            if ! command -v aws-vault &> /dev/null; then
                wget https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-amd64
                sudo mv aws-vault-linux-amd64 /usr/local/bin/aws-vault
                sudo chmod +x /usr/local/bin/aws-vault
                print_status "aws-vault installed"
            else
                print_status "aws-vault already installed"
            fi
            ;;
    esac
}

configure_aws_cli() {
    print_info "Checking AWS configuration..."
    
    if [ ! -f ~/.aws/credentials ] && [ ! -f ~/.aws/config ]; then
        print_warning "AWS CLI not configured"
        
        # Read input from /dev/tty if stdin is piped
        if [ ! -t 0 ]; then
            if read -p "Would you like to configure AWS CLI now? (y/n): " response </dev/tty 2>/dev/null; then
                :
            else
                print_warning "No TTY available, skipping AWS configuration"
                print_info "You can configure AWS CLI later with: aws configure"
                return 0
            fi
        else
            read -p "Would you like to configure AWS CLI now? (y/n): " response
        fi
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            aws configure
        else
            print_info "You can configure AWS CLI later with: aws configure"
        fi
    else
        print_status "AWS configuration found"
        
        # Setup AWS profile selector
        if [ -f ~/.aws/config ]; then
            print_info "Available AWS profiles:"
            grep '\[profile' ~/.aws/config | sed 's/\[profile /  • /g' | sed 's/\]//g'
            grep '\[default\]' ~/.aws/config > /dev/null 2>&1 && echo "  • default"
        fi
    fi
}

#=============================================================================
# CONTAINER TOOLS INSTALLATION
#=============================================================================

install_container_tools() {
    print_section "Installing Container Tools (Podman + Docker Compatibility)"
    
    check_existing_docker
    install_podman
    refresh_environment
    setup_podman_machine
    setup_docker_compatibility
    add_container_shell_aliases
    setup_auto_startup
    verify_compose
    test_container_installation
    
    print_status "Container tools installation complete!"
}

check_existing_docker() {
    if command -v docker &> /dev/null && [ -S /var/run/docker.sock ]; then
        print_warning "Docker is already installed and running"
        echo "This script will install Podman as a Docker replacement."
        echo "You may want to stop Docker first to avoid conflicts."
        
        # Read input from /dev/tty if stdin is piped
        if [ ! -t 0 ]; then
            if read -p "Continue with Podman installation? (y/N): " -n 1 -r </dev/tty 2>/dev/null; then
                :
            else
                print_warning "No TTY available, continuing with installation"
                return 0
            fi
        else
            read -p "Continue with Podman installation? (y/N): " -n 1 -r
        fi
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled by user"
            exit 0
        fi
    fi
}

install_podman() {
    print_info "Installing Podman and Podman Desktop..."
    
    case "${OS_TYPE}" in
        macos)
            print_info "Detected macOS"
            if ! command -v brew &> /dev/null; then
                print_error "Homebrew not found. Please install core tools first."
                return 1
            fi
            
            # Install Podman
            if command -v podman &> /dev/null; then
                print_status "Podman already installed: $(podman --version)"
            else
                print_info "Installing Podman via Homebrew..."
                brew install podman
                print_status "Podman installed: $(podman --version)"
            fi
            
            # Install Podman Desktop
            if brew list --cask podman-desktop &>/dev/null 2>&1; then
                print_status "Podman Desktop already installed"
            else
                print_info "Installing Podman Desktop..."
                if brew install --cask podman-desktop 2>/dev/null; then
                    print_status "Podman Desktop installed successfully"
                else
                    print_warning "Failed to install Podman Desktop via Homebrew"
                    print_info "You can download it manually from https://podman-desktop.io"
                fi
            fi
            ;;
            
        linux)
            print_info "Detected Linux"
            
            # Detect package manager
            if command -v apt-get &> /dev/null; then
                PKG_INSTALL="sudo apt-get install -y"
                PKG_UPDATE="sudo apt-get update"
                
                print_info "Updating package lists..."
                $PKG_UPDATE
                
                print_info "Installing Podman..."
                $PKG_INSTALL podman
                
            elif command -v yum &> /dev/null; then
                PKG_INSTALL="sudo yum install -y"
                
                print_info "Installing Podman..."
                $PKG_INSTALL podman
                
            else
                print_error "No supported package manager found"
                return 1
            fi
            
            print_status "Podman installed: $(podman --version)"
            print_info "For Podman Desktop on Linux, visit https://podman-desktop.io"
            ;;
            
        *)
            print_error "Unsupported operating system: ${OS_TYPE}"
            return 1
            ;;
    esac
}

setup_podman_machine() {
    if [ "${OS_TYPE}" != "macos" ]; then
        return 0
    fi
    
    print_info "Setting up Podman machine..."
    
    # Check if machine already exists
    if podman machine list | grep -q "podman-machine-default"; then
        print_status "Podman machine already exists"
        
        # Check if it's running
        if podman machine list | grep "podman-machine-default" | grep -q "Running"; then
            print_status "Podman machine is already running"
        else
            print_info "Starting Podman machine..."
            podman machine start
            print_status "Podman machine started"
        fi
    else
        print_info "Initializing Podman machine with optimized settings..."
        
        # Initialize with good defaults for development
        podman machine init \
            --cpus 4 \
            --memory 4096 \
            --disk-size 100 \
            --volume $HOME:$HOME \
            --now
            
        print_status "Podman machine initialized and started"
    fi
}

setup_docker_compatibility() {
    print_info "Setting up Docker compatibility..."
    
    case "${OS_TYPE}" in
        macos)
            # Install podman-mac-helper for Docker socket compatibility
            print_info "Installing podman-mac-helper for Docker socket compatibility..."
            
            if sudo podman-mac-helper install 2>/dev/null; then
                print_status "podman-mac-helper installed successfully"
                
                # Verify socket creation
                if [ -S /var/run/docker.sock ]; then
                    print_status "Docker socket (/var/run/docker.sock) created successfully"
                else
                    print_warning "Docker socket not found, Docker tools may not work"
                    print_info "You may need to restart the Podman machine: podman machine restart"
                fi
            else
                print_warning "Failed to install podman-mac-helper"
                print_info "Docker compatibility may be limited"
            fi
            
            # Create docker command symlink
            local podman_path
            if command -v podman &> /dev/null; then
                podman_path=$(which podman)
                local bin_dir=$(dirname "$podman_path")
                
                if [ ! -f "$bin_dir/docker" ]; then
                    print_info "Creating Docker command symlink..."
                    if sudo ln -sf "$podman_path" "$bin_dir/docker" 2>/dev/null; then
                        print_status "Docker command symlink created: $bin_dir/docker"
                    else
                        print_warning "Failed to create Docker symlink, using shell aliases instead..."
                    fi
                else
                    print_status "Docker command already available"
                fi
            fi
            ;;
            
        linux)
            # On Linux, create docker alias and configure socket
            print_info "Configuring Docker compatibility on Linux..."
            
            # Create docker symlink
            if [ ! -f /usr/local/bin/docker ]; then
                print_info "Creating Docker command symlink..."
                sudo ln -sf $(which podman) /usr/local/bin/docker
                print_status "Docker command symlink created"
            fi
            
            # Enable and start podman socket for Docker API compatibility
            print_info "Enabling Podman socket for Docker API compatibility..."
            systemctl --user enable --now podman.socket
            print_status "Podman socket enabled"
            
            # Set DOCKER_HOST for current session
            export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
            ;;
    esac
}

add_container_shell_aliases() {
    print_info "Adding Docker compatibility aliases to shell profiles..."
    
    local user_shell="$(basename "$SHELL")"
    local aliases_config
    
    case "$user_shell" in
        fish)
            aliases_config='alias docker="podman"
alias docker-compose="podman compose"'
            ;;
        csh|tcsh)
            aliases_config='alias docker podman
alias docker-compose "podman compose"'
            ;;
        *)
            aliases_config='alias docker="podman"
alias docker-compose="podman compose"'
            ;;
    esac
    
    add_to_shell_config "$aliases_config" "Podman Docker compatibility aliases"
}

setup_auto_startup() {
    if [ "${OS_TYPE}" != "macos" ]; then
        return 0
    fi
    
    print_info "Setting up automatic Podman machine startup..."
    
    local plist_dir="$HOME/Library/LaunchAgents"
    local plist_file="$plist_dir/com.podman.machine.plist"
    
    # Create LaunchAgents directory if it doesn't exist
    mkdir -p "$plist_dir"
    
    # Create LaunchAgent plist file
    cat > "$plist_file" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.podman.machine</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <string>command -v podman >/dev/null 2>&1 && podman machine start || true</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>/tmp/podman-machine-startup.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/podman-machine-startup.log</string>
</dict>
</plist>
EOF
    
    # Load the LaunchAgent
    if launchctl load "$plist_file" 2>/dev/null; then
        print_status "Automatic Podman machine startup configured"
        print_info "Podman machine will start automatically at login"
    else
        print_warning "Failed to configure automatic startup"
        print_info "You can manually start Podman with: podman machine start"
    fi
}

verify_compose() {
    print_info "Verifying Podman Compose functionality..."
    
    if podman compose --version &>/dev/null; then
        print_status "Podman Compose is available: $(podman compose --version)"
    else
        print_warning "Podman Compose not available"
        print_info "Install docker-compose for legacy compatibility if needed"
        
        case "${OS_TYPE}" in
            macos)
                print_info "You can install docker-compose with: brew install docker-compose"
                ;;
            linux)
                print_info "You can install docker-compose with your package manager"
                ;;
        esac
    fi
}

test_container_installation() {
    print_info "Testing container functionality..."
    
    # Test basic Podman functionality
    if podman run --rm hello-world &>/dev/null; then
        print_status "Podman container test successful"
    else
        print_warning "Podman container test failed"
        print_info "Try running: podman machine restart"
    fi
    
    # Test Docker compatibility if symlink/alias exists
    if command -v docker &>/dev/null && [ "$(which docker)" != "$(which podman)" ]; then
        # Docker symlink exists
        if docker run --rm hello-world &>/dev/null; then
            print_status "Docker compatibility test successful"
        else
            print_warning "Docker compatibility test failed"
        fi
    else
        print_info "Docker compatibility available via shell aliases"
        print_info "Restart your terminal and use 'docker' commands normally"
    fi
}

#=============================================================================
# MAIN INSTALLATION MENU AND EXECUTION
#=============================================================================

# Main installation menu
show_menu() {
    while true; do
        echo ""
        echo "Select components to install:"
        echo ""
        echo "  1) Full Installation (Recommended)"
        echo "  2) Core Development Tools (Homebrew, Git, Neovim, etc.)"
        echo "  3) Programming Languages (Python + Poetry, Node.js + Yarn, Go, Bun)"
        echo "  4) Web Browsers (Chrome, Firefox, Edge, Brave)"
        echo "  5) Design Tools (Figma, image tools, fonts)"
        echo "  6) Claude Code + Agent Orchestration"
        echo "  7) AWS Development Tools"
        echo "  8) Container Tools (Docker, Kubernetes)"
        echo "  9) Custom Selection"
        echo "  0) Exit"
        echo ""
        
        # Read input from /dev/tty if stdin is piped
        if [ ! -t 0 ]; then
            # Try to read from /dev/tty
            if read -p "Enter your choice [1-9, 0]: " choice </dev/tty 2>/dev/null; then
                # Successfully read from /dev/tty
                :
            else
                # /dev/tty not available, can't continue interactively
                print_error "Cannot read input: no TTY available"
                print_info "To run non-interactively, set NONINTERACTIVE=1"
                exit 1
            fi
        else
            read -p "Enter your choice [1-9, 0]: " choice
        fi
        
        case $choice in
            1)
                install_full
                break
                ;;
            2)
                install_core_tools
                ;;
            3)
                install_programming_languages
                ;;
            4)
                install_web_browsers
                ;;
            5)
                install_design_tools
                ;;
            6)
                install_claude_code
                ;;
            7)
                install_aws_tools
                ;;
            8)
                install_container_tools
                ;;
            9)
                custom_installation
                ;;
            0)
                print_info "Exiting installer"
                break
                ;;
            *)
                print_error "Invalid choice, please try again"
                ;;
        esac
        
        # After each installation (except exit), ask if user wants to install more
        if [ "$choice" != "0" ] && [ "$choice" != "1" ]; then
            echo ""
            # Read input from /dev/tty if stdin is piped
            if [ ! -t 0 ]; then
                if read -p "Install another component? (y/N): " -n 1 -r </dev/tty 2>/dev/null; then
                    :
                else
                    print_error "Cannot read input: no TTY available"
                    break
                fi
            else
                read -p "Install another component? (y/N): " -n 1 -r
            fi
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                break
            fi
        fi
    done
}

# Full installation
install_full() {
    print_section "Starting Full Installation"
    
    install_core_tools
    refresh_environment
    install_programming_languages
    refresh_environment
    install_web_browsers
    refresh_environment
    install_design_tools
    refresh_environment
    install_claude_code
    refresh_environment
    install_aws_tools
    refresh_environment
    install_container_tools
    
    print_status "All components installed successfully!"
}

# Custom installation
custom_installation() {
    print_section "Custom Installation"
    
    echo "Available components:"
    echo ""
    
    local components=(
        "Core Development Tools"
        "Programming Languages"
        "Web Browsers"
        "Design Tools"
        "Claude Code + Agents"
        "AWS Tools"
        "Container Tools"
    )
    
    for i in "${!components[@]}"; do
        echo "  $((i+1))) ${components[$i]}"
    done
    
    echo ""
    echo "Enter component numbers separated by spaces (e.g., 1 3 4):"
    
    # Read input from /dev/tty if stdin is piped
    if [ ! -t 0 ]; then
        if read -a selections </dev/tty 2>/dev/null; then
            :
        else
            print_error "Cannot read input: no TTY available"
            return 1
        fi
    else
        read -a selections
    fi
    
    for sel in "${selections[@]}"; do
        case $sel in
            1)
                install_core_tools
                refresh_environment
                ;;
            2)
                install_programming_languages
                refresh_environment
                ;;
            3)
                install_web_browsers
                refresh_environment
                ;;
            4)
                install_design_tools
                refresh_environment
                ;;
            5)
                install_claude_code
                refresh_environment
                ;;
            6)
                install_aws_tools
                refresh_environment
                ;;
            7)
                install_container_tools
                refresh_environment
                ;;
            *)
                print_warning "Invalid selection: $sel"
                ;;
        esac
    done
}

# Main execution
main() {
    print_header
    
    detect_os
    
    if [ "$OS" = "unsupported" ]; then
        print_error "Unsupported operating system"
        exit 1
    fi
    
    print_info "Detected OS: $OS ($DISTRO)"
    
    check_prerequisites
    
    # Request sudo access upfront on macOS (unless running non-interactively)
    if [ -z "$CI" ] && [ -z "$AUTOMATED_INSTALL" ] && [ -z "$NONINTERACTIVE" ]; then
        request_sudo
    fi
    
    # Check if running in CI/automated environment or non-interactive mode
    if [ -n "$CI" ] || [ -n "$AUTOMATED_INSTALL" ] || [ -n "$NONINTERACTIVE" ]; then
        print_info "Running in automated mode - installing all components"
        install_full
    else
        # Try interactive mode
        if [ ! -t 0 ]; then
            # stdin is piped, check if we can use /dev/tty
            if echo -n "" </dev/tty 2>/dev/null; then
                print_info "Running interactively via /dev/tty (stdin is piped)"
                show_menu
            else
                # No TTY available at all
                print_warning "No TTY available for interactive mode"
                print_info "To run non-interactively, set NONINTERACTIVE=1 or AUTOMATED_INSTALL=1"
                print_info "Example: curl -fsSL https://peek-tech.github.io/devenv-setup/install.sh | NONINTERACTIVE=1 bash"
                exit 1
            fi
        else
            # Normal terminal mode
            show_menu
        fi
    fi
    
    print_section "Installation Complete"
    
    # Give shell-specific restart instructions
    local user_shell="$(basename "$SHELL")"
    local config_file="$(get_shell_config_file)"
    
    case "$user_shell" in
        fish)
            print_info "Please restart your terminal or run: source $config_file"
            print_info "Fish shell users: Some tools may require a full terminal restart"
            ;;
        csh|tcsh)
            print_info "Please restart your terminal or run: source $config_file" 
            print_info "C shell users: Some tools may require a full terminal restart"
            ;;
        *)
            print_info "Please restart your terminal or run: source $config_file"
            ;;
    esac
    
    print_info "For help and documentation, visit: https://peek-tech.github.io/devenv-setup"
}

# Run main function
main "$@"