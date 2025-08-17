#!/bin/bash

# Omamacy - Bat Installation
# Cat replacement with syntax highlighting

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "bat.sh" "Bat (Cat with Syntax Highlighting)"
    
    # Install bat
    if ! install_brew_package "bat" false "Better cat with syntax highlighting"; then
        script_failure "bat" "Failed to install via Homebrew"
    fi
    
    # Add aliases
    local aliases='
# Bat Aliases
alias cat="bat"'
    
    add_to_shell_config "$aliases" "Bat Aliases"
    print_status "Bat aliases configured"
    
    script_success "bat"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi