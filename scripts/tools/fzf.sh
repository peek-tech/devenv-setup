#!/bin/bash

# Omamacy - FZF Installation
# Fuzzy finder with shell integration

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
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