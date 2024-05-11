#!/bin/bash

run-evn=RUST_LOG=error,warn,info,debug,sqlx=off,reqwest=off,html2text=off

all:
	cargo build

build-android:
	cargo apk build --lib

run:
	$(run-evn) cargo run --bin downloader
