#!/bin/bash

# Omamacy - ncdu Installation
# Interactive disk usage analyzer

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "ncdu.sh" "ncdu (Interactive Disk Usage)"
    
    # Install ncdu
    if ! install_brew_package "ncdu" false "Interactive disk usage analyzer"; then
        script_failure "ncdu" "Failed to install via Homebrew"
    fi
    
    script_success "ncdu"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi