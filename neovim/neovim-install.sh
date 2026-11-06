#!/usr/bin/env bash
# Generic, reusable Neovim installer/updater (safe to publish in a dotfiles repo).
#
# 会改动：
#   1. <install dir>       解压后的 Neovim 目录（已存在则整体覆盖）
#   2. <bin dir>/nvim      指向 <install dir>/bin/nvim 的软链接（强制重建）
#   3. PATH               仅当前 shell（打印 export 提示），不写任何 dotfile
#
# 支持平台：macOS / Linux（arm64、x86_64）。Windows 不支持（发布物是 zip/msi）。
# 定位：没有 agent 时的兜底实现。有 agent 时由 AGENTS.md 让它按平台自选方式安装，
# 本脚本只保证「无判断能力时也能装对架构、不会装坏」。
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

# --- 平台 → 发布资产 ---
# 命名矩阵对应 Neovim >= 0.10；更老的版本用 nvim-linux64 / nvim-macos 命名，作为候选回退。
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin) PLATFORM=macos ;;
  Linux)  PLATFORM=linux ;;
  *) printf 'Unsupported OS: %s (supported: macOS, Linux)\n' "$OS" >&2; exit 1 ;;
esac

case "$ARCH" in
  arm64|aarch64) CPU=arm64 ;;
  x86_64|amd64)  CPU=x86_64 ;;
  *) printf 'Unsupported architecture: %s (supported: arm64, x86_64)\n' "$ARCH" >&2; exit 1 ;;
esac

CANDIDATES="nvim-${PLATFORM}-${CPU}.tar.gz"
case "${PLATFORM}-${CPU}" in
  linux-x86_64) CANDIDATES="$CANDIDATES nvim-linux64.tar.gz" ;;
  macos-x86_64) CANDIDATES="$CANDIDATES nvim-macos.tar.gz" ;;
esac

# --- 下载：候选名依次尝试，全部 404 才报错，并把官方页面指出来 ---

cd "$WORKDIR"
ASSET=""
for asset in $CANDIDATES; do
  if [[ "$NVIM_VERSION" == "latest" ]]; then
    URL="https://github.com/neovim/neovim/releases/latest/download/${asset}"
  else
    URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${asset}"
  fi
  echo "Downloading ${NVIM_VERSION} (${PLATFORM}/${CPU}) <- ${asset}"
  if curl -fL -o "$asset" "$URL"; then
    ASSET="$asset"
    break
  fi
  rm -f "$asset"
done

if [[ -z "$ASSET" ]]; then
  printf '\nNo release asset matched %s/%s for %s.\n' "$PLATFORM" "$CPU" "$NVIM_VERSION" >&2
  printf 'Check https://github.com/neovim/neovim/releases/latest and update the\n' >&2
  printf 'asset table in this script.\n' >&2
  exit 1
fi

echo "Extracting..."
tar xzf "$ASSET"

# Neovim tarball extracts to nvim-<platform>-<arch>
EXTRACTED_DIR="${ASSET%.tar.gz}"
if [[ ! -d "$EXTRACTED_DIR" ]]; then
  # Fallback for upstream directory naming changes.
  EXTRACTED_DIR="$(find "$WORKDIR" -mindepth 1 -maxdepth 1 -type d | head -n1)"
fi
if [[ -z "${EXTRACTED_DIR:-}" || ! -d "$EXTRACTED_DIR" ]]; then
  echo "Could not locate extracted Neovim directory."
  exit 1
fi

# 安装前自检：产物必须能在本机执行，否则直接停下，不覆盖已有安装
SMOKE_NVIM="$EXTRACTED_DIR/bin/nvim"
[[ "$SMOKE_NVIM" = /* ]] || SMOKE_NVIM="$WORKDIR/$SMOKE_NVIM"
if ! "$SMOKE_NVIM" --version >/dev/null 2>&1; then
  printf '\nDownloaded binary cannot run on %s/%s.\n' "$PLATFORM" "$CPU" >&2
  printf 'Existing installation left untouched.\n' >&2
  exit 1
fi

echo "Installing to $INSTALL_DIR..."
$SUDO rm -rf "$INSTALL_DIR"
$SUDO mkdir -p "$(dirname "$INSTALL_DIR")" "$BIN_DIR"
$SUDO mv "$EXTRACTED_DIR" "$INSTALL_DIR"
$SUDO ln -sfn "$INSTALL_DIR/bin/nvim" "$BIN_DIR/nvim"

echo "Installed:"
"$BIN_DIR/nvim" --version | head -n 1

# 配置依赖 nvim-treesitter main 分支，需要 0.12+；低于此只警告，不阻止升级流程
installed_ver=$("$BIN_DIR/nvim" --version | head -n1 | awk '{print $2}')
installed_ver="${installed_ver#v}"
case "$installed_ver" in
  0.1[2-9]*|0.[2-9][0-9]*) ;;
  *) printf 'warning: %s < 0.12, this config expects 0.12+\n' "$installed_ver" >&2 ;;
esac

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
