.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

mac-setup:
	./001-mac-setup.sh

ide-setup:
	./002-ide-setup.sh

zsh-setup:
	./003-zsh-setup.sh

all: mac-setup ide-setup zsh-setup
