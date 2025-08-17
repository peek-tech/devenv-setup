#!/bin/bash

# Omacy - Glances Installation
# System monitoring TUI with top alias

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "glances.sh" "Glances (System Monitor)"
    
    # Install glances
    if ! install_brew_package "glances" false "System monitor TUI"; then
        script_failure "glances" "Failed to install via Homebrew"
    fi
    
    # Add aliases
    local aliases='
# Glances Aliases
alias top="glances"'
    
    add_to_shell_config "$aliases" "Glances Aliases"
    print_status "Glances aliases configured"
    
    script_success "glances"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi