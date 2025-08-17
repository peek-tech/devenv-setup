#!/bin/bash

# Omamacy - Starship Installation
# Modern cross-shell prompt with theming support

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Configure starship with AntreasAntoniou configuration
configure_starship() {
    local starship_config="$HOME/.config/starship.toml"
    
    print_info "Configuring Starship with creative prompt configuration..."
    
    # Create config directory
    mkdir -p "$(dirname "$starship_config")"
    
    # Backup existing config if it exists
    if [ -f "$starship_config" ]; then
        cp "$starship_config" "$starship_config.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Existing Starship config backed up"
    fi
    
    # Create starship configuration based on AntreasAntoniou's gist
    cat > "$starship_config" << 'EOF'
# Omacy Starship Configuration
# Based on https://gist.github.com/AntreasAntoniou/3bfe47d51e915e93517ce335c2b1f98b

# Use a light bulb as the prompt symbol 💡, symbolizing creativity
[character]
success_symbol = "[💡](bold green)"
error_symbol = "[💔](bold red)"

# Add 🎨 when in a git repository, symbolizing the art of coding
[git_branch]
symbol = "🎨 "
format = "[$symbol$branch]($style)"

# Show a symbol of home 🏠 when in the home directory, symbolizing comfort
[directory]
home_symbol = "🏠"
truncation_length = 3
truncation_symbol = "…/"

# Use an advanced format with a rocket 🚀, because we love speedy code
[cmd_duration]
format = " took [🚀 $duration]($style)"
min_time = 500 # in milliseconds

# Show the Rust version with gears symbol, because code is like a well-oiled machine ⚙️
[rust]
symbol = "⚙️ "

# Use a globe symbol 🌍 to show we care about the Node.js environment, symbolizing global reach
[nodejs]
symbol = "🌍 "

# Add a magic wand symbol when Python environment is active 🐍✨, symbolizing the magic of Python
[python]
symbol = "🐍✨ "

# Show Go version with a gopher symbol
[golang]
symbol = "🐹 "

# Compassionate message when a command fails
[status]
format = '[\[$symbol\]($style) $common_meaning$signal_name 🤗]($style)'
not_executable_symbol = "🔒"
not_found_symbol = "🔍"
sigint_symbol = "🚦"
signal_symbol = "🚨"
disabled = false

# Display a star 💫 next to the hostname, because it's the core of our system
[hostname]
format = "on [🔩 $hostname]($style) "
disabled = false

# Display battery status with a lightning bolt ⚡ because technology is electric!
[battery]
full_symbol = "🔋 "
charging_symbol = "⚡ "
discharging_symbol = "💧 "

# Git status with helpful symbols
[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
conflicted = "🏳"
ahead = "🏎💨"
behind = "😰"
diverged = "😵"
up_to_date = "✓"
untracked = "🤷"
stashed = "📦"
modified = "📝"
staged = "🗃"
renamed = "📛"
deleted = "🗑"

# Time display
[time]
disabled = false
format = '🕐[\[ $time \]]($style) '
time_format = "%T"

# Docker context
[docker_context]
symbol = "🐳 "

# Kubernetes context
[kubernetes]
symbol = "☸ "
disabled = false

# Package version
[package]
symbol = "📦 "

# Memory usage
[memory_usage]
disabled = false
threshold = 70
symbol = "🧠 "
EOF

    print_status "Starship configuration created at $starship_config"
    print_info "Features enabled:"
    print_info "  Creative symbols for git, languages, and system status"
    print_info "  Performance timing with rocket emoji"
    print_info "  Battery status display"
    print_info "  Kubernetes and Docker context"
    print_info "  Memory usage monitoring"
}

# Add starship to shell configuration
setup_shell_integration() {
    local user_shell="$(basename "$SHELL")"
    local integration=""
    
    print_info "Setting up Starship shell integration for $user_shell..."
    
    case "$user_shell" in
        bash)
            integration='
# Starship Prompt
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi'
            ;;
        zsh)
            integration='
# Starship Prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi'
            ;;
        fish)
            # Fish has different config location
            local fish_config_dir="$HOME/.config/fish"
            local fish_config_file="$fish_config_dir/config.fish"
            mkdir -p "$fish_config_dir"
            
            if ! grep -q "starship init fish" "$fish_config_file" 2>/dev/null; then
                echo "# Starship Prompt" >> "$fish_config_file"
                echo "if command -v starship &> /dev/null" >> "$fish_config_file"
                echo "    starship init fish | source" >> "$fish_config_file"
                echo "end" >> "$fish_config_file"
            fi
            print_status "Fish shell integration configured"
            return 0
            ;;
        *)
            integration='
# Starship Prompt
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi'
            print_warning "Using bash-compatible integration for $user_shell"
            ;;
    esac
    
    if [ -n "$integration" ]; then
        add_to_shell_config "$integration" "Starship Prompt"
        print_status "Starship shell integration configured"
    fi
}

# Main installation
main() {
    run_individual_script "starship.sh" "Starship (Cross-Shell Prompt)"
    
    # Install starship
    if ! install_brew_package "starship" false "Cross-shell prompt"; then
        script_failure "starship" "Failed to install via Homebrew"
    fi
    
    # Configure starship
    configure_starship
    
    # Setup shell integration
    setup_shell_integration
    
    print_info "Restart your terminal or run 'source ~/.zshrc' to activate Starship"
    
    script_success "starship"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi