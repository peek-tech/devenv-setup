# Macose Themes

This directory contains theme configurations for the Macose development environment, inspired by Omarchy's theming system.

## Available Themes

### Catppuccin Variants
- **catppuccin-mocha** - Dark theme (default)
- **catppuccin-macchiato** - Dark theme with warmer tones
- **catppuccin-frappe** - Dark theme with cooler tones  
- **catppuccin-latte** - Light theme

## Themed Applications

Each theme includes configurations for:
- **Ghostty Terminal** - Color schemes and styling
- **VSCode** - Theme settings and terminal colors
- **Git Delta** - Diff highlighting themes
- **Bat** - Syntax highlighting themes
- **FZF** - Fuzzy finder color schemes
- **Neovim** - Colorscheme configurations

## Usage

Use the `macose` CLI tool to manage themes:

```bash
# List available themes
macose theme list

# Show current theme
macose theme current

# Switch to a specific theme
macose theme set catppuccin-latte

# Switch to dark theme
macose theme set catppuccin-mocha
```

## Theme Structure

Each theme directory contains:
- `colors.json` - Color palette definitions
- `ghostty.conf` - Ghostty terminal configuration
- `vscode.json` - VSCode theme settings
- `delta.conf` - Git delta configuration
- `bat.conf` - Bat theme configuration
- `fzf.conf` - FZF color configuration
- `neovim.lua` - Neovim theme configuration
- `light.mode` - Present for light themes (following Omarchy convention)

## Adding Custom Themes

To add a custom theme:
1. Create a new directory in `~/.config/macose/themes/`
2. Add the required configuration files
3. Use `macose theme set <theme-name>` to apply

## Notes

- Some applications may require extensions/plugins for full theme support
- VSCode: Install "Catppuccin for VSCode" extension for best results
- Neovim: Install catppuccin/nvim plugin
- Applications may need to be restarted to apply theme changes