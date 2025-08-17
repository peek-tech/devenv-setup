#!/bin/bash

# Omamacy - Poetry Installation
# Python package manager

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Install Poetry
install_poetry() {
    # Check if Poetry is already installed
    if command -v poetry &> /dev/null; then
        print_status "Poetry already installed"
        print_info "Poetry version: $(poetry --version)"
        return 0
    fi
    
    print_info "Installing Poetry..."
    
    # Install Poetry using the official installer
    curl -sSL https://install.python-poetry.org | python3 -
    
    # Add to PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    if command -v poetry &> /dev/null; then
        print_status "Poetry installed successfully"
        print_info "Poetry version: $(poetry --version)"
    else
        script_failure "Poetry" "Installation failed"
    fi
}

# Add Poetry to shell config
setup_poetry_shell_config() {
    local poetry_config='
# Poetry Configuration
export PATH="$HOME/.local/bin:$PATH"'
    
    add_to_shell_config "$poetry_config" "Poetry Configuration"
    print_status "Poetry shell configuration added"
}

# Configure Poetry
configure_poetry() {
    if command -v poetry &> /dev/null; then
        print_info "Configuring Poetry..."
        
        # Configure Poetry to create virtual environments in project directory
        poetry config virtualenvs.in-project true
        
        print_status "Poetry configured to create .venv in project directories"
    fi
}

# Main installation
main() {
    run_individual_script "poetry.sh" "Poetry (Python Package Manager)"
    
    install_poetry
    setup_poetry_shell_config
    configure_poetry
    
    script_success "Poetry"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi