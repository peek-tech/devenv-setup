#!/bin/bash

# Omamacy - Procs Installation
# Enhanced process viewer

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "procs.sh" "Procs (Enhanced Process Viewer)"
    
    # Install procs
    if ! install_brew_package "procs" false "Better ps - enhanced process viewer"; then
        script_failure "procs" "Failed to install via Homebrew"
    fi
    
    # Add aliases
    local aliases='
# Procs Aliases
alias ps="procs"'
    
    add_to_shell_config "$aliases" "Procs Aliases"
    print_status "Procs aliases configured"
    
    script_success "procs"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi