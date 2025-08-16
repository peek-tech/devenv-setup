#!/bin/bash

# Developer Environment Setup - Consolidated Installer
# Usage: curl -fsSL https://peek-tech.github.io/devenv-setup/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
VERSION="2.0.0"

# Helper functions
print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           Developer Environment Setup v${VERSION}           ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

print_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
        OS_TYPE="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        OS_TYPE="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
        else
            DISTRO="unknown"
        fi
    else
        OS="unsupported"
        DISTRO="unknown"
        OS_TYPE="unsupported"
    fi
}

# Check prerequisites
check_prerequisites() {
    local missing_tools=()
    
    # Check for required tools
    command -v curl &> /dev/null || missing_tools+=("curl")
    command -v git &> /dev/null || missing_tools+=("git")
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_info "Please install them first and run this script again."
        exit 1
    fi
}

# Request sudo access upfront for macOS installations
request_sudo() {
    if [[ "$OS_TYPE" == "macos" ]]; then
        print_info "This installer requires sudo access for Homebrew installation"
        print_info "Please enter your password when prompted"
        
        if ! sudo -v; then
            print_error "Sudo access is required for installation"
            print_info "Please run with appropriate permissions or contact your system administrator"
            exit 1
        fi
        
        print_status "Sudo access granted"
    fi
}

# Detect user's shell and return appropriate config file
get_shell_config_file() {
    local user_shell="$(basename "$SHELL")"
    local config_file=""
    
    case "$user_shell" in
        zsh)
            if [ "$OS_TYPE" = "macos" ]; then
                config_file="$HOME/.zprofile"
            else
                config_file="$HOME/.zshrc"
            fi
            ;;
        bash)
            if [ "$OS_TYPE" = "macos" ]; then
                config_file="$HOME/.bash_profile"
            else
                config_file="$HOME/.bashrc"
            fi
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            ;;
        csh|tcsh)
            config_file="$HOME/.cshrc"
            ;;
        ksh)
            config_file="$HOME/.kshrc"
            ;;
        *)
            # Default fallback
            if [ "$OS_TYPE" = "macos" ]; then
                config_file="$HOME/.profile"
            else
                config_file="$HOME/.bashrc"
            fi
            ;;
    esac
    
    echo "$config_file"
}

# Add content to shell config with shell-specific syntax
add_to_shell_config() {
    local content="$1"
    local description="$2"
    local user_shell="$(basename "$SHELL")"
    local config_file="$(get_shell_config_file)"
    
    if [ -z "$config_file" ]; then
        print_warning "Could not determine shell configuration file for $user_shell"
        return 1
    fi
    
    # Create config file if it doesn't exist
    mkdir -p "$(dirname "$config_file")"
    touch "$config_file"
    
    # Check if content already exists
    if grep -q "$description" "$config_file" 2>/dev/null; then
        print_status "$description already configured in $config_file"
        return 0
    fi
    
    print_info "Adding $description to $config_file..."
    
    # Add shell-specific content
    case "$user_shell" in
        fish)
            # Fish shell has different syntax
            echo "" >> "$config_file"
            echo "# $description" >> "$config_file"
            # Convert bash syntax to fish syntax if needed
            echo "$content" | sed 's/export \([^=]*\)=\(.*\)/set -gx \1 \2/' >> "$config_file"
            ;;
        csh|tcsh)
            # C shell syntax
            echo "" >> "$config_file"
            echo "# $description" >> "$config_file"
            echo "$content" | sed 's/export \([^=]*\)=\(.*\)/setenv \1 \2/' >> "$config_file"
            ;;
        *)
            # POSIX-compatible shells (bash, zsh, ksh, etc.)
            echo "" >> "$config_file"
            echo "# $description" >> "$config_file"
            echo "$content" >> "$config_file"
            ;;
    esac
    
    print_status "$description added to $config_file"
}

# Create modern CLI tools aliases file
create_modern_cli_aliases() {
    local aliases_file="$HOME/.modern_cli_aliases"
    
    print_info "Creating modern CLI tools aliases file..."
    
    cat > "$aliases_file" << 'EOF'
#!/bin/bash
# Modern CLI Tools Aliases
# This file replaces traditional CLI tools with their modern alternatives
# Generated by Developer Environment Setup

# Only create aliases if the modern tools are actually installed
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --time-style=long-iso'
    alias la='eza -la --icons --group-directories-first --time-style=long-iso'
    alias lt='eza --tree --icons --group-directories-first'
    alias l='eza -la --icons --group-directories-first --time-style=long-iso'
    alias tree='eza --tree --icons'
fi

if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias less='bat --paging=always'
    alias more='bat --paging=always'
fi

if command -v rg &> /dev/null; then
    alias grep='rg'
fi

if command -v fd &> /dev/null; then
    alias find='fd'
fi

if command -v delta &> /dev/null; then
    # Git aliases using delta for better diffs
    alias gdiff='git diff'
    alias gshow='git show'
    alias glog='git log --oneline --graph --decorate'
fi

if command -v fzf &> /dev/null; then
    # Enhanced command history search
    alias hist='history | fzf'
fi

if command -v dust &> /dev/null; then
    alias du='dust'
fi

if command -v procs &> /dev/null; then
    alias ps='procs'
fi

if command -v sd &> /dev/null; then
    alias sed='sd'
fi

if command -v tealdeer &> /dev/null; then
    alias tldr='tldr'
    alias man='tldr'
fi

if command -v glances &> /dev/null; then
    alias top='glances'
elif command -v htop &> /dev/null; then
    alias top='htop'
fi

if command -v hyperfine &> /dev/null; then
    alias time='hyperfine'
fi

# Git aliases (always available)
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git status'
alias gl='git pull'
alias gp='git push'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gm='git merge'
alias gr='git remote'
alias gra='git remote add'
alias grv='git remote -v'
alias gf='git fetch'

# Modern alternatives info
alias which-modern='echo "Modern CLI replacements active: eza→ls, bat→cat, rg→grep, fd→find, delta→git-diff, dust→du, procs→ps, sd→sed, tldr→man, glances→top, hyperfine→time + ncdu, just, zoxide(z), pspg, fclones"'
EOF

    print_status "Modern CLI aliases file created at $aliases_file"
    echo "$aliases_file"
}

# Create shell-specific aliases file for non-POSIX shells
create_shell_specific_aliases() {
    local user_shell="$(basename "$SHELL")"
    local shell_aliases_file=""
    
    case "$user_shell" in
        fish)
            shell_aliases_file="$HOME/.config/fish/functions/modern_cli_aliases.fish"
            mkdir -p "$(dirname "$shell_aliases_file")"
            
            print_info "Creating Fish shell aliases..."
            cat > "$shell_aliases_file" << 'EOF'
# Modern CLI Tools Aliases for Fish Shell
# Generated by Developer Environment Setup

# Only create aliases if the modern tools are actually installed
if command -v eza > /dev/null
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --time-style=long-iso'
    alias la='eza -la --icons --group-directories-first --time-style=long-iso'
    alias lt='eza --tree --icons --group-directories-first'
    alias l='eza -la --icons --group-directories-first --time-style=long-iso'
    alias tree='eza --tree --icons'
end

if command -v bat > /dev/null
    alias cat='bat --paging=never'
    alias less='bat --paging=always'
    alias more='bat --paging=always'
end

if command -v rg > /dev/null
    alias grep='rg'
end

if command -v fd > /dev/null
    alias find='fd'
end

if command -v dust > /dev/null
    alias du='dust'
end

if command -v procs > /dev/null
    alias ps='procs'
end

if command -v sd > /dev/null
    alias sed='sd'
end

if command -v tealdeer > /dev/null
    alias tldr='tldr'
    alias man='tldr'
end

if command -v glances > /dev/null
    alias top='glances'
else if command -v htop > /dev/null
    alias top='htop'
end

if command -v hyperfine > /dev/null
    alias time='hyperfine'
end

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git status'
alias gl='git pull'
alias gp='git push'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gm='git merge'
alias gr='git remote'
alias gra='git remote add'
alias grv='git remote -v'
alias gf='git fetch'

# Modern alternatives info
alias which-modern='echo "Modern CLI replacements active: eza→ls, bat→cat, rg→grep, fd→find, delta→git-diff, dust→du, procs→ps, sd→sed, tldr→man, glances→top, hyperfine→time + ncdu, just, zoxide(z), pspg, fclones"'
EOF
            ;;
            
        csh|tcsh)
            shell_aliases_file="$HOME/.modern_cli_aliases.csh"
            
            print_info "Creating C shell aliases..."
            cat > "$shell_aliases_file" << 'EOF'
# Modern CLI Tools Aliases for C Shell
# Generated by Developer Environment Setup

# Basic aliases (C shell doesn't support conditional aliases easily)
alias ls 'eza --icons --group-directories-first'
alias ll 'eza -l --icons --group-directories-first --time-style=long-iso'
alias la 'eza -la --icons --group-directories-first --time-style=long-iso'
alias lt 'eza --tree --icons --group-directories-first'
alias l 'eza -la --icons --group-directories-first --time-style=long-iso'
alias tree 'eza --tree --icons'

alias cat 'bat --paging=never'
alias less 'bat --paging=always'
alias more 'bat --paging=always'

alias grep 'rg'
alias find 'fd'
alias du 'dust'
alias ps 'procs'
alias sed 'sd'
alias tldr 'tldr'
alias man 'tldr'
alias top 'glances'
alias time 'hyperfine'

# Git aliases
alias g 'git'
alias ga 'git add'
alias gaa 'git add --all'
alias gc 'git commit'
alias gco 'git checkout'
alias gst 'git status'
alias gl 'git pull'
alias gp 'git push'
alias gb 'git branch'
alias gba 'git branch -a'
alias gbd 'git branch -d'
alias gm 'git merge'
alias gr 'git remote'
alias gra 'git remote add'
alias grv 'git remote -v'
alias gf 'git fetch'
EOF
            ;;
    esac
    
    if [ -n "$shell_aliases_file" ]; then
        print_status "Shell-specific aliases created at $shell_aliases_file"
        echo "$shell_aliases_file"
    fi
}

# Link aliases file to shell configuration
setup_modern_cli_aliases() {
    local user_shell="$(basename "$SHELL")"
    local config_file="$(get_shell_config_file)"
    local aliases_file=""
    
    print_info "Setting up modern CLI tool aliases..."
    
    case "$user_shell" in
        fish)
            # Fish uses functions, already created above
            aliases_file="$(create_shell_specific_aliases)"
            print_status "Fish shell aliases configured"
            ;;
            
        csh|tcsh)
            # C shell needs special handling
            aliases_file="$(create_shell_specific_aliases)"
            
            # Source the aliases file in shell config
            if [ -n "$aliases_file" ] && [ -f "$aliases_file" ]; then
                add_to_shell_config "source $aliases_file" "Modern CLI Tools Aliases"
            fi
            ;;
            
        *)
            # POSIX-compatible shells (bash, zsh, ksh, etc.)
            aliases_file="$(create_modern_cli_aliases)"
            
            # Source the aliases file in shell config
            if [ -f "$aliases_file" ]; then
                add_to_shell_config "source $aliases_file" "Modern CLI Tools Aliases"
            fi
            ;;
    esac
    
    print_status "Modern CLI aliases setup complete!"
    print_info "Restart your terminal or run 'source $(get_shell_config_file)' to activate aliases"
    print_info "Use 'which-modern' command to see active modern tool replacements"
}

# Setup shell completions for modern CLI tools
setup_shell_completions() {
    local user_shell="$(basename "$SHELL")"
    local completions_file="$HOME/.modern_cli_completions"
    
    print_info "Setting up shell completions for modern CLI tools..."
    
    case "$user_shell" in
        bash)
            setup_bash_completions
            ;;
        zsh)
            setup_zsh_completions
            ;;
        fish)
            setup_fish_completions
            ;;
        *)
            print_warning "Shell completions not configured for $user_shell"
            return 0
            ;;
    esac
    
    print_status "Shell completions setup complete!"
}

# Setup completions for Bash
setup_bash_completions() {
    local completions_dir="$HOME/.local/share/bash-completion/completions"
    local completions_file="$HOME/.modern_cli_completions"
    
    mkdir -p "$completions_dir"
    
    print_info "Setting up Bash completions..."
    
    # Create completions script
    cat > "$completions_file" << 'EOF'
#!/bin/bash
# Modern CLI Tools Completions for Bash
# Generated by Developer Environment Setup

# Setup completion directories
export BASH_COMPLETION_USER_DIR="$HOME/.local/share/bash-completion/completions"
mkdir -p "$BASH_COMPLETION_USER_DIR"

# Generate completions for tools that support runtime generation
generate_completion() {
    local tool="$1"
    local completion_cmd="$2"
    local output_file="$3"
    
    if command -v "$tool" &> /dev/null; then
        if ! [ -f "$output_file" ]; then
            $completion_cmd > "$output_file" 2>/dev/null || true
        fi
    fi
}

# Generate completions for supported tools
generate_completion "bat" "bat --completion bash" "$BASH_COMPLETION_USER_DIR/bat"
generate_completion "hyperfine" "hyperfine --completion bash" "$BASH_COMPLETION_USER_DIR/hyperfine"
generate_completion "just" "just --completions bash" "$BASH_COMPLETION_USER_DIR/just"
generate_completion "zoxide" "zoxide init bash" "$HOME/.zoxide_completion"

# Source zoxide if available (special case - provides shell integration)
if command -v zoxide &> /dev/null && [ -f "$HOME/.zoxide_completion" ]; then
    source "$HOME/.zoxide_completion"
fi

# Enable bash completion if available
if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi
EOF
    
    # Link to shell config
    add_to_shell_config "source $completions_file" "Modern CLI Tools Completions"
    
    # Generate initial completions
    source "$completions_file" 2>/dev/null || true
    
    print_status "Bash completions configured"
}

# Setup completions for Zsh
setup_zsh_completions() {
    local completions_dir="$HOME/.zfunc"
    local completions_file="$HOME/.modern_cli_completions"
    
    mkdir -p "$completions_dir"
    
    print_info "Setting up Zsh completions..."
    
    # Create completions script
    cat > "$completions_file" << 'EOF'
#!/bin/zsh
# Modern CLI Tools Completions for Zsh
# Generated by Developer Environment Setup

# Setup completion directories
export ZFUNC_DIR="$HOME/.zfunc"
mkdir -p "$ZFUNC_DIR"

# Add to FPATH if not already there
if [[ ":$FPATH:" != *":$ZFUNC_DIR:"* ]]; then
    export FPATH="$ZFUNC_DIR:$FPATH"
fi

# Generate completions for tools that support runtime generation
generate_completion() {
    local tool="$1"
    local completion_cmd="$2"
    local output_file="$3"
    
    if command -v "$tool" &> /dev/null; then
        if ! [ -f "$output_file" ]; then
            $completion_cmd > "$output_file" 2>/dev/null || true
        fi
    fi
}

# Generate completions for supported tools
generate_completion "bat" "bat --completion zsh" "$ZFUNC_DIR/_bat"
generate_completion "hyperfine" "hyperfine --completion zsh" "$ZFUNC_DIR/_hyperfine"
generate_completion "just" "just --completions zsh" "$ZFUNC_DIR/_just"

# Setup zoxide (special case - provides shell integration)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Initialize completion system
autoload -Uz compinit
compinit
EOF
    
    # Link to shell config
    add_to_shell_config "source $completions_file" "Modern CLI Tools Completions"
    
    # Generate initial completions
    source "$completions_file" 2>/dev/null || true
    
    print_status "Zsh completions configured"
}

# Setup completions for Fish
setup_fish_completions() {
    local completions_dir="$HOME/.config/fish/completions"
    local completions_file="$HOME/.config/fish/conf.d/modern_cli_completions.fish"
    
    mkdir -p "$completions_dir"
    mkdir -p "$(dirname "$completions_file")"
    
    print_info "Setting up Fish completions..."
    
    # Create completions script
    cat > "$completions_file" << 'EOF'
# Modern CLI Tools Completions for Fish
# Generated by Developer Environment Setup

# Function to generate completions if they don't exist
function generate_completion
    set tool $argv[1]
    set completion_cmd $argv[2]
    set output_file $argv[3]
    
    if command -v $tool > /dev/null 2>&1
        if not test -f $output_file
            eval $completion_cmd > $output_file 2>/dev/null
        end
    end
end

# Generate completions for supported tools
generate_completion "bat" "bat --completion fish" "$HOME/.config/fish/completions/bat.fish"
generate_completion "hyperfine" "hyperfine --completion fish" "$HOME/.config/fish/completions/hyperfine.fish"
generate_completion "just" "just --completions fish" "$HOME/.config/fish/completions/just.fish"

# Setup zoxide (special case - provides shell integration)
if command -v zoxide > /dev/null 2>&1
    zoxide init fish | source
end
EOF
    
    print_status "Fish completions configured"
}

# Setup SSH configuration for GitHub
setup_ssh_for_github() {
    print_info "Setting up SSH configuration for GitHub..."
    
    local ssh_dir="$HOME/.ssh"
    local ssh_config="$ssh_dir/config"
    local selected_key=""
    
    # Create SSH directory if it doesn't exist
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    
    # List existing SSH keys or offer to generate new one
    if ! select_or_generate_ssh_key; then
        print_warning "SSH key setup cancelled"
        return 1
    fi
    
    # Configure SSH config for GitHub
    if ! configure_ssh_config; then
        print_warning "SSH config setup failed"
        return 1
    fi
    
    # Test SSH connection and wait for user setup
    if ! wait_for_github_setup; then
        print_warning "GitHub SSH setup incomplete"
        return 1
    fi
    
    print_status "SSH configuration for GitHub complete!"
}

# Wrapper function for git operations that may require SSH
git_with_ssh_retry() {
    local operation="$1"
    shift
    local args=("$@")
    
    # First, try the git operation
    if git "$operation" "${args[@]}" 2>/dev/null; then
        return 0
    fi
    
    # If it failed, check if it's SSH-related and the operation involves github.com
    local error_output
    error_output=$(git "$operation" "${args[@]}" 2>&1)
    
    if echo "$error_output" | grep -q "github.com" && echo "$error_output" | grep -qE "(Permission denied|Could not read from remote|ssh:|fatal:)"; then
        print_warning "Git operation failed, likely due to SSH configuration"
        print_info "Error: $error_output"
        
        local retry
        if [ ! -t 0 ]; then
            if read -p "Retry SSH setup for GitHub? (y/N): " -n 1 -r retry </dev/tty 2>/dev/null; then
                echo ""
            else
                print_warning "No TTY available, skipping SSH retry"
                return 1
            fi
        else
            read -p "Retry SSH setup for GitHub? (y/N): " -n 1 -r retry
            echo ""
        fi
        
        if [[ $retry =~ ^[Yy]$ ]]; then
            print_info "Re-running SSH setup..."
            if setup_ssh_for_github; then
                print_info "Retrying git operation..."
                git "$operation" "${args[@]}"
            else
                print_error "SSH setup failed, git operation aborted"
                return 1
            fi
        else
            print_warning "Git operation cancelled"
            return 1
        fi
    else
        # Non-SSH related error, just show it
        print_error "Git operation failed: $error_output"
        return 1
    fi
}

# List available SSH keys and allow selection or generation
select_or_generate_ssh_key() {
    local ssh_dir="$HOME/.ssh"
    local keys=()
    
    print_info "Checking for existing SSH keys..."
    
    # Find existing private keys (exclude .pub files, known_hosts, config, etc.)
    while IFS= read -r -d '' key; do
        local keyname=$(basename "$key")
        # Skip public keys, known files, and directories
        if [[ ! "$keyname" =~ \.(pub|old|bak)$ ]] && \
           [[ "$keyname" != "known_hosts" ]] && \
           [[ "$keyname" != "config" ]] && \
           [[ "$keyname" != "authorized_keys" ]] && \
           [[ -f "$key" ]]; then
            keys+=("$keyname")
        fi
    done < <(find "$ssh_dir" -maxdepth 1 -type f -print0 2>/dev/null)
    
    if [ ${#keys[@]} -gt 0 ]; then
        print_info "Found existing SSH keys:"
        for i in "${!keys[@]}"; do
            echo "  $((i+1)). ${keys[i]}"
        done
        echo "  $((${#keys[@]}+1)). Generate new SSH key"
        echo "  $((${#keys[@]}+2)). Skip SSH setup"
        
        # Read user choice
        local choice
        if [ ! -t 0 ]; then
            if read -p "Select an option (1-$((${#keys[@]}+2))): " choice </dev/tty 2>/dev/null; then
                :
            else
                print_warning "No TTY available, generating new key"
                choice=$((${#keys[@]}+1))
            fi
        else
            read -p "Select an option (1-$((${#keys[@]}+2))): " choice
        fi
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#keys[@]} ]; then
            # User selected existing key
            selected_ssh_key="${keys[$((choice-1))]}"
            print_status "Selected existing key: $selected_ssh_key"
        elif [ "$choice" -eq $((${#keys[@]}+1)) ]; then
            # User wants to generate new key
            if ! generate_ssh_key; then
                return 1
            fi
        elif [ "$choice" -eq $((${#keys[@]}+2)) ]; then
            # User wants to skip
            print_info "Skipping SSH setup"
            return 1
        else
            print_error "Invalid choice"
            return 1
        fi
    else
        print_info "No existing SSH keys found"
        print_info "Options:"
        print_info "  1. Generate new SSH key"
        print_info "  2. Skip SSH setup (you can configure manually later)"
        
        local choice
        if [ ! -t 0 ]; then
            if read -p "Select option (1-2): " choice </dev/tty 2>/dev/null; then
                echo ""
            else
                print_warning "No TTY available, skipping SSH setup"
                return 1
            fi
        else
            read -p "Select option (1-2): " choice
        fi
        
        case "$choice" in
            1)
                if ! generate_ssh_key; then
                    print_error "Failed to generate SSH key"
                    return 1
                fi
                ;;
            2)
                print_info "Skipping SSH setup - you can configure manually later"
                print_info "Visit: https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
                return 1
                ;;
            *)
                print_error "Invalid choice, skipping SSH setup"
                return 1
                ;;
        esac
    fi
    
    return 0
}

# Generate new SSH key
generate_ssh_key() {
    local email=""
    local keyname="github"
    
    print_info "Generating new SSH key for GitHub..."
    
    # Get email for the key
    print_info "Enter your email address for the SSH key (or press Enter for default):"
    if [ ! -t 0 ]; then
        if read -p "Email [user@example.com]: " email </dev/tty 2>/dev/null; then
            :
        else
            print_warning "No TTY available, using default email"
            email="user@example.com"
        fi
    else
        read -p "Email [user@example.com]: " email
    fi
    
    if [ -z "$email" ]; then
        email="user@example.com"
        print_info "Using default email: $email"
    fi
    
    # Generate the key
    local key_path="$HOME/.ssh/$keyname"
    print_info "🔐 Generating SSH key pair..."
    
    if ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N ""; then
        selected_ssh_key="$keyname"
        print_status "✅ Generated new SSH key: $keyname"
        print_info "📁 Private key: $key_path"
        print_info "📄 Public key: ${key_path}.pub"
        
        # Add to ssh-agent
        if ssh-add "$key_path" 2>/dev/null; then
            print_status "🔑 Added key to ssh-agent"
        else
            print_warning "⚠️  Could not add key to ssh-agent (may need to start ssh-agent)"
        fi
    else
        print_error "❌ Failed to generate SSH key"
        return 1
    fi
    
    return 0
}

# Configure SSH config file for GitHub
configure_ssh_config() {
    local ssh_config="$HOME/.ssh/config"
    local key_path="$HOME/.ssh/$selected_ssh_key"
    
    print_info "Configuring SSH config for GitHub..."
    
    # Check if GitHub config already exists
    if grep -q "Host github.com" "$ssh_config" 2>/dev/null; then
        print_warning "GitHub SSH config already exists in $ssh_config"
        
        local choice
        if [ ! -t 0 ]; then
            if read -p "Update existing config? (y/N): " -n 1 -r choice </dev/tty 2>/dev/null; then
                echo ""
            else
                print_warning "No TTY available, skipping config update"
                return 0
            fi
        else
            read -p "Update existing config? (y/N): " -n 1 -r choice
            echo ""
        fi
        
        if [[ ! $choice =~ ^[Yy]$ ]]; then
            print_info "Keeping existing SSH config"
            return 0
        fi
        
        # Remove existing GitHub config
        sed -i.bak '/^Host github\.com$/,/^$/d' "$ssh_config"
    fi
    
    # Add GitHub SSH config
    cat >> "$ssh_config" << EOF

Host github.com
    HostName github.com
    AddKeysToAgent yes
    User git
    IdentityFile $key_path
EOF
    
    # Set proper permissions
    chmod 600 "$ssh_config"
    
    print_status "SSH config updated for GitHub"
    return 0
}

# Test SSH connection and wait for user to configure GitHub
wait_for_github_setup() {
    local key_path="$HOME/.ssh/$selected_ssh_key"
    local pub_key_path="${key_path}.pub"
    
    print_info "Setting up GitHub SSH key..."
    
    # Display the public key
    if [ -f "$pub_key_path" ]; then
        print_info "📋 Your SSH public key (copy the entire block below):"
        echo "" 
        echo "┌─────────────────────────────────────────────────────────────────────────────┐"
        echo "│ $(cat "$pub_key_path") │"
        echo "└─────────────────────────────────────────────────────────────────────────────┘"
        echo ""
        print_info "🔧 Setup Steps:"
        echo "   1. 📋 Copy the ENTIRE SSH key above (starts with 'ssh-ed25519')"
        echo "   2. 🌐 Open: https://github.com/settings/ssh/new"
        echo "   3. 📝 Title: 'Development Machine' (or any name you prefer)"
        echo "   4. 📋 Paste the key in the 'Key' field"
        echo "   5. ✅ Click 'Add SSH key'"
        echo "   6. 🔐 Enter your GitHub password if prompted"
        echo ""
    else
        print_error "SSH public key not found at $pub_key_path"
        return 1
    fi
    
    # Wait for user confirmation
    local ready=false
    while [ "$ready" = false ]; do
        local choice
        if [ ! -t 0 ]; then
            if read -p "Have you added the SSH key to GitHub? (y/N): " -n 1 -r choice </dev/tty 2>/dev/null; then
                echo ""
            else
                print_warning "No TTY available, assuming key is configured"
                choice="y"
            fi
        else
            read -p "Have you added the SSH key to GitHub? (y/N): " -n 1 -r choice
            echo ""
        fi
        
        if [[ $choice =~ ^[Yy]$ ]]; then
            # Test SSH connection
            print_info "🔍 Testing SSH connection to GitHub..."
            local ssh_output
            ssh_output=$(ssh -T git@github.com 2>&1)
            
            if echo "$ssh_output" | grep -q "successfully authenticated"; then
                print_status "✅ SSH connection to GitHub successful!"
                local username=$(echo "$ssh_output" | grep "Hi" | cut -d' ' -f2 | cut -d'!' -f1)
                if [ -n "$username" ]; then
                    print_info "🎉 Connected as GitHub user: $username"
                fi
                ready=true
            else
                print_warning "❌ SSH connection failed"
                print_info "Debug info: $ssh_output"
                echo ""
                print_info "🔧 Troubleshooting checklist:"
                echo "   1. ✅ SSH key was copied completely (including 'ssh-ed25519' prefix)"
                echo "   2. ✅ Key was pasted into GitHub settings correctly"
                echo "   3. ✅ You're logged into the correct GitHub account"
                echo "   4. ⏱️  Wait 30 seconds and try again (GitHub sync delay)"
                echo "   5. 🔄 Refresh the GitHub SSH keys page to confirm key was added"
                echo ""
                
                local retry
                if [ ! -t 0 ]; then
                    if read -p "Try again? (y/N): " -n 1 -r retry </dev/tty 2>/dev/null; then
                        echo ""
                    else
                        retry="n"
                    fi
                else
                    read -p "Try again? (y/N): " -n 1 -r retry
                    echo ""
                fi
                
                if [[ ! $retry =~ ^[Yy]$ ]]; then
                    print_warning "SSH setup incomplete - some git operations may fail"
                    return 1
                fi
            fi
        else
            print_info "⏳ Please complete the GitHub SSH setup first"
            print_info "🌐 Visit: https://github.com/settings/ssh/new"
            print_info "💡 Or press Ctrl+C to skip SSH setup and continue installation"
        fi
    done
    
    return 0
}

# Test GitHub SSH connection
test_github_ssh() {
    print_info "Testing GitHub SSH connection..."
    
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        print_status "GitHub SSH connection successful"
        return 0
    else
        print_warning "GitHub SSH connection failed"
        return 1
    fi
}

# Refresh environment to make newly installed tools available
refresh_environment() {
    local user_shell="$(basename "$SHELL")"
    local config_file="$(get_shell_config_file)"
    
    # Source common shell configuration files to pick up PATH changes
    if [ "$OS_TYPE" = "macos" ]; then
        # Source Homebrew environment for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]] && [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        # Source profile files based on shell
        case "$user_shell" in
            zsh)
                [ -f ~/.zprofile ] && source ~/.zprofile 2>/dev/null || true
                [ -f ~/.zshrc ] && source ~/.zshrc 2>/dev/null || true
                ;;
            bash)
                [ -f ~/.bash_profile ] && source ~/.bash_profile 2>/dev/null || true
                [ -f ~/.bashrc ] && source ~/.bashrc 2>/dev/null || true
                ;;
            fish)
                # Fish doesn't use traditional sourcing
                ;;
            *)
                [ -f ~/.profile ] && source ~/.profile 2>/dev/null || true
                ;;
        esac
    else
        # Linux - source based on shell
        case "$user_shell" in
            zsh)
                [ -f ~/.zshrc ] && source ~/.zshrc 2>/dev/null || true
                ;;
            bash)
                [ -f ~/.bashrc ] && source ~/.bashrc 2>/dev/null || true
                ;;
            fish)
                # Fish doesn't use traditional sourcing
                ;;
            *)
                [ -f ~/.profile ] && source ~/.profile 2>/dev/null || true
                ;;
        esac
    fi
    
    # Refresh PATH for local bin
    export PATH="$HOME/.local/bin:$PATH"
    
    # Source pyenv if available
    if [ -d "$HOME/.pyenv" ]; then
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        command -v pyenv >/dev/null && eval "$(pyenv init -)" 2>/dev/null || true
    fi
    
    # Source nvm if available
    if [ -d "$HOME/.nvm" ]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
    fi
    
    # Source bun if available
    if [ -d "$HOME/.bun" ]; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    fi
}

# Configure Catppuccin Mocha theme for supported tools
configure_tool_themes() {
    print_info "Configuring Catppuccin Mocha theme for modern CLI tools..."
    
    # Configure bat theme
    if command -v bat &> /dev/null; then
        print_info "Configuring bat with Catppuccin Mocha theme..."
        
        # Create bat config directory
        local bat_config_dir="$(bat --config-dir 2>/dev/null || echo "$HOME/.config/bat")"
        mkdir -p "$bat_config_dir/themes"
        
        # Download Catppuccin Mocha theme for bat
        print_info "Downloading Catppuccin Mocha theme for bat..."
        curl -fsSL "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme" \
             -o "$bat_config_dir/themes/Catppuccin-mocha.tmTheme" 2>/dev/null || {
            print_warning "Failed to download Catppuccin theme for bat"
        }
        
        # Rebuild bat cache
        if [ -f "$bat_config_dir/themes/Catppuccin-mocha.tmTheme" ]; then
            print_info "Building bat theme cache..."
            bat cache --build >/dev/null 2>&1
            
            # Create bat config file
            cat > "$bat_config_dir/config" << 'EOF'
# Bat configuration
# Theme: Catppuccin Mocha
--theme="Catppuccin Mocha"

# Show line numbers
--style="numbers,changes,header"

# Use italic text for emphasis
--italic-text=always

# Map file types
--map-syntax "*.ino:C++"
--map-syntax ".ignore:Git Ignore"
EOF
            print_status "Bat configured with Catppuccin Mocha theme"
        fi
    fi
    
    # Configure delta (git diff) with Catppuccin theme
    if command -v delta &> /dev/null; then
        print_info "Configuring delta with Catppuccin Mocha theme..."
        
        # Configure git to use delta with Catppuccin colors
        git config --global core.pager "delta"
        git config --global interactive.diffFilter "delta --color-only"
        git config --global delta.navigate "true"
        git config --global delta.light "false"
        git config --global delta.side-by-side "false"
        
        # Catppuccin Mocha colors for delta
        git config --global delta.syntax-theme "Catppuccin Mocha"
        git config --global delta.line-numbers "true"
        git config --global delta.line-numbers-left-format "{nm:>4}│"
        git config --global delta.line-numbers-right-format "{np:>4}│"
        git config --global delta.line-numbers-zero-style "#6c7086"
        git config --global delta.line-numbers-left-style "#6c7086"
        git config --global delta.line-numbers-right-style "#6c7086"
        git config --global delta.line-numbers-minus-style "#f38ba8"
        git config --global delta.line-numbers-plus-style "#a6e3a1"
        
        print_status "Delta configured with Catppuccin Mocha theme"
    fi
    
    # Configure fzf with Catppuccin colors
    if command -v fzf &> /dev/null; then
        print_info "Configuring fzf with Catppuccin Mocha colors..."
        
        local fzf_colors='--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
        
        # Add to shell config
        add_to_shell_config "export FZF_DEFAULT_OPTS=\"$fzf_colors\"" "FZF Catppuccin Mocha theme"
        
        print_status "FZF configured with Catppuccin Mocha colors"
    fi
    
    # Configure eza colors (eza uses LS_COLORS)
    if command -v eza &> /dev/null; then
        print_info "Configuring eza with Catppuccin colors..."
        
        # Catppuccin-inspired LS_COLORS
        local ls_colors='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33:cd=1;33:su=30;41:sg=30;46:tw=30;42:ow=30;43'
        
        add_to_shell_config "export LS_COLORS=\"$ls_colors\"" "LS_COLORS for eza Catppuccin theme"
        add_to_shell_config "export EZA_COLORS=\"da=1;34\"" "EZA specific colors"
        
        print_status "Eza configured with Catppuccin-inspired colors"
    fi
    
    print_status "Tool themes configuration complete!"
}

#=============================================================================
# DATABASE TOOLS INSTALLATION
#=============================================================================

install_database_tools() {
    print_section "Installing Database Development Tools"
    
    # Database GUI clients and CLI tools
    local db_gui_tools=(
        "dbeaver-community"        # Universal database GUI client
        "mongodb-compass"          # MongoDB official GUI client
    )
    
    local db_cli_tools=(
        "postgresql@16"            # PostgreSQL 16 server and psql CLI
        "mongosh"                  # MongoDB shell
        "lazysql"                  # Terminal UI for SQL databases
    )
    
    # Optional database servers (user choice)
    local db_servers=(
        "mongodb-community"        # MongoDB server
        "postgresql@16"            # PostgreSQL 16 server (already in CLI tools)
    )
    
    if [ "$OS_TYPE" = "macos" ]; then
        # Install GUI tools
        print_info "Installing database GUI clients..."
        for tool in "${db_gui_tools[@]}"; do
            if brew list --cask "$tool" &>/dev/null 2>&1; then
                print_status "$tool already installed"
            else
                print_info "Installing $tool..."
                if brew install --cask "$tool" 2>/dev/null; then
                    print_status "$tool installed successfully"
                else
                    print_warning "Failed to install $tool"
                fi
            fi
        done
    fi
    
    # Install CLI tools (cross-platform)
    print_info "Installing database CLI tools..."
    for tool in "${db_cli_tools[@]}"; do
        if brew list "$tool" &>/dev/null 2>&1; then
            print_status "$tool already installed"
        else
            print_info "Installing $tool..."
            if brew install "$tool" 2>/dev/null; then
                print_status "$tool installed successfully"
            else
                print_warning "Failed to install $tool"
            fi
        fi
    done
    
    # Ask about installing database servers
    setup_database_servers
    
    # Configure database tools
    configure_database_environment
    
    print_status "Database tools installation complete!"
}

setup_database_servers() {
    print_info "Database servers can be installed for local development..."
    
    # Ask about MongoDB
    local install_mongodb=false
    if [ ! -t 0 ]; then
        if read -p "Install MongoDB Community Server for local development? (y/N): " -n 1 -r mongodb_choice </dev/tty 2>/dev/null; then
            echo ""
            [[ $mongodb_choice =~ ^[Yy]$ ]] && install_mongodb=true
        else
            print_info "Skipping MongoDB server installation (no TTY)"
        fi
    else
        read -p "Install MongoDB Community Server for local development? (y/N): " -n 1 -r mongodb_choice
        echo ""
        [[ $mongodb_choice =~ ^[Yy]$ ]] && install_mongodb=true
    fi
    
    if [ "$install_mongodb" = true ]; then
        # Add MongoDB tap and install
        if ! brew tap | grep -q "mongodb/brew"; then
            print_info "Adding MongoDB Homebrew tap..."
            brew tap mongodb/brew
        fi
        
        if brew list mongodb-community &>/dev/null 2>&1; then
            print_status "MongoDB Community already installed"
        else
            print_info "Installing MongoDB Community Server..."
            if brew install mongodb-community; then
                print_status "MongoDB Community installed successfully"
                print_info "MongoDB can be started with: brew services start mongodb-community"
            else
                print_warning "Failed to install MongoDB Community"
            fi
        fi
    fi
    
    # PostgreSQL is already installed via postgresql@16 in CLI tools
    if brew list postgresql@16 &>/dev/null 2>&1; then
        print_status "PostgreSQL 16 server available"
        print_info "PostgreSQL can be started with: brew services start postgresql@16"
    fi
}

configure_database_environment() {
    print_info "Configuring database environment..."
    
    # Add PostgreSQL 16 to PATH
    if brew list postgresql@16 &>/dev/null 2>&1; then
        local pg_path="/opt/homebrew/opt/postgresql@16/bin"
        if [ "$OS_TYPE" = "macos" ] && [ -d "$pg_path" ]; then
            add_to_shell_config "export PATH=\"$pg_path:\$PATH\"" "PostgreSQL 16 PATH"
            print_status "PostgreSQL 16 added to PATH"
        fi
    fi
    
    # Add useful database aliases
    local db_aliases="
# Database development aliases
alias psql16='psql'
alias mongosh='mongosh'
alias lazysql='lazysql'

# Database service management (macOS)
alias start-postgres='brew services start postgresql@16'
alias stop-postgres='brew services stop postgresql@16'
alias restart-postgres='brew services restart postgresql@16'
alias start-mongo='brew services start mongodb-community'
alias stop-mongo='brew services stop mongodb-community'
alias restart-mongo='brew services restart mongodb-community'
"
    
    add_to_shell_config "$db_aliases" "Database Development Aliases"
    print_status "Database aliases configured"
    
    print_info "Database tools configured successfully!"
    print_info "Available commands:"
    echo "  • psql - PostgreSQL command line"
    echo "  • mongosh - MongoDB shell"
    echo "  • lazysql - Terminal UI for SQL databases"
    echo "  • DBeaver Community - Universal database GUI"
    echo "  • MongoDB Compass - MongoDB GUI client"
    echo ""
    print_info "Service management aliases:"
    echo "  • start-postgres / stop-postgres / restart-postgres"
    echo "  • start-mongo / stop-mongo / restart-mongo"
}

#=============================================================================
# CORE DEVELOPMENT TOOLS INSTALLATION
#=============================================================================

install_core_tools() {
    print_section "Installing Core Development Tools"
    
    if [ "$OS_TYPE" = "macos" ]; then
        install_homebrew
        refresh_environment
        install_macos_core_tools
        install_nerd_fonts
        configure_ghostty
        configure_vscode
        configure_vscode_terminal_default
    else
        install_linux_core_tools
    fi
    
    configure_git
    setup_git_aliases
    setup_modern_cli_aliases
    setup_shell_completions
    configure_tool_themes
    create_development_directories
    
    print_status "Core development tools installation complete!"
}

install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_info "Installing Homebrew..."
        
        # Always use non-interactive mode to avoid TTY issues
        print_info "Running Homebrew installation in non-interactive mode"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        print_status "Homebrew already installed"
    fi
}

install_macos_core_tools() {
    print_info "Installing core tools via Homebrew..."
    
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
    )
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            print_status "$tool already installed"
        else
            print_info "Installing $tool..."
            brew install "$tool"
        fi
    done
    
    # Install useful casks
    local casks=(
        "visual-studio-code"
        "ghostty"      # Modern terminal
        "rectangle"    # Window management
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

install_linux_core_tools() {
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        PKG_MGR="apt-get"
        PKG_UPDATE="sudo apt-get update"
        PKG_INSTALL="sudo apt-get install -y"
    elif command -v yum &> /dev/null; then
        PKG_MGR="yum"
        PKG_UPDATE="sudo yum check-update"
        PKG_INSTALL="sudo yum install -y"
    else
        print_error "No supported package manager found"
        return 1
    fi
    
    print_info "Updating package lists..."
    $PKG_UPDATE || true
    
    print_info "Installing core tools..."
    
    # Core tools for Linux
    local tools=(
        "git"
        "curl"
        "wget"
        "jq"
        "htop"
        "tmux"
        "tree"
        "build-essential"
        "software-properties-common"
    )
    
    for tool in "${tools[@]}"; do
        print_info "Installing $tool..."
        $PKG_INSTALL "$tool"
    done
    
    # Install GitHub CLI
    if ! command -v gh &> /dev/null; then
        print_info "Installing GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
    fi
    
    # Install ripgrep
    if ! command -v rg &> /dev/null; then
        print_info "Installing ripgrep..."
        curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
        sudo dpkg -i ripgrep_13.0.0_amd64.deb
        rm ripgrep_13.0.0_amd64.deb
    fi
}

configure_git() {
    if [ -z "$(git config --global user.name)" ]; then
        print_info "Git user name not configured"
        # Read input from /dev/tty if stdin is piped
        if [ ! -t 0 ]; then
            if read -p "Enter your name for git commits: " git_name </dev/tty 2>/dev/null; then
                :
            else
                print_warning "No TTY available, skipping git name configuration"
                return 0
            fi
        else
            read -p "Enter your name for git commits: " git_name
        fi
        git config --global user.name "$git_name"
    fi

    if [ -z "$(git config --global user.email)" ]; then
        print_info "Git email not configured"
        # Read input from /dev/tty if stdin is piped
        if [ ! -t 0 ]; then
            if read -p "Enter your email for git commits: " git_email </dev/tty 2>/dev/null; then
                :
            else
                print_warning "No TTY available, skipping git email configuration"
                return 0
            fi
        else
            read -p "Enter your email for git commits: " git_email
        fi
        git config --global user.email "$git_email"
    fi
    
    # Setup SSH for GitHub (optional, non-blocking)
    if ! setup_ssh_for_github; then
        print_warning "SSH setup failed or was skipped - you can configure it manually later"
        print_info "Visit https://docs.github.com/en/authentication/connecting-to-github-with-ssh for manual setup"
    fi
}

install_nerd_fonts() {
    if [ "$OS_TYPE" != "macos" ]; then
        return 0
    fi
    
    print_info "Installing ALL Nerd Fonts and Roboto family via Homebrew..."
    print_info "Note: homebrew/cask-fonts was deprecated in 2024 - using direct installation"
    
    # Complete list of ALL Nerd Fonts (based on nerdfonts.com/font-downloads + Homebrew search)
    local nerd_fonts=(
        # Core Nerd Fonts from nerdfonts.com + additional available fonts
        "font-0xproto-nerd-font"
        "font-3270-nerd-font"
        "font-adwaita-mono-nerd-font"
        "font-agave-nerd-font"
        "font-anonymice-nerd-font"
        "font-arimo-nerd-font"
        "font-aurulent-sans-mono-nerd-font"
        "font-bigblue-terminal-nerd-font"
        "font-bitstream-vera-sans-mono-nerd-font"
        "font-blex-mono-nerd-font"
        "font-caskaydia-cove-nerd-font"
        "font-caskaydia-mono-nerd-font"
        "font-code-new-roman-nerd-font"
        "font-comic-shanns-mono-nerd-font"
        "font-commit-mono-nerd-font"
        "font-cousine-nerd-font"
        "font-d2coding-nerd-font"
        "font-daddy-time-mono-nerd-font"
        "font-dejavu-sans-mono-nerd-font"
        "font-departure-mono-nerd-font"
        "font-droid-sans-mono-nerd-font"
        "font-envy-code-r-nerd-font"
        "font-fantasque-sans-mono-nerd-font"
        "font-fira-code-nerd-font"
        "font-fira-mono-nerd-font"
        "font-geist-mono-nerd-font"
        "font-go-mono-nerd-font"
        "font-gohufont-nerd-font"
        "font-hack-nerd-font"
        "font-hasklug-nerd-font"
        "font-heavy-data-nerd-font"
        "font-hurmit-nerd-font"
        "font-im-writing-nerd-font"
        "font-inconsolata-nerd-font"
        "font-inconsolata-go-nerd-font"
        "font-inconsolata-lgc-nerd-font"
        "font-intone-mono-nerd-font"
        "font-iosevka-nerd-font"
        "font-iosevka-term-nerd-font"
        "font-iosevka-term-slab-nerd-font"
        "font-jetbrains-mono-nerd-font"
        "font-lekton-nerd-font"
        "font-liberation-nerd-font"
        "font-lilex-nerd-font"
        "font-martian-mono-nerd-font"
        "font-meslo-lg-nerd-font"
        "font-monofur-nerd-font"
        "font-monoid-nerd-font"
        "font-mononoki-nerd-font"
        "font-m+-nerd-font"
        "font-noto-nerd-font"
        "font-open-dyslexic-nerd-font"
        "font-overpass-nerd-font"
        "font-profont-nerd-font"
        "font-proggy-clean-tt-nerd-font"
        "font-roboto-mono-nerd-font"
        "font-shure-tech-mono-nerd-font"
        "font-sauce-code-pro-nerd-font"
        "font-space-mono-nerd-font"
        "font-symbols-only-nerd-font"
        "font-terminess-ttf-nerd-font"
        "font-tinos-nerd-font"
        "font-ubuntu-nerd-font"
        "font-ubuntu-mono-nerd-font"
        "font-victor-mono-nerd-font"
        "font-recursive-mono-nerd-font"
        "font-zed-mono-nerd-font"
    )
    
    # Roboto font family (complete family)
    local roboto_fonts=(
        "font-roboto"
        "font-roboto-mono"
        "font-roboto-slab"
        "font-roboto-serif"
        "font-roboto-condensed"
        "font-roboto-flex"
    )
    
    # Install all Nerd Fonts
    print_info "Installing ${#nerd_fonts[@]} Nerd Fonts..."
    local installed_count=0
    local failed_count=0
    
    for font in "${nerd_fonts[@]}"; do
        if brew list --cask "$font" &>/dev/null 2>&1; then
            installed_count=$((installed_count + 1))
        else
            if brew install "$font" &>/dev/null; then
                installed_count=$((installed_count + 1))
                print_status "Installed $font"
            else
                failed_count=$((failed_count + 1))
                print_warning "Failed to install $font (may not be available)"
            fi
        fi
    done
    
    # Install Roboto font family
    print_info "Installing Roboto font family..."
    for font in "${roboto_fonts[@]}"; do
        if brew list --cask "$font" &>/dev/null 2>&1; then
            print_status "$font already installed"
        else
            if brew install "$font" &>/dev/null; then
                print_status "Installed $font"
            else
                print_warning "Failed to install $font (may not be available)"
            fi
        fi
    done
    
    print_status "Font installation complete!"
    print_info "Installed: $installed_count Nerd Fonts"
    if [ $failed_count -gt 0 ]; then
        print_info "Failed: $failed_count fonts (names may have changed)"
    fi
    print_info "All fonts are now available system-wide"
}

setup_git_aliases() {
    print_info "Setting up git aliases..."
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
}

configure_ghostty() {
    if [ "$OS_TYPE" != "macos" ]; then
        return 0
    fi
    
    print_info "Configuring Ghostty terminal..."
    
    # Create Ghostty config directory
    local ghostty_config_dir="$HOME/.config/ghostty"
    local ghostty_config_file="$ghostty_config_dir/config"
    
    mkdir -p "$ghostty_config_dir"
    
    # Check if config already exists
    if [ -f "$ghostty_config_file" ]; then
        # Backup existing config
        cp "$ghostty_config_file" "$ghostty_config_file.backup"
        print_info "Existing Ghostty config backed up to config.backup"
    fi
    
    # Create Ghostty configuration with OpenDyslexic font
    cat > "$ghostty_config_file" << 'EOF'
# Ghostty Configuration

# Font Configuration - OpenDyslexic for better readability
font-family = "OpenDyslexicM Nerd Font"
font-size = 14

# Fallback fonts in case OpenDyslexic isn't available
font-family-bold = "OpenDyslexicM Nerd Font Bold"
font-family-italic = "OpenDyslexicM Nerd Font Italic"
font-family-bold-italic = "OpenDyslexicM Nerd Font Bold Italic"

# Alternative font stack (will fall back if OpenDyslexic not found)
# You can uncomment these if you prefer a different font:
# font-family = "JetBrainsMono Nerd Font"
# font-family = "Hack Nerd Font"

# Window Configuration
window-decoration = true
window-padding-x = 10
window-padding-y = 10

# Theme Configuration (optional - add your preferred theme)
# theme = "dark"

# Performance
gpu-renderer = auto

# Cursor
cursor-style = block
cursor-blink = true

# Scrollback
scrollback-limit = 10000

# Bell
audible-bell = false
visual-bell = true

# MacOS specific settings
macos-option-as-alt = true
EOF
    
    print_status "Ghostty configured with OpenDyslexic font as default"
    print_info "Configuration file: $ghostty_config_file"
}

configure_vscode() {
    if ! command -v code &> /dev/null; then
        print_warning "VS Code not found, skipping extension installation"
        return
    fi
    
    print_info "Installing VS Code extensions..."
    
    # Essential extensions
    local extensions=(
        # Python development
        "ms-python.python"
        "ms-python.black-formatter"
        "ms-python.pylint"
        "ms-python.isort"
        "ms-toolsai.jupyter"
        "ms-toolsai.vscode-jupyter-cell-tags"
        "ms-toolsai.vscode-jupyter-slideshow"
        
        # Node.js/JavaScript development
        "ms-vscode.vscode-typescript-next"
        "bradlc.vscode-tailwindcss"
        "esbenp.prettier-vscode"
        "dbaeumer.vscode-eslint"
        "formulahendry.auto-rename-tag"
        "christian-kohler.path-intellisense"
        
        # General development
        "mhutchie.git-graph"
        "eamodio.gitlens"
        "ms-vsliveshare.vsliveshare"
        "ms-vscode-remote.remote-containers"
        "ms-vscode-remote.remote-ssh"
        "ms-vscode-remote.remote-wsl"
        
        # Productivity
        "wayou.vscode-todo-highlight"
        "streetsidesoftware.code-spell-checker"
        "thenikso.github-plus-theme"
    )
    
    for extension in "${extensions[@]}"; do
        print_info "Installing $extension..."
        if code --install-extension "$extension" --force &>/dev/null; then
            print_status "$extension installed"
        else
            print_warning "Failed to install $extension"
        fi
    done
    
    print_status "VS Code extensions installation complete"
}

configure_vscode_terminal_default() {
    if [ "$OS_TYPE" != "macos" ]; then
        return 0
    fi
    
    local vscode_settings_dir="$HOME/Library/Application Support/Code/User"
    local settings_file="$vscode_settings_dir/settings.json"
    
    mkdir -p "$vscode_settings_dir"
    
    # Check if Ghostty is installed
    local ghostty_path="/Applications/Ghostty.app/Contents/MacOS/ghostty"
    local use_ghostty=false
    
    if [ -f "$ghostty_path" ]; then
        use_ghostty=true
        print_info "Ghostty found, configuring as VS Code default terminal"
    else
        print_warning "Ghostty not found, using default terminal configuration"
    fi
    
    # Backup existing settings if they exist
    if [ -f "$settings_file" ]; then
        cp "$settings_file" "$settings_file.backup"
        print_info "Existing VS Code settings backed up to settings.json.backup"
    fi
    
    # Create VS Code settings with conditional Ghostty configuration
    if [ "$use_ghostty" = true ]; then
        cat > "$settings_file" << 'EOF'
{
    "terminal.integrated.defaultProfile.osx": "ghostty",
    "terminal.integrated.profiles.osx": {
        "ghostty": {
            "path": "/Applications/Ghostty.app/Contents/MacOS/ghostty",
            "args": [],
            "icon": "terminal"
        },
        "zsh": {
            "path": "zsh",
            "args": ["-l"],
            "icon": "terminal-bash"
        },
        "bash": {
            "path": "bash",
            "args": ["-l"],
            "icon": "terminal-bash"
        }
    },
    "terminal.external.osxExec": "Ghostty.app",
    "python.defaultInterpreterPath": "python",
    "python.formatting.provider": "black",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "files.associations": {
        "*.json": "jsonc"
    },
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "workbench.startupEditor": "welcomePageInEmptyWorkbench"
}
EOF
    else
        # Fallback configuration without Ghostty
        cat > "$settings_file" << 'EOF'
{
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.profiles.osx": {
        "zsh": {
            "path": "zsh",
            "args": ["-l"],
            "icon": "terminal-bash"
        },
        "bash": {
            "path": "bash",
            "args": ["-l"],
            "icon": "terminal-bash"
        }
    },
    "python.defaultInterpreterPath": "python",
    "python.formatting.provider": "black",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "files.associations": {
        "*.json": "jsonc"
    },
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "workbench.startupEditor": "welcomePageInEmptyWorkbench"
}
EOF
    fi
    
    print_status "VS Code terminal configuration complete"
}

create_development_directories() {
    print_info "Creating common development directories..."
    mkdir -p ~/Development
    mkdir -p ~/Scripts
    mkdir -p ~/.config
}

#=============================================================================
# PROGRAMMING LANGUAGES INSTALLATION
#=============================================================================

install_programming_languages() {
    print_section "Installing Programming Languages"
    
    install_pyenv
    refresh_environment
    install_nvm
    refresh_environment
    install_go
    refresh_environment
    install_bun
    refresh_environment
    setup_language_directories
    
    # Install specific language versions
    print_info "Installing specific language versions..."
    install_python_versions  # Python 3.11 as default
    install_node_versions    # Node.js 20, 22 with 20 as default
    
    print_status "Programming languages installation complete!"
}

install_pyenv() {
    if command -v pyenv &> /dev/null; then
        print_status "pyenv already installed: $(pyenv --version)"
        return 0
    fi
    
    print_info "Installing pyenv..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew install pyenv
                
                # Install Python build dependencies
                brew install openssl readline sqlite3 xz zlib tcl-tk
            else
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        linux)
            # Install dependencies first
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
                    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
                    libffi-dev liblzma-dev
            elif command -v yum &> /dev/null; then
                sudo yum groupinstall -y "Development Tools"
                sudo yum install -y zlib-devel bzip2 bzip2-devel readline-devel sqlite \
                    sqlite-devel openssl-devel tk-devel libffi-devel xz-devel
            fi
            
            # Install pyenv using installer
            curl https://pyenv.run | bash
            ;;
    esac
    
    # Add to shell configuration
    add_pyenv_to_shell
    
    print_status "pyenv installed successfully"
}

add_pyenv_to_shell() {
    local user_shell="$(basename "$SHELL")"
    local pyenv_config
    
    case "$user_shell" in
        fish)
            pyenv_config='set -gx PYENV_ROOT "$HOME/.pyenv"
fish_add_path "$PYENV_ROOT/bin"
pyenv init - | source'
            ;;
        csh|tcsh)
            pyenv_config='setenv PYENV_ROOT "$HOME/.pyenv"
setenv PATH "$PYENV_ROOT/bin:$PATH"
eval "`pyenv init -`"'
            ;;
        *)
            pyenv_config='export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"'
            ;;
    esac
    
    add_to_shell_config "$pyenv_config" "pyenv"
    
    # Source for current session (only works for POSIX shells)
    if [[ "$user_shell" != "fish" && "$user_shell" != "csh" && "$user_shell" != "tcsh" ]]; then
        export PYENV_ROOT="$HOME/.pyenv"
        command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)" 2>/dev/null || true
    fi
}

install_nvm() {
    if [ -d "$HOME/.nvm" ] || command -v nvm &> /dev/null; then
        print_status "nvm already installed"
        return 0
    fi
    
    print_info "Installing nvm..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew install nvm
                # Create nvm directory for Homebrew version
                mkdir -p ~/.nvm
            else
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        linux)
            # Download and install nvm
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
            ;;
    esac
    
    # Source nvm for current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    print_status "nvm installed successfully"
}

install_go() {
    if command -v go &> /dev/null; then
        print_status "Go already installed: $(go version)"
        return 0
    fi
    
    print_info "Installing Go..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew install go
            else
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        linux)
            # Get latest Go version
            GO_VERSION=$(curl -s https://go.dev/VERSION?m=text)
            GO_TARBALL="${GO_VERSION}.linux-amd64.tar.gz"
            
            print_info "Downloading Go ${GO_VERSION}..."
            wget "https://go.dev/dl/${GO_TARBALL}" -O "/tmp/${GO_TARBALL}"
            
            # Remove existing Go installation
            sudo rm -rf /usr/local/go
            
            # Extract new Go
            sudo tar -C /usr/local -xzf "/tmp/${GO_TARBALL}"
            rm "/tmp/${GO_TARBALL}"
            
            # Add to PATH
            add_go_to_shell
            ;;
    esac
    
    print_status "Go installed successfully"
}

add_go_to_shell() {
    local user_shell="$(basename "$SHELL")"
    local go_config
    
    case "$user_shell" in
        fish)
            go_config='fish_add_path "/usr/local/go/bin"
set -gx GOPATH "$HOME/go"
fish_add_path "$GOPATH/bin"'
            ;;
        csh|tcsh)
            go_config='setenv PATH "$PATH:/usr/local/go/bin"
setenv GOPATH "$HOME/go"
setenv PATH "$PATH:$GOPATH/bin"'
            ;;
        *)
            go_config='export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin'
            ;;
    esac
    
    add_to_shell_config "$go_config" "Go"
    
    # Source for current session (only works for POSIX shells)
    if [[ "$user_shell" != "fish" && "$user_shell" != "csh" && "$user_shell" != "tcsh" ]]; then
        export PATH=$PATH:/usr/local/go/bin
        export GOPATH=$HOME/go
        export PATH=$PATH:$GOPATH/bin
    fi
}

install_python_versions() {
    if ! command -v pyenv &> /dev/null; then
        print_warning "pyenv not available, skipping Python version installation"
        return
    fi
    
    print_info "Installing Python 3.11..."
    
    # Install Python 3.11 (latest patch version)
    local python_version="3.11.10"
    
    if pyenv versions | grep -q "$python_version"; then
        print_status "Python $python_version already installed"
    else
        print_info "Installing Python $python_version..."
        pyenv install "$python_version"
    fi
    
    # Set Python 3.11 as global default
    pyenv global "$python_version"
    print_status "Set Python $python_version as system default"
    
    # Install Poetry for dependency management
    install_poetry
}

install_poetry() {
    if command -v poetry &> /dev/null; then
        print_status "Poetry already installed: $(poetry --version)"
        return 0
    fi
    
    print_info "Installing Poetry..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew install poetry
            else
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        linux)
            # Install Poetry using the official installer
            curl -sSL https://install.python-poetry.org | python3 -
            # Add Poetry to PATH
            add_poetry_to_shell
            ;;
    esac
    
    print_status "Poetry installed successfully"
}

add_poetry_to_shell() {
    local user_shell="$(basename "$SHELL")"
    local poetry_config
    
    case "$user_shell" in
        fish)
            poetry_config='fish_add_path "$HOME/.local/bin"'
            ;;
        csh|tcsh)
            poetry_config='setenv PATH "$HOME/.local/bin:$PATH"'
            ;;
        *)
            poetry_config='export PATH="$HOME/.local/bin:$PATH"'
            ;;
    esac
    
    add_to_shell_config "$poetry_config" "Poetry"
    
    # Source for current session (only works for POSIX shells)
    if [[ "$user_shell" != "fish" && "$user_shell" != "csh" && "$user_shell" != "tcsh" ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

install_node_versions() {
    # Source nvm if available
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    if ! command -v nvm &> /dev/null; then
        print_warning "nvm not available, skipping Node.js version installation"
        return
    fi
    
    print_info "Installing Node.js versions..."
    
    # Install specific Node.js versions
    local node_versions=("20" "22")
    
    for version in "${node_versions[@]}"; do
        if nvm list | grep -q "v$version"; then
            print_status "Node.js $version already installed"
        else
            print_info "Installing Node.js $version..."
            nvm install "$version"
        fi
    done
    
    # Set Node.js 20 as default
    nvm use 20
    nvm alias default 20
    print_status "Set Node.js 20 as system default"
    
    # Install Yarn for dependency management
    install_yarn
}

install_yarn() {
    # Make sure we're using the default Node.js version
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm use default 2>/dev/null || true
    
    if command -v yarn &> /dev/null; then
        print_status "Yarn already installed: $(yarn --version)"
        return 0
    fi
    
    print_info "Installing Yarn..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew install yarn
            else
                # Install via npm as fallback
                npm install -g yarn
            fi
            ;;
        linux)
            # Install via npm
            npm install -g yarn
            ;;
    esac
    
    print_status "Yarn installed successfully"
}

install_bun() {
    if command -v bun &> /dev/null; then
        print_status "Bun already installed: $(bun --version)"
        return 0
    fi
    
    print_info "Installing Bun..."
    
    case "$OS_TYPE" in
        macos)
            if command -v brew &> /dev/null; then
                brew tap oven-sh/bun
                brew install bun
            else
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        linux)
            # Install Bun using the official installer
            curl -fsSL https://bun.sh/install | bash
            # Source bun for current session
            export BUN_INSTALL="$HOME/.bun"
            export PATH="$BUN_INSTALL/bin:$PATH"
            # Add to shell configuration
            add_bun_to_shell
            ;;
    esac
    
    print_status "Bun installed successfully"
}

add_bun_to_shell() {
    local user_shell="$(basename "$SHELL")"
    local bun_config
    
    case "$user_shell" in
        fish)
            bun_config='set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"'
            ;;
        csh|tcsh)
            bun_config='setenv BUN_INSTALL "$HOME/.bun"
setenv PATH "$BUN_INSTALL/bin:$PATH"'
            ;;
        *)
            bun_config='export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"'
            ;;
    esac
    
    add_to_shell_config "$bun_config" "Bun"
    
    # Source for current session (only works for POSIX shells)
    if [[ "$user_shell" != "fish" && "$user_shell" != "csh" && "$user_shell" != "tcsh" ]]; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    fi
}

setup_language_directories() {
    print_info "Creating language development directories..."
    
    mkdir -p ~/Development/python
    mkdir -p ~/Development/javascript
    mkdir -p ~/Development/go
    
    # Create Go workspace
    mkdir -p ~/go/{bin,src,pkg}
    
    print_status "Development directories created"
}

#=============================================================================
# WEB BROWSERS INSTALLATION
#=============================================================================

install_web_browsers() {
    print_section "Installing Web Browsers"
    
    if [[ "$OS_TYPE" != "macos" ]]; then
        print_error "Browser installation is designed for macOS only"
        return 1
    fi
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew not found. Please install core tools first."
        return 1
    fi
    
    # Browser casks to install
    local browsers=(
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
    
    # Read input from /dev/tty if stdin is piped
    if [ ! -t 0 ]; then
        if read -p "Select browsers to install (e.g., 1 3 4 or 0 for all): " -a selections </dev/tty 2>/dev/null; then
            :
        else
            print_warning "No TTY available, installing all browsers by default"
            selections=("0")
        fi
    else
        read -p "Select browsers to install (e.g., 1 3 4 or 0 for all): " -a selections
    fi
    
    if [[ "${selections[0]}" == "0" ]]; then
        # Install all browsers
        print_info "Installing all browsers..."
        for browser_info in "${browsers[@]}"; do
            IFS=':' read -r cask name <<< "$browser_info"
            install_browser_app "$cask" "$name"
        done
    else
        # Install selected browsers
        for selection in "${selections[@]}"; do
            if [[ $selection -ge 1 && $selection -le ${#browsers[@]} ]]; then
                IFS=':' read -r cask name <<< "${browsers[$((selection-1))]}"
                install_browser_app "$cask" "$name"
            else
                print_warning "Invalid selection: $selection"
            fi
        done
    fi
    
    # Install browser development tools
    install_browser_dev_tools
    
    print_status "Browser installation complete!"
}

install_browser_app() {
    local cask="$1"
    local name="$2"
    
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
}

install_browser_dev_tools() {
    print_info "Installing browser development tools..."
    
    local dev_tools=(
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
}

#=============================================================================
# DESIGN TOOLS INSTALLATION
#=============================================================================

install_design_tools() {
    print_section "Installing Design and Creative Tools"
    
    if [[ "$OS_TYPE" != "macos" ]]; then
        print_error "Design tools installation is designed for macOS only"
        return 1
    fi
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew not found. Please install core tools first."
        return 1
    fi
    
    # Design applications
    local design_apps=(
        "figma:Figma (UI/UX Design)"
    )
    
    # Development design tools (currently empty but preserved for structure)
    local dev_design_tools=(
        
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
    
    if [[ "${selections[0]}" == "0" ]]; then
        # Install essential design tools
        print_info "Installing essential design tools..."
        
        # Essential apps
        install_design_app "figma" "Figma"
        
        # All dev design tools
        for tool_info in "${dev_design_tools[@]}"; do
            IFS=':' read -r cask name <<< "$tool_info"
            install_design_app "$cask" "$name"
        done
    else
        # Install selected tools
        local total_apps=$((${#design_apps[@]} + ${#dev_design_tools[@]}))
        
        for selection in "${selections[@]}"; do
            if [[ $selection -ge 1 && $selection -le ${#design_apps[@]} ]]; then
                # Design app selection
                IFS=':' read -r cask name <<< "${design_apps[$((selection-1))]}"
                install_design_app "$cask" "$name"
            elif [[ $selection -gt ${#design_apps[@]} && $selection -le $total_apps ]]; then
                # Dev tool selection
                local index=$((selection - ${#design_apps[@]} - 1))
                IFS=':' read -r cask name <<< "${dev_design_tools[$index]}"
                install_design_app "$cask" "$name"
            else
                print_warning "Invalid selection: $selection"
            fi
        done
    fi
    
    # Install command-line design tools
    install_design_cli_tools
    
    # Install fonts
    install_design_fonts
    
    print_status "Design and creative tools installation complete!"
}

install_design_app() {
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

install_design_cli_tools() {
    print_info "Installing command-line design tools..."
    
    local cli_tools=(
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
}

install_design_fonts() {
    print_info "Installing developer-friendly fonts..."
    
    local fonts=(
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
}

#=============================================================================
# CLAUDE CODE INSTALLATION
#=============================================================================

install_claude_code() {
    print_section "Installing Claude Code and Agent Orchestration"
    
    # Configuration
    local AGENTS_REPO="https://github.com/peek-tech/claude_code_config.git"
    
    # Install Claude applications
    install_claude_applications
    
    # Setup agent orchestration
    setup_claude_agents "$AGENTS_REPO"
    
    print_status "Claude Code installation complete!"
}

install_claude_applications() {
    print_info "Installing Claude applications..."
    
    case "${OS_TYPE}" in
        macos)
            print_info "Detected macOS"
            if ! command -v brew &> /dev/null; then
                print_error "Homebrew not found. Please install core tools first."
                return 1
            fi
            
            # Install Claude desktop app (chat interface)
            print_info "Installing Claude desktop app..."
            if brew list --cask claude &>/dev/null 2>&1; then
                print_status "Claude desktop app already installed"
            else
                if brew install --cask claude 2>/dev/null; then
                    print_status "Claude desktop app installed successfully"
                else
                    print_warning "Claude desktop app not available via Homebrew cask"
                    print_info "You can download it manually from https://claude.ai"
                fi
            fi
            
            # Install Claude Code CLI
            install_claude_cli_macos
            ;;
        linux)
            print_info "Detected Linux"
            install_claude_cli_linux
            
            # Desktop app for Linux
            print_info "For Claude desktop app, please visit https://claude.ai in your browser"
            ;;
        *)
            print_error "Unsupported operating system: ${OS_TYPE}"
            return 1
            ;;
    esac
}

install_claude_cli_macos() {
    print_info "Installing Claude Code CLI..."
    if command -v claude &> /dev/null; then
        print_status "Claude Code CLI already installed: $(claude --version 2>/dev/null || echo 'version unknown')"
    else
        # Try to install via Homebrew first
        if brew install claude-code 2>/dev/null; then
            print_status "Claude Code CLI installed via Homebrew"
        else
            print_info "Claude Code CLI not available via Homebrew"
            print_info "Downloading Claude Code CLI manually..."
            
            # Create a directory for Claude Code
            local CLAUDE_DIR="$HOME/.local/bin"
            mkdir -p "$CLAUDE_DIR"
            
            # Download based on architecture
            local ARCH=$(uname -m)
            local CLAUDE_URL
            if [[ "$ARCH" == "arm64" ]]; then
                CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-macos-arm64"
            else
                CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-macos-x64"
            fi
            
            print_info "Downloading from $CLAUDE_URL..."
            if curl -fsSL "$CLAUDE_URL" -o "$CLAUDE_DIR/claude" 2>/dev/null; then
                chmod +x "$CLAUDE_DIR/claude"
                
                # Add to PATH if not already there
                if [[ ":$PATH:" != *":$CLAUDE_DIR:"* ]]; then
                    local claude_config
                    local user_shell="$(basename "$SHELL")"
                    
                    case "$user_shell" in
                        fish)
                            claude_config='fish_add_path "$HOME/.local/bin"'
                            ;;
                        csh|tcsh)
                            claude_config='setenv PATH "$HOME/.local/bin:$PATH"'
                            ;;
                        *)
                            claude_config='export PATH="$HOME/.local/bin:$PATH"'
                            ;;
                    esac
                    
                    add_to_shell_config "$claude_config" "Claude Code CLI"
                    export PATH="$HOME/.local/bin:$PATH"
                fi
                
                print_status "Claude Code CLI installed to $CLAUDE_DIR/claude"
            else
                print_warning "Failed to download Claude Code CLI"
                print_info "Please download manually from https://claude.ai/code"
            fi
        fi
    fi
}

install_claude_cli_linux() {
    print_info "Installing Claude Code CLI..."
    if command -v claude &> /dev/null; then
        print_status "Claude Code CLI already installed"
    else
        local CLAUDE_DIR="$HOME/.local/bin"
        mkdir -p "$CLAUDE_DIR"
        
        local ARCH=$(uname -m)
        local CLAUDE_URL
        if [[ "$ARCH" == "aarch64" ]]; then
            CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-linux-arm64"
        else
            CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-linux-x64"
        fi
        
        print_info "Downloading Claude Code CLI..."
        if curl -fsSL "$CLAUDE_URL" -o "$CLAUDE_DIR/claude" 2>/dev/null; then
            chmod +x "$CLAUDE_DIR/claude"
            
            # Add to PATH
            if [[ ":$PATH:" != *":$CLAUDE_DIR:"* ]]; then
                local claude_config
                local user_shell="$(basename "$SHELL")"
                
                case "$user_shell" in
                    fish)
                        claude_config='fish_add_path "$HOME/.local/bin"'
                        ;;
                    csh|tcsh)
                        claude_config='setenv PATH "$HOME/.local/bin:$PATH"'
                        ;;
                    *)
                        claude_config='export PATH="$HOME/.local/bin:$PATH"'
                        ;;
                esac
                
                add_to_shell_config "$claude_config" "Claude Code CLI"
                export PATH="$HOME/.local/bin:$PATH"
            fi
            
            print_status "Claude Code CLI installed"
        else
            print_warning "Failed to download Claude Code CLI"
            print_info "Please download manually from https://claude.ai/code"
        fi
    fi
}

setup_claude_agents() {
    local AGENTS_REPO="$1"
    
    print_info "Setting up agent orchestration system..."
    
    # Ask user for setup preference
    echo ""
    echo "Choose installation location for agents:"
    echo "1) Current project (.claude folder)"
    echo "2) Global installation (~/.claude)"
    echo "3) Skip agent installation"
    
    # Read input from /dev/tty if stdin is piped
    if [ ! -t 0 ]; then
        if read -p "Enter choice (1-3): " choice </dev/tty 2>/dev/null; then
            :
        else
            print_warning "No TTY available, skipping agent installation"
            choice="3"
        fi
    else
        read -p "Enter choice (1-3): " choice
    fi
    
    case $choice in
        1)
            # Install to current project
            if [ -d ".claude" ]; then
                print_warning ".claude directory exists. Backing up to .claude.backup"
                mv .claude .claude.backup
            fi
            
            print_info "Attempting to clone agent repository..."
            if git clone --quiet "$AGENTS_REPO" .claude 2>/dev/null; then
                print_status "Agents installed to current project"
                
                # Copy CLAUDE.md if it exists
                if [ -f ".claude/CLAUDE.md" ]; then
                    cp .claude/CLAUDE.md ./
                    print_status "CLAUDE.md copied to project root"
                fi
            else
                print_warning "Repository appears to be private. Please ensure you have access to: $AGENTS_REPO"
                print_info "You can manually clone it later with: git clone $AGENTS_REPO .claude"
            fi
            ;;
            
        2)
            # Install globally
            local GLOBAL_DIR
            if [ -d ~/.claude ]; then
                print_warning "Global ~/.claude directory exists. Creating ~/.claude-agents instead"
                GLOBAL_DIR=~/.claude-agents
            else
                GLOBAL_DIR=~/.claude
            fi
            
            print_info "Attempting to clone agent repository..."
            if git clone --quiet "$AGENTS_REPO" "$GLOBAL_DIR" 2>/dev/null; then
                print_status "Agents installed globally to $GLOBAL_DIR"
            else
                print_warning "Repository appears to be private. Please ensure you have access to: $AGENTS_REPO"
                print_info "You can manually clone it later with: git clone $AGENTS_REPO $GLOBAL_DIR"
            fi
            ;;
            
        3)
            print_info "Skipping agent installation"
            ;;
            
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
}

#=============================================================================
# AWS DEVELOPMENT TOOLS INSTALLATION
#=============================================================================

install_aws_tools() {
    print_section "Installing AWS Development Tools"
    
    local ARCH="$(uname -m)"
    
    install_aws_cli
    refresh_environment
    install_session_manager
    refresh_environment
    install_sam_cli
    refresh_environment
    install_aws_cdk
    refresh_environment
    install_additional_aws_tools
    configure_aws_cli
    
    print_status "AWS development tools installation complete!"
}

install_aws_cli() {
    if command -v aws &> /dev/null; then
        print_status "AWS CLI already installed: $(aws --version)"
    else
        print_info "Installing AWS CLI v2..."
        
        case "${OS_TYPE}" in
            macos)
                if command -v brew &> /dev/null; then
                    brew install awscli
                else
                    print_error "Homebrew not found. Please install core tools first."
                    return 1
                fi
                ;;
            linux)
                local ARCH="$(uname -m)"
                curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "awscliv2.zip"
                unzip -q awscliv2.zip
                sudo ./aws/install
                rm -rf aws awscliv2.zip
                ;;
        esac
        
        print_status "AWS CLI installed: $(aws --version)"
    fi
}

install_session_manager() {
    print_info "Installing AWS Session Manager Plugin..."
    
    case "${OS_TYPE}" in
        macos)
            if command -v brew &> /dev/null; then
                brew install --cask session-manager-plugin
            else
                print_error "Homebrew not found. Please install core tools first."
                return 1
            fi
            ;;
        linux)
            curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
            sudo dpkg -i session-manager-plugin.deb
            rm session-manager-plugin.deb
            ;;
    esac
    
    print_status "Session Manager Plugin installed"
}

install_sam_cli() {
    if command -v sam &> /dev/null; then
        print_status "AWS SAM CLI already installed: $(sam --version)"
    else
        print_info "Installing AWS SAM CLI..."
        
        case "${OS_TYPE}" in
            macos)
                if command -v brew &> /dev/null; then
                    brew install aws-sam-cli
                else
                    print_error "Homebrew not found. Please install core tools first."
                    return 1
                fi
                ;;
            linux)
                wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
                unzip -q aws-sam-cli-linux-x86_64.zip -d sam-installation
                sudo ./sam-installation/install
                rm -rf sam-installation aws-sam-cli-linux-x86_64.zip
                ;;
        esac
        
        print_status "AWS SAM CLI installed"
    fi
}

install_aws_cdk() {
    if command -v cdk &> /dev/null; then
        print_status "AWS CDK already installed: $(cdk --version)"
    else
        print_info "Installing AWS CDK..."
        
        # Check if npm is installed
        if ! command -v npm &> /dev/null; then
            print_warning "npm not found. Installing Node.js first..."
            
            case "${OS_TYPE}" in
                macos)
                    brew install node
                    ;;
                linux)
                    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                    ;;
            esac
            refresh_environment
        fi
        
        npm install -g aws-cdk
        print_status "AWS CDK installed: $(cdk --version)"
    fi
}

install_additional_aws_tools() {
    print_info "Installing additional AWS tools..."
    
    # Install aws-vault for secure credential storage
    case "${OS_TYPE}" in
        macos)
            if command -v brew &> /dev/null; then
                if brew list --cask aws-vault &>/dev/null 2>&1; then
                    print_status "aws-vault already installed"
                else
                    brew install --cask aws-vault
                    print_status "aws-vault installed"
                fi
            fi
            ;;
        linux)
            if ! command -v aws-vault &> /dev/null; then
                wget https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-amd64
                sudo mv aws-vault-linux-amd64 /usr/local/bin/aws-vault
                sudo chmod +x /usr/local/bin/aws-vault
                print_status "aws-vault installed"
            else
                print_status "aws-vault already installed"
            fi
            ;;
    esac
}

configure_aws_cli() {
    print_info "Checking AWS configuration..."
    
    if [ ! -f ~/.aws/credentials ] && [ ! -f ~/.aws/config ]; then
        print_warning "AWS CLI not configured"
        
        # Read input from /dev/tty if stdin is piped
        if [ ! -t 0 ]; then
            if read -p "Would you like to configure AWS CLI now? (y/n): " response </dev/tty 2>/dev/null; then
                :
            else
                print_warning "No TTY available, skipping AWS configuration"
                print_info "You can configure AWS CLI later with: aws configure"
                return 0
            fi
        else
            read -p "Would you like to configure AWS CLI now? (y/n): " response
        fi
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            aws configure
        else
            print_info "You can configure AWS CLI later with: aws configure"
        fi
    else
        print_status "AWS configuration found"
        
        # Setup AWS profile selector
        if [ -f ~/.aws/config ]; then
            print_info "Available AWS profiles:"
            grep '\[profile' ~/.aws/config | sed 's/\[profile /  • /g' | sed 's/\]//g'
            grep '\[default\]' ~/.aws/config > /dev/null 2>&1 && echo "  • default"
        fi
    fi
}

#=============================================================================
# CONTAINER TOOLS INSTALLATION
#=============================================================================

install_container_tools() {
    print_section "Installing Container Tools (Podman + Docker Compatibility)"
    
    check_existing_docker
    install_podman
    refresh_environment
    setup_podman_machine
    setup_docker_compatibility
    add_container_shell_aliases
    setup_auto_startup
    verify_compose
    test_container_installation
    
    print_status "Container tools installation complete!"
}

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

install_podman() {
    print_info "Installing Podman and Podman Desktop..."
    
    case "${OS_TYPE}" in
        macos)
            print_info "Detected macOS"
            if ! command -v brew &> /dev/null; then
                print_error "Homebrew not found. Please install core tools first."
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
            
        linux)
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
            print_error "Unsupported operating system: ${OS_TYPE}"
            return 1
            ;;
    esac
}

setup_podman_machine() {
    if [ "${OS_TYPE}" != "macos" ]; then
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

setup_docker_compatibility() {
    print_info "Setting up Docker compatibility..."
    
    case "${OS_TYPE}" in
        macos)
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
                        print_warning "Failed to create Docker symlink, using shell aliases instead..."
                    fi
                else
                    print_status "Docker command already available"
                fi
            fi
            ;;
            
        linux)
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

add_container_shell_aliases() {
    print_info "Adding Docker compatibility aliases to shell profiles..."
    
    local user_shell="$(basename "$SHELL")"
    local aliases_config
    
    case "$user_shell" in
        fish)
            aliases_config='alias docker="podman"
alias docker-compose="podman compose"'
            ;;
        csh|tcsh)
            aliases_config='alias docker podman
alias docker-compose "podman compose"'
            ;;
        *)
            aliases_config='alias docker="podman"
alias docker-compose="podman compose"'
            ;;
    esac
    
    add_to_shell_config "$aliases_config" "Podman Docker compatibility aliases"
}

setup_auto_startup() {
    if [ "${OS_TYPE}" != "macos" ]; then
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

verify_compose() {
    print_info "Verifying Podman Compose functionality..."
    
    if podman compose --version &>/dev/null; then
        print_status "Podman Compose is available: $(podman compose --version)"
    else
        print_warning "Podman Compose not available"
        print_info "Install docker-compose for legacy compatibility if needed"
        
        case "${OS_TYPE}" in
            macos)
                print_info "You can install docker-compose with: brew install docker-compose"
                ;;
            linux)
                print_info "You can install docker-compose with your package manager"
                ;;
        esac
    fi
}

test_container_installation() {
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

#=============================================================================
# MAIN INSTALLATION MENU AND EXECUTION
#=============================================================================

# Main installation menu
show_menu() {
    while true; do
        echo ""
        echo "Select components to install:"
        echo ""
        echo "  1) Full Installation (Recommended)"
        echo "  2) Core Development Tools (Homebrew, Git, Neovim, etc.)"
        echo "  3) Programming Languages (Python + Poetry, Node.js + Yarn, Go, Bun)"
        echo "  4) Web Browsers (Chrome, Firefox, Edge, Brave)"
        echo "  5) Design Tools (Figma, image tools, fonts)"
        echo "  6) Claude Code + Agent Orchestration"
        echo "  7) AWS Development Tools"
        echo "  8) Container Tools (Docker, Kubernetes)"
        echo "  9) Database Tools (DBeaver, MongoDB Compass, PostgreSQL, MongoDB)"
        echo " 10) Custom Selection"
        echo "  0) Exit"
        echo ""
        
        # Read input from /dev/tty if stdin is piped
        if [ ! -t 0 ]; then
            # Try to read from /dev/tty
            if read -p "Enter your choice [1-10, 0]: " choice </dev/tty 2>/dev/null; then
                # Successfully read from /dev/tty
                :
            else
                # /dev/tty not available, can't continue interactively
                print_error "Cannot read input: no TTY available"
                print_info "To run non-interactively, set NONINTERACTIVE=1"
                exit 1
            fi
        else
            read -p "Enter your choice [1-10, 0]: " choice
        fi
        
        case $choice in
            1)
                install_full
                break
                ;;
            2)
                install_core_tools
                ;;
            3)
                install_programming_languages
                ;;
            4)
                install_web_browsers
                ;;
            5)
                install_design_tools
                ;;
            6)
                install_claude_code
                ;;
            7)
                install_aws_tools
                ;;
            8)
                install_container_tools
                ;;
            9)
                install_database_tools
                ;;
            10)
                custom_installation
                ;;
            0)
                print_info "Exiting installer"
                break
                ;;
            *)
                print_error "Invalid choice, please try again"
                ;;
        esac
        
        # After each installation (except exit), ask if user wants to install more
        if [ "$choice" != "0" ] && [ "$choice" != "1" ]; then
            echo ""
            # Read input from /dev/tty if stdin is piped
            if [ ! -t 0 ]; then
                if read -p "Install another component? (y/N): " -n 1 -r </dev/tty 2>/dev/null; then
                    :
                else
                    print_error "Cannot read input: no TTY available"
                    break
                fi
            else
                read -p "Install another component? (y/N): " -n 1 -r
            fi
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                break
            fi
        fi
    done
}

# Robust installation wrapper that continues on component failures
install_with_error_handling() {
    local component_name="$1"
    local install_function="$2"
    
    print_info "Installing $component_name..."
    if $install_function; then
        print_status "$component_name installed successfully"
        refresh_environment
        return 0
    else
        print_warning "$component_name installation failed - continuing with other components"
        return 1
    fi
}

# Full installation
install_full() {
    print_section "Starting Full Installation"
    
    local failed_components=()
    
    install_with_error_handling "Core Development Tools" "install_core_tools" || failed_components+=("Core Tools")
    install_with_error_handling "Programming Languages" "install_programming_languages" || failed_components+=("Programming Languages")
    install_with_error_handling "Web Browsers" "install_web_browsers" || failed_components+=("Web Browsers")
    install_with_error_handling "Design Tools" "install_design_tools" || failed_components+=("Design Tools")
    install_with_error_handling "Claude Code" "install_claude_code" || failed_components+=("Claude Code")
    install_with_error_handling "AWS Tools" "install_aws_tools" || failed_components+=("AWS Tools")
    install_with_error_handling "Container Tools" "install_container_tools" || failed_components+=("Container Tools")
    install_with_error_handling "Database Tools" "install_database_tools" || failed_components+=("Database Tools")
    
    print_section "Installation Summary"
    if [ ${#failed_components[@]} -eq 0 ]; then
        print_status "All components installed successfully!"
    else
        print_warning "Installation completed with some failures:"
        for component in "${failed_components[@]}"; do
            print_warning "  - $component failed to install"
        done
        print_info "You can try running individual components again from the menu"
    fi
}

# Custom installation
custom_installation() {
    print_section "Custom Installation"
    
    echo "Available components:"
    echo ""
    
    local components=(
        "Core Development Tools"
        "Programming Languages"
        "Web Browsers"
        "Design Tools"
        "Claude Code + Agents"
        "AWS Tools"
        "Container Tools"
    )
    
    for i in "${!components[@]}"; do
        echo "  $((i+1))) ${components[$i]}"
    done
    
    echo ""
    echo "Enter component numbers separated by spaces (e.g., 1 3 4):"
    
    # Read input from /dev/tty if stdin is piped
    if [ ! -t 0 ]; then
        if read -a selections </dev/tty 2>/dev/null; then
            :
        else
            print_error "Cannot read input: no TTY available"
            return 1
        fi
    else
        read -a selections
    fi
    
    for sel in "${selections[@]}"; do
        case $sel in
            1)
                install_core_tools
                refresh_environment
                ;;
            2)
                install_programming_languages
                refresh_environment
                ;;
            3)
                install_web_browsers
                refresh_environment
                ;;
            4)
                install_design_tools
                refresh_environment
                ;;
            5)
                install_claude_code
                refresh_environment
                ;;
            6)
                install_aws_tools
                refresh_environment
                ;;
            7)
                install_container_tools
                refresh_environment
                ;;
            *)
                print_warning "Invalid selection: $sel"
                ;;
        esac
    done
}

# Main execution
main() {
    print_header
    
    detect_os
    
    if [ "$OS" = "unsupported" ]; then
        print_error "Unsupported operating system"
        exit 1
    fi
    
    print_info "Detected OS: $OS ($DISTRO)"
    
    check_prerequisites
    
    # Request sudo access upfront on macOS (unless running non-interactively)
    if [ -z "$CI" ] && [ -z "$AUTOMATED_INSTALL" ] && [ -z "$NONINTERACTIVE" ]; then
        request_sudo
    fi
    
    # Check if running in CI/automated environment or non-interactive mode
    if [ -n "$CI" ] || [ -n "$AUTOMATED_INSTALL" ] || [ -n "$NONINTERACTIVE" ]; then
        print_info "Running in automated mode - installing all components"
        install_full
    else
        # Try interactive mode
        if [ ! -t 0 ]; then
            # stdin is piped, check if we can use /dev/tty
            if echo -n "" </dev/tty 2>/dev/null; then
                print_info "Running interactively via /dev/tty (stdin is piped)"
                show_menu
            else
                # No TTY available at all
                print_warning "No TTY available for interactive mode"
                print_info "To run non-interactively, set NONINTERACTIVE=1 or AUTOMATED_INSTALL=1"
                print_info "Example: curl -fsSL https://peek-tech.github.io/devenv-setup/install.sh | NONINTERACTIVE=1 bash"
                exit 1
            fi
        else
            # Normal terminal mode
            show_menu
        fi
    fi
    
    print_section "Installation Complete"
    
    # Give shell-specific restart instructions
    local user_shell="$(basename "$SHELL")"
    local config_file="$(get_shell_config_file)"
    
    case "$user_shell" in
        fish)
            print_info "Please restart your terminal or run: source $config_file"
            print_info "Fish shell users: Some tools may require a full terminal restart"
            ;;
        csh|tcsh)
            print_info "Please restart your terminal or run: source $config_file" 
            print_info "C shell users: Some tools may require a full terminal restart"
            ;;
        *)
            print_info "Please restart your terminal or run: source $config_file"
            ;;
    esac
    
    print_info "For help and documentation, visit: https://peek-tech.github.io/devenv-setup"
}

# Run main function
main "$@"