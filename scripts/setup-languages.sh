#!/bin/bash

# Programming Languages Setup
# Installs language version managers and runtimes

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

echo ""
echo -e "${BLUE}🔧 Programming Languages Setup${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Darwin*) OS_TYPE="macos";;
    Linux*) OS_TYPE="linux";;
    *) print_error "Unsupported OS: ${OS}"; exit 1;;
esac

# Install pyenv (Python version manager)
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

# Add pyenv to shell configuration
add_pyenv_to_shell() {
    local shell_config=""
    
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zprofile"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        print_warning "Unknown shell. Please add pyenv to your PATH manually."
        return
    fi
    
    if ! grep -q 'pyenv init' "$shell_config" 2>/dev/null; then
        print_info "Adding pyenv to $shell_config..."
        {
            echo ''
            echo '# pyenv'
            echo 'export PYENV_ROOT="$HOME/.pyenv"'
            echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
            echo 'eval "$(pyenv init -)"'
        } >> "$shell_config"
        
        # Source for current session
        export PYENV_ROOT="$HOME/.pyenv"
        command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)" 2>/dev/null || true
    fi
}

# Install nvm (Node.js version manager)
install_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        print_status "nvm already installed"
        return 0
    fi
    
    print_info "Installing nvm..."
    
    # Download and install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Source nvm for current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    print_status "nvm installed successfully"
}

# Install Go
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

# Add Go to shell configuration (Linux only)
add_go_to_shell() {
    local shell_config=""
    
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zprofile"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        print_warning "Unknown shell. Please add Go to your PATH manually."
        return
    fi
    
    if ! grep -q '/usr/local/go/bin' "$shell_config" 2>/dev/null; then
        print_info "Adding Go to $shell_config..."
        {
            echo ''
            echo '# Go'
            echo 'export PATH=$PATH:/usr/local/go/bin'
            echo 'export GOPATH=$HOME/go'
            echo 'export PATH=$PATH:$GOPATH/bin'
        } >> "$shell_config"
        
        # Source for current session
        export PATH=$PATH:/usr/local/go/bin
        export GOPATH=$HOME/go
        export PATH=$PATH:$GOPATH/bin
    fi
}

# Install Python versions and Poetry
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

# Install Poetry
install_poetry() {
    if command -v poetry &> /dev/null; then
        print_status "Poetry already installed: $(poetry --version)"
        return 0
    fi
    
    print_info "Installing Poetry..."
    
    # Install Poetry using the official installer
    curl -sSL https://install.python-poetry.org | python3 -
    
    # Add Poetry to PATH
    add_poetry_to_shell
    
    print_status "Poetry installed successfully"
}

# Add Poetry to shell configuration
add_poetry_to_shell() {
    local shell_config=""
    
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zprofile"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        print_warning "Unknown shell. Please add Poetry to your PATH manually."
        return
    fi
    
    if ! grep -q 'poetry' "$shell_config" 2>/dev/null; then
        print_info "Adding Poetry to $shell_config..."
        {
            echo ''
            echo '# Poetry'
            echo 'export PATH="$HOME/.local/bin:$PATH"'
        } >> "$shell_config"
        
        # Source for current session
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

# Install Node.js versions and Yarn
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

# Install Yarn
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

# Install Bun
install_bun() {
    if command -v bun &> /dev/null; then
        print_status "Bun already installed: $(bun --version)"
        return 0
    fi
    
    print_info "Installing Bun..."
    
    # Install Bun using the official installer
    curl -fsSL https://bun.sh/install | bash
    
    # Source bun for current session
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    
    # Add to shell configuration
    add_bun_to_shell
    
    print_status "Bun installed successfully"
}

# Add Bun to shell configuration
add_bun_to_shell() {
    local shell_config=""
    
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zprofile"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        print_warning "Unknown shell. Please add Bun to your PATH manually."
        return
    fi
    
    if ! grep -q 'BUN_INSTALL' "$shell_config" 2>/dev/null; then
        print_info "Adding Bun to $shell_config..."
        {
            echo ''
            echo '# Bun'
            echo 'export BUN_INSTALL="$HOME/.bun"'
            echo 'export PATH="$BUN_INSTALL/bin:$PATH"'
        } >> "$shell_config"
    fi
}

# Setup language directories
setup_directories() {
    print_info "Creating language development directories..."
    
    mkdir -p ~/Development/python
    mkdir -p ~/Development/javascript
    mkdir -p ~/Development/go
    
    # Create Go workspace
    mkdir -p ~/go/{bin,src,pkg}
    
    print_status "Development directories created"
}

# Main execution
main() {
    print_info "This will install language version managers and runtimes:"
    echo "  • pyenv (Python version management)"
    echo "  • Poetry (Python dependency management)"
    echo "  • nvm (Node.js version management)"  
    echo "  • Yarn (Node.js package management)"
    echo "  • Go programming language"
    echo "  • Bun (fast JavaScript runtime)"
    echo ""
    
    read -p "Continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi
    
    install_pyenv
    install_nvm
    install_go
    install_bun
    setup_directories
    
    # Install specific language versions
    print_info "Installing specific language versions..."
    install_python_versions  # Python 3.11 as default
    install_node_versions    # Node.js 20, 22 with 20 as default
    
    print_status "Programming languages setup complete!"
    echo ""
    echo "Installed tools:"
    echo "  • pyenv (Python version manager)"
    echo "  • Poetry (Python dependency management)"
    echo "  • nvm (Node.js version manager)"
    echo "  • Yarn (Node.js package management)"
    echo "  • Go programming language"
    echo "  • Bun (fast JavaScript runtime)"
    echo ""
    echo "Installed versions:"
    echo "  • Python 3.11 (system default)"
    echo "  • Node.js 20 (system default)"
    echo "  • Node.js 22"
    echo "  • Latest Go version"
    echo "  • Latest Bun version"
    echo ""
    echo "Next steps:"
    echo "  • Restart your terminal or run: source ~/.zprofile (zsh) or ~/.bashrc (bash)"
    echo "  • Verify installations:"
    echo "    - python --version"
    echo "    - poetry --version"
    echo "    - node --version"
    echo "    - yarn --version"
    echo "    - go version"
    echo "    - bun --version"
    echo ""
    echo "Package management commands:"
    echo "  • poetry new myproject     # Create new Python project"
    echo "  • poetry install           # Install Python dependencies"
    echo "  • yarn install             # Install Node.js dependencies"
    echo "  • yarn add package-name    # Add Node.js package"
    echo ""
    echo "Version management commands:"
    echo "  • pyenv versions          # List installed Python versions"
    echo "  • pyenv global 3.11.10    # Set global Python version"
    echo "  • nvm list                # List installed Node.js versions"
    echo "  • nvm use 22              # Switch to Node.js 22"
}

main "$@"