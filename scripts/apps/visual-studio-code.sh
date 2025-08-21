#!/bin/bash

# Macose - Visual Studio Code Installation and Configuration
# Code editor with extensions and configuration

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Configuration functions
# Apply theme to existing VSCode configuration
apply_vscode_theme() {
    local theme_name="$1"
    local vscode_settings="$HOME/Library/Application Support/Code/User/settings.json"
    local themes_dir="$HOME/.config/makase/themes"
    local theme_file="$themes_dir/$theme_name/vscode.json"
    
    if [ ! -f "$vscode_settings" ]; then
        print_error "VSCode settings not found at $vscode_settings"
        return 1
    fi
    
    if [ ! -f "$theme_file" ]; then
        print_error "Theme file not found: $theme_file"
        return 1
    fi
    
    print_info "Applying $theme_name theme to VSCode..."
    
    # Backup existing settings
    cp "$vscode_settings" "$vscode_settings.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Extract theme-specific settings from theme file
    local temp_theme=$(mktemp)
    local temp_settings=$(mktemp)
    
    # Get current settings
    cp "$vscode_settings" "$temp_settings"
    
    # Extract theme settings from theme file
    local color_theme=$(jq -r '.["workbench.colorTheme"] // empty' "$theme_file")
    local icon_theme=$(jq -r '.["workbench.iconTheme"] // empty' "$theme_file")
    local color_customizations=$(jq '.["workbench.colorCustomizations"] // {}' "$theme_file")
    
    # Update settings with theme values
    if [ -n "$color_theme" ] && [ "$color_theme" != "null" ]; then
        jq --arg theme "$color_theme" '.["workbench.colorTheme"] = $theme' "$temp_settings" > "$temp_theme" && mv "$temp_theme" "$temp_settings"
    fi
    
    if [ -n "$icon_theme" ] && [ "$icon_theme" != "null" ]; then
        jq --arg theme "$icon_theme" '.["workbench.iconTheme"] = $theme' "$temp_settings" > "$temp_theme" && mv "$temp_theme" "$temp_settings"
    fi
    
    # Update color customizations
    if [ "$color_customizations" != "{}" ]; then
        jq --argjson customizations "$color_customizations" '.["workbench.colorCustomizations"] = $customizations' "$temp_settings" > "$temp_theme" && mv "$temp_theme" "$temp_settings"
    fi
    
    mv "$temp_settings" "$vscode_settings"
    rm -f "$temp_theme"
    
    print_status "VSCode theme applied: $theme_name"
}

# Apply font to existing VSCode configuration
apply_vscode_font() {
    local font_name="$1"
    local vscode_settings="$HOME/Library/Application Support/Code/User/settings.json"
    
    if [ ! -f "$vscode_settings" ]; then
        print_error "VSCode settings not found at $vscode_settings"
        return 1
    fi
    
    print_info "Applying font '$font_name' to VSCode..."
    
    # Backup existing settings
    cp "$vscode_settings" "$vscode_settings.backup.$(date +%Y%m%d_%H%M%S)"
    
    local temp_settings=$(mktemp)
    
    # Update font settings
    jq --arg font "$font_name" '
        .["editor.fontFamily"] = ($font + ", \"SF Mono\", Monaco, \"Cascadia Code\", \"Roboto Mono\", Consolas, \"Courier New\", monospace") |
        .["terminal.integrated.fontFamily"] = $font
    ' "$vscode_settings" > "$temp_settings"
    
    mv "$temp_settings" "$vscode_settings"
    
    print_status "VSCode font applied: $font_name"
}

# Prompt user for configuration
prompt_user_for_config() {
    print_info "Visual Studio Code is installed. Would you like to configure it now?"
    print_info "This will install essential extensions and configure settings."
    
    printf "\n" >&2
    local configure_choice
    tty_prompt "Configure VSCode? (y/N)" "N" configure_choice
    
    if [[ $configure_choice =~ ^[Yy]$ ]]; then
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

# Setup VSCode configuration
setup_vscode_config() {
    # Check for theme-only mode
    if [ -n "$MACOSE_APPLY_THEME_ONLY" ]; then
        apply_vscode_theme "$MACOSE_APPLY_THEME_ONLY"
        return $?
    fi
    
    # Check for font-only mode
    if [ -n "$MACOSE_APPLY_FONT_ONLY" ]; then
        apply_vscode_font "$MACOSE_APPLY_FONT_ONLY"
        return $?
    fi
    
    # Ask user if they want to configure
    if ! prompt_user_for_config; then
        return 0
    fi
    
    configure_vscode
    configure_vscode_terminal_default
    
    print_status "VSCode configuration complete!"
    print_info "Visual Studio Code is now configured with essential extensions and settings."
}

# Main installation
main() {
    run_individual_script "visual-studio-code.sh" "Visual Studio Code Installation and Configuration"
    
    # Install Visual Studio Code
    if ! install_brew_package "visual-studio-code" true "Code editor"; then
        script_failure "Visual Studio Code" "Failed to install via Homebrew"
    fi
    
    print_status "Visual Studio Code installed successfully"
    
    # Offer configuration setup
    setup_vscode_config
    
    script_success "Visual Studio Code"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi