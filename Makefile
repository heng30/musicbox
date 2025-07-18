#!/bin/sh

run-evn=RUST_LOG=debug
version=`git describe --tags --abbrev=0`
android-build-flag=--release --obfuscate --split-debug-info=./build/debug-info

all:
	fvm flutter build apk

run:
	$(run-evn) fvm flutter run

build: build-arm build-arm64 build-x64

build-arm:
	fvm flutter build apk ${android-build-flag} --target-platform=android-arm
	cp build/app/outputs/flutter-apk/app-release.apk build/release/musicbox-arm-${version}.apk

build-arm64:
	fvm flutter build apk ${android-build-flag} --target-platform=android-arm64
	cp build/app/outputs/flutter-apk/app-release.apk build/release/musicbox-arm64-${version}.apk

build-x64:
	fvm flutter build apk ${android-build-flag} --target-platform=android-x64
	cp build/app/outputs/flutter-apk/app-release.apk build/release/musicbox-x64-${version}.apk

clean:
	fvm flutter clean
	- rm -rf ./rust/target
	- rm -rf ./flutter_jank_metrics_*.json

# just call this cmd once
# integrate-rust:
#	flutter_rust_bridge_codegen integrate

# generate dart codes
generate-rust:
	flutter_rust_bridge_codegen generate

# watch the rust codes and generate dart codes on the background
generate-rust-watch:
	flutter_rust_bridge_codegen generate --watch

upgrade-dependencies-version:
	flutter pub upgrade --major-versions

gen-icons:
	fvm flutter pub run flutter_launcher_icons

gen-splash:
	fvm dart run flutter_native_splash:create
