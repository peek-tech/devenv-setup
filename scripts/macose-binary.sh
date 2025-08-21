#!/bin/bash

# Macose - Binary Installation
# Install the macose CLI tool for theme and font management

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Install macose binary
install_macose_binary() {
    local bin_dir="$HOME/.local/bin"
    local source_bin="$SCRIPT_DIR/../bin/macose"
    local target_bin="$bin_dir/macose"
    
    print_info "Installing macose binary..."
    
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
    
    print_status "macose binary installed to $target_bin"
    
    # Add to PATH if not already there
    local shell_config_file=$(get_shell_config_file)
    local path_export='export PATH="$HOME/.local/bin:$PATH"'
    
    if ! grep -Fq "$path_export" "$shell_config_file" 2>/dev/null; then
        add_to_shell_config "$path_export" "Add ~/.local/bin to PATH for macose"
        print_status "Added ~/.local/bin to PATH in $shell_config_file"
    fi
    
    return 0
}

# Test macose installation
test_macose_installation() {
    # Source the shell config to get updated PATH
    local shell_config_file=$(get_shell_config_file)
    if [ -f "$shell_config_file" ]; then
        source "$shell_config_file" 2>/dev/null || true
    fi
    
    # Test if macose is in PATH
    if command -v macose &> /dev/null; then
        print_status "macose is available in PATH"
        print_info "Run 'macose --help' to see available commands"
        return 0
    else
        print_warning "macose not found in PATH - you may need to restart your terminal"
        print_info "You can also run: source $shell_config_file"
        return 1
    fi
}

# Main installation
main() {
    run_individual_script "macose-binary.sh" "Macose CLI Tool"
    
    # Install the binary
    if ! install_macose_binary; then
        script_failure "macose binary" "Failed to install binary"
    fi
    
    # Test installation
    test_macose_installation
    
    print_info "macose CLI provides theme and font management:"
    print_info "  macose theme list    - Show available themes"
    print_info "  macose theme set <name> - Switch theme"
    print_info "  macose font list     - Open Font Book"
    print_info "  macose font set <name> - Set font"
    
    script_success "macose binary"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi