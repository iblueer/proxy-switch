#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")/.." && pwd)"

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

export PROXY_SWITCH_HOME="$tmp_root/home"
mkdir -p "$PROXY_SWITCH_HOME/envs"

print -r -- "clash" >| "$PROXY_SWITCH_HOME/choice"

printf '%s\n' \
  'export http_proxy=http://127.0.0.1:7890' \
  'export https_proxy=http://127.0.0.1:7890' \
  >| "$PROXY_SWITCH_HOME/envs/clash.env"
printf '%s' 'export all_proxy=socks5://127.0.0.1:7890' >> "$PROXY_SWITCH_HOME/envs/clash.env"

eval "$("$SCRIPT_DIR/proxy-switch" env --quiet)"

[[ "${all_proxy:-}" == 'socks5://127.0.0.1:7890' ]]
[[ "${ALL_PROXY:-}" == 'socks5://127.0.0.1:7890' ]]

print -r -- "ok"
