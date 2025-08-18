#!/bin/bash

# Omamacy - Podman Installation
# Container runtime with Docker compatibility

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Install and configure Podman
install_podman() {
    print_info "Installing Podman..."
    
    # Check if on Apple Silicon
    if [[ $(uname -m) == 'arm64' ]]; then
        print_warning "Note: Podman on Apple Silicon may prompt to install Rosetta 2"
        print_info "If a GRAPHICAL popup appears asking to install Rosetta 2:"
        print_info "👉 Click 'Install' in the popup window"
        print_info "This is required for x86_64 container compatibility"
        echo ""
    fi
    
    # Install Podman
    if ! install_brew_package "podman" false "Container runtime"; then
        script_failure "Podman" "Failed to install via Homebrew"
    fi
    
    print_status "Podman installed: $(podman --version)"
}

# Setup Podman machine
setup_podman_machine() {
    print_info "Setting up Podman machine..."
    
    # Check if machine already exists
    if podman machine list 2>/dev/null | grep -q "podman-machine-default"; then
        print_status "Podman machine already exists"
        
        # Check if running
        if podman machine list | grep "podman-machine-default" | grep -q "Running"; then
            print_status "Podman machine is already running"
        else
            print_info "Starting Podman machine..."
            podman machine start
            print_status "Podman machine started"
        fi
    else
        print_info "Initializing Podman machine with optimized settings..."
        podman machine init \
            --cpus 4 \
            --memory 8192 \
            --disk-size 60 \
            --now
        print_status "Podman machine initialized and started"
    fi
}

# Setup Docker compatibility
setup_docker_compatibility() {
    print_info "Setting up Docker compatibility..."
    
    # Add Docker aliases
    local aliases='
# Podman Docker Compatibility
alias docker="podman"
alias docker-compose="podman compose"'
    
    add_to_shell_config "$aliases" "Podman Docker Compatibility"
    print_status "Docker compatibility aliases configured"
}

# Main installation
main() {
    run_individual_script "podman.sh" "Podman (Container Runtime)"
    
    install_podman
    setup_podman_machine
    setup_docker_compatibility
    
    print_info "Verifying Podman installation..."
    if podman machine list | grep -q "Running"; then
        print_status "Podman machine is running successfully"
    else
        print_warning "Podman machine may need manual start: podman machine start"
    fi
    
    script_success "Podman"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi