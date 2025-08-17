#!/bin/bash

# Omacy - Developer Fonts Installation
# Installs comprehensive Nerd Fonts collection via Homebrew

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

# Load Homebrew environment
load_homebrew_env() {
    if [[ $(uname -m) == 'arm64' ]] && [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

# Install complete Nerd Fonts collection (all 72 fonts)
install_nerd_fonts() {
    print_info "Installing complete Nerd Fonts collection (all available) via Homebrew..."
    
    # Complete Nerd Fonts collection - all available fonts from Homebrew
    local nerd_fonts=(
        "font-0xproto-nerd-font"
        "font-3270-nerd-font"
        "font-adwaita-mono-nerd-font"
        "font-agave-nerd-font"
        "font-anonymice-nerd-font"
        "font-arimo-nerd-font"
        "font-atkynson-mono-nerd-font"
        "font-aurulent-sans-mono-nerd-font"
        "font-bigblue-terminal-nerd-font"
        "font-bitstream-vera-sans-mono-nerd-font"
        "font-blex-mono-nerd-font"
        "font-caskaydia-cove-nerd-font"
        "font-caskaydia-mono-nerd-font"
        "font-code-new-roman-nerd-font"
        "font-comic-shanns-mono-nerd-font"
        "font-commit-mono-nerd-font"
        "font-cousine-nerd-font"
        "font-d2coding-nerd-font"
        "font-daddy-time-mono-nerd-font"
        "font-dejavu-sans-mono-nerd-font"
        "font-departure-mono-nerd-font"
        "font-droid-sans-mono-nerd-font"
        "font-envy-code-r-nerd-font"
        "font-fantasque-sans-mono-nerd-font"
        "font-fira-code-nerd-font"
        "font-fira-mono-nerd-font"
        "font-geist-mono-nerd-font"
        "font-go-mono-nerd-font"
        "font-gohufont-nerd-font"
        "font-hack-nerd-font"
        "font-hasklug-nerd-font"
        "font-heavy-data-nerd-font"
        "font-hurmit-nerd-font"
        "font-im-writing-nerd-font"
        "font-inconsolata-go-nerd-font"
        "font-inconsolata-lgc-nerd-font"
        "font-inconsolata-nerd-font"
        "font-intone-mono-nerd-font"
        "font-iosevka-nerd-font"
        "font-iosevka-term-nerd-font"
        "font-iosevka-term-slab-nerd-font"
        "font-jetbrains-mono-nerd-font"
        "font-lekton-nerd-font"
        "font-liberation-nerd-font"
        "font-lilex-nerd-font"
        "font-m+-nerd-font"
        "font-martian-mono-nerd-font"
        "font-meslo-lg-nerd-font"
        "font-monaspace-nerd-font"
        "font-monocraft-nerd-font"
        "font-monofur-nerd-font"
        "font-monoid-nerd-font"
        "font-mononoki-nerd-font"
        "font-noto-nerd-font"
        "font-open-dyslexic-nerd-font"
        "font-overpass-nerd-font"
        "font-profont-nerd-font"
        "font-proggy-clean-tt-nerd-font"
        "font-recursive-mono-nerd-font"
        "font-roboto-mono-nerd-font"
        "font-sauce-code-pro-nerd-font"
        "font-sf-mono-nerd-font-ligaturized"
        "font-shure-tech-mono-nerd-font"
        "font-space-mono-nerd-font"
        "font-symbols-only-nerd-font"
        "font-terminess-ttf-nerd-font"
        "font-tinos-nerd-font"
        "font-ubuntu-mono-nerd-font"
        "font-ubuntu-nerd-font"
        "font-ubuntu-sans-nerd-font"
        "font-victor-mono-nerd-font"
        "font-zed-mono-nerd-font"
    )
    
    local installed_count=0
    local total_count=${#nerd_fonts[@]}
    
    print_info "Installing $total_count Nerd Fonts..."
    
    for font in "${nerd_fonts[@]}"; do
        if brew list --cask "$font" &>/dev/null; then
            print_status "$font already installed"
            ((installed_count++))
        else
            print_info "Installing $font... ($((installed_count + 1))/$total_count)"
            if brew install --cask "$font"; then
                ((installed_count++))
            else
                print_warning "Failed to install $font"
            fi
        fi
    done
    
    print_status "Nerd Fonts installation complete: $installed_count/$total_count fonts installed"
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