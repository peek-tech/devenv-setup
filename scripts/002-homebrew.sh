#!/bin/bash

# Omacy - Homebrew Installation
# Installs Homebrew package manager for macOS

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Install Homebrew
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
        
        print_status "Homebrew installed successfully"
    else
        print_status "Homebrew already installed"
    fi
}

# Refresh environment to pick up Homebrew
refresh_environment() {
    # Source Homebrew environment for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]] && [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    # Source shell configuration files
    if [ -f ~/.zprofile ]; then
        set +e
        source ~/.zprofile 2>/dev/null
        set -e
    fi
    
    if [ -f ~/.zshrc ]; then
        set +e
        source ~/.zshrc 2>/dev/null
        set -e
    fi
}

# Main execution
main() {
    install_homebrew
    
    # Temporarily disable exit on error for environment refresh
    # Shell config files may contain commands that return non-zero exit codes
    set +e
    refresh_environment
    set -e
    
    print_status "Homebrew setup complete"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi