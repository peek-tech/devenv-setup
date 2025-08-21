#!/bin/bash

# Macose - Common Library Functions
# Shared functions for all installation scripts

# Detect if colors should be used
# Check multiple conditions like Homebrew does
should_use_colors() {
    # Force colors if CI environment
    if [ -n "$CI" ]; then
        return 0
    fi
    
    # Force colors if explicitly requested
    if [ "$FORCE_COLOR" = "1" ] || [ "$CLICOLOR_FORCE" = "1" ]; then
        return 0
    fi
    
    # Disable if NO_COLOR is set (https://no-color.org/)
    if [ -n "$NO_COLOR" ]; then
        return 1
    fi
    
    # Check if output is to a terminal
    if [ -t 1 ]; then
        return 0
    fi
    
    # Check if TERM supports colors (even when piped)
    case "${TERM:-dumb}" in
        *color*|xterm*|rxvt*|screen*|tmux*|alacritty*|kitty*|iterm*)
            # Terminal supports colors, use them even if piped
            # This is what makes Homebrew colorful even through curl | bash
            return 0
            ;;
        dumb|"")
            return 1
            ;;
    esac
    
    return 1
}

# Set up colors based on terminal capabilities
if should_use_colors; then
    # Use standard ANSI codes for better compatibility
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
else
    # No colors
    GREEN=''
    BLUE=''
    YELLOW=''
    RED=''
    CYAN=''
    NC=''
fi

# Print functions - always use colors when available
# All user-visible output goes to stderr for curl|bash compatibility
print_status() {
    printf "${GREEN}✅${NC} %s\n" "$1" >&2
}

print_info() {
    printf "${BLUE}ℹ️${NC} %s\n" "$1" >&2
}

print_warning() {
    printf "${YELLOW}⚠️${NC} %s\n" "$1" >&2
}

print_error() {
    printf "${RED}❌${NC} %s\n" "$1" >&2
}

print_section() {
    printf "" >&2
    printf "${CYAN}===============================================${NC}\n" >&2
    printf "${CYAN}%s${NC}\n" "$1" >&2
    printf "${CYAN}===============================================${NC}\n" >&2
}

print_header() {
    printf "\n" >&2
    printf "${CYAN}### %s ###${NC}\n" "$1" >&2
}

print_banner() {
    printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n" >&2
    printf "${CYAN}%s${NC}\n" "$1" >&2
    printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n" >&2
}

print_br() {
    printf "${CYAN}────────────────────────────────────────────────────────────────────────────────${NC}\n" >&2
}

# Optional: Inform about non-interactive mode for prompts
ensure_tty() {
    # Check if we need to use non-interactive mode for prompts
    if [ ! -t 0 ]; then
        export MAKASE_NON_INTERACTIVE=1
    fi
}

# Check if running in a TTY context (for optional warning)
check_tty() {
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        return 1
    fi
    return 0
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

# Prompt with TTY detection and default support
# Usage: tty_prompt "Enter your name" "John" name_var
#        tty_prompt "Continue?" "y" response
# Returns: Sets the variable with user input or default
# Note: Does NOT make yes/no decisions - calling script should check the value
tty_prompt() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    # If explicitly in non-interactive mode, use default
    if [ "$MAKASE_NON_INTERACTIVE" = "1" ]; then
        eval "$var_name='$default'"
        printf "→ %s: %s (auto-selected)\n" "$prompt" "$default" >&2
        return 0
    fi
    
    # Interactive prompt with default shown
    local display_prompt="$prompt"
    if [ -n "$default" ]; then
        display_prompt="$prompt [$default]: "
    else
        display_prompt="$prompt: "
    fi
    
    # If stdin is not a TTY (like when running from curl | bash), use /dev/tty
    if [ ! -t 0 ]; then
        printf "%s" "$display_prompt" >&2
        read response </dev/tty
    else
        read -p "$display_prompt" response
    fi
    
    # Use default if empty response
    if [ -z "$response" ] && [ -n "$default" ]; then
        response="$default"
    fi
    
    # Set the variable with the response
    eval "$var_name='$response'"
    
    return 0
}

# Script execution wrapper for individual tools/apps
run_individual_script() {
    local script_name="$1"
    local script_description="$2"
    
    # Skip header if running from main installer
    if [ "$MAKASE_FROM_INSTALLER" != "1" ]; then
        print_section "$script_description"
        print_info "Script: $script_name"
    fi
    
    # Load Homebrew environment
    load_homebrew_env
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