#!/bin/bash

run-evn=RUST_LOG=debug,sqlx=off,reqwest=off
version=`git describe --tags --abbrev=0`
android-build-flag=--release --obfuscate --split-debug-info=./build/debug-info

all:
	fvm flutter build apk

gen-icons:
	fvm flutter pub run flutter_launcher_icons

gen-splash:
	fvm dart run flutter_native_splash:create

run:
	$(run-evn) fvm flutter run

run-linux:
	$(run-evn) fvm flutter run -d linux

build-rust:
	cd ./rust && cargo build

build-apk: remove-old-apk build-apk-all build-apk-arm build-apk-arm64 build-apk-x64

build-apk-all: make-release-dir
	- rm build/release/musicbox-${version}.apk
	fvm flutter build apk ${android-build-flag}
	cp build/app/outputs/flutter-apk/app-release.apk build/release/musicbox-${version}.apk

build-apk-arm: make-release-dir
	- rm build/release/musicbox-arm-${version}.apk
	fvm flutter build apk ${android-build-flag} --target-platform=android-arm
	cp build/app/outputs/flutter-apk/app-release.apk build/release/musicbox-arm-${version}.apk

build-apk-arm64: make-release-dir
	- rm build/release/musicbox-arm64-${version}.apk
	fvm flutter build apk ${android-build-flag} --target-platform=android-arm64
	cp build/app/outputs/flutter-apk/app-release.apk build/release/musicbox-arm64-${version}.apk

build-apk-x64: make-release-dir
	- rm build/release/musicbox-x64-${version}.apk
	fvm flutter build apk ${android-build-flag} --target-platform=android-x64
	cp build/app/outputs/flutter-apk/app-release.apk build/release/musicbox-x64-${version}.apk

make-release-dir:
	mkdir -p ./build/release

remove-old-apk:
	-rm -f ./build/release/*

clean:
	rm -rf ./flutter_jank_metrics_*.json
	rm -rf ./rust/target
	fvm flutter clean

clean-jank:
	rm -rf ./flutter_jank_metrics_*.json

# just call this cmd once
# integrate-rust:
#	flutter_rust_bridge_codegen integrate

# it will watch the rust codes and generate dart codes on the background
generate-rust:
	flutter_rust_bridge_codegen generate

# it will watch the rust codes and generate dart codes on the background
generate-rust-watch:
	flutter_rust_bridge_codegen generate --watch

upgrade-dependencies-version:
	flutter pub upgrade --major-versions
