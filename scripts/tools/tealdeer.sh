#!/bin/bash

# Omamacy - tealdeer Installation
# Fast tldr client for concise command examples

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "tealdeer.sh" "tealdeer (Fast tldr Client)"
    
    # Install tealdeer
    if ! install_brew_package "tealdeer" false "Better man - concise command examples (tldr)"; then
        script_failure "tealdeer" "Failed to install via Homebrew"
    fi
    
    # Update tldr database
    print_info "Updating tldr database..."
    tldr --update 2>/dev/null || true
    
    script_success "tealdeer"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi