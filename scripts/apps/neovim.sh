#!/bin/bash

# Omamacy - Neovim Installation and Configuration
# Modern Vim-based editor with optional configuration setup

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Configuration functions
print_config_header() {
    printf "${BLUE}" >&2
    printf "╔══════════════════════════════════════════════════════════════════════════════╗\n" >&2
    printf "║                           🚀 Omamacy Neovim Setup                           ║\n" >&2
    printf "║                     Configure Neovim for Development                        ║\n" >&2
    printf "╚══════════════════════════════════════════════════════════════════════════════╝\n" >&2
    printf "${NC}" >&2
}

# Check if nvim config already exists
check_existing_config() {
    if [ -d "$HOME/.config/nvim" ] && [ -f "$HOME/.config/nvim/init.lua" ]; then
        print_warning "Neovim configuration already exists at ~/.config/nvim"
        printf "\n" >&2
        local replace_config
        tty_prompt "Do you want to backup and replace it? (y/N)" "N" replace_config
        if [[ ! $replace_config =~ ^[Yy]$ ]]; then
            print_info "Keeping existing configuration. Exiting."
            return 1
        fi
        
        # Backup existing config
        local backup_dir="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backing up existing config to $backup_dir"
        mv "$HOME/.config/nvim" "$backup_dir"
        print_status "Backup created"
    fi
    return 0
}

# Show configuration options
show_config_options() {
    printf "\n" >&2
    print_info "Choose a Neovim configuration:"
    printf "\n" >&2
    printf "  1) LazyVim - Modern Neovim config with sensible defaults\n" >&2
    printf "  2) AstroNvim - Community-driven config with great aesthetics\n" >&2
    printf "  3) NvChad - Fast and minimal config with beautiful UI\n" >&2
    printf "  4) LunarVim - IDE-like experience with extensive features\n" >&2
    printf "  5) Custom Config - Follow the medium.com guide for manual setup\n" >&2
    printf "  6) Exit - Keep current configuration\n" >&2
    printf "\n" >&2
    printf "  Or provide a git URL for a custom distribution\n" >&2
    printf "    (Repository must contain a 'neovim/' directory with your config)\n" >&2
    printf "\n" >&2
}

# Install LazyVim
install_lazyvim() {
    print_info "Installing LazyVim..."
    
    # Clone LazyVim starter
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    
    # Remove .git folder to make it your own
    rm -rf ~/.config/nvim/.git
    
    print_status "LazyVim installed successfully!"
    print_info "Run 'nvim' to complete the setup. LazyVim will install plugins automatically."
}

# Install AstroNvim
install_astronvim() {
    print_info "Installing AstroNvim..."
    
    # Clone AstroNvim
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    
    # Remove .git folder
    rm -rf ~/.config/nvim/.git
    
    print_status "AstroNvim installed successfully!"
    print_info "Run 'nvim' to complete the setup. AstroNvim will install plugins automatically."
}

# Install NvChad
install_nvchad() {
    print_info "Installing NvChad..."
    
    # Clone NvChad
    git clone https://github.com/NvChad/starter ~/.config/nvim
    
    # Remove .git folder
    rm -rf ~/.config/nvim/.git
    
    print_status "NvChad installed successfully!"
    print_info "Run 'nvim' to complete the setup. NvChad will install plugins automatically."
}

# Install LunarVim
install_lunarvim() {
    print_info "Installing LunarVim..."
    
    # Install LunarVim using their installer
    LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)
    
    print_status "LunarVim installed successfully!"
    print_info "Use 'lvim' command to start LunarVim, or 'nvim' for regular Neovim."
}

# Custom configuration following the medium guide
install_custom_config() {
    print_info "Setting up custom Neovim configuration..."
    print_info "Following guide: https://medium.com/@edominguez.se/so-i-switched-to-neovim-in-2025-163b85aa0935"
    
    # Create basic directory structure
    mkdir -p ~/.config/nvim/lua/config
    
    # Create init.lua
    cat > ~/.config/nvim/init.lua << 'EOF'
-- Neovim Configuration (Based on 2025 Setup Guide)
-- https://medium.com/@edominguez.se/so-i-switched-to-neovim-in-2025-163b85aa0935

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load configuration modules
require("config.options")
require("config.keymaps")
require("config.lazy")
EOF

    # Create options.lua
    cat > ~/.config/nvim/lua/config/options.lua << 'EOF'
-- Options configuration
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.wrap = false
opt.cursorline = true

-- Behavior
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.mouse = "a"

-- Split behavior
opt.splitbelow = true
opt.splitright = true
EOF

    # Create keymaps.lua
    cat > ~/.config/nvim/lua/config/keymaps.lua << 'EOF'
-- Keymaps configuration
local keymap = vim.keymap.set

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Buffer navigation
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })

-- Clear search highlights
keymap("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- File explorer
keymap("n", "<leader>e", vim.cmd.Ex, { desc = "Open file explorer" })

-- Save and quit
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- Move lines up/down
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
EOF

    # Create lazy.lua (plugin manager setup)
    cat > ~/.config/nvim/lua/config/lazy.lua << 'EOF'
-- Lazy.nvim plugin manager setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
  
  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    end,
  },
  
  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Find buffers" })
    end,
  },
  
  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "javascript", "python", "rust", "go" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "tsserver", "pyright", "rust_analyzer" },
      })
      
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
      lspconfig.tsserver.setup({})
      lspconfig.pyright.setup({})
      lspconfig.rust_analyzer.setup({})
    end,
  },
  
  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
  
})
EOF
    
    print_status "Custom Neovim configuration created!"
    print_info "Run 'nvim' to start. Lazy.nvim will install plugins automatically."
    print_info "Guide reference: https://medium.com/@edominguez.se/so-i-switched-to-neovim-in-2025-163b85aa0935"
}

# Install from git URL
install_from_git_url() {
    local git_url="$1"
    print_info "Installing Neovim configuration from: $git_url"
    
    # Create a temporary directory for cloning
    local temp_dir="/tmp/nvim-config-$$"
    
    # Clone the configuration repository
    if git clone "$git_url" "$temp_dir"; then
        # Check if the repo has a neovim directory
        if [ -d "$temp_dir/neovim" ]; then
            # Copy the neovim directory contents to ~/.config/nvim
            mkdir -p ~/.config/nvim
            cp -r "$temp_dir/neovim/"* ~/.config/nvim/
            
            print_status "Custom Neovim configuration installed successfully!"
            print_info "Configuration copied from $git_url/neovim/ to ~/.config/nvim/"
            print_info "Run 'nvim' to complete the setup."
        else
            print_error "Repository does not contain a 'neovim' directory"
            print_info "Expected structure: your-repo/neovim/[config files]"
            print_info "Falling back to NvChad as default..."
            install_nvchad
        fi
        
        # Clean up temporary directory
        rm -rf "$temp_dir"
    else
        print_error "Failed to clone configuration from git URL"
        print_info "Falling back to NvChad as default..."
        install_nvchad
    fi
}

# Add tmux navigation plugin to existing Neovim configuration
add_tmux_navigation_plugin() {
    local nvim_config_dir="$HOME/.config/nvim"
    local plugins_dir="$nvim_config_dir/lua/plugins"
    
    # Check if Neovim config exists
    if [ ! -d "$nvim_config_dir" ]; then
        print_info "No Neovim configuration found, skipping tmux navigation setup"
        return 0
    fi
    
    print_info "Adding tmux navigation plugin to existing Neovim configuration..."
    
    # Create plugins directory if it doesn't exist
    mkdir -p "$plugins_dir"
    
    # Create tmux navigation plugin file
    cat > "$plugins_dir/tmux-navigation.lua" << 'EOF'
-- Tmux navigation integration
-- Allows seamless navigation between Neovim splits and tmux panes
return {
  'alexghergh/nvim-tmux-navigation',
  config = function()
    local nvim_tmux_nav = require('nvim-tmux-navigation')

    nvim_tmux_nav.setup {
      disable_when_zoomed = true -- defaults to false
    }

    vim.keymap.set('n', "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
    vim.keymap.set('n', "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
    vim.keymap.set('n', "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
    vim.keymap.set('n', "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
    vim.keymap.set('n', "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
    vim.keymap.set('n', "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
  end
}
EOF
    
    print_status "Tmux navigation plugin added to ~/.config/nvim/lua/plugins/tmux-navigation.lua"
    print_info "Use Ctrl+h/j/k/l to navigate between Neovim splits and tmux panes"
    print_info "Restart Neovim to load the new plugin"
}

# Prompt user for configuration
prompt_user_for_config() {
    printf "\n" >&2
    print_info "Neovim is installed. Would you like to configure it now?"
    printf "\n" >&2
    local configure_choice
    tty_prompt "Configure Neovim? (y/N)" "N" configure_choice
    
    if [[ ! $configure_choice =~ ^[Yy]$ ]]; then
        print_info "Skipping Neovim configuration. You can run this script later to configure."
        return 1
    fi
    return 0
}

# Configuration setup
setup_neovim_config() {
    # Ask user if they want to configure
    if ! prompt_user_for_config; then
        return 0
    fi
    
    print_config_header
    
    # Check for existing config
    if ! check_existing_config; then
        return 0
    fi
    
    # Show options and get user choice
    show_config_options
    
    local choice
    tty_prompt "Enter your choice (1-6) or a git URL" "" choice
    
    # Check if input is a git URL
    if [[ "$choice" =~ ^(https?://|git@) ]]; then
        install_from_git_url "$choice"
    else
        case $choice in
            1)
                install_lazyvim
                ;;
            2)
                install_astronvim
                ;;
            3)
                install_nvchad
                ;;
            4)
                install_lunarvim
                ;;
            5)
                install_custom_config
                ;;
            6)
                print_info "Exiting without changes."
                return 0
                ;;
            *)
                print_warning "Invalid choice. Installing NvChad as default..."
                install_nvchad
                ;;
        esac
    fi
    
    printf "\n" >&2
    print_status "Neovim configuration complete!"
    
    # Add tmux navigation plugin to any configuration
    add_tmux_navigation_plugin
    
    print_info "Start Neovim with: nvim"
    
    if [ "$choice" = "4" ]; then
        print_info "For LunarVim, use: lvim"
    fi
}

# Main installation
main() {
    run_individual_script "neovim.sh" "Neovim Installation and Configuration"
    
    # Install Neovim
    if ! install_brew_package "neovim" false "Modern Vim-based editor"; then
        script_failure "neovim" "Failed to install via Homebrew"
    fi
    
    print_status "Neovim installed successfully"
    
    # Offer configuration setup
    setup_neovim_config
    
    script_success "Neovim"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi