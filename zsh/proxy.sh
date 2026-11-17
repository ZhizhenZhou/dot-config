# 终端代理开关（macOS / Linux 通用，可选组件）
#
# 用法：
#   1. 把 PROXY_PORT 改成你本机代理客户端监听的端口（建议放 ~/.zshenv，本机值不进仓库）
#   2. 在 ~/.zshrc（或 ~/.bashrc）里 source 本文件
#   3. 新开终端：端口在监听就自动开启，没监听则保持关闭
#   4. 需要时手动切换：proxy on / proxy off / proxy status
#
# 只对 source 它的交互式 shell 生效，不影响非交互脚本与 cron。

PROXY_PORT="${PROXY_PORT:-}"   # 在 ~/.zshenv 或 ~/.zshrc 里设置

_proxy_on() {
  if [ -z "$PROXY_PORT" ]; then
    printf 'PROXY_PORT 未设置，无法开启代理。\n' >&2
    return 1
  fi
  export https_proxy="http://127.0.0.1:$PROXY_PORT"
  export http_proxy="$https_proxy"
  export all_proxy="socks5://127.0.0.1:$PROXY_PORT"
  # 大小写都设：Go / npm / 部分 Java 工具只读大写，curl 则刻意忽略 HTTP_PROXY
  export HTTPS_PROXY="$https_proxy"
  export HTTP_PROXY="$http_proxy"
  export ALL_PROXY="$all_proxy"
  export no_proxy="127.0.0.1,localhost"
  export NO_PROXY="$no_proxy"
}

# 公开别名：交互时不用敲下划线
proxy_on() { _proxy_on; }

proxy_off() {
  unset https_proxy http_proxy all_proxy no_proxy NO_PROXY
  unset HTTPS_PROXY HTTP_PROXY ALL_PROXY
}

proxy() {
  case "${1:-status}" in
    on) _proxy_on ;;
    off) proxy_off ;;
    status|"")
      if [ -n "${https_proxy:-}" ]; then
        printf 'proxy ON  %s\n' "$https_proxy"
      else
        printf 'proxy OFF\n'
      fi
      ;;
    *)
      printf 'usage: proxy [on|off|status]\n' >&2
      return 1
      ;;
  esac
}

# 端口确实在监听才自动开；没装 nc 时只定义函数，需要时手动执行 proxy on
if [ -n "$PROXY_PORT" ] && command -v nc >/dev/null 2>&1 \
    && nc -z 127.0.0.1 "$PROXY_PORT" >/dev/null 2>&1; then
  _proxy_on
fi
