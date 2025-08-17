#!/bin/bash

# Omacy - Claude Code Installation
# AI assistant command line tool

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "claude-code.sh" "Claude Code CLI"
    
    # Install Claude Code
    if ! install_brew_package "claude-code" false "AI assistant command line tool"; then
        script_failure "claude-code" "Failed to install via Homebrew"
    fi
    
    script_success "Claude Code"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi