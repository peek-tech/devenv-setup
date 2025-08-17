#!/bin/bash

# Omamacy - KeyCastr Installation
# Open-source keystroke visualizer for macOS

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "keycastr.sh" "KeyCastr (Keystroke Visualizer)"
    
    # Install KeyCastr
    if ! install_brew_package "keycastr" true "Open-source keystroke visualizer for macOS"; then
        script_failure "KeyCastr" "Failed to install via Homebrew"
    fi
    
    print_info "KeyCastr installed successfully!"
    print_info "Usage: Great for screencasts and presentations to show keyboard shortcuts"
    print_info "Note: You may need to grant Input Monitoring permissions in System Settings"
    
    script_success "KeyCastr"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi