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

# Install common Python versions
install_python_versions() {
    if ! command -v pyenv &> /dev/null; then
        print_warning "pyenv not available, skipping Python version installation"
        return
    fi
    
    print_info "Installing common Python versions..."
    
    # Get latest Python 3.11 and 3.12
    local python_versions=("3.11.10" "3.12.7")
    
    for version in "${python_versions[@]}"; do
        if pyenv versions | grep -q "$version"; then
            print_status "Python $version already installed"
        else
            print_info "Installing Python $version..."
            pyenv install "$version"
        fi
    done
    
    # Set latest as global default
    pyenv global "${python_versions[-1]}"
    print_status "Set Python ${python_versions[-1]} as global default"
}

# Install common Node.js versions
install_node_versions() {
    # Source nvm if available
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    if ! command -v nvm &> /dev/null; then
        print_warning "nvm not available, skipping Node.js version installation"
        return
    fi
    
    print_info "Installing Node.js LTS version..."
    
    # Install and use LTS
    nvm install --lts
    nvm use --lts
    nvm alias default node
    
    print_status "Node.js LTS installed and set as default"
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
    echo "  • nvm (Node.js version management)"  
    echo "  • Go programming language"
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
    setup_directories
    
    # Install common versions (optional)
    echo ""
    read -p "Install common language versions? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_python_versions
        install_node_versions
    fi
    
    print_status "Programming languages setup complete!"
    echo ""
    echo "Installed tools:"
    echo "  • pyenv (Python version manager)"
    echo "  • nvm (Node.js version manager)"
    echo "  • Go programming language"
    echo ""
    echo "Next steps:"
    echo "  • Restart your terminal or run: source ~/.zprofile (zsh) or ~/.bashrc (bash)"
    echo "  • Install Python versions: pyenv install 3.12.7"
    echo "  • Install Node.js versions: nvm install 18"
    echo "  • Create Go projects in ~/go/src/"
    echo ""
    echo "Version management commands:"
    echo "  • pyenv versions          # List installed Python versions"
    echo "  • pyenv global 3.12.7     # Set global Python version"
    echo "  • nvm list                # List installed Node.js versions"
    echo "  • nvm use 18              # Switch to Node.js 18"
    echo "  • go version              # Check Go version"
}

main "$@"