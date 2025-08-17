#!/bin/bash

# Omacy - Developer Fonts Installation
# Installs comprehensive Nerd Fonts collection via Homebrew

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

# Install comprehensive Nerd Fonts collection
install_nerd_fonts() {
    print_info "Installing comprehensive Nerd Fonts collection via Homebrew..."
    
    # Comprehensive Nerd Fonts collection (most popular and useful ones)
    local nerd_fonts=(
        # Core programming fonts with Nerd Font patches
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
        
        # Additional popular Nerd Fonts
        "font-3270-nerd-font"
        "font-agave-nerd-font"
        "font-anonymice-nerd-font"
        "font-arimo-nerd-font"
        "font-aurulent-sans-mono-nerd-font"
        "font-bigblue-terminal-nerd-font"
        "font-bitstream-vera-sans-mono-nerd-font"
        "font-blex-mono-nerd-font"
        "font-fira-mono-nerd-font"
        "font-inconsolata-go-nerd-font"
        "font-inconsolata-lgc-nerd-font"
        "font-monofur-nerd-font"
        "font-overpass-nerd-font"
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

# Install additional developer fonts (non-Nerd Font versions)
install_additional_dev_fonts() {
    print_info "Installing additional developer fonts..."
    
    # Non-Nerd Font versions for applications that don't need icons
    local dev_fonts=(
        "font-roboto"
        "font-roboto-mono"
        "font-roboto-slab"
        "font-roboto-condensed"
        "font-roboto-flex"
        "font-inter"
        "font-fira-code"
        "font-jetbrains-mono"
        "font-cascadia-code"
        # Note: Removed font-sf-mono and font-sf-pro due to Apple licensing restrictions
        # and permission issues requiring sudo. These fonts are already available in macOS.
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
    # Load Homebrew environment first
    load_homebrew_env
    
    install_nerd_fonts
    install_additional_dev_fonts
    print_status "Developer fonts installation complete!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi