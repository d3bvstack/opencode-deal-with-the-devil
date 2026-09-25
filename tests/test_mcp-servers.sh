#!/bin/sh
# Tests for tools/mcp-servers.sh and jsonc_parse (tools/lib/common.sh).
set -eu
DIR="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../tools/lib/common.sh
. "$DIR/tools/lib/common.sh"
TOOL="$DIR/tools/mcp-servers.sh"

TMP="$(mktemp)"
trap 'rm -f "$TMP" "$TMP.full-missing"' EXIT INT TERM

fail() { printf '%s\n' "FAIL: $1" >&2; exit 1; }

test_jsonc_parse() {
  cat >"$TMP" <<'EOF'
{
  // comment
  "mcp": {
    "test": { "enabled": true, "type": "stdio", "url": "https://x.test/y" },
  },
}
EOF
  out="$(jsonc_parse "$TMP" | jq -r '.mcp.test.enabled')"
  [ "$out" = "true" ] || fail "jsonc_parse enabled: expected true, got $out"
  out="$(jsonc_parse "$TMP" | jq -r '.mcp.test.url')"
  [ "$out" = "https://x.test/y" ] || fail "jsonc_parse url: // in string mangled: $out"
  printf '%s\n' "PASS: jsonc_parse strips comments + trailing commas, keeps URLs"
}

test_summary() {
  if out="$(REFRESH=1 bash "$TOOL" --summary)"; then rc=0; else rc=$?; fi
  [ "$rc" = 0 ] || fail "--summary exit: expected 0, got $rc"
  case "$out" in
    *"chrome-devtools"*context7*) ;;
    *) fail "--summary shape: missing known servers: $out" ;;
  esac
  printf '%s\n' "PASS: --summary exit 0 + lists real servers"
}

test_full() {
  if out="$(REFRESH=1 bash "$TOOL")"; then rc=0; else rc=$?; fi
  [ "$rc" = 0 ] || fail "full exit: expected 0, got $rc"
  case "$out" in
    *"# Configured MCP servers"*chrome-devtools*) ;;
    *) fail "full shape: missing header/servers: $out" ;;
  esac
  printf '%s\n' "PASS: full exit 0 + header + servers"
}

test_summary_missing() {
  # REFRESH=1: bypass emit_cached so the builder (not a fresh cache) runs.
  if out="$(MCP_CONFIG_OVERRIDE="$TMP.missing" REFRESH=1 bash "$TOOL" --summary)"; then rc=0; else rc=$?; fi
  [ "$rc" = 0 ] || fail "--summary missing-config exit: expected 0, got $rc"
  case "$out" in
    *"(no "*) ;;
    *) fail "--summary missing-config shape unexpected: $out" ;;
  esac
  printf '%s\n' "PASS: --summary missing-config branch"
}

test_full_missing() {
  rm -f "$TMP.full-missing"
  if out1="$(MCP_CONFIG_OVERRIDE="$TMP.full-missing" REFRESH=1 bash "$TOOL")"; then rc1=0; else rc1=$?; fi
  [ -n "$out1" ] || fail "full missing rebuild: empty stdout (rc=$rc1)"
  case "$out1" in *"not found"*) ;; *) fail "full missing rebuild shape unexpected: $out1" ;; esac
  if out2="$(MCP_CONFIG_OVERRIDE="$TMP.full-missing" bash "$TOOL")"; then rc2=0; else rc2=$?; fi
  [ -n "$out2" ] || fail "full missing cached: empty stdout (rc=$rc2)"
  case "$out2" in *"not found"*) ;; *) fail "full missing cached shape unexpected: $out2" ;; esac
  [ "$rc1" = "$rc2" ] || fail "full missing exit inconsistent: rebuild=$rc1 cached=$rc2"
  [ "$rc1" = 1 ] || fail "full missing exit: expected 1, got $rc1"
  REFRESH=1 bash "$TOOL" >/dev/null
  printf '%s\n' "PASS: full missing-config rebuild + cached agree (rc=$rc1)"
}

test_refresh() {
  if out="$(bash "$TOOL" --summary --refresh)"; then rc=0; else rc=$?; fi
  [ "$rc" = 0 ] || fail "--refresh exit: expected 0, got $rc"
  case "$out" in
    *"chrome-devtools"*) ;;
    *) fail "--refresh shape: missing servers: $out" ;;
  esac
  printf '%s\n' "PASS: --refresh rebuilds cache, exit 0"
}

test_jsonc_parse
test_summary
test_full
test_summary_missing
test_full_missing
test_refresh
printf '%s\n' "ALL PASS: mcp-servers"
