{ pkgs ? import <nixpkgs> { } }:

derivation {
  name = "musicbox-1.1.3";
  system = builtins.currentSystem;
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./musicbox-builder.sh ];
  inherit (pkgs) coreutils;
  src = ./.;
}

