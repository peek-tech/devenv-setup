#!/bin/bash

# Omacy - Visual Studio Code Installation
# Code editor with extensions and configuration

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "visual-studio-code.sh" "Visual Studio Code"
    
    # Install Visual Studio Code
    if ! install_brew_package "visual-studio-code" true "Code editor"; then
        script_failure "Visual Studio Code" "Failed to install via Homebrew"
    fi
    
    print_info "Visual Studio Code installed successfully"
    print_info "Optional: Run vscode-config.sh to install extensions and configure settings"
    
    script_success "Visual Studio Code"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi