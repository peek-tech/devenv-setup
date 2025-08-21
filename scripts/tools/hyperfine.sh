#!/bin/bash

# Macose - hyperfine Installation
# Benchmarking tool for command performance

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "hyperfine.sh" "hyperfine (Benchmarking Tool)"
    
    # Install hyperfine
    if ! install_brew_package "hyperfine" false "Better time - benchmarking tool"; then
        script_failure "hyperfine" "Failed to install via Homebrew"
    fi
    
    script_success "hyperfine"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi