#!/bin/bash

# Omacy - Delta Installation
# Better git diff with syntax highlighting

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "delta.sh" "Delta (Better Git Diff)"
    
    # Install delta
    if ! install_brew_package "delta" false "Better git diff"; then
        script_failure "delta" "Failed to install via Homebrew"
    fi
    
    print_info "Delta installed. Configure in git with:"
    print_info "  git config --global core.pager delta"
    print_info "  git config --global interactive.diffFilter 'delta --color-only'"
    
    script_success "delta"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi