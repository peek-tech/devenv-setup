#!/bin/bash

# Omacy - GitHub CLI Installation
# GitHub command line interface

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "gh.sh" "GitHub CLI"
    
    # Install GitHub CLI
    if ! install_brew_package "gh" false "GitHub CLI"; then
        script_failure "gh" "Failed to install via Homebrew"
    fi
    
    print_info "GitHub CLI installed. You can authenticate with: gh auth login"
    
    script_success "GitHub CLI"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi