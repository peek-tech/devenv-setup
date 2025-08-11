#!/bin/bash

# Claude Code and Agent Orchestration Setup
# This script installs Claude Code and sets up the agent orchestration system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AGENTS_REPO="https://github.com/peek-tech/claude_code_config.git"

# Helper functions
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

# Check if Claude Code is installed
check_claude_installation() {
    if command -v claude &> /dev/null; then
        print_status "Claude Code is already installed"
        claude --version
        return 0
    else
        return 1
    fi
}

# Install Claude Code
install_claude() {
    print_info "Installing Claude Code..."
    
    OS="$(uname -s)"
    case "${OS}" in
        Darwin*)
            print_info "Detected macOS"
            if command -v brew &> /dev/null; then
                brew install claude
            else
                print_error "Homebrew not found. Please install Homebrew first or download Claude Code from https://claude.ai/code"
                return 1
            fi
            ;;
        Linux*)
            print_info "Detected Linux"
            # Download Claude Code for Linux
            print_info "Downloading Claude Code for Linux..."
            # Add actual download commands when available
            print_warning "Please download Claude Code manually from https://claude.ai/code"
            return 1
            ;;
        *)
            print_error "Unsupported operating system: ${OS}"
            return 1
            ;;
    esac
}

# Setup agent orchestration
setup_agents() {
    print_info "Setting up agent orchestration system..."
    
    # Ask user for setup preference
    echo ""
    echo "Choose installation location for agents:"
    echo "1) Current project (.claude folder)"
    echo "2) Global installation (~/.claude)"
    echo "3) Skip agent installation"
    read -p "Enter choice (1-3): " choice
    
    case $choice in
        1)
            # Install to current project
            if [ -d ".claude" ]; then
                print_warning ".claude directory exists. Backing up to .claude.backup"
                mv .claude .claude.backup
            fi
            
            print_info "Attempting to clone agent repository..."
            if git clone --quiet "$AGENTS_REPO" .claude 2>/dev/null; then
                print_status "Agents installed to current project"
                
                # Copy CLAUDE.md if it exists
                if [ -f ".claude/CLAUDE.md" ]; then
                    cp .claude/CLAUDE.md ./
                    print_status "CLAUDE.md copied to project root"
                fi
            else
                print_warning "Repository appears to be private. Please ensure you have access to: $AGENTS_REPO"
                print_info "You can manually clone it later with: git clone $AGENTS_REPO .claude"
            fi
            ;;
            
        2)
            # Install globally
            if [ -d ~/.claude ]; then
                print_warning "Global ~/.claude directory exists. Creating ~/.claude-agents instead"
                GLOBAL_DIR=~/.claude-agents
            else
                GLOBAL_DIR=~/.claude
            fi
            
            print_info "Attempting to clone agent repository..."
            if git clone --quiet "$AGENTS_REPO" "$GLOBAL_DIR" 2>/dev/null; then
                print_status "Agents installed globally to $GLOBAL_DIR"
            else
                print_warning "Repository appears to be private. Please ensure you have access to: $AGENTS_REPO"
                print_info "You can manually clone it later with: git clone $AGENTS_REPO $GLOBAL_DIR"
            fi
            ;;
            
        3)
            print_info "Skipping agent installation"
            ;;
            
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
}

# Main execution
main() {
    echo ""
    echo -e "${BLUE}🤖 Claude Code Setup${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check/Install Claude Code
    if ! check_claude_installation; then
        if ! install_claude; then
            print_error "Failed to install Claude Code"
            exit 1
        fi
    fi
    
    # Setup agents
    setup_agents
    
    print_status "Claude Code setup complete!"
    echo ""
    echo "Next steps:"
    echo "  • Run 'claude' to start using Claude Code"
    echo "  • Run 'claude init' in your project directory"
    echo "  • Check .claude/README.md for agent documentation"
}

main "$@"