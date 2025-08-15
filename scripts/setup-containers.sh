#!/bin/bash

# Container Tools Setup - Podman with Docker Compatibility
# Installs Podman, Podman Desktop, and configures full Docker compatibility

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠️${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ️${NC} $1"; }

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

echo ""
echo -e "${BLUE}🐳 Container Tools Setup (Podman + Docker Compatibility)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check for existing Docker installation
check_existing_docker() {
    if command -v docker &> /dev/null && [ -S /var/run/docker.sock ]; then
        print_warning "Docker is already installed and running"
        echo "This script will install Podman as a Docker replacement."
        echo "You may want to stop Docker first to avoid conflicts."
        # Read input from /dev/tty if stdin is piped
        if [ ! -t 0 ]; then
            if read -p "Continue with Podman installation? (y/N): " -n 1 -r </dev/tty 2>/dev/null; then
                :
            else
                print_warning "No TTY available, continuing with installation"
                return 0
            fi
        else
            read -p "Continue with Podman installation? (y/N): " -n 1 -r
        fi
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled by user"
            exit 0
        fi
    fi
}

# Install Podman and Podman Desktop
install_podman() {
    print_info "Installing Podman and Podman Desktop..."
    
    case "${OS}" in
        Darwin*)
            print_info "Detected macOS"
            if ! command -v brew &> /dev/null; then
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            
            # Install Podman
            if command -v podman &> /dev/null; then
                print_status "Podman already installed: $(podman --version)"
            else
                print_info "Installing Podman via Homebrew..."
                brew install podman
                print_status "Podman installed: $(podman --version)"
            fi
            
            # Install Podman Desktop
            if brew list --cask podman-desktop &>/dev/null 2>&1; then
                print_status "Podman Desktop already installed"
            else
                print_info "Installing Podman Desktop..."
                if brew install --cask podman-desktop 2>/dev/null; then
                    print_status "Podman Desktop installed successfully"
                else
                    print_warning "Failed to install Podman Desktop via Homebrew"
                    print_info "You can download it manually from https://podman-desktop.io"
                fi
            fi
            ;;
            
        Linux*)
            print_info "Detected Linux"
            
            # Detect package manager
            if command -v apt-get &> /dev/null; then
                PKG_INSTALL="sudo apt-get install -y"
                PKG_UPDATE="sudo apt-get update"
                
                print_info "Updating package lists..."
                $PKG_UPDATE
                
                print_info "Installing Podman..."
                $PKG_INSTALL podman
                
            elif command -v yum &> /dev/null; then
                PKG_INSTALL="sudo yum install -y"
                
                print_info "Installing Podman..."
                $PKG_INSTALL podman
                
            else
                print_error "No supported package manager found"
                return 1
            fi
            
            print_status "Podman installed: $(podman --version)"
            print_info "For Podman Desktop on Linux, visit https://podman-desktop.io"
            ;;
            
        *)
            print_error "Unsupported operating system: ${OS}"
            return 1
            ;;
    esac
}

# Initialize and configure Podman machine (macOS only)
setup_podman_machine() {
    if [ "${OS}" != "Darwin" ]; then
        return 0
    fi
    
    print_info "Setting up Podman machine..."
    
    # Check if machine already exists
    if podman machine list | grep -q "podman-machine-default"; then
        print_status "Podman machine already exists"
        
        # Check if it's running
        if podman machine list | grep "podman-machine-default" | grep -q "Running"; then
            print_status "Podman machine is already running"
        else
            print_info "Starting Podman machine..."
            podman machine start
            print_status "Podman machine started"
        fi
    else
        print_info "Initializing Podman machine with optimized settings..."
        
        # Initialize with good defaults for development
        podman machine init \
            --cpus 4 \
            --memory 4096 \
            --disk-size 100 \
            --volume $HOME:$HOME \
            --now
            
        print_status "Podman machine initialized and started"
    fi
}

# Install and configure podman-mac-helper for Docker socket compatibility
setup_docker_compatibility() {
    print_info "Setting up Docker compatibility..."
    
    case "${OS}" in
        Darwin*)
            # Install podman-mac-helper for Docker socket compatibility
            print_info "Installing podman-mac-helper for Docker socket compatibility..."
            
            if sudo podman-mac-helper install 2>/dev/null; then
                print_status "podman-mac-helper installed successfully"
                
                # Verify socket creation
                if [ -S /var/run/docker.sock ]; then
                    print_status "Docker socket (/var/run/docker.sock) created successfully"
                else
                    print_warning "Docker socket not found, Docker tools may not work"
                    print_info "You may need to restart the Podman machine: podman machine restart"
                fi
            else
                print_warning "Failed to install podman-mac-helper"
                print_info "Docker compatibility may be limited"
            fi
            
            # Create docker command symlink
            local podman_path
            if command -v podman &> /dev/null; then
                podman_path=$(which podman)
                local bin_dir=$(dirname "$podman_path")
                
                if [ ! -f "$bin_dir/docker" ]; then
                    print_info "Creating Docker command symlink..."
                    if sudo ln -sf "$podman_path" "$bin_dir/docker" 2>/dev/null; then
                        print_status "Docker command symlink created: $bin_dir/docker"
                    else
                        print_warning "Failed to create Docker symlink, trying alternative method..."
                        # Add alias to shell profiles instead
                        add_shell_aliases
                    fi
                else
                    print_status "Docker command already available"
                fi
            fi
            ;;
            
        Linux*)
            # On Linux, create docker alias and configure socket
            print_info "Configuring Docker compatibility on Linux..."
            
            # Create docker symlink
            if [ ! -f /usr/local/bin/docker ]; then
                print_info "Creating Docker command symlink..."
                sudo ln -sf $(which podman) /usr/local/bin/docker
                print_status "Docker command symlink created"
            fi
            
            # Enable and start podman socket for Docker API compatibility
            print_info "Enabling Podman socket for Docker API compatibility..."
            systemctl --user enable --now podman.socket
            print_status "Podman socket enabled"
            
            # Set DOCKER_HOST for current session
            export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
            ;;
    esac
}

# Add shell aliases for Docker compatibility
add_shell_aliases() {
    print_info "Adding Docker compatibility aliases to shell profiles..."
    
    local aliases="
# Podman Docker compatibility aliases
alias docker='podman'
alias docker-compose='podman compose'
"
    
    # Add to .zshrc if it exists
    if [ -f ~/.zshrc ]; then
        if ! grep -q "alias docker='podman'" ~/.zshrc; then
            echo "$aliases" >> ~/.zshrc
            print_status "Aliases added to ~/.zshrc"
        else
            print_status "Aliases already present in ~/.zshrc"
        fi
    fi
    
    # Add to .bashrc if it exists
    if [ -f ~/.bashrc ]; then
        if ! grep -q "alias docker='podman'" ~/.bashrc; then
            echo "$aliases" >> ~/.bashrc
            print_status "Aliases added to ~/.bashrc"
        else
            print_status "Aliases already present in ~/.bashrc"
        fi
    fi
    
    # Add to .bash_profile for macOS
    if [ "${OS}" = "Darwin" ] && [ -f ~/.bash_profile ]; then
        if ! grep -q "alias docker='podman'" ~/.bash_profile; then
            echo "$aliases" >> ~/.bash_profile
            print_status "Aliases added to ~/.bash_profile"
        fi
    fi
}

# Set up automatic Podman machine startup on macOS
setup_auto_startup() {
    if [ "${OS}" != "Darwin" ]; then
        return 0
    fi
    
    print_info "Setting up automatic Podman machine startup..."
    
    local plist_dir="$HOME/Library/LaunchAgents"
    local plist_file="$plist_dir/com.podman.machine.plist"
    
    # Create LaunchAgents directory if it doesn't exist
    mkdir -p "$plist_dir"
    
    # Create LaunchAgent plist file
    cat > "$plist_file" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.podman.machine</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <string>command -v podman >/dev/null 2>&1 && podman machine start || true</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>/tmp/podman-machine-startup.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/podman-machine-startup.log</string>
</dict>
</plist>
EOF
    
    # Load the LaunchAgent
    if launchctl load "$plist_file" 2>/dev/null; then
        print_status "Automatic Podman machine startup configured"
        print_info "Podman machine will start automatically at login"
    else
        print_warning "Failed to configure automatic startup"
        print_info "You can manually start Podman with: podman machine start"
    fi
}

# Verify Podman Compose functionality
verify_compose() {
    print_info "Verifying Podman Compose functionality..."
    
    if podman compose --version &>/dev/null; then
        print_status "Podman Compose is available: $(podman compose --version)"
    else
        print_warning "Podman Compose not available"
        print_info "Install docker-compose for legacy compatibility if needed"
        
        case "${OS}" in
            Darwin*)
                print_info "You can install docker-compose with: brew install docker-compose"
                ;;
            Linux*)
                print_info "You can install docker-compose with your package manager"
                ;;
        esac
    fi
}

# Test the installation
test_installation() {
    print_info "Testing container functionality..."
    
    # Test basic Podman functionality
    if podman run --rm hello-world &>/dev/null; then
        print_status "Podman container test successful"
    else
        print_warning "Podman container test failed"
        print_info "Try running: podman machine restart"
    fi
    
    # Test Docker compatibility if symlink/alias exists
    if command -v docker &>/dev/null && [ "$(which docker)" != "$(which podman)" ]; then
        # Docker symlink exists
        if docker run --rm hello-world &>/dev/null; then
            print_status "Docker compatibility test successful"
        else
            print_warning "Docker compatibility test failed"
        fi
    else
        print_info "Docker compatibility available via shell aliases"
        print_info "Restart your terminal and use 'docker' commands normally"
    fi
}

# Main execution
main() {
    check_existing_docker
    install_podman
    setup_podman_machine
    setup_docker_compatibility
    add_shell_aliases
    setup_auto_startup
    verify_compose
    test_installation
    
    print_status "Container tools setup complete!"
    echo ""
    echo "Installed tools:"
    echo "  • Podman ($(podman --version 2>/dev/null || echo 'version unknown'))"
    echo "  • Podman Desktop (GUI application)"
    if [ "${OS}" = "Darwin" ]; then
        echo "  • podman-mac-helper (Docker socket compatibility)"
        echo "  • Automatic startup configured"
    fi
    echo "  • Docker command compatibility (symlink + aliases)"
    echo "  • Podman Compose (docker-compose replacement)"
    echo ""
    echo "Next steps:"
    echo "  • Restart your terminal to use Docker aliases"
    echo "  • Test with: docker run hello-world"
    echo "  • Use docker-compose commands normally (they'll use Podman)"
    echo "  • Open Podman Desktop for GUI management"
    if [ "${OS}" = "Darwin" ]; then
        echo "  • Podman machine will start automatically on next login"
    fi
    echo ""
    echo "Benefits of this setup:"
    echo "  • No Docker Desktop licensing requirements"
    echo "  • Better security with rootless containers"
    echo "  • Lower resource usage (no background daemon)"
    echo "  • Full Docker compatibility for existing workflows"
}

main "$@"