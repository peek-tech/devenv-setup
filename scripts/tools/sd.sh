#!/bin/bash

# Macose - sd Installation
# Intuitive find and replace tool

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "sd.sh" "sd (Find and Replace Tool)"
    
    # Install sd
    if ! install_brew_package "sd" false "Better sed - intuitive find-and-replace"; then
        script_failure "sd" "Failed to install via Homebrew"
    fi
    
    script_success "sd"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi