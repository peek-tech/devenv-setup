#!/bin/bash

# Omacy - VSCode Configuration
# Configures Visual Studio Code with extensions and settings

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Configure VSCode
configure_vscode() {
    if ! command -v code &> /dev/null; then
        print_warning "VSCode not found - skipping configuration"
        return 0
    fi
    
    print_info "Configuring Visual Studio Code..."
    
    # Essential extensions
    local extensions=(
        "ms-python.python"
        "ms-vscode.vscode-typescript-next"
        "bradlc.vscode-tailwindcss"
        "esbenp.prettier-vscode"
        "ms-vscode.vscode-eslint"
        "GitHub.copilot"
        "GitHub.copilot-chat"
        "ms-vscode-remote.remote-ssh"
        "ms-vscode.remote-explorer"
        "catppuccin.catppuccin-vsc"
        "PKief.material-icon-theme"
    )
    
    for ext in "${extensions[@]}"; do
        if code --list-extensions | grep -q "^$ext$"; then
            print_status "Extension $ext already installed"
        else
            print_info "Installing extension: $ext"
            code --install-extension "$ext"
        fi
    done
}

# Configure VSCode as default terminal
configure_vscode_terminal_default() {
    print_info "Configuring VSCode as default Git editor..."
    
    # Set VSCode as default git editor
    git config --global core.editor "code --wait"
    
    print_status "VSCode configured as default Git editor"
}

# Main execution
main() {
    configure_vscode
    configure_vscode_terminal_default
    print_status "VSCode configuration complete!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi