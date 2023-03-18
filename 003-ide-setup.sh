#!/bin/sh

# VERSIONS

TERRAFORM_VER=1.1.3
GOLINES_VER=v0.10.0
BUF_VER=0.56.0
PROTOC_VER=3
PROTOC_GEN_GO_VER=1.27.1
PROTOC_GEN_GO_GRPC_VER=1.2.0
GO_VER=1.18
NODE_VER=16
GOLANGCI_LINT_VER=v1.49.0
OAPI_CODEGEN_VER=v1.12.4
MOCKERY_VER=v2.14.0
PYTHON_VER=3.11

function vecho() {
    echo "[\033[1;32mIDE-SETUP\033[0m] ${1}"
}
function install_or_upgrade() {
    if brew ls --versions "$1" >/dev/null; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade "$1"
    else
        HOMEBREW_NO_AUTO_UPDATE=1 brew install "$1"
    fi
}
function install_or_upgrade_cask() {
    if brew ls --cask --versions "$1" >/dev/null; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade --cask "$1"
    else
        HOMEBREW_NO_AUTO_UPDATE=1 brew install --cask "$1"
    fi
}

set -e

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
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
echo "Choose a username for git:"
read username
git config --global user.name "${username}"
echo "Choose an email for git:"
read email
git config --global user.email "${email}"

##############
## Homebrew ##
##############

if test ! $(which brew); then
    vecho "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    vecho "Add brew to your shell based on the above instructions, and run the script again"
fi

vecho "Updating brew"
brew update

vecho "Installing brew packages"

brew tap yoheimuta/protolint
brew tap vmware-tanzu/carvel
brew tap goreleaser/tap
brew tap bufbuild/buf

declare -a brew_packages=(
    coreutils
    findutils # Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
    jq
    yq
    tmux
    vim
    wget
    curl
    kubectl
    kube-ps1
    direnv
    fzf
    gh
    awscli
    pre-commit
    helm
    circleci
    grpcurl
    kustomize
    kapp
    semgrep
    goreleaser
    bufbuild/buf/buf
    tfenv
    kubectx
    k9s
    k3d
    protolint
    protobuf@${PROTOC_VER}
    nvm
    pipenv
    pyenv
    terraform-docs
)

for pkg in "${brew_packages[@]}"; do
    vecho "brew install ${pkg}"
    install_or_upgrade ${pkg}
done

vecho "Installing fzf bindings"
$(brew --prefix)/opt/fzf/install

vecho "Installing brew casks"

declare -a brew_cask_packages=(
    visual-studio-code
    iterm2
    google-cloud-sdk
    postman
    1password
    1password/tap/1password-cli
    homebrew/cask-fonts/font-jetbrains-mono
    notion
    docker
    alacritty
    spotify
    zoom
    raycast
    telegram
    rambox
    todoist
    goland
    datagrip
)

for pkg in "${brew_cask_packages[@]}"; do
    vecho "brew install cask ${pkg}"
    install_or_upgrade_cask ${pkg} || true
done

############
## Golang ##
############

vecho "Installing gvm (go version manager)"
zsh < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source /Users/ilaif/.gvm/scripts/gvm

vecho "Installing Go ${GO_VER}"
gvm install go${GO_VER}
gvm use go${GO_VER} --default

declare -a go_packages=(
    gotest.tools/gotestsum@latest
    github.com/segmentio/golines@$GOLINES_VER
    github.com/fdaines/arch-go@latest
    github.com/swaggo/swag/cmd/swag@latest
    github.com/deepmap/oapi-codegen/cmd/oapi-codegen@${OAPI_CODEGEN_VER}
    google.golang.org/protobuf/cmd/protoc-gen-go@v${PROTOC_GEN_GO_VER}
    google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${PROTOC_GEN_GO_GRPC_VER}
    github.com/vektra/mockery/v2@${MOCKERY_VER}
)

for pkg in "${go_packages[@]}"; do
    vecho "go install ${pkg}"
    go install ${pkg}
done

vecho "Installing buf"
curl -sSL \
    "https://github.com/bufbuild/buf/releases/download/v${BUF_VER}/buf-$(uname -s)-$(uname -m)" \
    -o "/usr/local/bin/buf" &&
    chmod +x "/usr/local/bin/buf"

vecho "Installing golangci-lint"
curl -sSfL \
    "https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh" |
    sh -s -- -b $(go env GOPATH)/bin $GOLANGCI_LINT_VER

#############
## Node.JS ##
#############

vecho "Installing Node.JS"

nvm install ${NODE_VER}
nvm use ${NODE_VER}
node --version > ~/.node-version

vecho "Install npm packages"
npm i -g jest
npm i -g @stoplight/spectral-cli

############
## Python ##
############

vecho "Installing Python"
pyenv install ${PYTHON_VER}
pyenv global ${PYTHON_VER}

vecho "Install python virtualenv"
pip install virtualenv
vecho "Install python virtualenvwrapper"
pip install virtualenvwrapper

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

###############
## Terraform ##
###############

vecho "Installing terraform"
tfenv install $TERRAFORM_VER
tfenv use $TERRAFORM_VER
