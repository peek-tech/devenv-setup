#!/bin/bash

# Macose - Firefox Installation
# Web browser

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "firefox.sh" "Firefox"
    
    # Install Firefox
    if ! install_brew_package "firefox" true "Web browser"; then
        script_failure "Firefox" "Failed to install via Homebrew"
    fi
    
    script_success "Firefox"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi