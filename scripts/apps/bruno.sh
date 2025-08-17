#!/bin/bash

# Omamacy - Bruno Installation
# API client for testing REST, GraphQL, and gRPC

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "bruno.sh" "Bruno (API Client)"
    
    # Install Bruno
    if ! install_brew_package "bruno" true "API client for testing REST, GraphQL, and gRPC"; then
        script_failure "Bruno" "Failed to install via Homebrew"
    fi
    
    script_success "Bruno"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi