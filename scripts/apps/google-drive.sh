#!/bin/bash

# Omamacy - Google Drive Installation
# Google Drive for file sync and collaboration

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "google-drive.sh" "Google Drive (File Sync)"
    
    # Install Google Drive
    if ! install_brew_package "google-drive" true "Google Drive for file sync and collaboration"; then
        script_failure "Google Drive" "Failed to install via Homebrew"
    fi
    
    script_success "Google Drive"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi