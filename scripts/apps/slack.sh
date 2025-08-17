#!/bin/bash

# Omamacy - Slack Installation
# Team communication and collaboration platform

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "slack.sh" "Slack (Team Communication)"
    
    # Install Slack
    if ! install_brew_package "slack" true "Team communication and collaboration platform"; then
        script_failure "Slack" "Failed to install via Homebrew"
    fi
    
    script_success "Slack"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi