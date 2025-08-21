#!/bin/bash

# Macose - macOS System Defaults
# Configure macOS with reasonable developer-friendly defaults

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Load Homebrew environment for this script
load_homebrew_env

# Main installation
main() {
    run_individual_script "macos-defaults.sh" "macOS System Defaults"
    
    print_info "Configuring macOS system defaults..."
    print_info "This will modify system preferences and may require admin privileges."
    
    # Confirm with user
    printf "\n" >&2
    local apply_defaults
    tty_prompt "Apply macOS system defaults? (Y/n)" "y" apply_defaults
    if [[ ! $apply_defaults =~ ^[Yy]$ ]]; then
        print_info "Skipping macOS defaults configuration."
        script_success "macos-defaults"
        return 0
    fi
    
    print_header "Dark Mode & Appearance"
    
    # Set system to dark mode
    print_info "Setting system appearance to dark mode..."
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
    
    # Dark menu bar and dock (redundant with dark mode but explicit)
    defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool false
    
    print_header "Finder Configuration"
    
    # Show all filename extensions
    print_info "Configuring Finder to show all file extensions..."
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    
    # Show full POSIX path in Finder title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    
    # Allow text selection in Quick Look
    defaults write com.apple.finder QLEnableTextSelection -bool true
    
    # Default to list view
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    
    # Search current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    
    # Show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Disable warning before changing file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    
    # Show the ~/Library folder
    chflags nohidden ~/Library
    
    # Empty Trash securely by default
    defaults write com.apple.finder EmptyTrashSecurely -bool true
    
    print_header "Dock Configuration"
    
    # Auto-hide dock
    print_info "Configuring Dock behavior..."
    defaults write com.apple.dock autohide -bool true
    
    # Show hidden app icons as translucent
    defaults write com.apple.dock showhidden -bool true
    
    # Minimize windows into app icon
    defaults write com.apple.dock minimize-to-application -bool true
    
    # Set icon size
    defaults write com.apple.dock tilesize -int 36
    
    # Faster dock auto-hide animation
    defaults write com.apple.dock autohide-delay -float 0.1
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    
    print_header "Keyboard & Input"
    
    # Enable full keyboard access for all controls
    print_info "Configuring keyboard and input settings..."
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    
    # Set fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    print_header "Screenshots & Media"
    
    # Save screenshots to Desktop
    print_info "Configuring screenshot settings..."
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"
    
    # Screenshot format: PNG
    defaults write com.apple.screencapture type -string "png"
    
    # Disable screenshot thumbnail preview
    defaults write com.apple.screencapture show-thumbnail -bool false
    
    # Disable startup sound
    sudo nvram StartupMute=%01
    
    print_header "System Behavior"
    
    # Expand print dialog by default
    print_info "Configuring system dialog behavior..."
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    
    # Expand save dialog by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    
    # Software Update: check daily
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
    
    # Disable dashboard
    defaults write com.apple.dashboard mcx-disabled -bool true
    
    # Automatically quit printer app once jobs complete
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
    
    # Disable automatic app termination when idle
    defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true
    
    # Disable window animations and Get Info animations
    defaults write com.apple.finder DisableAllAnimations -bool true
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    
    print_header "Safari Developer Settings"
    
    # Enable developer menu
    print_info "Enabling Safari developer features..."
    # Safari is sandboxed - write to the actual plist file instead of using defaults
    if [ -f ~/Library/Preferences/com.apple.Safari.plist ]; then
        # Use PlistBuddy for Safari preferences (works with sandboxed apps)
        /usr/libexec/PlistBuddy -c "Set :IncludeDevelopMenu true" ~/Library/Preferences/com.apple.Safari.plist 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add :IncludeDevelopMenu bool true" ~/Library/Preferences/com.apple.Safari.plist 2>/dev/null
        
        /usr/libexec/PlistBuddy -c "Set :WebKitDeveloperExtrasEnabledPreferenceKey true" ~/Library/Preferences/com.apple.Safari.plist 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add :WebKitDeveloperExtrasEnabledPreferenceKey bool true" ~/Library/Preferences/com.apple.Safari.plist 2>/dev/null
        
        /usr/libexec/PlistBuddy -c "Set :\"com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled\" true" ~/Library/Preferences/com.apple.Safari.plist 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add :\"com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled\" bool true" ~/Library/Preferences/com.apple.Safari.plist 2>/dev/null
    else
        print_warning "Safari preferences not found - Safari may need to be launched once first"
    fi
    # This one can still use defaults as it's a global domain
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
    
    print_header "Energy & Performance"
    
    # Show battery percentage
    print_info "Configuring energy and performance settings..."
    defaults write com.apple.menuextra.battery ShowPercent -string "YES"
    
    # Prevent system sleep when on power adapter (useful for development)
    sudo pmset -c sleep 0
    
    # Set display sleep to 30 minutes when on power
    sudo pmset -c displaysleep 30
    
    print_header "Security & Privacy"
    
    # Require password immediately after sleep or screen saver
    print_info "Configuring security settings..."
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    
    # Enable firewall
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    
    # Enable stealth mode
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
    
    print_header "Developer Enhancements"
    
    # Show build duration in Xcode
    print_info "Configuring developer-specific settings..."
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool true
    
    # Enable debug menu in various apps
    defaults write com.apple.appstore ShowDebugMenu -bool true
    defaults write com.apple.appstore WebKitDeveloperExtras -bool true
    
    # Disable smart quotes and dashes (useful for coding)
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    
    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    
    print_header "Applying Changes"
    
    print_info "Restarting affected applications..."
    
    # Restart necessary apps
    killall Finder 2>/dev/null || true
    killall Dock 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true
    killall cfprefsd 2>/dev/null || true
    
    print_status "macOS system defaults configured successfully!"
    print_info "Some changes may require a logout/login or restart to take full effect."
    print_info "Dark mode and most settings should be active immediately."
    
    script_success "macos-defaults"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi