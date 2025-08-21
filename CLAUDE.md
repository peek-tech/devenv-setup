# Claude Code Context - Makase Development Environment

## Project Overview
Makase is a macOS developer environment setup tool (previously called "Omamacy", originally "Omacy"). Like omakase dining where you trust the chef's expertise, Makase provides **automated** installation and configuration of development tools with centralized theme and font management.

### Installation Requirements
The installation process is **automated** but requires user attention for:
- **Authentication prompts**: Multiple sudo password requests throughout the process
- **Git configuration**: Setting up name, email, and SSH keys for GitHub
- **External installers**: Xcode Command Line Tools popup (appears outside terminal)
- **Application-specific setup**: VSCode configuration, Neovim setup, Claude Code authentication

## Current Architecture

### Installation System
The installer uses a **manifest-driven approach** with automated script execution:

#### Manifest Configuration (`scripts/manifest.json`):
- **Script definitions**: Each script has name, description, group, and dependencies
- **Grouped organization**: Scripts organized by categories (tools, languages, apps, etc.)
- **Execution order**: Scripts run in the order defined in the manifest

#### Automated Flow:
1. **Sequential Execution**: All scripts run automatically in manifest order
2. **No User Selection**: No prompts for which components to install
3. **Individual Configuration**: Each script may have its own internal configuration prompts:
   - Git name/email and SSH key setup
   - VSCode extension and settings configuration
   - Neovim configuration selection
   - Claude Code repository setup
4. **Error Handling**: Failed scripts log errors but don't stop the overall installation

### Theme Management System
The project implements a **delegation pattern** for theme management that preserves user customizations while maintaining centralized control.

#### Key Components:
- **CLI Tool**: `/Users/james/.claude/devenv-setup/bin/makase` - Main interface for theme/font management
- **Theme Scripts**: `/Users/james/.claude/devenv-setup/scripts/themes.sh` - Installation and setup
- **Theme Configs**: `/Users/james/.claude/devenv-setup/themes/` - Theme configuration files
- **User Config**: `~/.config/makase/` - User-specific configurations

#### Delegation Pattern:
Individual app scripts respond to environment variables:
- `MAKASE_APPLY_THEME_ONLY="theme-name"` - Apply only theme settings
- `MAKASE_APPLY_FONT_ONLY="font-name"` - Apply only font settings

#### Supported Applications:
- **Ghostty** (terminal): `/Users/james/.claude/devenv-setup/scripts/apps/ghostty.sh`
- **VSCode**: `/Users/james/.claude/devenv-setup/scripts/apps/vscode-config.sh`
- **tmux**: `/Users/james/.claude/devenv-setup/scripts/apps/tmux.sh`
- **Bat** (syntax highlighting): `/Users/james/.claude/devenv-setup/scripts/tools/bat.sh`
- **Starship** (prompt): `/Users/james/.claude/devenv-setup/scripts/tools/starship.sh`
- **FZF** (fuzzy finder): `/Users/james/.claude/devenv-setup/scripts/tools/fzf.sh`
- **Delta** (git diff): `/Users/james/.claude/devenv-setup/scripts/tools/delta.sh`

### Font Management System
Centralized font management across applications that support font configuration.

#### Supported Applications:
- **Ghostty** - Terminal font configuration
- **VSCode** - Editor font configuration

#### Commands:
- `makase font list` - Opens macOS Font Book for browsing
- `makase font set "Font Name"` - Applies font to supported applications

### Technical Implementation Details

#### Intelligent Config Parsing
Scripts use sophisticated parsing to update only theme/font-specific settings:

**Ghostty Example** (`/Users/james/.claude/devenv-setup/scripts/apps/ghostty.sh`):
```bash
# Theme settings that can be safely updated
theme_settings=(
    "background" "foreground" "cursor-color" "selection-background"
    "selection-foreground" "palette"
)

apply_ghostty_theme() {
    # Remove existing theme settings while preserving user customizations
    for setting in "${theme_settings[@]}"; do
        if [ "$setting" = "palette" ]; then
            sed -i '' '/^palette = /d' "$temp_file"
        else
            sed -i '' "/^$setting = /d" "$temp_file"
        fi
    done
    # Append new theme settings
    cat "$theme_file" >> "$temp_file"
}
```

**VSCode Example** (`/Users/james/.claude/devenv-setup/scripts/apps/vscode-config.sh`):
```bash
apply_vscode_theme() {
    # Use jq for precise JSON manipulation
    local color_theme=$(jq -r '.["workbench.colorTheme"] // empty' "$theme_file")
    if [ -n "$color_theme" ] && [ "$color_theme" != "null" ]; then
        jq --arg theme "$color_theme" '.["workbench.colorTheme"] = $theme' "$temp_settings" > "$temp_theme"
    fi
}
```

**FZF Example** (`/Users/james/.claude/devenv-setup/scripts/tools/fzf.sh`):
```bash
apply_fzf_theme() {
    # Use awk to remove theme blocks while preserving other configurations
    awk '
        /^# Omamacy FZF Theme/ { skip=1; next }
        skip && /^export FZF_DEFAULT_OPTS/ { 
            while (getline > 0 && /\\$/) { }
            skip=0; next
        }
        !skip { print }
    ' "$shell_config" > "$temp_config"
}
```

#### Git Integration
Delta themes use git's include.path feature:
```bash
git config --global include.path "$theme_file"
```

### Theme Files Structure
```
themes/
├── catppuccin-mocha/
│   ├── ghostty.conf      # Terminal colors
│   ├── vscode.json       # Editor theme settings
│   ├── tmux.conf         # Terminal multiplexer theme
│   ├── starship.toml     # Prompt theme with creative symbols
│   ├── bat.conf          # Syntax highlighting theme
│   ├── fzf.conf          # Fuzzy finder colors
│   └── delta.conf        # Git diff theme
```

### CLI Commands

#### Theme Management:
- `makase theme list` - Show available themes
- `makase theme current` - Show current theme
- `makase theme set <theme>` - Switch to specified theme

#### Font Management:
- `makase font list` - Open Font Book for browsing
- `makase font set "<font>"` - Set font for supported applications

#### Examples:
```bash
makase theme set catppuccin-latte
makase font set "JetBrains Mono Nerd Font"
makase font set "SF Mono"
```

### Recent Architectural Decisions

#### Problem Solved:
The original architecture moved theme configurations into individual install scripts, breaking centralized theme control. Users couldn't change themes without losing customizations.

#### Solution Implemented:
1. **Delegation Pattern**: Individual scripts handle their own configs but respond to env vars for theme-only updates
2. **Intelligent Parsing**: Only theme/font-specific settings are updated, preserving user customizations
3. **Centralized Control**: `makase` CLI maintains control over theme/font switching
4. **Font Management**: Similar delegation pattern for font management across applications

### Key Files Created/Modified:

#### New Theme Files:
- `/Users/james/.claude/devenv-setup/themes/catppuccin-mocha/starship.toml` - Creative prompt with symbols
- `/Users/james/.claude/devenv-setup/themes/catppuccin-mocha/tmux.conf` - Developer-friendly tmux config

#### Enhanced Scripts:
All app scripts now support `MAKASE_APPLY_THEME_ONLY` and `MAKASE_APPLY_FONT_ONLY` environment variables for delegation-based updates.

### Development Commands

#### Testing:
User indicated they will test the system. No automated tests available.

#### Linting/Type Checking:
No specific lint or typecheck commands identified. When working on this project, ask user for appropriate commands to run.

### Future Considerations

1. **Theme Switching**: Preserves user customizations while updating only theme-specific settings
2. **Font Management**: Centralized font control across applications
3. **Extensibility**: Easy to add new applications to the theming system
4. **User Experience**: Simple CLI interface for common operations

### Current Status
All requested features have been implemented:
- ✅ Delegated theme management system
- ✅ Font management system with Font Book integration
- ✅ Intelligent config parsing to preserve user customizations
- ✅ CLI interface for theme and font operations
- ✅ Missing theme files created (starship.toml, tmux.conf)

The system is ready for user testing. The architecture successfully balances centralized control with preservation of user customizations.