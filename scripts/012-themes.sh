#!/bin/bash

# Omacy - Themes and Customization
# Configures themes and visual customizations

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
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

# Add content to shell config
add_to_shell_config() {
    local content="$1"
    local description="$2"
    local config_file="$(get_shell_config_file)"
    
    # Create config file if it doesn't exist
    mkdir -p "$(dirname "$config_file")"
    touch "$config_file"
    
    # Check if content already exists
    if grep -Fq "$content" "$config_file"; then
        return 0
    fi
    
    # Add content with description
    echo "" >> "$config_file"
    echo "# $description" >> "$config_file"
    echo "$content" >> "$config_file"
}

# Configure tool themes
configure_tool_themes() {
    print_info "Configuring tool themes and aliases..."
    
    # Modern CLI aliases
    local aliases='
# Modern CLI Tool Aliases
alias ls="eza --icons"
alias ll="eza -l --icons"
alias la="eza -la --icons"
alias tree="eza --tree --icons"
alias cat="bat"
alias grep="rg"
alias find="fd"
alias ps="procs"
alias du="dust"
alias top="glances"
alias cd="z"  # zoxide smart cd
'
    
    add_to_shell_config "$aliases" "Modern CLI Tool Aliases"
    
    # Git aliases
    local git_aliases='
# Git Aliases
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias lg="lazygit"
'
    
    add_to_shell_config "$git_aliases" "Git Aliases"
    
    # Database aliases
    local db_aliases='
# Database Aliases  
alias pg="psql"
alias mongo="mongosh"
alias sql="lazysql"
'
    
    add_to_shell_config "$db_aliases" "Database Aliases"
    
    print_status "Tool themes and aliases configured"
}

# Create development directories
create_development_directories() {
    print_info "Creating development directories..."
    
    local dev_dirs=(
        "$HOME/Development"
        "$HOME/Development/Projects"
        "$HOME/Development/Learning"
        "$HOME/Development/Scripts"
        "$HOME/Development/Sandbox"
    )
    
    for dir in "${dev_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_status "Created directory: $dir"
        else
            print_status "Directory already exists: $dir"
        fi
    done
}

# Main execution
main() {
    configure_tool_themes
    create_development_directories
    print_status "Themes and customization complete!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi