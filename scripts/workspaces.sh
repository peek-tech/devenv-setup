#!/bin/bash

# Macose - Workspaces Setup
# Creates workspace directories and clones repositories from JSON files

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

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

# Validate JSON file format
validate_json_file() {
    local temp_json="$1"
    
    # Check if file exists and is not empty
    if [ ! -s "$temp_json" ]; then
        return 1
    fi
    
    # Validate JSON structure using jq
    if ! jq empty "$temp_json" 2>/dev/null; then
        return 1
    fi
    
    # Check if it's an object with at least one key
    local type=$(jq 'type' "$temp_json" 2>/dev/null)
    if [ "$type" != '"object"' ]; then
        return 1
    fi
    
    # Check if object has at least one folder with repos
    local has_repos=$(jq 'to_entries | map(.value | type == "array" and length > 0) | any' "$temp_json" 2>/dev/null)
    if [ "$has_repos" != "true" ]; then
        return 1
    fi
    
    return 0
}

# Process a JSON file and clone repositories
process_json_file() {
    local json_url="$1"
    local workspaces_dir="$HOME/Workspaces"
    
    print_info "Processing JSON from: $json_url"
    
    # Download the JSON file
    local temp_json="/tmp/macose_workspaces_$$.json"
    if ! curl -fsSL "$json_url" -o "$temp_json" 2>/dev/null; then
        print_error "Failed to download JSON from $json_url"
        return 1
    fi
    
    # Validate JSON format
    if ! validate_json_file "$temp_json"; then
        print_error "Invalid JSON file format. File must be an object with folder names as keys and arrays of git repos as values."
        rm -f "$temp_json"
        return 1
    fi
    
    # Process the JSON file
    local cloned_count=0
    local failed_count=0
    
    # Get all folder names (keys) from the JSON object
    local folders=$(jq -r 'keys[]' "$temp_json")
    
    # Process each folder
    while IFS= read -r folder; do
        # Skip empty folder names
        if [ -z "$folder" ]; then
            continue
        fi
        
        # Create directory path
        local workspace_path="$workspaces_dir/$folder"
        
        # Create workspace directory if it doesn't exist (non-fatal)
        if [ ! -d "$workspace_path" ]; then
            if mkdir -p "$workspace_path" 2>/dev/null; then
                print_status "Created workspace directory: $workspace_path"
            else
                print_warning "Failed to create directory: $workspace_path (continuing)"
                continue
            fi
        fi
        
        # Get the array of repos for this folder
        local repo_count=$(jq -r --arg folder "$folder" '.[$folder] | length' "$temp_json")
        
        # Process each repository in the folder
        for i in $(seq 0 $((repo_count - 1))); do
            local git_repo=$(jq -r --arg folder "$folder" --arg i "$i" '.[$folder][$i | tonumber]' "$temp_json")
            
            # Skip if repo is null or empty
            if [ "$git_repo" = "null" ] || [ -z "$git_repo" ]; then
                continue
            fi
            
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
            
            # Clone the repository (non-fatal)
            local repo_path="$workspace_path/$repo_name"
            if [ -d "$repo_path" ]; then
                print_info "Repository already exists: $repo_path"
            else
                print_info "Cloning $repo_name into $workspace_path..."
                if git clone "$git_repo" "$repo_path" 2>/dev/null; then
                    print_status "Cloned: $repo_name → $repo_path"
                    cloned_count=$((cloned_count + 1))
                else
                    print_warning "Failed to clone: $git_repo (continuing)"
                    failed_count=$((failed_count + 1))
                fi
            fi
        done
    done <<< "$folders"
    
    # Clean up temp file
    rm -f "$temp_json"
    
    print_info "Processed JSON: $cloned_count repos cloned, $failed_count failed"
    return 0
}

# Setup workspaces
setup_workspaces() {
    print_info "Setting up development workspaces..."
    
    # Create base workspaces directory
    local workspaces_dir="$HOME/workspaces"
    if [ ! -d "$workspaces_dir" ]; then
        mkdir -p "$workspaces_dir"
        print_status "Created base Workspaces directory: $workspaces_dir"
    else
        print_status "Workspaces directory already exists: $workspaces_dir"
    fi
    
    # Ask user for JSON URLs
    print_info "You can provide JSON files with workspace configurations."
    print_info "JSON format: Object with folder names as keys and arrays of git repos as values"
    print_info 'Example: {"Work": ["git@github.com:company/project1.git", "git@github.com:company/project2.git"]}'
    printf "\n" >&2
    
    local json_count=0
    while true; do
        local json_url=""
        if prompt_user "Enter JSON URL (or press Enter to skip): " json_url; then
            # Check if URL is empty - if so, break the loop
            if [ -z "$json_url" ]; then
                break
            fi
            
            # Process the JSON file
            if process_json_file "$json_url"; then
                json_count=$((json_count + 1))
                print_status "Successfully processed JSON file $json_url"
            else
                print_warning "Failed to process JSON file $json_url, but continuing..."
            fi
            
            printf "\n" >&2
        else
            print_warning "No TTY available, skipping workspace setup"
            break
        fi
    done
    
    # Summary after loop completion
    if [ $json_count -eq 0 ]; then
        print_info "No JSON files processed, continuing without repository setup"
    else
        print_info "Finished processing $json_count JSON file(s)"
    fi
    
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