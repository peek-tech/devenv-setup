#!/bin/bash

# Macose - Tokei Installation
# Fast code statistics tool

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "tokei.sh" "Tokei (Code Statistics)"
    
    # Install tokei
    if ! install_brew_package "tokei" false "Code statistics tool - count lines of code"; then
        script_failure "tokei" "Failed to install via Homebrew"
    fi
    
    # Add aliases
    local aliases='
# Tokei Aliases
alias loc="tokei"
alias codestats="tokei"'
    
    add_to_shell_config "$aliases" "Tokei Aliases"
    print_status "Tokei aliases configured"
    
    script_success "tokei"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi