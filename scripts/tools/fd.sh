#!/bin/bash

# Omamacy - fd Installation
# User-friendly file search tool

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "fd.sh" "fd (User-friendly File Search)"
    
    # Install fd
    if ! install_brew_package "fd" false "Better find - user-friendly file search"; then
        script_failure "fd" "Failed to install via Homebrew"
    fi
    
    # Add aliases
    local aliases='
# fd Aliases
alias find="fd"'
    
    add_to_shell_config "$aliases" "fd Aliases"
    print_status "fd aliases configured"
    
    script_success "fd"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi