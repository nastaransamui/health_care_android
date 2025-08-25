#!/usr/bin/env bash
set -euo pipefail

FAST=${1:-}   # pass FAST to skip builds

echo "==> flutter analyze"
flutter analyze

if [ -d "test" ]; then
  echo "==> flutter test"
  flutter test
fi

if [ "$FAST" != "FAST" ]; then
  echo "==> flutter build apk --release"
  flutter build apk --release

  if [ -d "ios" ]; then
    echo "==> ios pod install (skip if no iOS)"
    (cd ios && pod install --repo-update)
    echo "==> flutter build ios --no-codesign"
    flutter build ios --no-codesign
  fi
fi

echo "✅ verify.sh passed"