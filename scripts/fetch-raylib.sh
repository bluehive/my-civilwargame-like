#!/usr/bin/env bash
# Fetch prebuilt raylib for Linux amd64 (GitHub Releases).
# Output: vendor/raylib-prebuilt/{include,lib}
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RAYLIB_VERSION="${RAYLIB_VERSION:-5.5}"
RAYLIB_DIR="${RAYLIB_DIR:-vendor/raylib-prebuilt}"
# Official release asset name (linux amd64)
ASSET="raylib-${RAYLIB_VERSION}_linux_amd64.tar.gz"
URL="https://github.com/raysan5/raylib/releases/download/${RAYLIB_VERSION}/${ASSET}"

if [[ -f "${RAYLIB_DIR}/lib/libraylib.a" || -f "${RAYLIB_DIR}/lib/libraylib.so" ]]; then
  echo "✅ raylib already present: ${RAYLIB_DIR}"
  exit 0
fi

mkdir -p vendor
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "⬇️  Downloading ${URL}"
if ! curl -fsSL "$URL" -o "${TMP}/${ASSET}"; then
  echo "❌ Download failed. Check network or RAYLIB_VERSION=${RAYLIB_VERSION}"
  exit 1
fi

echo "📦 Extracting..."
tar -xzf "${TMP}/${ASSET}" -C "$TMP"

# Layout may be raylib-X.Y_linux_amd64/{include,lib} or flat
EXTRACTED="$(find "$TMP" -type d -name 'include' | head -n1)"
if [[ -z "$EXTRACTED" ]]; then
  echo "❌ Unexpected archive layout (no include/)"
  find "$TMP" -maxdepth 3 -type d
  exit 1
fi
BASE="$(dirname "$EXTRACTED")"

rm -rf "$RAYLIB_DIR"
mkdir -p "$RAYLIB_DIR"
cp -a "${BASE}/include" "${RAYLIB_DIR}/"
cp -a "${BASE}/lib" "${RAYLIB_DIR}/"

# Some releases ship only .so; ensure we have something linkable
if [[ ! -f "${RAYLIB_DIR}/lib/libraylib.a" && ! -f "${RAYLIB_DIR}/lib/libraylib.so" ]]; then
  echo "❌ No libraylib.a / libraylib.so under ${RAYLIB_DIR}/lib"
  ls -la "${RAYLIB_DIR}/lib" || true
  exit 1
fi

echo "✅ raylib ${RAYLIB_VERSION} → ${RAYLIB_DIR}"
ls -la "${RAYLIB_DIR}/lib"
