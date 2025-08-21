#!/bin/bash

# Macose - Fira Code Font Installation
# Coding font with ligatures

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "fira-code.sh" "Fira Code Font"
    
    # Install Fira Code
    if ! install_brew_package "font-fira-code" true "Coding font with ligatures"; then
        script_failure "Fira Code" "Failed to install via Homebrew"
    fi
    
    script_success "Fira Code"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi