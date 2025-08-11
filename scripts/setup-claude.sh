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

# Install Claude applications
install_claude_apps() {
    print_info "Installing Claude applications..."
    
    OS="$(uname -s)"
    case "${OS}" in
        Darwin*)
            print_info "Detected macOS"
            if ! command -v brew &> /dev/null; then
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            
            # Install Claude desktop app (chat interface)
            print_info "Installing Claude desktop app..."
            if brew list --cask claude &>/dev/null 2>&1; then
                print_status "Claude desktop app already installed"
            else
                if brew install --cask claude 2>/dev/null; then
                    print_status "Claude desktop app installed successfully"
                else
                    print_warning "Claude desktop app not available via Homebrew cask"
                    print_info "You can download it manually from https://claude.ai"
                fi
            fi
            
            # Install Claude Code CLI
            print_info "Installing Claude Code CLI..."
            if command -v claude &> /dev/null; then
                print_status "Claude Code CLI already installed: $(claude --version 2>/dev/null || echo 'version unknown')"
            else
                # Try to install via Homebrew first
                if brew install claude-code 2>/dev/null; then
                    print_status "Claude Code CLI installed via Homebrew"
                else
                    print_info "Claude Code CLI not available via Homebrew"
                    print_info "Downloading Claude Code CLI manually..."
                    
                    # Create a directory for Claude Code
                    CLAUDE_DIR="$HOME/.local/bin"
                    mkdir -p "$CLAUDE_DIR"
                    
                    # Download based on architecture
                    ARCH=$(uname -m)
                    if [[ "$ARCH" == "arm64" ]]; then
                        CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-macos-arm64"
                    else
                        CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-macos-x64"
                    fi
                    
                    print_info "Downloading from $CLAUDE_URL..."
                    if curl -fsSL "$CLAUDE_URL" -o "$CLAUDE_DIR/claude" 2>/dev/null; then
                        chmod +x "$CLAUDE_DIR/claude"
                        
                        # Add to PATH if not already there
                        if [[ ":$PATH:" != *":$CLAUDE_DIR:"* ]]; then
                            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
                            export PATH="$HOME/.local/bin:$PATH"
                        fi
                        
                        print_status "Claude Code CLI installed to $CLAUDE_DIR/claude"
                    else
                        print_warning "Failed to download Claude Code CLI"
                        print_info "Please download manually from https://claude.ai/code"
                    fi
                fi
            fi
            ;;
        Linux*)
            print_info "Detected Linux"
            
            # Install Claude Code CLI for Linux
            print_info "Installing Claude Code CLI..."
            if command -v claude &> /dev/null; then
                print_status "Claude Code CLI already installed"
            else
                CLAUDE_DIR="$HOME/.local/bin"
                mkdir -p "$CLAUDE_DIR"
                
                ARCH=$(uname -m)
                if [[ "$ARCH" == "aarch64" ]]; then
                    CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-linux-arm64"
                else
                    CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-linux-x64"
                fi
                
                print_info "Downloading Claude Code CLI..."
                if curl -fsSL "$CLAUDE_URL" -o "$CLAUDE_DIR/claude" 2>/dev/null; then
                    chmod +x "$CLAUDE_DIR/claude"
                    
                    # Add to PATH
                    if [[ ":$PATH:" != *":$CLAUDE_DIR:"* ]]; then
                        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
                        export PATH="$HOME/.local/bin:$PATH"
                    fi
                    
                    print_status "Claude Code CLI installed"
                else
                    print_warning "Failed to download Claude Code CLI"
                    print_info "Please download manually from https://claude.ai/code"
                fi
            fi
            
            # Desktop app for Linux
            print_info "For Claude desktop app, please visit https://claude.ai in your browser"
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
    
    # Install Claude applications
    install_claude_apps
    
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