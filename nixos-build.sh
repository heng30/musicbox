#!/bin/sh

cp ./run-shell.nix ./build/linux/x64/release/bundle/shell.nix

nix-build musicbox.nix
