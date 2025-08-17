#!/bin/bash

# Omamacy - Microsoft Edge Installation
# Web browser

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "microsoft-edge.sh" "Microsoft Edge"
    
    # Install Microsoft Edge
    if ! install_brew_package "microsoft-edge" true "Web browser"; then
        script_failure "Microsoft Edge" "Failed to install via Homebrew"
    fi
    
    script_success "Microsoft Edge"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi