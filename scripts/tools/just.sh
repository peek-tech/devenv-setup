#!/bin/bash

# Omamacy - just Installation
# Modern task runner and command organizer

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "just.sh" "just (Command Runner)"
    
    # Install just
    if ! install_brew_package "just" false "Modern task runner - better than make"; then
        script_failure "just" "Failed to install via Homebrew"
    fi
    
    script_success "just"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi