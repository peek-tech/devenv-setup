#!/bin/bash

# Omacy - Neovim Installation
# Modern Vim-based editor

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "neovim.sh" "Neovim"
    
    # Install Neovim
    if ! install_brew_package "neovim" false "Modern Vim-based editor"; then
        script_failure "neovim" "Failed to install via Homebrew"
    fi
    
    print_info "Neovim installed successfully"
    print_info "Optional: Run nvim-config.sh to set up a configuration framework"
    
    script_success "Neovim"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi