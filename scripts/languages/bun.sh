#!/bin/bash

# Omacy - Bun Installation
# Fast JavaScript runtime and package manager

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "bun.sh" "Bun (Fast JavaScript Runtime)"
    
    # Install Bun
    if ! install_brew_package "bun" false "Fast JavaScript runtime and package manager"; then
        script_failure "bun" "Failed to install via Homebrew"
    fi
    
    print_info "Bun version: $(bun --version)"
    
    script_success "Bun"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi