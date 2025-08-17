#!/bin/bash

# Omacy - CLI Tools Installation
# Installs modern command-line tools via Homebrew

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Install core CLI tools
install_core_tools() {
    print_info "Installing core CLI tools via Homebrew..."
    
    # Core tools
    local tools=(
        "git"
        "gh"           # GitHub CLI
        "jq"           # JSON processor - powerful JSON/structured data processor
        "wget"
        "tree"
        "htop"
        "tmux"
        "neovim"       # Neovim editor
        "ripgrep"      # Better grep - fast text search
        "fd"           # Better find - user-friendly file search
        "bat"          # Better cat with syntax highlighting
        "eza"          # Better ls - modern replacement with icons
        "fzf"          # Fuzzy finder for commands/files
        "lazygit"      # Terminal UI for git
        "delta"        # Better git diff
        "dust"         # Better du - visual disk usage
        "procs"        # Better ps - enhanced process viewer
        "tealdeer"     # Better man - concise command examples (tldr)
        "sd"           # Better sed - intuitive find-and-replace
        "glances"      # Better top/htop - comprehensive system monitor
        "hyperfine"    # Better time - benchmarking tool
        "ncdu"         # Interactive disk usage analyzer
        "just"         # Modern task runner - better than make
        "zoxide"       # Smart directory navigation
        "pspg"         # Tabular data pager - better for databases/CSV
        "fclones"      # Efficient duplicate file finder
        "mas"          # Mac App Store CLI
    )
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            print_status "$tool already installed"
        else
            print_info "Installing $tool..."
            brew install "$tool"
        fi
    done
}

# Install essential GUI applications
install_essential_apps() {
    print_info "Installing essential GUI applications..."
    
    # Essential casks
    local casks=(
        "visual-studio-code"
        "ghostty"      # Modern terminal
        "rectangle"    # Window management
        "bruno"        # API client for testing REST, GraphQL, and gRPC
        "google-drive" # Google Drive for file sync and collaboration
    )
    
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            print_status "$cask already installed"
        else
            print_info "Installing $cask..."
            brew install --cask "$cask"
        fi
    done
}

# Main execution
main() {
    install_core_tools
    install_essential_apps
    print_status "CLI tools installation complete!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi