#!/bin/bash

# Design and Creative Tools Setup
# Installs design tools and creative applications

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
echo -e "${BLUE}🎨 Design and Creative Tools Setup${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

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

# Design applications
design_apps=(
    "figma:Figma (UI/UX Design)"
    "sketch:Sketch (UI Design)"
    "adobe-creative-cloud:Adobe Creative Cloud"
    "canva:Canva (Graphic Design)"
    "pixelmator-pro:Pixelmator Pro (Image Editing)"
)

# Development design tools
dev_design_tools=(
    "imageoptim:ImageOptim (Image Optimization)"
    "color-oracle:Color Oracle (Color Blindness Simulator)"
    "colorpicker-skalacolor:Skala Color (Advanced Color Picker)"
    "iconjar:IconJar (Icon Management)"
)

print_info "Available design applications:"
echo ""
for i in "${!design_apps[@]}"; do
    IFS=':' read -r cask name <<< "${design_apps[$i]}"
    echo "  $((i+1))) $name"
done
echo ""

print_info "Available development design tools:"
echo ""
for i in "${!dev_design_tools[@]}"; do
    IFS=':' read -r cask name <<< "${dev_design_tools[$i]}"
    echo "  $((i+${#design_apps[@]}+1))) $name"
done
echo ""
echo "  0) Install essential design tools (Figma + dev tools)"
echo ""

# Read input from /dev/tty if stdin is piped
if [ ! -t 0 ]; then
    if read -p "Select tools to install (e.g., 1 3 4 or 0 for essentials): " -a selections </dev/tty 2>/dev/null; then
        :
    else
        print_warning "No TTY available, installing essential design tools by default"
        selections=("0")
    fi
else
    read -p "Select tools to install (e.g., 1 3 4 or 0 for essentials): " -a selections
fi

install_app() {
    local cask="$1"
    local name="$2"
    
    if brew list --cask "$cask" &>/dev/null 2>&1; then
        print_status "$name already installed"
    else
        print_info "Installing $name..."
        if brew install --cask "$cask" 2>/dev/null; then
            print_status "$name installed successfully"
        else
            print_warning "Failed to install $name (may not be available or require payment)"
        fi
    fi
}

if [[ "${selections[0]}" == "0" ]]; then
    # Install essential design tools
    print_info "Installing essential design tools..."
    
    # Essential apps
    install_app "figma" "Figma"
    
    # All dev design tools
    for tool_info in "${dev_design_tools[@]}"; do
        IFS=':' read -r cask name <<< "$tool_info"
        install_app "$cask" "$name"
    done
else
    # Install selected tools
    total_apps=$((${#design_apps[@]} + ${#dev_design_tools[@]}))
    
    for selection in "${selections[@]}"; do
        if [[ $selection -ge 1 && $selection -le ${#design_apps[@]} ]]; then
            # Design app selection
            IFS=':' read -r cask name <<< "${design_apps[$((selection-1))]}"
            install_app "$cask" "$name"
        elif [[ $selection -gt ${#design_apps[@]} && $selection -le $total_apps ]]; then
            # Dev tool selection
            index=$((selection - ${#design_apps[@]} - 1))
            IFS=':' read -r cask name <<< "${dev_design_tools[$index]}"
            install_app "$cask" "$name"
        else
            print_warning "Invalid selection: $selection"
        fi
    done
fi

# Install command-line design tools
print_info "Installing command-line design tools..."

cli_tools=(
    "imagemagick:ImageMagick (Image Processing)"
    "graphicsmagick:GraphicsMagick (Image Processing)"
    "optipng:OptiPNG (PNG Optimization)"
    "jpegoptim:JPEG Optimization"
    "ffmpeg:FFmpeg (Video/Audio Processing)"
)

for tool_info in "${cli_tools[@]}"; do
    IFS=':' read -r formula name <<< "$tool_info"
    
    if brew list "$formula" &>/dev/null 2>&1; then
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

# Install fonts
print_info "Installing developer-friendly fonts..."

fonts=(
    "font-fira-code"
    "font-source-code-pro"
    "font-cascadia-code"
    "font-inter"
)

# Tap font cask if not already tapped
if ! brew tap | grep -q "homebrew/cask-fonts"; then
    print_info "Adding Homebrew font repository..."
    brew tap homebrew/cask-fonts
fi

for font in "${fonts[@]}"; do
    if brew list --cask "$font" &>/dev/null 2>&1; then
        print_status "$font already installed"
    else
        print_info "Installing $font..."
        if brew install --cask "$font"; then
            print_status "$font installed successfully"
        else
            print_warning "Failed to install $font"
        fi
    fi
done

print_status "Design and creative tools setup complete!"
echo ""
echo "Installed tools include:"
echo "  • Design applications (Figma, etc.)"
echo "  • Image optimization tools"
echo "  • Command-line media processing tools"
echo "  • Developer-friendly fonts"
echo ""
echo "Next steps:"
echo "  • Launch Figma and sign in to your account"
echo "  • Configure design tools with your preferred settings"
echo "  • Set up design system libraries and components"
echo "  • Install browser extensions for design inspection"