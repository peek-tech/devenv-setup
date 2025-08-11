#!/bin/bash

# Developer Environment Setup - Main Installer
# Usage: curl -fsSL https://peek-tech.github.io/devenv-setup/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPTS_BASE_URL="https://peek-tech.github.io/devenv-setup/scripts"
VERSION="1.0.0"

# Helper functions
print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           Developer Environment Setup v${VERSION}           ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

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

print_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
        else
            DISTRO="unknown"
        fi
    else
        OS="unsupported"
        DISTRO="unknown"
    fi
}

# Check prerequisites
check_prerequisites() {
    local missing_tools=()
    
    # Check for required tools
    command -v curl &> /dev/null || missing_tools+=("curl")
    command -v git &> /dev/null || missing_tools+=("git")
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_info "Please install them first and run this script again."
        exit 1
    fi
}

# Run component installer
run_installer() {
    local component=$1
    local script_name=$2
    local description=$3
    
    print_section "Installing $description"
    
    # Download and run the script
    if curl -fsSL "${SCRIPTS_BASE_URL}/${script_name}" | bash; then
        print_status "$description installed successfully"
        return 0
    else
        print_warning "Failed to install $description"
        return 1
    fi
}

# Main installation menu
show_menu() {
    echo ""
    echo "Select components to install:"
    echo ""
    echo "  1) Full Installation (Recommended)"
    echo "  2) Core Development Tools (Homebrew, Git, Neovim, etc.)"
    echo "  3) Programming Languages (pyenv, nvm, Go)"
    echo "  4) Web Browsers (Chrome, Firefox, Edge, Brave)"
    echo "  5) Design Tools (Figma, image tools, fonts)"
    echo "  6) Claude Code + Agent Orchestration"
    echo "  7) AWS Development Tools"
    echo "  8) Container Tools (Docker, Kubernetes)"
    echo "  9) Custom Selection"
    echo "  0) Exit"
    echo ""
    read -p "Enter your choice [1-9, 0]: " choice
    
    case $choice in
        1)
            install_full
            ;;
        2)
            run_installer "core" "setup-core.sh" "Core Development Tools"
            ;;
        3)
            run_installer "languages" "setup-languages.sh" "Programming Languages"
            ;;
        4)
            run_installer "browsers" "setup-browsers.sh" "Web Browsers"
            ;;
        5)
            run_installer "design" "setup-design.sh" "Design and Creative Tools"
            ;;
        6)
            run_installer "claude" "setup-claude.sh" "Claude Code with Agent Orchestration"
            ;;
        7)
            run_installer "aws" "setup-aws.sh" "AWS Development Tools"
            ;;
        8)
            run_installer "containers" "setup-containers.sh" "Container Tools"
            ;;
        9)
            custom_installation
            ;;
        0)
            print_info "Installation cancelled"
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            show_menu
            ;;
    esac
}

# Full installation
install_full() {
    print_section "Starting Full Installation"
    
    local components=(
        "core:setup-core.sh:Core Development Tools"
        "languages:setup-languages.sh:Programming Languages"
        "browsers:setup-browsers.sh:Web Browsers"
        "design:setup-design.sh:Design and Creative Tools"
        "claude:setup-claude.sh:Claude Code with Agent Orchestration"
        "aws:setup-aws.sh:AWS Development Tools"
        "containers:setup-containers.sh:Container Tools"
    )
    
    local failed_components=()
    
    for component_info in "${components[@]}"; do
        IFS=':' read -r component script description <<< "$component_info"
        if ! run_installer "$component" "$script" "$description"; then
            failed_components+=("$description")
        fi
    done
    
    if [ ${#failed_components[@]} -eq 0 ]; then
        print_status "All components installed successfully!"
    else
        print_warning "Some components failed to install:"
        for comp in "${failed_components[@]}"; do
            echo "  - $comp"
        done
    fi
}

# Custom installation
custom_installation() {
    print_section "Custom Installation"
    
    echo "Available components:"
    echo ""
    
    local components=(
        "Core Development Tools:setup-core.sh"
        "Programming Languages:setup-languages.sh"
        "Web Browsers:setup-browsers.sh"
        "Design Tools:setup-design.sh"
        "Claude Code + Agents:setup-claude.sh"
        "AWS Tools:setup-aws.sh"
        "Container Tools:setup-containers.sh"
    )
    
    local selected=()
    
    for i in "${!components[@]}"; do
        IFS=':' read -r description script <<< "${components[$i]}"
        echo "  $((i+1))) $description"
    done
    
    echo ""
    echo "Enter component numbers separated by spaces (e.g., 1 3 4):"
    read -a selections
    
    for sel in "${selections[@]}"; do
        if [[ $sel -ge 1 && $sel -le ${#components[@]} ]]; then
            IFS=':' read -r description script <<< "${components[$((sel-1))]}"
            run_installer "" "$script" "$description"
        fi
    done
}

# Main execution
main() {
    print_header
    
    detect_os
    
    if [ "$OS" = "unsupported" ]; then
        print_error "Unsupported operating system"
        exit 1
    fi
    
    print_info "Detected OS: $OS ($DISTRO)"
    
    check_prerequisites
    
    # Check if running in CI/automated environment
    if [ -n "$CI" ] || [ -n "$AUTOMATED_INSTALL" ]; then
        print_info "Running in automated mode - installing all components"
        install_full
    else
        show_menu
    fi
    
    print_section "Installation Complete"
    print_info "Please restart your terminal or run: source ~/.bashrc"
    print_info "For help and documentation, visit: https://peek-tech.github.io/devenv-setup"
}

# Run main function
main "$@"