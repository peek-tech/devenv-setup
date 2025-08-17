#!/bin/bash

# Omamacy - Claude App Installation
# AI assistant desktop application

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "claude.sh" "Claude AI Assistant"
    
    # Install Claude
    if ! install_brew_package "claude" true "AI assistant desktop application"; then
        script_failure "Claude" "Failed to install via Homebrew"
    fi
    
    script_success "Claude"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi