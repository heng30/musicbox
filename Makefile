#!/bin/bash

run-evn= RUST_LOG=debug,sqlx=off,reqwest=off

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

build-apk:
	fvm flutter build apk

clean:
	rm -rf ./flutter_jank_metrics_*.json
	rm -rf ./rust/target
	fvm flutter clean

clean-jank:
	rm -rf ./flutter_jank_metrics_*.json

# just call this cmd once
# integrate-rust:
# 	flutter_rust_bridge_codegen integrate

# it will watch the rust codes and generate dart codes on the background
generate-rust:
	flutter_rust_bridge_codegen generate

# it will watch the rust codes and generate dart codes on the background
generate-rust-watch:
	flutter_rust_bridge_codegen generate --watch

