#!/bin/bash

# Omacy - Shell Completions Setup
# Configures shell completions for modern CLI tools

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

# Setup shell completions
setup_shell_completions() {
    local user_shell="$(basename "$SHELL")"
    
    print_info "Setting up shell completions for $user_shell..."
    
    case "$user_shell" in
        bash)
            setup_bash_completions
            ;;
        zsh)
            setup_zsh_completions
            ;;
        fish)
            print_info "Fish shell has built-in completions - no additional setup needed"
            ;;
        *)
            print_warning "Shell completions not configured for $user_shell"
            return 0
            ;;
    esac
    
    print_status "Shell completions setup complete!"
}

# Setup Bash completions
setup_bash_completions() {
    local completions_file="$HOME/.completions"
    
    print_info "Setting up Bash completions..."
    
    # Create simple completions file
    cat > "$completions_file" << 'EOF'
#!/bin/bash
# CLI Tools Completions for Bash

# Load homebrew completions if available
if command -v brew &> /dev/null; then
    HOMEBREW_PREFIX="$(brew --prefix)"
    if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
        source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" 2>/dev/null || true
    fi
fi

# Enable fzf key bindings
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)" 2>/dev/null || true
fi

# Enable zoxide completions
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)" 2>/dev/null || true
fi
EOF
    
    # Add to shell config
    add_to_shell_config "source $completions_file" "CLI Tools Completions"
    
    # Generate initial completions (disable exit on error temporarily)
    set +e
    source "$completions_file" 2>/dev/null
    set -e
    
    print_status "Bash completions configured"
}

# Setup Zsh completions
setup_zsh_completions() {
    local completions_file="$HOME/.completions"
    
    print_info "Setting up Zsh completions..."
    
    # Create completions file
    cat > "$completions_file" << 'EOF'
#!/bin/zsh
# CLI Tools Completions for Zsh

# Enable completions
autoload -U compinit
compinit

# Load homebrew completions if available
if command -v brew &> /dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Enable fzf key bindings
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)" 2>/dev/null || true
fi

# Enable zoxide completions
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)" 2>/dev/null || true
fi
EOF
    
    # Add to shell config
    add_to_shell_config "source $completions_file" "CLI Tools Completions"
    
    # Generate initial completions (disable exit on error temporarily)
    set +e
    source "$completions_file" 2>/dev/null
    set -e
    
    print_status "Zsh completions configured"
}

# Main execution
main() {
    setup_shell_completions
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi