#!/bin/bash

# Macose - jq Installation
# JSON processor and query tool

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "jq.sh" "jq (JSON Processor)"
    
    # Install jq
    if ! install_brew_package "jq" false "JSON processor - powerful JSON/structured data processor"; then
        script_failure "jq" "Failed to install via Homebrew"
    fi
    
    script_success "jq"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi