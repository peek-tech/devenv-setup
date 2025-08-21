#!/bin/bash

# Macose - tree Installation
# Directory tree viewer

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "tree.sh" "tree (Directory Tree Viewer)"
    
    # Install tree
    if ! install_brew_package "tree" false "Directory tree viewer"; then
        script_failure "tree" "Failed to install via Homebrew"
    fi
    
    script_success "tree"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi