#!/bin/sh

LOC=$(readlink -f "$0")
DIR=$(dirname "$LOC")

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DIR/musicbox-bundle/lib
cd $DIR/musicbox-bundle
nix-shell --run './musicbox'

