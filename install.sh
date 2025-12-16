#!/usr/bin/env zsh

set -e

SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
ZSHRC="$HOME/.zshrc"
ENVS_DIR="$HOME/.proxy-switch/envs"
SNIPPET_MARKER="# proxy-switch 自动配置"

printf '📦 安装 proxy-switch ...\n'

mkdir -p "$INSTALL_DIR"
mkdir -p "$ENVS_DIR"

cp "$SCRIPT_DIR/proxy-switch" "$INSTALL_DIR/proxy-switch"
chmod +x "$INSTALL_DIR/proxy-switch"

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  printf '📝 PATH 中缺少 %s ，将写入 ~/.zshrc\n' "$INSTALL_DIR"
  {
    echo ''
    echo '# proxy-switch bin 路径'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
  } >> "$ZSHRC"
else
  printf 'ℹ️  PATH 已包含 %s\n' "$INSTALL_DIR"
fi

if grep -q "$SNIPPET_MARKER" "$ZSHRC" 2>/dev/null; then
  printf '🔄 检测到旧配置，正在更新...\n'
  sed -i '' '/# proxy-switch 自动配置/,/# proxy-switch 自动配置 END/d' "$ZSHRC"
fi

printf '🧩 写入 shell 启动配置...\n'
{
  echo ''
  echo "$SNIPPET_MARKER"
  echo 'if command -v proxy-switch >/dev/null 2>&1; then'
  echo '  eval "$(proxy-switch env --quiet)"'
  echo '  # 定义包装函数，在 use/off 后自动应用环境变量'
  echo '  proxy-switch() {'
  echo '    command proxy-switch "$@"'
  echo '    local ret=$?'
  echo '    case "${1:-}" in'
  echo '      use|off)'
  echo '        eval "$(command proxy-switch env --quiet)"'
  echo '        ;;'
  echo '    esac'
  echo '    return $ret'
  echo '  }'
  echo 'fi'
  echo '# proxy-switch 自动配置 END'
} >> "$ZSHRC"

# 创建默认的 env 文件（如果不存在）
if [[ ! -f "$ENVS_DIR/surge.env" ]]; then
  printf '📝 创建默认 surge.env 配置...\n'
  cat > "$ENVS_DIR/surge.env" <<'EOF'
export http_proxy=http://127.0.0.1:6152
export https_proxy=http://127.0.0.1:6152
export all_proxy=socks5://127.0.0.1:6153
EOF
fi

if [[ ! -f "$ENVS_DIR/clash.env" ]]; then
  printf '📝 创建默认 clash.env 配置...\n'
  cat > "$ENVS_DIR/clash.env" <<'EOF'
export http_proxy=http://127.0.0.1:8234
export https_proxy=http://127.0.0.1:8234
export all_proxy=socks5://127.0.0.1:8235
EOF
fi

printf '\n✅ 安装完成！\n'
printf '   运行: proxy-switch show  查看当前状态\n'
printf '   可用: proxy-switch use <env> | off | show | list | env\n'
printf '\n重新加载 shell 以应用配置: source ~/.zshrc\n'
