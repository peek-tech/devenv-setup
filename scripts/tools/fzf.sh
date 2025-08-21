#!/bin/bash

# Macose - FZF Installation
# Fuzzy finder with shell integration

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Apply theme to existing FZF configuration
apply_fzf_theme() {
    local theme_name="$1"
    local themes_dir="$HOME/.config/makase/themes"
    local theme_file="$themes_dir/$theme_name/fzf.conf"
    
    if [ ! -f "$theme_file" ]; then
        print_error "FZF theme file not found: $theme_file"
        return 1
    fi
    
    print_info "Applying $theme_name theme to FZF..."
    
    # Get shell config file
    local shell_config="$(get_shell_config_file)"
    
    if [ ! -f "$shell_config" ]; then
        print_error "Shell config not found: $shell_config"
        return 1
    fi
    
    # Backup shell config
    cp "$shell_config" "$shell_config.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Remove existing FZF theme block
    local temp_config=$(mktemp)
    awk '
        /^# Macose FZF Theme/ { skip=1; next }
        skip && /^export FZF_DEFAULT_OPTS/ { 
            # Skip the export line and any continuation lines
            while (getline > 0 && /\\$/) { }
            skip=0
            next
        }
        skip && /^$/ { skip=0; next }
        !skip { print }
    ' "$shell_config" > "$temp_config"
    
    # Add new theme
    echo "" >> "$temp_config"
    echo "# Macose FZF Theme" >> "$temp_config"
    cat "$theme_file" >> "$temp_config"
    
    # Replace shell config
    mv "$temp_config" "$shell_config"
    
    print_status "FZF theme applied: $theme_name"
    print_info "Restart your terminal or source your shell config to see changes"
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

# Main installation
main() {
    # Check for theme-only mode
    if [ -n "$MACOSE_APPLY_THEME_ONLY" ]; then
        apply_fzf_theme "$MACOSE_APPLY_THEME_ONLY"
        return $?
    fi
    
    # Normal installation mode
    run_individual_script "fzf.sh" "FZF (Fuzzy Finder)"
    
    # Install fzf
    if ! install_brew_package "fzf" false "Fuzzy finder for commands/files"; then
        script_failure "fzf" "Failed to install via Homebrew"
    fi
    
    # Add shell integration
    local user_shell="$(basename "$SHELL")"
    local integration=""
    
    case "$user_shell" in
        bash)
            integration='
# FZF Shell Integration
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)" 2>/dev/null || true
fi'
            ;;
        zsh)
            integration='
# FZF Shell Integration
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)" 2>/dev/null || true
fi'
            ;;
        *)
            print_warning "FZF shell integration not configured for $user_shell"
            ;;
    esac
    
    if [ -n "$integration" ]; then
        add_to_shell_config "$integration" "FZF Shell Integration"
        print_status "FZF shell integration configured"
    fi
    
    script_success "fzf"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi