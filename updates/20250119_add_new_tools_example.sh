#!/bin/bash

# Update: 20250119_add_new_tools_example.sh
# Description: Example update that adds new productivity tools
# Version: 2.1.1

OMAMACY_DIR="$HOME/.local/share/omamacy"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$SCRIPT_DIR/manifests/20250119_manifest.json"

# Source common functions if available
if [ -f "$OMAMACY_DIR/scripts/lib/common.sh" ]; then
    source "$OMAMACY_DIR/scripts/lib/common.sh"
else
    # Fallback print functions
    print_info() { echo "ℹ️ $1"; }
    print_status() { echo "✅ $1"; }
fi

print_info "Installing new productivity tools update..."

# Check if manifest exists
if [ ! -f "$MANIFEST" ]; then
    print_error "Manifest not found: $MANIFEST"
    exit 1
fi

# Run installer with specific manifest in update mode
bash "$OMAMACY_DIR/install" --manifest "$MANIFEST" --update-mode

print_status "Update 20250119 completed successfully"