#!/bin/bash

# Omamacy - pyenv Installation
# Python Version Manager with Python 3.11

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

# Add pyenv to shell config
setup_pyenv_shell_config() {
    local pyenv_config='
# pyenv Configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi'
    
    add_to_shell_config "$pyenv_config" "pyenv Configuration"
    print_status "pyenv shell configuration added"
}

# Main installation
main() {
    run_individual_script "pyenv.sh" "pyenv & Python 3.11"
    
    install_pyenv
    setup_pyenv_shell_config
    install_python
    
    script_success "pyenv & Python 3.11"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi