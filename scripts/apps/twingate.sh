#!/bin/bash

# Macose - Twingate Installation
# Zero Trust Network Access platform

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "twingate.sh" "Twingate (Zero Trust Network Access)"
    
    # Install Twingate
    if ! install_brew_package "twingate" true "Zero Trust Network Access platform"; then
        script_failure "Twingate" "Failed to install via Homebrew"
    fi
    
    print_info "Twingate installed successfully!"
    print_info "Setup: You'll need to configure VPN settings and enable system extension"
    print_info "Note: Requires macOS 13.0 or later"
    print_info "First run will prompt for notifications, VPN configs, and system extension permissions"
    
    script_success "Twingate"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi