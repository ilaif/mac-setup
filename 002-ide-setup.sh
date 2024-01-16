#!/bin/bash

set -e

source ./shared.sh

vecho() {
  printf "[\033[1;32mIDE-SETUP\033[0m] %s\n" "$1"
}

# VERSIONS

TERRAFORM_VER=1.6.3
GOLINES_VER=v0.11.0
GO_VER=1.21.6
NVM_VER=v0.39.5
NODE_VER=20
GOLANGCI_LINT_VER=v1.55.1
PYTHON_VER=3.12

vecho "#########################"
vecho "# Welcome to IDE setup! #"
vecho "#########################"
echo ""

vecho "Installing Xcode Command Line Tools"
xcode-select --install || true

##############
## Git[Hub] ##
##############

vecho "Setting up git"
if [ -z "$(git config --global user.name)" ]; then
  ssh-keyscan -t rsa github.com >>~/.ssh/known_hosts
  echo "Choose a username for git:"
  read -r username
  git config --global user.name "${username}"
  echo "Choose an email for git:"
  read -r email
  git config --global user.email "${email}"
fi

##############
## Homebrew ##
##############

install_brew

vecho "Updating brew"
brew update

vecho "Installing brew packages"

brew tap goreleaser/tap

declare -a brew_packages=(
  coreutils
  findutils # Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
  diffutils # Required for goanalysis_metalinter
  jq
  yq
  tmux
  vim
  wget
  curl
  htop
  kubectl
  direnv
  fzf
  gh
  awscli
  pre-commit
  helm
  kustomize
  semgrep
  goreleaser
  tfenv
  kubectx
  k9s
  kind
  pipenv
  pyenv
  terraform-docs
  starship    # prompt
  neovim      # terminal ide
  zoxide      # z for improved cd
  lf          # list files
  bat         # cat with syntax highlighting
  nvim        # terminal ide
  lazygit     # git ui
  dust        # du with syntax highlighting
  cloudflared # argo tunnel
  libpq       # postgresql client
  shellcheck  # shell linter
  ruff        # python linter
  watch
  tree
  go # golang (later gvm will be installed to manage versions)
)

for pkg in "${brew_packages[@]}"; do
  vecho "brew install ${pkg}"
  install_or_upgrade "${pkg}"
done

vecho "Installing fzf bindings"
"$(brew --prefix)/opt/fzf/install"

vecho "Installing brew casks"

declare -a brew_cask_packages=(
  visual-studio-code
  google-cloud-sdk
  postman
  1password
  1password/tap/1password-cli
  homebrew/cask-fonts/font-jetbrains-mono
  homebrew/cask-fonts/font-jetbrains-mono-nerd-font
  notion
  docker
  alacritty
  spotify
  zoom
  raycast
  telegram
  todoist
  goland
  datagrip
  slack
  arc
  rectangle
  google-drive
  linear-linear
  insomnia
  licecap
  raycast
  stremio
)

for pkg in "${brew_cask_packages[@]}"; do
  vecho "brew install cask ${pkg}"
  install_or_upgrade_cask "${pkg}" || true
done

#############
## GH Exts ##
#############

vecho "Installing gh extensions"
gh auth login
gh extension install ilaif/gh-prx
gh extension install mislav/gh-branch

############
## Golang ##
############

vecho "Installing gvm (go version manager)"
if [ -n "$(type gvm &>/dev/null)" ]; then
  bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
fi
set +e
# shellcheck disable=SC1091
source "$HOME/.gvm/scripts/gvm"
set -e

vecho "Installing Go ${GO_VER}"
gvm install go${GO_VER}
gvm use go${GO_VER} --default
brew uninstall go

declare -a go_packages=(
  "github.com/segmentio/golines@${GOLINES_VER}"
)

for pkg in "${go_packages[@]}"; do
  vecho "go install ${pkg}"
  go install "${pkg}"
done

vecho "Installing golangci-lint"
curl -sSfL \
  "https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh" |
  sh -s -- -b "$(go env GOPATH)/bin" $GOLANGCI_LINT_VER

#############
## Node.JS ##
#############

vecho "Installing NVM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VER/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

vecho "Installing Node.JS"
nvm install ${NODE_VER}
nvm use ${NODE_VER}
nvm alias default ${NODE_VER}
node --version >~/.node-version

vecho "Install npm packages"
npm install -g @githubnext/github-copilot-cli
npm install -g @escape.tech/mookme

############
## Python ##
############

vecho "Installing Python"
pyenv install ${PYTHON_VER}
pyenv global ${PYTHON_VER}

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

vecho "Install python virtualenv"
pip install virtualenv
vecho "Install python virtualenvwrapper"
pip install virtualenvwrapper

vecho "Installing poetry"
curl -sSL https://install.python-poetry.org | python3 -

#########
## K8s ##
#########

vecho "Installing K8S Krew"
(
  set -x
  cd "$(mktemp -d)"
  OS="$(uname | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
  KREW="krew-${OS}_${ARCH}"
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
  tar zxvf "${KREW}.tar.gz"
  ./"${KREW}" install krew
)

gcloud components install gke-gcloud-auth-plugin

###############
## Terraform ##
###############

vecho "Installing terraform"
tfenv install $TERRAFORM_VER
tfenv use $TERRAFORM_VER

################
## Other Apps ##
################

vecho "Other apps to install:"
vecho "* Okta Verify: https://apps.apple.com/us/app/okta-verify/id490179405"
vecho "* Login to google drive"
vecho "* Import settings from personal-drive/dev/environment/raycast.export"
vecho "* Open RayCast and configure"
vecho "* Open 1Password and configure"
vecho "* Open VSCode and login to Settings & Sync"
