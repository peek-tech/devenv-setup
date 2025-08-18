#!/bin/bash

# Omamacy - Preflight Checks
# Validates system prerequisites before installation

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Preflight validation
check_prerequisites() {
    print_info "Running preflight checks..."
    
    local missing_tools=()
    local warnings=()
    
    # Check for required tools
    command -v curl &> /dev/null || missing_tools+=("curl")
    command -v git &> /dev/null || missing_tools+=("git")
    
    # Check network connectivity
    if ! curl -s --head --max-time 5 https://github.com > /dev/null; then
        warnings+=("Network connectivity to GitHub may be limited")
    fi
    
    # Check Xcode Command Line Tools
    if ! xcode-select -p &> /dev/null; then
        warnings+=("Xcode Command Line Tools not installed - will be prompted during Homebrew installation")
    fi
    
    # Check available disk space (warn if less than 5GB)
    local available_space
    available_space=$(df -h /System/Volumes/Data | awk 'NR==2 {print $4}' | sed 's/G.*//')
    if [[ "$available_space" =~ ^[0-9]+$ ]] && [ "$available_space" -lt 5 ]; then
        warnings+=("Low disk space: ${available_space}GB available (recommended: 5GB+)")
    fi
    
    # Report findings
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_info "Please install them first and run this script again."
        exit 1
    fi
    
    if [ ${#warnings[@]} -ne 0 ]; then
        print_warning "Preflight warnings detected:"
        for warning in "${warnings[@]}"; do
            print_warning "  - $warning"
        done
        print_info "Installation will continue, but you may encounter issues."
    else
        print_status "All preflight checks passed!"
    fi
}

# Request sudo access upfront
request_sudo() {
    print_info "This installer requires sudo access for Homebrew installation"
    print_info "You may be prompted for your password..."
    
    if sudo -v; then
        print_status "Sudo access granted"
        # Keep sudo alive for the duration of the script
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    else
        print_error "Sudo access required for installation"
        exit 1
    fi
}

# Main execution
main() {
    check_prerequisites
    request_sudo
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi