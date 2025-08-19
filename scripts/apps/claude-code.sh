#!/bin/bash

# Omamacy - Claude Code Installation
# AI assistant command line tool

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Apply theme to Claude Code
apply_claude_theme() {
    local theme_name="$1"
    
    # Check if Claude Code is available
    if ! command -v claude >/dev/null 2>&1; then
        print_warning "Claude Code not found, skipping theme application"
        return 0
    fi
    
    print_info "Applying $theme_name theme to Claude Code..."
    
    # Map Catppuccin themes to Claude Code themes
    local claude_theme
    case "$theme_name" in
        "catppuccin-mocha"|"catppuccin-macchiato"|"catppuccin-frappe")
            claude_theme="dark"
            ;;
        "catppuccin-latte")
            claude_theme="light"
            ;;
        *)
            # Default to dark for unknown themes
            claude_theme="dark"
            print_warning "Unknown theme '$theme_name', defaulting to dark"
            ;;
    esac
    
    # Apply theme using Claude Code CLI
    if claude config set -g theme "$claude_theme" >/dev/null 2>&1; then
        print_status "Claude Code theme applied: $claude_theme"
    else
        print_warning "Failed to apply Claude Code theme (may need authentication)"
        return 1
    fi
    
    return 0
}

# Apply font to Claude Code (placeholder for future font support)
apply_claude_font() {
    local font_name="$1"
    
    # Check if Claude Code is available
    if ! command -v claude >/dev/null 2>&1; then
        print_warning "Claude Code not found, skipping font application"
        return 0
    fi
    
    print_info "Font configuration for Claude Code not yet supported"
    print_info "Requested font: $font_name"
    
    return 0
}

# Claude Code configuration
setup_claude_config() {
    local config_dir="$HOME/.local/omamacy/claude-config"
    
    # Check if config repo already exists
    if [ -d "$config_dir" ]; then
        print_info "Claude Code configuration repository found at $config_dir"
        
        # Change to config directory
        cd "$config_dir" || {
            print_error "Failed to change to config directory"
            return 1
        }
        
        # Run update script if it exists
        if [ -x "./update" ]; then
            print_info "Running configuration update..."
            if ./update; then
                print_status "Configuration updated successfully"
            else
                print_warning "Configuration update failed, continuing with install"
            fi
        fi
        
        # Run install script if it exists
        if [ -x "./install" ]; then
            print_info "Running Claude Code configuration installer..."
            if ./install; then
                print_status "Claude Code configured successfully"
            else
                print_error "Claude Code configuration failed"
                return 1
            fi
        else
            print_warning "No install script found in configuration repository"
        fi
    else
        # No existing config - ask if user wants to set one up
        echo ""
        print_info "Claude Code can be configured with custom agents and MCP servers"
        
        local want_config
        tty_prompt "Do you want to configure Claude Code with a custom repository? (y/N)" "n" want_config
        
        if [[ $want_config =~ ^[Yy]$ ]]; then
            print_warning "Configuration scripts may be destructive - back up your existing Claude directories first"
            print_info "Consider backing up: ~/.claude/ and ~/.config/claude/ directories"
            
            local repo_url
            tty_prompt "Enter the git repository URL" "" repo_url
            
            if [ -z "$repo_url" ]; then
                print_warning "No repository URL provided, skipping configuration"
                return 0
            fi
            
            # Validate git URL format (basic check)
            if [[ ! "$repo_url" =~ ^(https?://|git@) ]]; then
                print_error "Invalid git repository URL format"
                return 1
            fi
            
            # Create omamacy directory if it doesn't exist
            mkdir -p "$HOME/.local/omamacy"
            
            # Clone the configuration repository
            print_info "Cloning Claude Code configuration repository..."
            if git clone "$repo_url" "$config_dir"; then
                print_status "Configuration repository cloned successfully"
                
                # Change to config directory
                cd "$config_dir" || {
                    print_error "Failed to change to config directory"
                    return 1
                }
                
                # Run install script if it exists
                if [ -x "./install" ]; then
                    print_info "Running Claude Code configuration installer..."
                    if ./install; then
                        print_status "Claude Code configured successfully"
                    else
                        print_error "Claude Code configuration failed"
                        return 1
                    fi
                else
                    print_warning "No executable install script found in configuration repository"
                fi
            else
                print_error "Failed to clone configuration repository"
                return 1
            fi
        else
            print_info "Skipping Claude Code configuration"
        fi
    fi
    
    return 0
}

# Main installation
main() {
    # Handle theme-only application via delegation
    if [ -n "$OMAMACY_APPLY_THEME_ONLY" ]; then
        apply_claude_theme "$OMAMACY_APPLY_THEME_ONLY"
        return $?
    fi
    
    # Handle font-only application via delegation
    if [ -n "$OMAMACY_APPLY_FONT_ONLY" ]; then
        apply_claude_font "$OMAMACY_APPLY_FONT_ONLY"
        return $?
    fi
    
    run_individual_script "claude-code.sh" "Claude Code CLI"
    
    # Install Claude Code using official installer
    if ! command -v claude >/dev/null 2>&1; then
        print_info "Installing Claude Code..."
        
        # Download and run the official Claude Code installer
        if curl -fsSL https://claude.ai/install.sh | bash; then
            print_status "Claude Code installed successfully"
            
            # Verify installation
            if command -v claude >/dev/null 2>&1; then
                print_status "Claude Code installation verified"
            else
                print_warning "Claude Code installed but not found in PATH - restart terminal"
            fi
        else
            script_failure "claude-code" "Failed to install via official installer"
        fi
    else
        print_status "Claude Code already installed"
    fi
    
    # Setup Claude Code configuration
    if ! setup_claude_config; then
        print_warning "Claude Code configuration setup failed, but installation completed"
    fi
    
    script_success "Claude Code"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi