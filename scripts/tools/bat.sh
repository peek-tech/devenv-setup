#!/bin/bash

# Macose - Bat Installation
# Cat replacement with syntax highlighting

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Apply theme to existing Bat configuration
apply_bat_theme() {
    local theme_name="$1"
    local bat_config_dir="$HOME/.config/bat"
    local bat_config="$bat_config_dir/config"
    local themes_dir="$HOME/.config/makase/themes"
    local theme_file="$themes_dir/$theme_name/bat.conf"
    
    if [ ! -f "$theme_file" ]; then
        print_error "Theme file not found: $theme_file"
        return 1
    fi
    
    print_info "Applying $theme_name theme to Bat..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$bat_config_dir"
    
    # Backup existing config if it exists
    if [ -f "$bat_config" ]; then
        cp "$bat_config" "$bat_config.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Copy theme config (bat theme files are complete configs)
    cp "$theme_file" "$bat_config"
    
    print_status "Bat theme applied: $theme_name"
}

# Main installation
main() {
    # Check for theme-only mode
    if [ -n "$MACOSE_APPLY_THEME_ONLY" ]; then
        apply_bat_theme "$MACOSE_APPLY_THEME_ONLY"
        return $?
    fi
    
    # Normal installation mode
    run_individual_script "bat.sh" "Bat (Cat with Syntax Highlighting)"
    
    # Install bat
    if ! install_brew_package "bat" false "Better cat with syntax highlighting"; then
        script_failure "bat" "Failed to install via Homebrew"
    fi
    
    # Add aliases
    local aliases='
# Bat Aliases
alias cat="bat"'
    
    add_to_shell_config "$aliases" "Bat Aliases"
    print_status "Bat aliases configured"
    
    script_success "bat"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi