#!/usr/bin/env bash
# Generic, reusable Neovim installer/updater (safe to publish in a dotfiles repo).
#
# Usage:
#   sudo bash neovim-install.sh
#   sudo NVIM_VERSION=v0.12.6 bash neovim-install.sh
#
# Privacy notes:
# - No hostnames, accounts, tokens or secrets are referenced.
# - If you need a proxy, export https_proxy (or all_proxy) before running;
#   this script itself never changes proxy settings.

set -euo pipefail


if [[ $EUID -ne 0 ]]; then
  echo "Please run with sudo: sudo bash $(basename "$0")"
  exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

# Proxy handling is intentionally not built in.
# If you need one, just export the usual variables before running:
#   export https_proxy=http://127.0.0.1:10808
#
# Do NOT commit any personal proxy port/server address to the repo.

NVIM_VERSION="${NVIM_VERSION:-latest}"

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ASSET="nvim-linux-x86_64.tar.gz" ;;
  aarch64|arm64) ASSET="nvim-linux-arm64.tar.gz" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

if [[ "$NVIM_VERSION" == "latest" ]]; then
  URL="https://github.com/neovim/neovim/releases/latest/download/${ASSET}"
  echo "Resolving latest Neovim release..."
else
  URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${ASSET}"
fi

cd "$WORKDIR"
echo "Downloading ${NVIM_VERSION} (${ARCH})..."
curl -fL -o "$ASSET" "$URL"

echo "Extracting..."
tar xzf "$ASSET"

# Neovim tarball extracts to nvim-linux-<arch>
EXTRACTED_DIR="${ASSET%.tar.gz}"
if [[ ! -d "$EXTRACTED_DIR" ]]; then
  # Fallback for upstream directory naming changes.
  EXTRACTED_DIR="$(find "$WORKDIR" -mindepth 1 -maxdepth 1 -type d | head -n1)"
fi
if [[ -z "${EXTRACTED_DIR:-}" || ! -d "$EXTRACTED_DIR" ]]; then
  echo "Could not locate extracted Neovim directory."
  exit 1
fi

echo "Installing to /usr/local/nvim..."
rm -rf /usr/local/nvim
mv "$EXTRACTED_DIR" /usr/local/nvim
ln -sfn /usr/local/nvim/bin/nvim /usr/local/bin/nvim

echo "Installed:"
/usr/local/bin/nvim --version | head -n 1