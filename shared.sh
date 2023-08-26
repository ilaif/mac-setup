#!/bin/sh

set -e

function install_brew() {
    if test ! $(which brew); then
        vecho "Installing homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        vecho "Add brew to your shell based on the above instructions, and run the script again"
        exit 1
    fi
}

function install_or_upgrade() {
    install_brew

    if brew ls --versions "$1" >/dev/null; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade "$1"
    else
        HOMEBREW_NO_AUTO_UPDATE=1 brew install "$1"
    fi
}

function install_or_upgrade_cask() {
    install_brew

    if brew ls --cask --versions "$1" >/dev/null; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade --cask "$1"
    else
        HOMEBREW_NO_AUTO_UPDATE=1 brew install --cask "$1"
    fi
}
