#!/bin/bash

# Omacy - lazysql Installation
# Database TUI client with sql alias

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "lazysql.sh" "lazysql (Database TUI)"
    
    # Install lazysql
    if ! install_brew_package "lazysql" false "Database TUI client"; then
        script_failure "lazysql" "Failed to install via Homebrew"
    fi
    
    # Add aliases
    local aliases='
# lazysql Aliases
alias sql="lazysql"'
    
    add_to_shell_config "$aliases" "lazysql Aliases"
    print_status "lazysql aliases configured"
    
    script_success "lazysql"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi