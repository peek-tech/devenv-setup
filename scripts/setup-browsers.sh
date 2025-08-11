#!/bin/bash

# Browser Installation Setup
# Installs modern web browsers via Homebrew

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

echo ""
echo -e "${BLUE}🌐 Browser Installation Setup${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Detect OS
OS="$(uname -s)"
if [[ "$OS" != "Darwin" ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    print_error "Homebrew not found. Please install Homebrew first."
    print_info "Run the core setup script first: curl -fsSL https://peek-tech.github.io/devenv-setup/scripts/setup-core.sh | bash"
    exit 1
fi

# Browser casks to install
browsers=(
    "google-chrome:Google Chrome"
    "firefox:Mozilla Firefox"
    "microsoft-edge:Microsoft Edge"
    "brave-browser:Brave Browser"
    "arc:Arc Browser"
)

print_info "Available browsers to install:"
echo ""
for i in "${!browsers[@]}"; do
    IFS=':' read -r cask name <<< "${browsers[$i]}"
    echo "  $((i+1))) $name"
done
echo "  0) Install all browsers"
echo ""

read -p "Select browsers to install (e.g., 1 3 4 or 0 for all): " -a selections

if [[ "${selections[0]}" == "0" ]]; then
    # Install all browsers
    print_info "Installing all browsers..."
    for browser_info in "${browsers[@]}"; do
        IFS=':' read -r cask name <<< "$browser_info"
        
        if brew list --cask "$cask" &>/dev/null; then
            print_status "$name already installed"
        else
            print_info "Installing $name..."
            if brew install --cask "$cask"; then
                print_status "$name installed successfully"
            else
                print_warning "Failed to install $name"
            fi
        fi
    done
else
    # Install selected browsers
    for selection in "${selections[@]}"; do
        if [[ $selection -ge 1 && $selection -le ${#browsers[@]} ]]; then
            IFS=':' read -r cask name <<< "${browsers[$((selection-1))]}"
            
            if brew list --cask "$cask" &>/dev/null; then
                print_status "$name already installed"
            else
                print_info "Installing $name..."
                if brew install --cask "$cask"; then
                    print_status "$name installed successfully"
                else
                    print_warning "Failed to install $name"
                fi
            fi
        else
            print_warning "Invalid selection: $selection"
        fi
    done
fi

# Install browser development tools
print_info "Installing browser development tools..."

dev_tools=(
    "chromedriver:ChromeDriver for Selenium"
    "geckodriver:GeckoDriver for Firefox"
)

for tool_info in "${dev_tools[@]}"; do
    IFS=':' read -r formula name <<< "$tool_info"
    
    if brew list "$formula" &>/dev/null; then
        print_status "$name already installed"
    else
        print_info "Installing $name..."
        if brew install "$formula"; then
            print_status "$name installed successfully"
        else
            print_warning "Failed to install $name"
        fi
    fi
done

print_status "Browser setup complete!"
echo ""
echo "Installed browsers and tools:"
echo "  • Web browsers for development and testing"
echo "  • WebDriver tools for automation"
echo ""
echo "Tips:"
echo "  • Set your preferred default browser in System Preferences"
echo "  • Install browser extensions for development (React DevTools, etc.)"
echo "  • Consider setting up browser profiles for different projects"