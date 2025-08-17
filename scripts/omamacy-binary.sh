#!/bin/bash

# Omamacy - Binary Installation
# Install the omamacy CLI tool for theme and font management

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Install omamacy binary
install_omamacy_binary() {
    local bin_dir="$HOME/.local/bin"
    local source_bin="$SCRIPT_DIR/../bin/omamacy"
    local target_bin="$bin_dir/omamacy"
    
    print_info "Installing omamacy binary..."
    
    # Create bin directory if it doesn't exist
    mkdir -p "$bin_dir"
    
    # Check if source binary exists
    if [ ! -f "$source_bin" ]; then
        print_error "Source binary not found: $source_bin"
        return 1
    fi
    
    # Copy binary to user's local bin
    cp "$source_bin" "$target_bin"
    chmod +x "$target_bin"
    
    print_status "omamacy binary installed to $target_bin"
    
    # Add to PATH if not already there
    local shell_config_file=$(get_shell_config_file)
    local path_export='export PATH="$HOME/.local/bin:$PATH"'
    
    if ! grep -Fq "$path_export" "$shell_config_file" 2>/dev/null; then
        add_to_shell_config "$path_export" "Add ~/.local/bin to PATH for omamacy"
        print_status "Added ~/.local/bin to PATH in $shell_config_file"
    fi
    
    return 0
}

# Test omamacy installation
test_omamacy_installation() {
    # Source the shell config to get updated PATH
    local shell_config_file=$(get_shell_config_file)
    if [ -f "$shell_config_file" ]; then
        source "$shell_config_file" 2>/dev/null || true
    fi
    
    # Test if omamacy is in PATH
    if command -v omamacy &> /dev/null; then
        print_status "omamacy is available in PATH"
        print_info "Run 'omamacy --help' to see available commands"
        return 0
    else
        print_warning "omamacy not found in PATH - you may need to restart your terminal"
        print_info "You can also run: source $shell_config_file"
        return 1
    fi
}

# Main installation
main() {
    run_individual_script "omamacy-binary.sh" "Omamacy CLI Tool"
    
    # Install the binary
    if ! install_omamacy_binary; then
        script_failure "omamacy binary" "Failed to install binary"
    fi
    
    # Test installation
    test_omamacy_installation
    
    print_info "omamacy CLI provides theme and font management:"
    print_info "  omamacy theme list    - Show available themes"
    print_info "  omamacy theme set <name> - Switch theme"
    print_info "  omamacy font list     - Open Font Book"
    print_info "  omamacy font set <name> - Set font"
    
    script_success "omamacy binary"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi