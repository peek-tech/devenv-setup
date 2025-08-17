#!/bin/bash

# Omacy - Google Chrome Installation
# Web browser

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "google-chrome.sh" "Google Chrome"
    
    # Install Google Chrome
    if ! install_brew_package "google-chrome" true "Web browser"; then
        script_failure "Google Chrome" "Failed to install via Homebrew"
    fi
    
    script_success "Google Chrome"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi