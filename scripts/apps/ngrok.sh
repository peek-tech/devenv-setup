#!/bin/bash

# Omamacy - ngrok Installation
# Secure tunnels to localhost

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "ngrok.sh" "ngrok (Secure Tunnels)"
    
    # Install ngrok
    if ! install_brew_package "ngrok" true "Secure tunnels to localhost"; then
        script_failure "ngrok" "Failed to install via Homebrew"
    fi
    
    print_info "ngrok installed successfully!"
    print_info "Setup: Add your auth token with 'ngrok config add-authtoken <YOUR_TOKEN>'"
    print_info "Get your token from: https://dashboard.ngrok.com/get-started/your-authtoken"
    print_info "Usage: Start a tunnel with 'ngrok http 8080' (or your desired port)"
    print_info "Note: Requires macOS 10.11 or later"
    
    script_success "ngrok"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi