FORMAT_MODE ?= inplace # or check

ifeq '$(FORMAT_MODE)' 'inplace'
FOURMOLU := fourmolu --mode inplace
NIXPKGS_FMT := nixpkgs-fmt
else
FOURMOLU := fourmolu --mode check
NIXPKGS_FMT := nixpkgs-fmt --check
endif

.PHONY: all
all: build

.PHONY: build
build:
	cabal build all

.PHONY: format
format: format-haskell format-nix

.PHONY: format-haskell
format-haskell:
	$(FOURMOLU) app/Main.hs

.PHONY: format-nix
format-nix:
	$(NIXPKGS_FMT) flake.nix

.PHONY: spell
spell:
	cspell '**/*'

.PHONY: lint
lint: lint-shell

.PHONY: lint-shell
lint-shell:
	shellcheck --shell=bash dev/download-dependencies

.PHONY: download-dependencies
download-dependencies:
	dev/download-dependencies -o .local-repository

.PHONY: clean-local-repository
clean-local-repository:
	-rm .local-repository/*
