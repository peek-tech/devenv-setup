#!/bin/bash

# Omamacy - Common Library Functions
# Shared functions for all installation scripts

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Load Homebrew environment
load_homebrew_env() {
    if [[ $(uname -m) == 'arm64' ]] && [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
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

# Check if brew package is installed
is_brew_installed() {
    local package="$1"
    local is_cask="$2"
    
    if [ "$is_cask" = "true" ]; then
        brew list --cask "$package" &>/dev/null
    else
        brew list "$package" &>/dev/null
    fi
}

# Install brew package with error handling
install_brew_package() {
    local package="$1"
    local is_cask="$2"
    local description="$3"
    
    if is_brew_installed "$package" "$is_cask"; then
        print_status "$package already installed"
        return 0
    fi
    
    print_info "Installing $package${description:+ ($description)}..."
    
    if [ "$is_cask" = "true" ]; then
        if brew install --cask "$package"; then
            print_status "$package installed successfully"
            return 0
        else
            print_error "Failed to install $package"
            return 1
        fi
    else
        if brew install "$package"; then
            print_status "$package installed successfully"
            return 0
        else
            print_error "Failed to install $package"
            return 1
        fi
    fi
}

# TTY-aware prompt helper
prompt_user() {
    local prompt="$1"
    local var_name="$2"
    local read_args="$3"  # Optional: additional read arguments like "-n 1 -r"
    
    if [ ! -t 0 ]; then
        # No TTY on stdin, try to use /dev/tty
        if [ -t 1 ]; then
            # stdout is a TTY, display prompt normally
            echo -n "$prompt"
        else
            # No TTY available, print to stderr
            echo -n "$prompt" >&2
        fi
        
        if [ -n "$read_args" ]; then
            read $read_args "$var_name" </dev/tty 2>/dev/null || return 1
        else
            read "$var_name" </dev/tty 2>/dev/null || return 1
        fi
    else
        # stdin is a TTY, use normal read with prompt
        if [ -n "$read_args" ]; then
            read -p "$prompt" $read_args "$var_name"
        else
            read -p "$prompt" "$var_name"
        fi
    fi
}

# Script execution wrapper for individual tools/apps
run_individual_script() {
    local script_name="$1"
    local script_description="$2"
    
    print_section "$script_description"
    
    # Load Homebrew environment
    load_homebrew_env
    
    print_info "Script: $script_name"
}

# Exit with success message
script_success() {
    local item_name="$1"
    print_status "$item_name setup complete!"
}

# Exit with failure message
script_failure() {
    local item_name="$1"
    local error_msg="$2"
    print_error "$item_name setup failed: $error_msg"
    exit 1
}