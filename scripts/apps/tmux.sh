#!/bin/bash

# Macose - tmux Installation
# Terminal multiplexer with developer-friendly configuration

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Apply theme to existing tmux configuration
apply_tmux_theme() {
    local theme_name="$1"
    local tmux_config="$HOME/.tmux.conf"
    local themes_dir="$HOME/.config/makase/themes"
    local theme_file="$themes_dir/$theme_name/tmux.conf"
    
    # For now, tmux themes will be complete configs since it doesn't support includes
    # In the future, we could implement smart merging of theme-specific settings
    if [ ! -f "$theme_file" ]; then
        print_warning "tmux theme file not found: $theme_file"
        print_info "tmux themes are managed as complete configurations"
        return 1
    fi
    
    print_info "Applying $theme_name theme to tmux..."
    
    # Backup existing config if it exists
    if [ -f "$tmux_config" ]; then
        cp "$tmux_config" "$tmux_config.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Copy theme config (complete replacement for now)
    cp "$theme_file" "$tmux_config"
    
    print_status "tmux theme applied: $theme_name"
}

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
# Omamacy tmux Configuration
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

# vim-tmux-navigator plugin will handle pane navigation
# Smart pane switching with awareness of Vim splits
# Use Ctrl+h/j/k/l for unified navigation

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

# Plugin Manager (TPM) and Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-sessionist'
set -g @plugin 'christoomey/vim-tmux-navigator'

# Plugin configurations
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-vim 'session'
set -g @resurrect-strategy-nvim 'session'

# Session management keybindings (tmux-sessionist)
# Prefix + g - prompt for new session name and create it
# Prefix + C - prompt for new session name and create it in background
# Prefix + X - kill current session and switch to previous one
# Prefix + S - switch to another session via interactive menu
# Prefix + @ - promote current pane to new session

# Session restore/save (tmux-resurrect)
# Prefix + Ctrl-s - save session
# Prefix + Ctrl-r - restore session

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF

    print_status "tmux configuration created at $tmux_config"
    print_info "Key bindings:"
    print_info "  Prefix: Ctrl-a (instead of Ctrl-b)"
    print_info "  Split horizontal: Prefix + |"
    print_info "  Split vertical: Prefix + -"
    print_info "  Reload config: Prefix + r"
    print_info "  Navigate panes/vim: Ctrl + h/j/k/l"
    print_info "Session management:"
    print_info "  Save session: Prefix + Ctrl-s"
    print_info "  Restore session: Prefix + Ctrl-r"
    print_info "  New session: Prefix + g"
    print_info "  Switch sessions: Prefix + S"
}

# Install TPM (Tmux Plugin Manager) and plugins
install_tmux_plugins() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    
    print_info "Installing Tmux Plugin Manager (TPM)..."
    
    # Install TPM if not already installed
    if [ ! -d "$tpm_dir" ]; then
        mkdir -p "$HOME/.tmux/plugins"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        print_status "TPM installed successfully"
    else
        print_status "TPM already installed"
    fi
    
    # Install plugins automatically
    print_info "Installing tmux plugins..."
    "$tpm_dir/scripts/install_plugins.sh"
    print_status "tmux plugins installed: tmux-resurrect, tmux-continuum, tmux-sessionist, vim-tmux-navigator"
    
    print_info "Plugin features enabled:"
    print_info "  • Automatic session saving every 15 minutes"
    print_info "  • Session restoration across reboots"
    print_info "  • Enhanced session management commands"
    print_info "  • Seamless navigation between tmux panes and vim splits"
}

# Setup automatic tmux session management
setup_tmux_auto_start() {
    printf "\n" >&2
    local auto_start
    tty_prompt "Do you want tmux to auto-start/attach when opening new terminals? (y/N)" "n" auto_start
    
    if [[ $auto_start =~ ^[Yy]$ ]]; then
        print_info "Setting up automatic tmux session management..."
        
        local tmux_auto_config='
# Automatic tmux session management
if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && command -v tmux &> /dev/null; then
    # Only auto-start in interactive shells that are not already inside tmux
    if tmux has-session 2>/dev/null; then
        # Attach to existing session
        tmux attach
    else
        # Create new session
        tmux new-session
    fi
fi'
        
        add_to_shell_config "$tmux_auto_config" "tmux auto-start/attach"
        print_status "tmux will automatically start/attach in new terminals"
        print_info "To disable: remove the 'tmux auto-start/attach' section from your shell config"
    else
        print_info "tmux installed without auto-start (use 'tmux' command manually)"
    fi
}

# Main installation
main() {
    # Check for theme-only mode
    if [ -n "$MACOSE_APPLY_THEME_ONLY" ]; then
        apply_tmux_theme "$MACOSE_APPLY_THEME_ONLY"
        return $?
    fi
    
    # Normal installation mode
    run_individual_script "tmux.sh" "tmux (Terminal Multiplexer)"
    
    # Install tmux
    if ! install_brew_package "tmux" false "Terminal multiplexer"; then
        script_failure "tmux" "Failed to install via Homebrew"
    fi
    
    # Configure tmux
    configure_tmux
    
    # Install TPM and plugins
    install_tmux_plugins
    
    # Setup optional auto-start/attach
    setup_tmux_auto_start
    
    script_success "tmux"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi