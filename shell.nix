{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    gst_all_1.gstreamer.dev
    gst_all_1.gst-plugins-base.dev
    gst_all_1.gst-plugins-good.dev
    gst_all_1.gst-plugins-bad.dev
    gst_all_1.gst-plugins-ugly.dev
    gst_all_1.gst-libav.dev
    gst_all_1.gst-vaapi.dev
  ];
  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = with pkgs.buildPackages; [ pkg-config flutter jdk17 clang ];
}
