#!/bin/bash

# Omacy - NVM Installation
# Node Version Manager with Node 20

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Install nvm and Node.js
install_nvm() {
    # Check if nvm is already installed
    if [ -d "$HOME/.nvm" ] && [ -s "$HOME/.nvm/nvm.sh" ]; then
        print_status "nvm already installed"
        return 0
    fi
    
    print_info "Installing nvm (Node Version Manager)..."
    
    # Download and install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        print_status "nvm installed successfully"
    else
        script_failure "nvm" "Installation failed"
    fi
}

# Install Node.js 20
install_node() {
    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    print_info "Installing Node.js 20..."
    
    if nvm install 20 && nvm use 20 && nvm alias default 20; then
        print_status "Node.js 20 installed and set as default"
        
        # Show versions
        print_info "Node version: $(node --version)"
        print_info "npm version: $(npm --version)"
    else
        script_failure "Node.js" "Failed to install Node.js 20"
    fi
}

# Add nvm to shell config
setup_nvm_shell_config() {
    local nvm_config='
# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
    
    add_to_shell_config "$nvm_config" "NVM Configuration"
    print_status "nvm shell configuration added"
}

# Main installation
main() {
    run_individual_script "nvm.sh" "NVM & Node.js 20"
    
    install_nvm
    setup_nvm_shell_config
    install_node
    
    script_success "nvm & Node.js 20"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi