#!/bin/sh

set -e

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
git clone https://github.com/larkery/zsh-histdb ${OH_MY_ZSH_PLUGINS}/zsh-histdb
git clone https://github.com/m42e/zsh-histdb-fzf.git ${OH_MY_ZSH_PLUGINS}/zsh-histdb-fzf

vecho "Installing tmux"
git clone https://github.com/gpakosz/.tmux.git $HOME/.tmux
ln -s -f $HOME/.tmux/.tmux.conf $HOME/.tmux.conf

vecho "Hardlinking tmux/.tmux.conf.local to $HOME/.tmux.conf.local"
ln -f tmux/.tmux.conf.local $HOME/.tmux.conf.local

vecho "Hardlinking zsh/.zshrc to $HOME/.zshrc"
ln -f zsh/.zshrc $HOME/.zshrc

vecho "Hardlinking vim/.vimrc to $HOME/.vimrc"
ln -f vim/.vimrc $HOME/.vimrc

vecho "Hardlinking alacritty/.alacritty.yml to $HOME/.alacritty.yml"
ln -f alacritty/.alacritty.yml $HOME/.alacritty.yml

vecho "Hardlinking scripts/open-ide.sh to $HOME/.open-ide.sh"
ln -f scripts/.open-ide.sh $HOME/.open-ide.sh

vecho "Hardlinking starship.tomk to $HOME/.config/starship.toml"
ln -f starship.toml $HOME/.config/starship.toml
