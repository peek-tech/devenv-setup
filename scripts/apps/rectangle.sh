#!/bin/bash

# Omamacy - Rectangle Installation
# Window management tool for macOS

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "rectangle.sh" "Rectangle (Window Management)"
    
    # Install Rectangle
    if ! install_brew_package "rectangle" true "Window management tool"; then
        script_failure "Rectangle" "Failed to install via Homebrew"
    fi
    
    script_success "Rectangle"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi