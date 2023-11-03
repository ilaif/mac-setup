#!/bin/sh

set -e

source ./shared.sh

function vecho() {
    echo "[\033[1;32mZSH-SETUP\033[0m] ${1}"
}

vecho "Installing Oh-My-Zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

vecho "Installing Oh-My-Zsh plugins"
OH_MY_ZSH_PLUGINS="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins"
git clone https://github.com/zsh-users/zsh-completions ${OH_MY_ZSH_PLUGINS}/zsh-completions || true
git clone https://github.com/zsh-users/zsh-autosuggestions ${OH_MY_ZSH_PLUGINS}/zsh-autosuggestions || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${OH_MY_ZSH_PLUGINS}/zsh-syntax-highlighting || true
git clone https://github.com/larkery/zsh-histdb ${OH_MY_ZSH_PLUGINS}/zsh-histdb || true
git clone https://github.com/m42e/zsh-histdb-fzf.git ${OH_MY_ZSH_PLUGINS}/zsh-histdb-fzf || true
git clone https://github.com/Aloxaf/fzf-tab ${OH_MY_ZSH_PLUGINS}/fzf-tab || true

vecho "Installing tmux"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/gpakosz/.tmux.git $HOME/.tmux || true
ln -s -f $HOME/.tmux/.tmux.conf $HOME/.tmux.conf

vecho "Applying dotfiles"
install_or_upgrade chezmoi
chezmoi init --apply https://github.com/ilaif/dotfiles.git
