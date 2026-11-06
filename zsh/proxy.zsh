# 终端代理开关（macOS / Linux 通用，可选组件）
#
# 用法：
#   1. 把 PROXY_PORT 改成你本机代理客户端监听的端口
#   2. 追加到 ~/.zshrc 末尾，或在 ~/.zshrc 里 source 本文件
#   3. 新开终端；代理没启动时不会自动打开，需要时手动执行 _proxy_on
#
# 只影响交互式 zsh，不影响 sh/bash 脚本与 cron。

PROXY_PORT="${PROXY_PORT:-}"   # 例：7897

_proxy_on() {
  export https_proxy="http://127.0.0.1:$PROXY_PORT"
  export http_proxy="$https_proxy"
  export all_proxy="socks5://127.0.0.1:$PROXY_PORT"
  export no_proxy="127.0.0.1,localhost"
  export NO_PROXY="$no_proxy"
}

proxy_off() {
  unset https_proxy http_proxy all_proxy no_proxy NO_PROXY
}

# 端口确实在监听才自动开；没装 nc 时只定义函数，需要时手动 _proxy_on
if [ -n "$PROXY_PORT" ] && command -v nc >/dev/null 2>&1 \
    && nc -z 127.0.0.1 "$PROXY_PORT" >/dev/null 2>&1; then
  _proxy_on
fi
