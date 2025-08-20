#!/bin/bash

# Omamacy - Homebrew Installation
# Installs Homebrew package manager for macOS

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Install Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_info "Installing Homebrew..."
        
        # Install Homebrew (sudo access already cached from preflight-checks.sh)
        print_info "Running Homebrew installation..."
        
        # Install Homebrew with explicit error handling
        # Redirect stdin from /dev/tty to ensure interactive mode when run via curl|bash
        set +e
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/tty
        local brew_install_result=$?
        set -e
        
        if [ $brew_install_result -ne 0 ]; then
            print_error "Homebrew installation failed with exit code: $brew_install_result"
            print_info "This often happens after Xcode Command Line Tools installation"
            print_info "Retrying Homebrew installation..."
            
            # Wait a moment and retry once
            sleep 3
            set +e
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/tty
            brew_install_result=$?
            set -e
            
            if [ $brew_install_result -ne 0 ]; then
                print_error "Homebrew installation failed after retry"
                return 1
            fi
        fi
        
        # Add Homebrew to PATH based on architecture
        if [[ $(uname -m) == 'arm64' ]]; then
            # Apple Silicon Macs
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Intel Macs
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        # Verify brew is now available
        if ! command -v brew &> /dev/null; then
            print_error "Homebrew installation completed but brew command not found"
            print_info "Please restart your terminal and run the installer again"
            return 1
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