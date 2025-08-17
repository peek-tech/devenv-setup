#!/bin/bash

# Omacy - Arc Installation
# Modern web browser

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "arc.sh" "Arc Browser"
    
    # Install Arc
    if ! install_brew_package "arc" true "Modern web browser"; then
        script_failure "Arc" "Failed to install via Homebrew"
    fi
    
    script_success "Arc"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi