#!/bin/bash

# Macose - Brave Browser Installation
# Privacy-focused web browser

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "brave-browser.sh" "Brave Browser"
    
    # Install Brave Browser
    if ! install_brew_package "brave-browser" true "Privacy-focused web browser"; then
        script_failure "Brave Browser" "Failed to install via Homebrew"
    fi
    
    script_success "Brave Browser"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi