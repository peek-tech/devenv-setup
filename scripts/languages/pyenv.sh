#!/bin/bash

# Macose - Python Development Environment
# Python version manager (pyenv) with Poetry package manager

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Install pyenv
install_pyenv() {
    if ! install_brew_package "pyenv" false "Python Version Manager"; then
        script_failure "pyenv" "Failed to install via Homebrew"
    fi
}

# Install Python 3.11
install_python() {
    print_info "Installing Python 3.11.9..."
    
    # Source pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
    if pyenv install 3.11.9 && pyenv global 3.11.9; then
        print_status "Python 3.11.9 installed and set as global default"
        
        # Show version
        print_info "Python version: $(python --version)"
        print_info "pip version: $(pip --version)"
    else
        script_failure "Python" "Failed to install Python 3.11.9"
    fi
}

# Install Poetry package manager
install_poetry() {
    # Check if Poetry is already installed
    if command -v poetry &> /dev/null; then
        print_status "Poetry already installed"
        print_info "Poetry version: $(poetry --version)"
        return 0
    fi
    
    print_info "Installing Poetry Python package manager..."
    
    # Initialize pyenv in current session to ensure Python 3.11 is available
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
    # Install Poetry using the official installer
    curl -sSL https://install.python-poetry.org | python3 -
    
    # Add to PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    if command -v poetry &> /dev/null; then
        print_status "Poetry installed successfully"
        print_info "Poetry version: $(poetry --version)"
    else
        print_error "Poetry installation failed"
        return 1
    fi
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

# Add Python tools to shell config
setup_python_shell_config() {
    local python_config='
# Python Development Environment
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi'
    
    add_to_shell_config "$python_config" "Python Development Environment"
    print_status "Python development environment shell configuration added"
}

# Main installation
main() {
    run_individual_script "pyenv.sh" "Python Development Environment (pyenv + Poetry)"
    
    install_pyenv
    install_python
    install_poetry
    configure_poetry
    setup_python_shell_config
    
    script_success "Python Development Environment"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi