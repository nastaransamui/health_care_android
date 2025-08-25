#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: tool/upgrade_pkg.sh <package> [FAST]"
  exit 1
fi

PKG="$1"
MODE="${2:-}"  # pass FAST to skip heavy builds

echo "==> Current locked version (if any):"
grep -A2 -n "\"$PKG\":" pubspec.lock || true

echo "==> Upgrading $PKG to latest major (edits pubspec.yaml)"
dart pub add "$PKG"

echo "==> flutter pub get"
flutter pub get

# If you use codegen, rebuild it safely:
if grep -q "build_runner" pubspec.yaml; then
  echo "==> Rebuilding generated files"
  dart run build_runner build -d
fi

echo "==> Running fixes (harmless if nothing to do)"
dart fix --apply || true

echo "==> Verifying project"
./tool/verify.sh "$MODE"

echo "✅ $PKG upgraded cleanly."
echo "==> Git commit"
git add .
git commit -m "chore: upgrade $PKG to latest"