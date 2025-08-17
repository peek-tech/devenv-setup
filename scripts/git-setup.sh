#!/bin/bash

# Omamacy - Git Setup  
# Configures git credentials and SSH for GitHub

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
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

# Configure git user information
configure_git() {
    print_info "Configuring git credentials..."
    
    if [ -z "$(git config --global user.name)" ]; then
        print_info "Git user name not configured"
        # Read input from /dev/tty if stdin is piped
        if prompt_user "Enter your name for git commits: " git_name; then
            git config --global user.name "$git_name"
            print_status "Git name configured: $git_name"
        else
            print_warning "No TTY available, skipping git name configuration"
            return 0
        fi
    else
        print_status "Git name already configured: $(git config --global user.name)"
    fi

    if [ -z "$(git config --global user.email)" ]; then
        print_info "Git email not configured"
        # Read input from /dev/tty if stdin is piped
        if prompt_user "Enter your email for git commits: " git_email; then
            git config --global user.email "$git_email"
            print_status "Git email configured: $git_email"
        else
            print_warning "No TTY available, skipping git email configuration"
            return 0
        fi
    else
        print_status "Git email already configured: $(git config --global user.email)"
    fi
}

# Check if SSH is configured for GitHub
is_ssh_configured() {
    local ssh_config="$HOME/.ssh/config"
    [ -f "$ssh_config" ] && grep -q "Host github.com" "$ssh_config"
}

# Test SSH connection to GitHub
test_ssh_connection() {
    print_info "Testing SSH connection to GitHub..."
    ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"
}

# Setup SSH key and config for GitHub
setup_ssh_key_and_config() {
    local ssh_dir="$HOME/.ssh"
    local ssh_key="$ssh_dir/github"
    
    # Create SSH directory if it doesn't exist
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    
    # Generate SSH key if it doesn't exist
    if [ ! -f "$ssh_key" ]; then
        print_info "Generating new SSH key..."
        local email=$(git config --global user.email)
        if [ -z "$email" ]; then
            email="user@example.com"
        fi
        
        ssh-keygen -t ed25519 -C "$email" -f "$ssh_key" -N ""
        chmod 600 "$ssh_key"
        chmod 644 "${ssh_key}.pub"
        print_status "SSH key generated: $ssh_key"
    else
        print_status "SSH key already exists: $ssh_key"
    fi
    
    # Configure SSH for GitHub
    local ssh_config="$ssh_dir/config"
    if ! grep -q "Host github.com" "$ssh_config" 2>/dev/null; then
        print_info "Configuring SSH for GitHub..."
        cat >> "$ssh_config" << EOF

Host github.com
    HostName github.com
    User git
    IdentityFile $ssh_key
    UseKeychain yes
    AddKeysToAgent yes
EOF
        chmod 600 "$ssh_config"
        print_status "SSH config updated for GitHub"
    fi
    
    # Add key to SSH agent
    if command -v ssh-add &> /dev/null; then
        ssh-add --apple-use-keychain "$ssh_key" 2>/dev/null || ssh-add "$ssh_key" 2>/dev/null
    fi
}

# Show public key and GitHub setup instructions
show_github_setup_instructions() {
    local ssh_key="$HOME/.ssh/github"
    
    print_info "Your SSH public key for GitHub:"
    echo ""
    cat "${ssh_key}.pub"
    echo ""
    print_info "To complete GitHub setup:"
    print_info "1. Copy the public key above"
    print_info "2. Go to: https://github.com/settings/ssh/new"
    print_info "3. Add the key with a descriptive title"
}

# Main SSH setup function with proper flow
setup_ssh_for_github() {
    print_info "Setting up SSH for GitHub..."
    
    # Step 1: Check if SSH is already configured
    if is_ssh_configured; then
        print_status "SSH already configured for GitHub"
        
        # Step 2a: If configured, test immediately
        if test_ssh_connection; then
            print_status "SSH connection to GitHub successful!"
            return 0
        fi
        
        # Step 3a: If test fails with existing config, show key and loop
        print_warning "SSH is configured but connection test failed"
        show_github_setup_instructions
    else
        # Step 2b: If not configured, walk through setup
        print_info "SSH not configured for GitHub, setting up..."
        setup_ssh_key_and_config
        
        # Step 3b: Test after initial setup
        if test_ssh_connection; then
            print_status "SSH connection to GitHub successful!"
            return 0
        fi
        
        # Step 4b: If test fails after setup, show instructions
        print_warning "SSH setup complete but connection test failed"
        show_github_setup_instructions
    fi
    
    # Step 4: Loop until SSH works or user skips
    while true; do
        if prompt_user "Press Enter when you've added the key to GitHub (or type 'skip' to continue without SSH)... " user_input; then
            if [ "$user_input" = "skip" ]; then
                print_warning "Skipping SSH setup - you can configure it manually later"
                print_info "Visit: https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
                return 1
            fi
            
            if test_ssh_connection; then
                print_status "SSH connection to GitHub successful!"
                return 0
            else
                print_warning "SSH connection test failed. Please verify the key was added correctly."
                print_info "Make sure you've pasted the FULL public key shown above to GitHub"
            fi
        else
            print_warning "No TTY available, skipping GitHub SSH setup"
            return 1
        fi
    done
}

# Main execution
main() {
    configure_git
    
    # Setup SSH for GitHub (optional, non-blocking)
    if ! setup_ssh_for_github; then
        print_warning "SSH setup failed or was skipped - you can configure it manually later"
        print_info "Visit https://docs.github.com/en/authentication/connecting-to-github-with-ssh for manual setup"
    fi
    
    print_status "Git setup complete!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi