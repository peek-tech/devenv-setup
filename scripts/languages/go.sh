#!/bin/bash

# Macose - Go Installation
# Go programming language

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "go.sh" "Go Programming Language"
    
    # Install Go
    if ! install_brew_package "go" false "Go programming language"; then
        script_failure "go" "Failed to install via Homebrew"
    fi
    
    # Add Go environment variables
    local go_config='
# Go Configuration
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"'
    
    add_to_shell_config "$go_config" "Go Configuration"
    print_status "Go environment configuration added"
    
    # Create GOPATH directory
    mkdir -p "$HOME/go/bin"
    mkdir -p "$HOME/go/src"
    mkdir -p "$HOME/go/pkg"
    
    print_info "Go version: $(go version)"
    
    script_success "Go"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi