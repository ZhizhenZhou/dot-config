# 终端代理开关（macOS / Linux 通用，可选组件）
#
# 用法：
#   1. 设置候选端口（建议放 ~/.zshenv，本机值不进仓库）：
#        PROXY_PORTS="<端口1> <端口2>"   # 按顺序取第一个在监听的；只有一个端口就写一个
#   2. 在 ~/.zshrc（或 ~/.bashrc）里 source 本文件
#   3. 新开终端：有候选端口在监听就自动开启，否则保持关闭
#   4. 手动切换：proxy on [端口] / proxy off / proxy status
#
# 只对 source 它的交互式 shell 生效，不影响非交互脚本与 cron。

PROXY_PORTS="${PROXY_PORTS:-}"

# 端口是否在监听：优先 nc，没有 nc 时退回 bash 的 /dev/tcp（Linux）
_port_live() {
  if command -v nc >/dev/null 2>&1; then
    nc -z 127.0.0.1 "$1" >/dev/null 2>&1
  else
    bash -c "exec 3<>/dev/tcp/127.0.0.1/$1" 2>/dev/null
  fi
}

# 选端口：显式参数 > PROXY_PORTS 里第一个在监听的
_pick_port() {
  if [ -n "${1:-}" ]; then
    printf '%s\n' "$1"
    return 0
  fi
  for _pp in $(printf '%s\n' "$PROXY_PORTS"); do
    if _port_live "$_pp"; then
      printf '%s\n' "$_pp"
      return 0
    fi
  done
  return 1
}

_proxy_on() {
  _port=$(_pick_port "${1:-}") || {
    printf '没有代理端口在监听（PROXY_PORTS=%s）。\n' "${PROXY_PORTS:-<未设>}" >&2
    printf '代理客户端启动后重试，或用 proxy on <端口> 指定。\n' >&2
    return 1
  }
  export https_proxy="http://127.0.0.1:$_port"
  export http_proxy="$https_proxy"
  export all_proxy="socks5://127.0.0.1:$_port"
  # 大小写都设：Go / npm / 部分 Java 工具只读大写，curl 则刻意忽略 HTTP_PROXY
  export HTTPS_PROXY="$https_proxy"
  export HTTP_PROXY="$http_proxy"
  export ALL_PROXY="$all_proxy"
  export no_proxy="127.0.0.1,localhost"
  export NO_PROXY="$no_proxy"
}

# 公开别名：交互时不用敲下划线
proxy_on() { _proxy_on "$@"; }

proxy_off() {
  unset https_proxy http_proxy all_proxy no_proxy NO_PROXY
  unset HTTPS_PROXY HTTP_PROXY ALL_PROXY
}

proxy() {
  case "${1:-status}" in
    on)
      _want="${2:-}"
      _proxy_on "$_want" || return 1
      [ -n "$_want" ] && ! _port_live "$_want" \
        && printf 'warning: 127.0.0.1:%s 当前没有监听\n' "$_want" >&2
      printf 'proxy ON  %s\n' "$https_proxy"
      ;;
    off)
      proxy_off
      printf 'proxy OFF\n'
      ;;
    status|"")
      if [ -n "${https_proxy:-}" ]; then
        printf 'proxy ON  %s\n' "$https_proxy"
      else
        printf 'proxy OFF\n'
      fi
      _seen=""
      for _pp in $(printf '%s\n' "$PROXY_PORTS"); do
        case " $_seen " in *" $_pp "*) continue ;; esac
        _seen="$_seen $_pp"
        if _port_live "$_pp"; then
          printf '  %s: listening\n' "$_pp"
        else
          printf '  %s: closed\n' "$_pp"
        fi
      done
      ;;
    *)
      printf 'usage: proxy [on [port]|off|status]\n' >&2
      return 1
      ;;
  esac
}

# 启动时：有候选端口在监听就自动开；一个都没有则保持关闭
if _auto_port=$(_pick_port); then
  _proxy_on "$_auto_port"
fi
