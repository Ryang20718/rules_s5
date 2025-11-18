#!/bin/bash

set -eu -ox pipefail

VERSION="2.3.1"

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

# lock file to ensure thread safety
LOCKFILE="${CACHE_DIR}/.s5cmd.lock"
(
    flock -x 200  # exclusive lock
    if [[ ! -x "$S5CMD_BIN" ]]; then
        # https://github.com/peak/s5cmd/pull/769
        # we can not use the main github release as the go aws sdk doesn't support eks pod identity
        # we use a fork to patch the s5cmd to support this
        URL="https://github.com/hustcer/s5cmd/releases/download/v${VERSION}/s5cmd_${VERSION}_${OS_NAME}-${ARCH_NAME}.tar.gz"
        echo "Downloading s5cmd from: $URL"

        TMP_TAR="$(mktemp)"
        TMP_DIR="$(mktemp -d)"

        curl -sSL "$URL" -o "$TMP_TAR"
        tar -xzf "$TMP_TAR" -C "$TMP_DIR"
        rm "$TMP_TAR"

        # Move atomically to cache
        mv -f "$TMP_DIR/s5cmd" "$S5CMD_BIN"
        rm -rf "$TMP_DIR"

        chmod +x "$S5CMD_BIN"
    fi
) 200>"$LOCKFILE"

"$S5CMD_BIN" "$@"
