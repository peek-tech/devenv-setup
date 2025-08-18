#!/bin/bash

# Example usage of new print functions
# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/lib/common.sh"

print_info "Demonstrating new print functions:"
echo ""

print_banner "This is a banner with text"
echo ""

print_br
echo ""

print_info "Banner: Used for highlighting important content with borders"
print_info "Page break: Used for visual separation between sections"
print_info "Both use consistent 80-character width for professional appearance"