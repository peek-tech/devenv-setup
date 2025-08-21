#!/bin/bash

# Macose - Maccy Installation
# Lightweight clipboard manager for macOS

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "maccy.sh" "Maccy (Clipboard Manager)"
    
    # Install Maccy
    if ! install_brew_package "maccy" true "Lightweight clipboard manager for macOS"; then
        script_failure "Maccy" "Failed to install via Homebrew"
    fi
    
    print_info "Maccy installed successfully!"
    print_info "Usage: Press SHIFT (⇧) + COMMAND (⌘) + C to open Maccy"
    print_info "Note: You may need to grant Accessibility permissions in System Settings"
    
    script_success "Maccy"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi