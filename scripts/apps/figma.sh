#!/bin/bash

# Macose - Figma Installation
# UI/UX design application

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "figma.sh" "Figma (UI/UX Design)"
    
    # Install Figma
    if ! install_brew_package "figma" true "UI/UX design application"; then
        script_failure "Figma" "Failed to install via Homebrew"
    fi
    
    script_success "Figma"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi