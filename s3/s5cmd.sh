#!/bin/bash

set -eu -ox pipefail

VERSION="2.3.0"

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Linux) OS_NAME="Linux" ;;
    Darwin) OS_NAME="macOS" ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

# Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64) ARCH_NAME="64bit" ;;
    arm64|aarch64) ARCH_NAME="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

CACHE_DIR="${HOME}/.cache/s5cmd/${VERSION}"
mkdir -p "$CACHE_DIR"

# Output binary path
S5CMD_BIN="$CACHE_DIR/s5cmd"

if [[ ! -x "$S5CMD_BIN" ]]; then
    URL="https://github.com/peak/s5cmd/releases/download/v${VERSION}/s5cmd_${VERSION}_${OS_NAME}-${ARCH_NAME}.tar.gz"
    echo "Downloading s5cmd from: $URL"
    exit 1
    
    TMP_TAR="$(mktemp)"
    curl -L "$URL" -o "$TMP_TAR"
    
    tar -xzf "$TMP_TAR" -C "$CACHE_DIR"
    rm "$TMP_TAR"
    
    chmod +x "$S5CMD_BIN"
fi

"$S5CMD_BIN" "$@"
