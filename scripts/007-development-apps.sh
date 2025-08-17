#!/bin/bash

# Omacy - Development Applications
# Installs development-focused applications

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

# Install development applications
install_development_apps() {
    print_info "Installing development applications..."
    
    local dev_apps=(
        "docker"
        "github-desktop"
        "postman"
        "insomnia"
        "tableplus"
        "proxyman"
        "raycast"
        "iterm2"
    )
    
    for app in "${dev_apps[@]}"; do
        if brew list --cask "$app" &>/dev/null; then
            print_status "$app already installed"
        else
            print_info "Installing $app..."
            brew install --cask "$app"
        fi
    done
}

# Install programming languages
install_programming_languages() {
    print_info "Installing programming languages and runtimes..."
    
    local languages=(
        "node"
        "python@3.12"
        "go"
        "rust"
        "deno"
        "bun"
    )
    
    for lang in "${languages[@]}"; do
        if brew list "$lang" &>/dev/null; then
            print_status "$lang already installed"
        else
            print_info "Installing $lang..."
            brew install "$lang"
        fi
    done
}

# Main execution
main() {
    install_development_apps
    install_programming_languages
    print_status "Development applications installation complete!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi