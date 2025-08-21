#!/bin/bash

# Macose - Dust Installation
# Visual disk usage analyzer

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "dust.sh" "Dust (Visual Disk Usage)"
    
    # Install dust
    if ! install_brew_package "dust" false "Better du - visual disk usage"; then
        script_failure "dust" "Failed to install via Homebrew"
    fi
    
    # Add aliases
    local aliases='
# Dust Aliases
alias du="dust"'
    
    add_to_shell_config "$aliases" "Dust Aliases"
    print_status "Dust aliases configured"
    
    script_success "dust"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi