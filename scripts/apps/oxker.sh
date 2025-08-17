#!/bin/bash

# Omacy - Oxker Installation
# TUI for Docker/container management

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "oxker.sh" "Oxker (Container Management TUI)"
    
    # Install Oxker
    if ! install_brew_package "oxker" false "TUI for Docker/container management"; then
        script_failure "oxker" "Failed to install via Homebrew"
    fi
    
    print_info "Oxker provides a terminal interface for managing containers"
    print_info "Works with Docker/Podman - use 'oxker' command to launch"
    
    script_success "oxker"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi