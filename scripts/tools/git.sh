#!/bin/bash

# Omamacy - Git Installation
# Version control system with helpful aliases

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Main installation
main() {
    run_individual_script "git.sh" "Git (Version Control)"
    
    # Install git
    if ! install_brew_package "git" false "Distributed version control system"; then
        script_failure "git" "Failed to install via Homebrew"
    fi
    
    # Add helpful git aliases
    local aliases='
# Git Aliases
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"'
    
    add_to_shell_config "$aliases" "Git Aliases"
    print_status "Git aliases configured"
    
    script_success "git"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi