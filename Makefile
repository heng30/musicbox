#!/bin/sh

run-evn=RUST_LOG=debug
version=`git describe --tags --abbrev=0`
android-build-flag=--release --obfuscate --split-debug-info=./build/debug-info

all: build-arm build-arm64 build-x64

debug:
	$(run-evn) fvm flutter run

build-arm:
	fvm flutter build apk ${android-build-flag} --target-platform=android-arm
	cp build/app/outputs/flutter-apk/app-release.apk build/musicbox-arm-${version}.apk

build-arm64:
	fvm flutter build apk ${android-build-flag} --target-platform=android-arm64
	cp build/app/outputs/flutter-apk/app-release.apk build/musicbox-arm64-${version}.apk

build-x64:
	fvm flutter build apk ${android-build-flag} --target-platform=android-x64
	cp build/app/outputs/flutter-apk/app-release.apk build/musicbox-x64-${version}.apk

build-action:
	flutter build apk ${android-build-flag} --target-platform=android-arm
	cp build/app/outputs/flutter-apk/app-release.apk build/musicbox-arm-${version}.apk
	flutter build apk ${android-build-flag} --target-platform=android-arm64
	cp build/app/outputs/flutter-apk/app-release.apk build/musicbox-arm64-${version}.apk
	flutter build apk ${android-build-flag} --target-platform=android-x64
	cp build/app/outputs/flutter-apk/app-release.apk build/musicbox-x64-${version}.apk

clean:
	fvm flutter clean
	- rm -rf ./rust/target
	- rm -rf ./flutter_jank_metrics_*.json

generate-rust:
	flutter_rust_bridge_codegen generate

generate-rust-watch:
	flutter_rust_bridge_codegen generate --watch

upgrade-dependencies-version:
	flutter pub upgrade --major-versions

gen-icons:
	fvm flutter pub run flutter_launcher_icons

gen-splash:
	fvm dart run flutter_native_splash:create
