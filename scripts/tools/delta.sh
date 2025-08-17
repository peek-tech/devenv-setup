#!/bin/bash

# Omamacy - Delta Installation
# Better git diff with syntax highlighting

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Apply theme to existing Delta configuration
apply_delta_theme() {
    local theme_name="$1"
    local themes_dir="$HOME/.config/omamacy/themes"
    local theme_file="$themes_dir/$theme_name/delta.conf"
    
    if [ ! -f "$theme_file" ]; then
        print_error "Delta theme file not found: $theme_file"
        return 1
    fi
    
    print_info "Applying $theme_name theme to Git Delta..."
    
    # Delta theme is applied via git config include
    git config --global include.path "$theme_file" 2>/dev/null || true
    
    print_status "Git Delta theme applied: $theme_name"
}

# Main installation
main() {
    # Check for theme-only mode
    if [ -n "$OMAMACY_APPLY_THEME_ONLY" ]; then
        apply_delta_theme "$OMAMACY_APPLY_THEME_ONLY"
        return $?
    fi
    
    # Normal installation mode
    run_individual_script "delta.sh" "Delta (Better Git Diff)"
    
    # Install delta
    if ! install_brew_package "delta" false "Better git diff"; then
        script_failure "delta" "Failed to install via Homebrew"
    fi
    
    print_info "Delta installed. Configure in git with:"
    print_info "  git config --global core.pager delta"
    print_info "  git config --global interactive.diffFilter 'delta --color-only'"
    
    script_success "delta"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi