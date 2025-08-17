#!/bin/bash

# Omamacy - VSCode Configuration
# Configures Visual Studio Code with extensions and settings

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Prompt user for configuration (with TTY detection)
prompt_user_for_config() {
    print_info "Visual Studio Code is installed. Would you like to configure it now?"
    print_info "This will install essential extensions and configure settings."
    
    local configure_choice
    if tty_prompt "Configure VSCode?" "y" configure_choice; then
        return 0
    else
        print_info "Skipping VSCode configuration. You can run this script later to configure."
        return 1
    fi
}

# Configure VSCode
configure_vscode() {
    if ! command -v code &> /dev/null; then
        print_info "VSCode 'code' command not available. Skipping configuration."
        print_info "Note: You may need to install 'code' command via VSCode Command Palette > 'Shell Command: Install code command in PATH'"
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
    run_individual_script "vscode-config.sh" "VSCode Configuration (Optional)"
    
    # Check if VSCode is installed (as a cask)
    if ! brew list --cask visual-studio-code &>/dev/null; then
        print_info "Visual Studio Code is not installed. Skipping configuration."
        script_success "vscode-config"
        return 0
    fi
    
    # Ask user if they want to configure
    if ! prompt_user_for_config; then
        script_success "vscode-config"
        return 0
    fi
    
    configure_vscode
    configure_vscode_terminal_default
    
    print_status "VSCode configuration complete!"
    print_info "Visual Studio Code is now configured with essential extensions and settings."
    
    script_success "vscode-config"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi