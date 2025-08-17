#!/bin/bash

# Omacy - tmux Installation
# Terminal multiplexer with developer-friendly configuration

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Configure tmux with developer-friendly settings
configure_tmux() {
    local tmux_config="$HOME/.tmux.conf"
    
    print_info "Configuring tmux with developer-friendly settings..."
    
    # Backup existing config if it exists
    if [ -f "$tmux_config" ]; then
        cp "$tmux_config" "$tmux_config.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Existing tmux config backed up"
    fi
    
    # Create tmux configuration based on hamvocke.com guide
    cat > "$tmux_config" << 'EOF'
# Omacy tmux Configuration
# Based on https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/

# Remap prefix from 'C-b' to 'C-a' (more convenient)
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Split panes using | and - (more intuitive)
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config file (useful for development)
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Switch panes using Alt-arrow without prefix (faster navigation)
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Enable mouse mode (modern convenience)
set -g mouse on

# Don't rename windows automatically (preserve custom names)
set-option -g allow-rename off

# Increase scrollback buffer size
set -g history-limit 10000

# Start windows and panes at 1, not 0 (easier to reach)
set -g base-index 1
setw -g pane-base-index 1

# Enable activity alerts
setw -g monitor-activity on
set -g visual-activity on

# Status bar configuration
set -g status-position bottom
set -g status-justify left
set -g status-style 'bg=colour234 fg=colour137'
set -g status-left ''
set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
set -g status-right-length 50
set -g status-left-length 20

# Window status
setw -g window-status-current-style 'fg=colour1 bg=colour19 bold'
setw -g window-status-current-format ' #I#[fg=colour249]:#[fg=colour255]#W#[fg=colour249]#F '
setw -g window-status-style 'fg=colour9 bg=colour18'
setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '

# Pane borders
set -g pane-border-style 'fg=colour238'
set -g pane-active-border-style 'fg=colour51'

# Message text
set -g message-style 'fg=colour232 bg=colour166 bold'

# Copy mode
setw -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection
bind-key -T copy-mode-vi r send-keys -X rectangle-toggle
EOF

    print_status "tmux configuration created at $tmux_config"
    print_info "Key bindings:"
    print_info "  Prefix: Ctrl-a (instead of Ctrl-b)"
    print_info "  Split horizontal: Prefix + |"
    print_info "  Split vertical: Prefix + -"
    print_info "  Reload config: Prefix + r"
    print_info "  Switch panes: Alt + Arrow keys"
}

# Main installation
main() {
    run_individual_script "tmux.sh" "tmux (Terminal Multiplexer)"
    
    # Install tmux
    if ! install_brew_package "tmux" false "Terminal multiplexer"; then
        script_failure "tmux" "Failed to install via Homebrew"
    fi
    
    # Configure tmux
    configure_tmux
    
    script_success "tmux"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi