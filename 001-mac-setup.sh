#!/bin/bash

set -e

function vecho() {
  printf "[\033[1;32mMAC-SETUP\033[0m] %s\n" "$1"
}

vecho "#########################"
vecho "# Welcome to MAC setup! #"
vecho "#########################"
echo ""

DO_SCREENPASS=y
DO_NATURALSCROLL=n
DO_AUTOHIDEDOCK=y
DO_SHOWHIDEDOCKFASTER=y
DO_FASTER_KEY=n
DO_FAST_WINDOW_RESIZING=y

function question() {
  echo "$1"
  select yn in "yes" "no"; do
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

function configure() {
  vecho "Great, let me ask you some questions:"
  echo ""
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

if [ "$DO_FASTER_KEY" = "y" ]; then
  vecho "Faster key repeat"
  defaults write -g InitialKeyRepeat -int 15
  defaults write -g KeyRepeat -int 1
fi

if [ "$DO_SCREENPASS" = "y" ]; then
  vecho "Require password as soon as screensaver or sleep mode starts"
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
fi

vecho "Show filename extensions by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

vecho "Enable tap-to-click"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

if [ "$DO_NATURALSCROLL" = "y" ]; then
  vecho "Disable natural scroll"
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
fi

vecho "Disable smart quotes"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

vecho "Disable smart dashes"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

vecho "Enable full keyboard access for all controls"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

if [ "$DO_AUTOHIDEDOCK" = "y" ]; then
  vecho "Automatically hide and show the Dock"
  defaults write com.apple.dock autohide -bool true
fi

if [ "$DO_SHOWHIDEDOCKFASTER" = "y" ]; then
  vecho "Make showing the dock faster"
  defaults write com.apple.Dock autohide-delay -float 0
  killall Dock
  defaults write com.apple.dock autohide-time-modifier -float 0.4
  killall Dock
fi

if [ "$DO_FAST_WINDOW_RESIZING" = "y" ]; then
  vecho "Make window resizing animations faster"
  defaults write -g NSWindowResizeTime -float 0.003
fi

vecho "Disable opening and closing window animations"
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

vecho "Only use UTF-8 in Terminal.app"
defaults write com.apple.terminal StringEncodings -array 4

echo ""
vecho "Mac setup complete"
echo ""

DO_LOGOUT=n
question "You need to logout to apply some of the changes. Do you want to logout now?" DO_LOGOUT
if [ "$DO_LOGOUT" = "y" ]; then
  osascript -e 'tell application "System Events" to log out'
fi
