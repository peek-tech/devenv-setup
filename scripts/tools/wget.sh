#!/bin/bash

# Omamacy - wget Installation
# Network downloader

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "wget.sh" "wget (Network Downloader)"
    
    # Install wget
    if ! install_brew_package "wget" false "Network downloader"; then
        script_failure "wget" "Failed to install via Homebrew"
    fi
    
    script_success "wget"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi