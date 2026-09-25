#!/usr/bin/env bash
# common.sh — shared helpers for .opencode/tools/*.
# Source it; never execute it. This is the project library for the tools:
# every tool stays thin glue over these functions (see rules/library-first.md).

set -euo pipefail

# --- capability probes ------------------------------------------------------

have() { command -v "$1" >/dev/null 2>&1; }

# --- locations --------------------------------------------------------------

# Root of the repo being analyzed: CWD's git toplevel, else CWD.
repo_root() { git rev-parse --show-toplevel 2>/dev/null || pwd; }

# Directory holding the tools (.opencode/tools), resolved from this file.
_tools_dir() { cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd; }

# Cache lives at .opencode/cache — next to the tools, so it survives any CWD.
cache_dir() {
  local d; d="$(_tools_dir)/../cache"
  mkdir -p "$d"
  (cd "$d" && pwd)
}

# --- caching ----------------------------------------------------------------

_sum() { if have md5sum; then md5sum; else cksum; fi | cut -d' ' -f1; }

# Fingerprint of repo state: HEAD + dirty tree + tool code contents. Any
# change => caches are stale. Tool edits must invalidate even when
# .opencode/ is untracked: git status reports paths, never file contents.
_repo_stamp() {
  {
    if git rev-parse HEAD >/dev/null 2>&1; then
      git rev-parse HEAD
      git status --porcelain -uall 2>/dev/null
    else
      date +%Y%m%d%H   # hourly bucket for non-git trees
    fi
    find "$(_tools_dir)" -type f -print0 | sort -z | xargs -0 md5sum
  } | _sum
}

cache_fresh() {
  local cache="$1" stamp="$1.stamp"
  [ -s "$cache" ] && [ -f "$stamp" ] || return 1
  [ "$(_repo_stamp)" = "$(cat "$stamp")" ]
}

# emit_cached <cache-basename> <builder-fn> [args...]
# Prints the cache when fresh (unless REFRESH=1); otherwise rebuilds + caches.
# Propagates the builder exit code on both paths (stored in <cache>.rc) so a
# failing builder (e.g. missing-config full mode, rc=1) still prints its
# message to the caller and rebuild agrees with the cached read.
emit_cached() {
  local name="$1"; shift
  local builder="$1"; shift
  local cache; cache="$(cache_dir)/$name"
  local rc=0
  if [ "${REFRESH:-0}" != "1" ] && cache_fresh "$cache"; then
    cat "$cache"
    rc="$(cat "$cache.rc" 2>/dev/null || printf '0')"
    case "$rc" in ''|*[!0-9]*) rc=0 ;; esac
    return "$rc"
  fi
  rc=0
  "$builder" "$@" >"$cache" || rc=$?
  printf '%s\n' "$rc" >"$cache.rc"
  _repo_stamp >"$cache.stamp"
  cat "$cache"
  return "$rc"
}

# --- source inventory -------------------------------------------------------

# Repo-relative paths of tracked files (respects .gitignore), else a pruned find.
list_files() {
  local root; root="$(repo_root)"
  if git -C "$root" rev-parse >/dev/null 2>&1; then
    git -C "$root" ls-files
  else
    find "$root" -type f \
      -not -path '*/.git/*'   -not -path '*/node_modules/*' \
      -not -path '*/target/*' -not -path '*/vendor/*' \
      -not -path '*/dist/*'   -not -path '*/build/*' \
      -printf '%P\n'
  fi
}

# Does a file exist at the repo root?
manifest() { [ -f "$(repo_root)/$1" ]; }

# Does any tracked file carry one of these extensions? (regex alternation, no dots)
has_ext() { list_files | grep -qiE "\.($1)$"; }

# Language of a path by extension; empty string for unknown.
lang_of() {
  case "$1" in
    *.c|*.h)                echo c ;;
    *.go)                   echo go ;;
    *.rs)                   echo rust ;;
    *.ts|*.tsx)             echo typescript ;;
    *.js|*.jsx|*.mjs|*.cjs) echo javascript ;;
    *.py)                   echo python ;;
    *.sh|*.bash)            echo shell ;;
    *.sql)                  echo sql ;;
    *.proto)                echo proto ;;
    *.md)                   echo markdown ;;
    *)                      echo "" ;;
  esac
}

# True for source code; false for docs/unknown.
is_code() {
  case "$(lang_of "$1")" in
    ""|markdown) return 1 ;;
    *)           return 0 ;;
  esac
}

is_test_file() {
  local p b
  case "$1" in
    /*) p="$1" ;;
    *)  p="/$1" ;;
  esac
  b="${p##*/}"
  case "$b" in
    *_test.go|*_test.rs|*_test.py|test_*.py)            return 0 ;;
    *.test.ts|*.test.tsx|*.test.js|*.spec.ts|*.spec.js) return 0 ;;
  esac
  case "$p" in
    */tests/*|*/test/*|*/__tests__/*|*/spec/*)          return 0 ;;
  esac
  return 1
}

loc() { wc -l <"$1" 2>/dev/null | tr -d ' ' || echo 0; }

# Best-effort top-level symbol matches (regex, not AST — ponytail: good enough
# to navigate; the agent reads the real file before editing).
symbols_of() {
  local f="$1" pat
  case "$(lang_of "$f")" in
    go)                    pat='^func (\([^)]*\) )?[A-Za-z]|^type [A-Za-z]' ;;
    rust)                  pat='^[[:space:]]*pub (fn|struct|enum|trait|mod) ' ;;
    c)                     pat='^[A-Za-z_].*[A-Za-z_*)][[:space:]]*\(' ;;
    typescript|javascript) pat='^export (default )?(async )?(function|class|const|interface|type|enum) ' ;;
    python)                pat='^(def|class) ' ;;
    shell)                 pat='^[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)' ;;
    *)                     return 0 ;;
  esac
  grep -E "$pat" "$f" 2>/dev/null || true
}

symbol_count() { symbols_of "$1" | grep -c . || true; }
