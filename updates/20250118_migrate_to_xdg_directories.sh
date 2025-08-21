#!/bin/bash

# Update: 20250118_migrate_to_xdg_directories.sh
# Description: Migrate Macose installation to XDG directory structure
# Version: 2.1.0

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

# Define directories
OLD_DIR="$HOME/.macose"
NEW_DIR="$HOME/.local/share/macose"
CONFIG_DIR="$HOME/.config/macose"

print_info "Migrating Macose to XDG directory structure..."

# Move installation if it exists in old location
if [ -d "$OLD_DIR" ] && [ ! -d "$NEW_DIR" ]; then
    print_info "Moving installation from $OLD_DIR to $NEW_DIR..."
    mkdir -p "$(dirname "$NEW_DIR")"
    mv "$OLD_DIR" "$NEW_DIR"
    print_status "Installation migrated to $NEW_DIR"
fi

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"
print_status "Config directory ready at $CONFIG_DIR"

# Update shell configuration files
print_info "Updating shell configuration references..."
for rc in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile; do
    if [ -f "$rc" ]; then
        if grep -q "$OLD_DIR" "$rc"; then
            sed -i '' "s|$OLD_DIR|$NEW_DIR|g" "$rc"
            print_status "Updated $rc"
        fi
    fi
done

# Update PATH references
if [ -f ~/.zshrc ]; then
    # Check if ~/.local/bin is in PATH
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc; then
        echo '' >> ~/.zshrc
        echo '# Macose binary path' >> ~/.zshrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
        print_status "Added ~/.local/bin to PATH in ~/.zshrc"
    fi
fi

# Migrate theme configuration if it exists
OLD_THEME_FILE="$HOME/.config/macose/current-theme"
if [ -f "$OLD_THEME_FILE" ]; then
    print_info "Theme configuration already in correct location"
else
    # Check if there's an old theme setting somewhere
    if [ -f "$OLD_DIR/current-theme" ]; then
        cp "$OLD_DIR/current-theme" "$CONFIG_DIR/current-theme"
        print_status "Migrated theme configuration"
    fi
fi

print_status "Migration to XDG directories completed successfully!"
print_info "New installation location: $NEW_DIR"
print_info "Configuration location: $CONFIG_DIR"