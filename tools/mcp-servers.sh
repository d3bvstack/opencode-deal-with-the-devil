#!/usr/bin/env bash
# mcp-servers.sh — list configured MCP servers from opencode.jsonc.
# Thin glue over lib/common.sh; emits markdown for agents.
#
# Usage: mcp-servers.sh [--summary] [--refresh]
#   MCP_CONFIG_OVERRIDE: explicit config path (test seam for the
#   missing-config branch; production callers never set it).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$DIR/lib/common.sh"

MODE=full
for a in "$@"; do case "$a" in
  --summary) MODE=summary ;;
  --refresh) export REFRESH=1 ;;
  *) printf 'mcp-servers.sh: unknown arg %s\n' "$a" >&2; exit 2 ;;
esac; done

# Config lives at <repo>/.opencode/opencode.jsonc when the harness is a
# subdir, or at <repo>/opencode.jsonc when the harness itself is the repo
# (repo_root == .opencode dir); the DIR-anchored check is CWD-independent.
resolve_config() {
  local r="$1"
  if [ -f "$r/.opencode/opencode.jsonc" ]; then
    printf '%s\n' "$r/.opencode/opencode.jsonc"
  elif [ -f "$r/opencode.jsonc" ]; then
    printf '%s\n' "$r/opencode.jsonc"
  elif [ -f "$DIR/../opencode.jsonc" ]; then
    printf '%s\n' "$DIR/../opencode.jsonc"
  else
    printf '%s\n' "$r/.opencode/opencode.jsonc"
  fi
}

CONFIG_FILE="${MCP_CONFIG_OVERRIDE:-$(resolve_config "$(repo_root)")}"

build_full_header() {
  printf '# Configured MCP servers\n\n'
  printf 'Source: `.opencode/opencode.jsonc`\n\n'
}

build_full_missing() {
  printf -- '- ❌ `.opencode/opencode.jsonc` not found at `%s`\n\n' "$(repo_root)"
  printf '_No MCP servers configured._\n'
}

build_full_items() {
  local path="$1"
  jsonc_parse "$path" | jq -r '
    .mcp // {} | to_entries[] |
    "- **\(.key)** (\(.value.type // "N/A")) — enabled: `\(.value.enabled // "N/A")`" +
    (if .value.url and .value.url != "N/A" then "\n  - url: `\(.value.url)`" else "" end) +
    (if .value.command and (.value.command | length) > 0 then "\n  - command: `\(.value.command | join(" "))`" else "" end)
  ' 2>/dev/null || printf -- '- (none configured)\n'
}

build_full() {
  local path="$CONFIG_FILE"
  build_full_header
  if [ ! -f "$path" ]; then
    build_full_missing
    return 1
  fi
  build_full_items "$path"
}

build_summary_header() {
  printf '## MCP servers\n'
}

build_summary_items() {
  local path="$1"
  if [ ! -f "$path" ]; then
    printf -- '- (no `.opencode/opencode.jsonc`)\n'
    return
  fi
  jsonc_parse "$path" | jq -r '
    .mcp // {} | to_entries[] |
    "- \(.key) (\(.value.type // "N/A"), enabled=\(.value.enabled // "N/A"))"
  ' 2>/dev/null || printf -- '- none\n'
}

build_summary() {
  local path="$CONFIG_FILE"
  build_summary_header
  if [ ! -f "$path" ]; then
    printf -- '- (no `.opencode/opencode.jsonc`)\n'
    return
  fi
  build_summary_items "$path"
}

case "$MODE" in
  summary) emit_cached mcp-servers.summary.md build_summary ;;
  full)    emit_cached mcp-servers.md build_full ;;
esac
