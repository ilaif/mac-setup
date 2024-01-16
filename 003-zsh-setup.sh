#!/bin/bash

set -e

source ./shared.sh

vecho() {
	printf "[\033[1;32mZSH-SETUP\033[0m] %s\n" "$1"
}

vecho "Installing Oh-My-Zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

vecho "Installing Oh-My-Zsh plugins"
git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions" || true
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" || true
git clone https://github.com/larkery/zsh-histdb "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-histdb" || true
git clone https://github.com/m42e/zsh-histdb-fzf.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-histdb-fzf" || true
git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab" || true

vecho "Installing tmux"
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" || true
git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux" || true
ln -s -f "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"

vecho "Installing alacritty catppucin theme"
git clone https://github.com/catppuccin/alacritty.git ~/.config/alacritty/catppuccin || true

vecho "Applying dotfiles"
install_or_upgrade chezmoi
chezmoi init --apply https://github.com/ilaif/dotfiles.git
