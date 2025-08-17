#!/bin/bash

# Omacy - Ripgrep Installation
# Fast text search tool with grep aliases

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "ripgrep.sh" "Ripgrep (Fast Text Search)"
    
    # Install ripgrep
    if ! install_brew_package "ripgrep" false "Better grep - fast text search"; then
        script_failure "ripgrep" "Failed to install via Homebrew"
    fi
    
    # Add aliases
    local aliases='
# Ripgrep Aliases
alias grep="rg"'
    
    add_to_shell_config "$aliases" "Ripgrep Aliases"
    print_status "Ripgrep aliases configured"
    
    script_success "ripgrep"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi