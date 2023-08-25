#!/bin/sh

set -e

function vecho() {
    echo "[\033[1;32mMAC-SETUP\033[0m] ${1}"
}

vecho "#########################"
vecho "# Welcome to MAC setup! #"
vecho "#########################"
echo ""

DO_VIRTENWRAP=y
DO_SCREENPASS=y
DO_NATURALSCROLL=n
DO_AUTOHIDEDOCK=y
DO_SHOWHIDEDOCKFASTER=y
DO_FASTER_KEY=n
DO_FAST_WINDOW_RESIZING=y

function question() {
    # Print question
    echo $1
    select yn in "yes" "no"; do
        # Save answer in the given variable
        case $yn in
        "yes")
            eval "$2=y"
            break
            ;;
        "no")
            eval "$2=n"
            break
            ;;
        esac
    done
}

# Configure installation by user input
function configure() {
    vecho "Great, let me ask you some questions:"
    echo ""
    question "Do you wish to install virtualenvwrapper for python?" DO_VIRTENWRAP
    question "Require password as soon as screensaver or sleep mode starts?" DO_SCREENPASS
    question "Use natural scroll?" DO_NATURALSCROLL
    question "Automatically hide dock?" DO_AUTOHIDEDOCK
    question "Make hiding and showing dock faster?" DO_SHOWHIDEDOCKFASTER
    question "Make key repeat and initial key repeat faster?" DO_FASTER_KEY
    question "Make window resizing animations faster?" DO_FAST_WINDOW_RESIZING
}

vecho "Do you want to configure the installation, or use defaults?"
select yn in "configure" "default"; do
    case $yn in
    "configure")
        configure
        break
        ;;
    "default") break ;;
    esac
done
echo ""

vecho "Updating OSX. If this requires a restart, run the script again."
sudo softwareupdate -ia

vecho "Configuring macOS"

# Make key repeat and initial key repeat faster
if [ "$DO_FASTER_KEY" = "y" ]; then
    defaults write -g InitialKeyRepeat -int 15
    defaults write -g KeyRepeat -int 1
fi

# Require password as soon as screensaver or sleep mode starts
if [ "$DO_SCREENPASS" = "y" ]; then
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
fi

# Show filename extensions by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable "natural" scroll
if [ "$DO_NATURALSCROLL" = "y" ]; then
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
fi

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Automatically hide and show the Dock
if [ "$DO_AUTOHIDEDOCK" = "y" ]; then
    defaults write com.apple.dock autohide -bool true
fi

# Make showing the dock faster
if [ "$DO_SHOWHIDEDOCKFASTER" = "y" ]; then
    defaults write com.apple.Dock autohide-delay -float 0
    killall Dock
    defaults write com.apple.dock autohide-time-modifier -float 0.4
    killall Dock
fi

if [ "$DO_FAST_WINDOW_RESIZING" = "y" ]; then
    # Disable opening and closing window animations
    defaults write -g NSWindowResizeTime -float 0.003
fi

# Disable opening and closing window animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Privacy: don’t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Make opening visor for iTerm2 faster
defaults write com.googlecode.iterm2 HotkeyTermAnimationDuration -float 0.00001

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

echo ""
vecho "Mac setup complete"
echo ""

DO_LOGOUT=n
question "You need to logout to apply some of the changes. Do you want to logout now?" DO_LOGOUT
if [ "$DO_LOGOUT"="y" ]; then
    osascript -e 'tell application "System Events" to log out'
fi
