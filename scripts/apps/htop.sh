#!/bin/bash

# Omacy - htop Installation
# Interactive process viewer

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "htop.sh" "htop (Interactive Process Viewer)"
    
    # Install htop
    if ! install_brew_package "htop" false "Interactive process viewer"; then
        script_failure "htop" "Failed to install via Homebrew"
    fi
    
    script_success "htop"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi