#!/usr/bin/env bash
# Installs the Flutter SDK on Vercel's build image (it ships without Flutter).
set -euo pipefail

if ! command -v unzip >/dev/null 2>&1; then
  dnf install -y unzip xz >/dev/null
fi

if [ ! -x .flutter-sdk/bin/flutter ]; then
  git clone https://github.com/flutter/flutter.git --branch stable --depth 1 .flutter-sdk
fi

.flutter-sdk/bin/flutter config --no-analytics --enable-web
.flutter-sdk/bin/flutter --version
.flutter-sdk/bin/flutter pub get
