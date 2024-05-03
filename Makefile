#!/bin/bash

gen-icons:
	fvm flutter pub run flutter_launcher_icons

gen-splash:
	fvm dart run flutter_native_splash:create

run:
	fvm flutter run

linux:
	fvm flutter run -d linux

