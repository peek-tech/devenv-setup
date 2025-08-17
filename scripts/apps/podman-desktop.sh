#!/bin/bash

# Omacy - Podman Desktop Installation
# Container management GUI for Podman

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "podman-desktop.sh" "Podman Desktop (Container GUI)"
    
    # Install Podman Desktop
    if ! install_brew_package "podman-desktop" true "Container management GUI"; then
        script_failure "Podman Desktop" "Failed to install via Homebrew"
    fi
    
    print_info "Podman Desktop provides a GUI for managing containers and images"
    
    script_success "Podman Desktop"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi