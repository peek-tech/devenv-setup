#!/bin/bash

# Omacy - Eza Installation
# Modern ls replacement with icons and colors

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "eza.sh" "Eza (Modern ls Replacement)"
    
    # Install eza
    if ! install_brew_package "eza" false "Better ls - modern replacement with icons"; then
        script_failure "eza" "Failed to install via Homebrew"
    fi
    
    # Add aliases
    local aliases='
# Eza Aliases
alias ls="eza --icons"
alias ll="eza -l --icons"
alias la="eza -la --icons"
alias tree="eza --tree --icons"'
    
    add_to_shell_config "$aliases" "Eza Aliases"
    print_status "Eza aliases configured"
    
    script_success "eza"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi