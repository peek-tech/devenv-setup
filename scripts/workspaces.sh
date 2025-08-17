#!/bin/bash

# Omamacy - Workspaces Setup
# Creates workspace directories and clones repositories from CSV files

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# TTY-aware prompt helper
prompt_user() {
    local prompt="$1"
    local var_name="$2"
    local read_args="$3"  # Optional: additional read arguments like "-n 1 -r"
    
    if [ ! -t 0 ]; then
        # No TTY on stdin, try to use /dev/tty
        if [ -t 1 ]; then
            # stdout is a TTY, display prompt normally
            echo -n "$prompt"
        else
            # No TTY available, print to stderr
            echo -n "$prompt" >&2
        fi
        
        if [ -n "$read_args" ]; then
            read $read_args "$var_name" </dev/tty 2>/dev/null || return 1
        else
            read "$var_name" </dev/tty 2>/dev/null || return 1
        fi
    else
        # stdin is a TTY, use normal read with prompt
        if [ -n "$read_args" ]; then
            read -p "$prompt" $read_args "$var_name"
        else
            read -p "$prompt" "$var_name"
        fi
    fi
}

# Process a CSV file and clone repositories
process_csv_file() {
    local csv_url="$1"
    local workspaces_dir="$HOME/Workspaces"
    
    print_info "Processing CSV from: $csv_url"
    
    # Download the CSV file
    local temp_csv="/tmp/omacy_workspaces_$$.csv"
    if ! curl -fsSL "$csv_url" -o "$temp_csv" 2>/dev/null; then
        print_error "Failed to download CSV from $csv_url"
        return 1
    fi
    
    # Process the CSV file (skip header line)
    local line_num=0
    local cloned_count=0
    local failed_count=0
    
    while IFS=',' read -r directory git_repo || [ -n "$directory" ]; do
        line_num=$((line_num + 1))
        
        # Skip header line
        if [ $line_num -eq 1 ]; then
            continue
        fi
        
        # Trim whitespace
        directory=$(echo "$directory" | xargs)
        git_repo=$(echo "$git_repo" | xargs)
        
        # Skip empty lines
        if [ -z "$directory" ] || [ -z "$git_repo" ]; then
            continue
        fi
        
        # Create directory path
        local workspace_path="$workspaces_dir/$directory"
        
        # Extract repo name from git URL
        local repo_name=""
        if [[ "$git_repo" =~ /([^/]+)\.git$ ]]; then
            repo_name="${BASH_REMATCH[1]}"
        elif [[ "$git_repo" =~ /([^/]+)$ ]]; then
            repo_name="${BASH_REMATCH[1]}"
        else
            print_warning "Could not extract repo name from: $git_repo"
            continue
        fi
        
        # Create workspace directory if it doesn't exist
        if [ ! -d "$workspace_path" ]; then
            mkdir -p "$workspace_path"
            print_status "Created workspace directory: $workspace_path"
        fi
        
        # Clone the repository
        local repo_path="$workspace_path/$repo_name"
        if [ -d "$repo_path" ]; then
            print_info "Repository already exists: $repo_path"
        else
            print_info "Cloning $repo_name into $workspace_path..."
            if git clone "$git_repo" "$repo_path" 2>/dev/null; then
                print_status "Cloned: $repo_name → $repo_path"
                cloned_count=$((cloned_count + 1))
            else
                print_error "Failed to clone: $git_repo"
                failed_count=$((failed_count + 1))
            fi
        fi
    done < "$temp_csv"
    
    # Clean up temp file
    rm -f "$temp_csv"
    
    print_info "Processed CSV: $cloned_count repos cloned, $failed_count failed"
    return 0
}

# Setup workspaces
setup_workspaces() {
    print_info "Setting up development workspaces..."
    
    # Create base Workspaces directory
    local workspaces_dir="$HOME/Workspaces"
    if [ ! -d "$workspaces_dir" ]; then
        mkdir -p "$workspaces_dir"
        print_status "Created base Workspaces directory: $workspaces_dir"
    else
        print_status "Workspaces directory already exists: $workspaces_dir"
    fi
    
    # Ask user for CSV URLs
    print_info "You can provide CSV files with workspace configurations."
    print_info "CSV format: directory, git repo (with header line)"
    print_info "Example: Work, git@github.com/peek-tech/omacy"
    echo ""
    
    local csv_count=0
    while true; do
        local csv_url=""
        if prompt_user "Enter CSV URL (or press Enter to skip): " csv_url; then
            if [ -z "$csv_url" ]; then
                if [ $csv_count -eq 0 ]; then
                    print_info "No CSV URLs provided, continuing without repository setup"
                else
                    print_info "Finished processing $csv_count CSV file(s)"
                fi
                break
            fi
            
            # Process the CSV file
            if process_csv_file "$csv_url"; then
                csv_count=$((csv_count + 1))
            fi
            
            echo ""
        else
            print_warning "No TTY available, skipping workspace setup"
            break
        fi
    done
    
    # Create some default workspace directories
    local default_dirs=(
        "$workspaces_dir/Personal"
        "$workspaces_dir/Work"
        "$workspaces_dir/Learning"
        "$workspaces_dir/Sandbox"
    )
    
    print_info "Creating default workspace directories..."
    for dir in "${default_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_status "Created: $dir"
        else
            print_status "Already exists: $dir"
        fi
    done
}

# Main execution
main() {
    setup_workspaces
    print_status "Workspaces setup complete!"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi