#!/bin/bash

# Omacy - Fonts Installation
# Installs Nerd Fonts and developer fonts via Homebrew

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

# Install Nerd Fonts
install_nerd_fonts() {
    print_info "Installing selected Nerd Fonts via Homebrew..."
    
    # Essential Nerd Fonts (focused selection instead of all)
    local nerd_fonts=(
        "font-fira-code-nerd-font"
        "font-jetbrains-mono-nerd-font"
        "font-hack-nerd-font"
        "font-source-code-pro-nerd-font"
        "font-inconsolata-nerd-font"
        "font-cascadia-code-nerd-font"
        "font-ubuntu-mono-nerd-font"
        "font-dejavu-sans-mono-nerd-font"
        "font-liberation-nerd-font"
        "font-meslo-lg-nerd-font"
    )
    
    for font in "${nerd_fonts[@]}"; do
        if brew list --cask "$font" &>/dev/null; then
            print_status "$font already installed"
        else
            print_info "Installing $font..."
            brew install --cask "$font"
        fi
    done
}

# Install developer fonts
install_developer_fonts() {
    print_info "Installing developer font families..."
    
    local dev_fonts=(
        "font-roboto"
        "font-roboto-mono"
        "font-roboto-slab"
        "font-roboto-condensed"
        "font-roboto-flex"
        "font-sf-mono"
        "font-sf-pro"
        "font-inter"
        "font-fira-code"
        "font-jetbrains-mono"
        "font-cascadia-code"
    )
    
    for font in "${dev_fonts[@]}"; do
        if brew list --cask "$font" &>/dev/null; then
            print_status "$font already installed"
        else
            print_info "Installing $font..."
            brew install --cask "$font"
        fi
    done
}

# Main execution
main() {
    install_nerd_fonts
    install_developer_fonts
    print_status "Fonts installation complete!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi