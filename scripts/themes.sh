#!/bin/bash

# Macose - Themes System Installation
# Installs the theming system and CLI tool

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Load Homebrew environment
load_homebrew_env() {
    if [[ $(uname -m) == 'arm64' ]] && [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
MACOSE_CONFIG_DIR="$HOME/.config/macose"
THEMES_DIR="$MACOSE_CONFIG_DIR/themes"
BIN_DIR="/usr/local/bin"

# Install themes system
install_themes_system() {
    print_info "Setting up Macose themes system..."
    
    # Create config directories
    mkdir -p "$MACOSE_CONFIG_DIR"
    mkdir -p "$THEMES_DIR"
    
    # Copy theme configurations
    if [ -d "$PROJECT_ROOT/themes" ]; then
        print_info "Installing theme configurations..."
        cp -r "$PROJECT_ROOT/themes"/* "$THEMES_DIR/"
        print_status "Theme configurations installed"
    else
        print_warning "Theme configurations not found in project"
    fi
    
    # Set default theme
    set_default_theme
}

# Set Catppuccin Mocha as default theme and FiraCode Nerd Font as default font
set_default_theme() {
    print_info "Setting Catppuccin Mocha as default theme..."
    
    local current_theme_file="$MACOSE_CONFIG_DIR/current-theme"
    echo "catppuccin-mocha" > "$current_theme_file"
    
    # Apply default theme configurations
    apply_default_configurations
    
    # Set default font
    set_default_font
    
    print_status "Default theme set to Catppuccin Mocha"
}

# Apply default theme configurations using delegation pattern
apply_default_configurations() {
    local default_theme="catppuccin-mocha"
    
    print_info "Applying default theme configurations via individual scripts..."
    
    # Get the directory where this script is located
    local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    
    # List of themed applications and their script paths
    local themed_apps=(
        "apps/ghostty.sh"
        "apps/vscode-config.sh"
        "apps/tmux.sh"
        "tools/bat.sh"
        "tools/starship.sh"
        "tools/fzf.sh"
        "tools/delta.sh"
    )
    
    print_info "Delegating theme application to individual scripts..."
    
    # Apply theme via individual scripts
    for app_script in "${themed_apps[@]}"; do
        local script_path="$script_dir/$app_script"
        local app_name=$(basename "$app_script" .sh)
        
        if [ -f "$script_path" ]; then
            print_info "Applying theme to $app_name..."
            # Set environment variable and call script
            if MACOSE_APPLY_THEME_ONLY="$default_theme" "$script_path" 2>/dev/null; then
                print_status "Applied $app_name theme via delegation"
            else
                print_warning "Failed to apply theme to $app_name (may not be installed yet)"
            fi
        else
            print_warning "Script not found: $script_path"
        fi
    done
    
    print_status "Default theme delegation complete"
}

# Set FiraCode Nerd Font as default font using delegation pattern
set_default_font() {
    local default_font="FiraCode Nerd Font"
    
    print_info "Setting FiraCode Nerd Font as default font..."
    
    # Get the directory where this script is located
    local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    
    # List of applications that support font configuration
    local font_apps=(
        "apps/ghostty.sh"
        "apps/vscode-config.sh"
    )
    
    print_info "Delegating font application to individual scripts..."
    
    # Apply font via individual scripts
    for app_script in "${font_apps[@]}"; do
        local script_path="$script_dir/$app_script"
        local app_name=$(basename "$app_script" .sh)
        
        if [ -f "$script_path" ]; then
            print_info "Applying font to $app_name..."
            # Set environment variable and call script
            if MACOSE_APPLY_FONT_ONLY="$default_font" "$script_path" 2>/dev/null; then
                print_status "Applied $app_name font via delegation"
            else
                print_warning "Failed to apply font to $app_name (may not be installed yet)"
            fi
        else
            print_warning "Script not found: $script_path"
        fi
    done
    
    print_status "Default font delegation complete"
}

# Get shell config file
get_shell_config_file() {
    local user_shell="$(basename "$SHELL")"
    case "$user_shell" in
        bash)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

# Install theme-related packages
install_theme_packages() {
    print_info "Installing theme-related packages..."
    
    # Install jq for JSON processing
    if ! command -v jq &> /dev/null; then
        print_info "Installing jq for theme configuration..."
        brew install jq
    fi
    
    # Note: Catppuccin themes for various applications are often available as extensions/plugins
    # For VSCode: Catppuccin extension should be installed manually or via extension installation
    print_info "Note: For full theme support, install application-specific theme extensions:"
    print_info "  - VSCode: Install 'Catppuccin for VSCode' extension"
    print_info "  - Neovim: Install catppuccin/nvim plugin"
    print_info "  - Bat: Catppuccin themes should be available via bat --list-themes"
}

# Main execution
main() {
    # Load Homebrew environment first
    load_homebrew_env
    
    install_theme_packages
    install_themes_system
    
    print_status "Themes system installation complete!"
    print_info "Use 'omamacy theme list' to see available themes"
    print_info "Use 'omamacy theme set <theme-name>' to switch themes"
    print_info "Use 'omamacy font set <font-name>' to change fonts"
    print_info "Current theme: catppuccin-mocha"
    print_info "Default font: FiraCode Nerd Font"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi