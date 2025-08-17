#!/bin/bash

# Omacy - Lazygit Installation
# Git TUI with helpful aliases

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "lazygit.sh" "Lazygit (Git TUI)"
    
    # Install Lazygit
    if ! install_brew_package "lazygit" false "Git TUI"; then
        script_failure "lazygit" "Failed to install via Homebrew"
    fi
    
    # Add aliases
    local aliases='
# Lazygit Aliases
alias lg="lazygit"'
    
    add_to_shell_config "$aliases" "Lazygit Aliases"
    print_status "Lazygit aliases configured"
    
    script_success "Lazygit"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi