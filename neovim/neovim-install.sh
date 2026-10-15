#!/usr/bin/env bash
# Generic, reusable Neovim installer/updater (safe to publish in a dotfiles repo).
#
# 会改动：
#   1. <install dir>       解压后的 Neovim 目录（已存在则整体覆盖）
#   2. <bin dir>/nvim      指向 <install dir>/bin/nvim 的软链接（强制重建）
#   3. PATH               仅当前 shell（打印 export 提示），不写任何 dotfile
#
# Usage:
#   bash neovim-install.sh                              # 交互式询问安装目录
#   bash neovim-install.sh --yes                        # 不询问，用默认 /usr/local/nvim
#   sudo bash neovim-install.sh                         # 装到 /usr/local（需要 root）
#   NVIM_INSTALL_DIR=~/.local/opt/nvim \
#   NVIM_BIN_DIR=~/.local/bin bash neovim-install.sh    # 装到用户目录，无需 sudo
#   NVIM_VERSION=v0.12.6 bash neovim-install.sh         # 指定版本
#
# 环境变量：
#   NVIM_INSTALL_DIR  安装目录（默认 /usr/local/nvim）
#   NVIM_BIN_DIR      软链接目录（默认 <install dir> 的同级 bin）
#   NVIM_VERSION      指定版本，默认 latest
#
# Privacy notes:
# - No hostnames, accounts, tokens or secrets are referenced.
# - If you need a proxy, export https_proxy (or all_proxy) before running;
#   this script itself never changes proxy settings.

set -euo pipefail

DEFAULT_INSTALL_DIR=/usr/local/nvim

usage() {
  sed -n '4,20p' "$0" | sed 's/^# \{0,1\}//'
}

case "${1:-}" in
  -h | --help)
    usage
    exit 0
    ;;
esac

ASSUME_YES=0
if [ "${1:-}" = "--yes" ]; then ASSUME_YES=1; fi

# --- 安装路径：env 优先，其次交互询问，最后默认值 ---

INSTALL_DIR_FROM_ENV=0
if [ -n "${NVIM_INSTALL_DIR:-}" ]; then
  INSTALL_DIR_FROM_ENV=1
  INSTALL_DIR=$NVIM_INSTALL_DIR
else
  INSTALL_DIR=$DEFAULT_INSTALL_DIR
fi

BIN_DIR_FROM_ENV=0
if [ -n "${NVIM_BIN_DIR:-}" ]; then
  BIN_DIR_FROM_ENV=1
  BIN_DIR=$NVIM_BIN_DIR
else
  BIN_DIR=$(dirname "$INSTALL_DIR")/bin
fi

if [ "$ASSUME_YES" -eq 0 ] && [ "$INSTALL_DIR_FROM_ENV" -eq 0 ] && [ -t 0 ]; then
  printf 'Install Neovim to [%s]: ' "$INSTALL_DIR" >&2
  read -r answer || answer=""
  if [ -n "$answer" ]; then
    INSTALL_DIR=$answer
    [ "$BIN_DIR_FROM_ENV" -eq 1 ] || BIN_DIR=$(dirname "$INSTALL_DIR")/bin
  fi
fi

INSTALL_DIR=${INSTALL_DIR%/}
BIN_DIR=${BIN_DIR%/}
[ -n "$INSTALL_DIR" ] || INSTALL_DIR=$DEFAULT_INSTALL_DIR
[ -n "$BIN_DIR" ] || BIN_DIR=$(dirname "$INSTALL_DIR")/bin

# --- 权限：只有写不进去时才需要 sudo，装用户目录时全程不需要 root ---

parent_writable() {
  local dir=$1
  while [ ! -e "$dir" ] && [ "$dir" != "/" ]; do dir=$(dirname "$dir"); done
  [ -w "$dir" ]
}

SUDO=""
if [ "$EUID" -ne 0 ] && { ! parent_writable "$INSTALL_DIR" || ! parent_writable "$BIN_DIR"; }; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    printf 'Need write access to %s and %s. Re-run with sudo.\n' \
      "$(dirname "$INSTALL_DIR")" "$BIN_DIR" >&2
    exit 1
  fi
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

echo "Installing to $INSTALL_DIR..."
$SUDO rm -rf "$INSTALL_DIR"
$SUDO mkdir -p "$(dirname "$INSTALL_DIR")" "$BIN_DIR"
$SUDO mv "$EXTRACTED_DIR" "$INSTALL_DIR"
$SUDO ln -sfn "$INSTALL_DIR/bin/nvim" "$BIN_DIR/nvim"

echo "Installed:"
"$BIN_DIR/nvim" --version | head -n 1

# PATH 里有另一份 nvim 且优先级更高时提醒，避免装出第二份互相盖
resolved_new=$(readlink -f "$BIN_DIR/nvim")
other_nvim=$(command -v nvim 2>/dev/null || true)
if [ -n "$other_nvim" ]; then
  resolved_other=$(readlink -f "$other_nvim")
  if [ "$resolved_other" != "$resolved_new" ]; then
    printf '\nwarning: another nvim is on PATH at %s -> %s\n' \
      "$other_nvim" "$resolved_other" >&2
    printf '         this install: %s -> %s\n' "$BIN_DIR/nvim" "$resolved_new" >&2
    printf '         remove the old one, or put %s earlier in PATH\n' "$BIN_DIR" >&2
  fi
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    printf '\nAdd it to your PATH (this script never edits your dotfiles):\n'
    printf '  export PATH="%s:$PATH"\n' "$BIN_DIR"
    ;;
esac
