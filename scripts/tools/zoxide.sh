#!/bin/bash

# Omamacy - Zoxide Installation
# Smart directory navigation with shell integration

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "zoxide.sh" "Zoxide (Smart Directory Navigation)"
    
    # Install zoxide
    if ! install_brew_package "zoxide" false "Smart directory navigation"; then
        script_failure "zoxide" "Failed to install via Homebrew"
    fi
    
    # Add shell integration and aliases
    local user_shell="$(basename "$SHELL")"
    local integration=""
    
    case "$user_shell" in
        bash)
            integration='
# Zoxide Smart Directory Navigation
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)" 2>/dev/null || true
fi
alias cd="z"  # zoxide smart cd'
            ;;
        zsh)
            integration='
# Zoxide Smart Directory Navigation
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)" 2>/dev/null || true
fi
alias cd="z"  # zoxide smart cd'
            ;;
        *)
            print_warning "Zoxide shell integration not configured for $user_shell"
            integration='
# Zoxide Smart Directory Navigation
alias cd="z"  # zoxide smart cd'
            ;;
    esac
    
    add_to_shell_config "$integration" "Zoxide Smart Directory Navigation"
    print_status "Zoxide shell integration configured"
    
    script_success "zoxide"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi