#!/bin/bash

# Omamacy - Themes System Installation
# Installs the theming system and CLI tool

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
OMACY_CONFIG_DIR="$HOME/.config/omacy"
THEMES_DIR="$OMACY_CONFIG_DIR/themes"
BIN_DIR="/usr/local/bin"

# Install themes system
install_themes_system() {
    print_info "Setting up Omacy themes system..."
    
    # Create config directories
    mkdir -p "$OMACY_CONFIG_DIR"
    mkdir -p "$THEMES_DIR"
    
    # Copy theme configurations
    if [ -d "$PROJECT_ROOT/themes" ]; then
        print_info "Installing theme configurations..."
        cp -r "$PROJECT_ROOT/themes"/* "$THEMES_DIR/"
        print_status "Theme configurations installed"
    else
        print_warning "Theme configurations not found in project"
    fi
    
    # Install omacy CLI tool
    if [ -f "$PROJECT_ROOT/bin/omacy" ]; then
        print_info "Installing omacy CLI tool..."
        sudo cp "$PROJECT_ROOT/bin/omacy" "$BIN_DIR/omacy"
        sudo chmod +x "$BIN_DIR/omacy"
        print_status "Omacy CLI tool installed to $BIN_DIR/omacy"
    else
        print_warning "Omacy CLI tool not found in project"
    fi
    
    # Set default theme
    set_default_theme
}

# Set Catppuccin Mocha as default theme
set_default_theme() {
    print_info "Setting Catppuccin Mocha as default theme..."
    
    local current_theme_file="$OMACY_CONFIG_DIR/current-theme"
    echo "catppuccin-mocha" > "$current_theme_file"
    
    # Apply default theme configurations
    apply_default_configurations
    
    print_status "Default theme set to Catppuccin Mocha"
}

# Apply default theme configurations
apply_default_configurations() {
    local theme_dir="$THEMES_DIR/catppuccin-mocha"
    
    # Apply Ghostty theme if Ghostty config exists
    local ghostty_config_dir="$HOME/.config/ghostty"
    if [ -d "$ghostty_config_dir" ] && [ -f "$theme_dir/ghostty.conf" ]; then
        cp "$theme_dir/ghostty.conf" "$ghostty_config_dir/config"
        print_status "Applied Ghostty theme"
    fi
    
    # Apply bat theme
    if [ -f "$theme_dir/bat.conf" ]; then
        local bat_config_dir="$HOME/.config/bat"
        mkdir -p "$bat_config_dir"
        cp "$theme_dir/bat.conf" "$bat_config_dir/config"
        print_status "Applied bat theme"
    fi
    
    # Apply FZF theme to shell config
    if [ -f "$theme_dir/fzf.conf" ]; then
        local shell_config="$(get_shell_config_file)"
        if [ -f "$shell_config" ] && ! grep -q "# Omacy FZF Theme" "$shell_config"; then
            echo "" >> "$shell_config"
            echo "# Omacy FZF Theme" >> "$shell_config"
            cat "$theme_dir/fzf.conf" >> "$shell_config"
            print_status "Applied FZF theme to shell config"
        fi
    fi
    
    # Apply git delta theme
    if [ -f "$theme_dir/delta.conf" ]; then
        git config --global include.path "$theme_dir/delta.conf" 2>/dev/null || true
        print_status "Applied Git Delta theme"
    fi
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
    print_info "Use 'omacy theme list' to see available themes"
    print_info "Use 'omacy theme set <theme-name>' to switch themes"
    print_info "Current theme: catppuccin-mocha"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi