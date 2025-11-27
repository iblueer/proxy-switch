#!/usr/bin/env zsh

set -e

INSTALL_DIR="$HOME/.local/bin"
ZSHRC="$HOME/.zshrc"
CONFIG_DIR="$HOME/.proxy-switch"

printf '🗑️  卸载 proxy-switch ...\n'

# 删除可执行文件
if [[ -f "$INSTALL_DIR/proxy-switch" ]]; then
  rm "$INSTALL_DIR/proxy-switch"
  printf '✓ 已删除 %s/proxy-switch\n' "$INSTALL_DIR"
else
  printf 'ℹ️  %s/proxy-switch 不存在\n' "$INSTALL_DIR"
fi

# 从 .zshrc 中移除配置
if [[ -f "$ZSHRC" ]]; then
  # 移除 proxy-switch 自动配置块
  if grep -q "# proxy-switch 自动配置" "$ZSHRC"; then
    sed -i '' '/# proxy-switch 自动配置/,/# proxy-switch 自动配置 END/d' "$ZSHRC"
    printf '✓ 已从 ~/.zshrc 中移除 proxy-switch 配置\n'
  fi
fi

printf '\n✅ 卸载完成！\n'
printf 'ℹ️  配置目录 %s 已保留，如需删除请手动执行:\n' "$CONFIG_DIR"
printf '   rm -rf %s\n' "$CONFIG_DIR"
printf '\n请运行 source ~/.zshrc 或重新打开终端。\n'
