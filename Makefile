#!/bin/bash

gen-icons:
	fvm flutter pub run flutter_launcher_icons

gen-splash:
	fvm dart run flutter_native_splash:create

linux:
	fvm flutter -d linux

