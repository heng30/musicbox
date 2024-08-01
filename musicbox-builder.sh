#!/bin/bash

export PATH="$coreutils/bin"

mkdir -p $out/bin
cp -rf $src/build/linux/x64/release/bundle $out/bin/musicbox-bundle
cp $src/nixos-run.sh $out/bin/musicbox
