#!/bin/bash

# Omacy - Design Applications
# Installs design and creative applications

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

# Install design applications
install_design_apps() {
    print_info "Installing design applications..."
    
    local design_apps=(
        "figma"
        "sketch"
        "adobe-creative-cloud"
        "imageoptim"
        "cleanmymac"
        "the-unarchiver"
    )
    
    for app in "${design_apps[@]}"; do
        if brew list --cask "$app" &>/dev/null; then
            print_status "$app already installed"
        else
            print_info "Installing $app..."
            brew install --cask "$app"
        fi
    done
}

# Main execution
main() {
    # Load Homebrew environment first
    load_homebrew_env
    
    install_design_apps
    print_status "Design applications installation complete!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi