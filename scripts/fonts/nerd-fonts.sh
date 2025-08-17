#!/bin/bash

# Omamacy - Nerd Fonts Installation
# Programming fonts with icons and symbols

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Install Nerd Fonts
install_nerd_fonts() {
    local fonts=(
        "font-fira-code-nerd-font"
        "font-hack-nerd-font"
        "font-jetbrains-mono-nerd-font"
        "font-source-code-pro"
        "font-cascadia-code"
    )
    
    for font in "${fonts[@]}"; do
        if ! install_brew_package "$font" true "Nerd Font"; then
            print_warning "Failed to install $font, continuing with others"
        fi
    done
}

# Main installation
main() {
    run_individual_script "nerd-fonts.sh" "Nerd Fonts Collection"
    
    # Tap homebrew fonts if needed
    print_info "Adding Homebrew fonts tap..."
    brew tap homebrew/cask-fonts 2>/dev/null || true
    
    install_nerd_fonts
    
    script_success "Nerd Fonts"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi