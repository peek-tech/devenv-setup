#!/bin/bash

# Omacy - Web Browsers
# Installs web browsers for development and testing

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

# Load Homebrew environment
load_homebrew_env() {
    if [[ $(uname -m) == 'arm64' ]] && [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

# Install web browsers
install_browsers() {
    print_info "Installing web browsers..."
    
    local browsers=(
        "google-chrome"
        "firefox"
        "microsoft-edge"
        "arc"
        "brave-browser"
    )
    
    for browser in "${browsers[@]}"; do
        if brew list --cask "$browser" &>/dev/null; then
            print_status "$browser already installed"
        else
            print_info "Installing $browser..."
            brew install --cask "$browser"
        fi
    done
}

# Main execution
main() {
    # Load Homebrew environment first
    load_homebrew_env
    
    install_browsers
    print_status "Browsers installation complete!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi