#!/usr/bin/env bash
# mk-agents.sh — compose, refresh, or verify AGENTS.md at repo_root().
#
# Generates marker-wrapped sections from the live harness files:
# commands/, skills/, agents/, rules/, tools/, facts.sh, and digest.sh.
#
# Usage:
#   mk-agents.sh              # Update or create AGENTS.md
#   mk-agents.sh --refresh    # Refresh existing marker blocks
#   mk-agents.sh --check      # CI mode: exit 0 if up-to-date, 1 if drift detected
#   mk-agents.sh --adopt      # Migrate legacy AGENTS.md without markers into harness
#
# Exit codes:
#   0: Success (or in-sync for --check)
#   1: Legacy file refused / Drift detected in --check
#   2: Invalid arguments / Environment failure
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$DIR/lib/common.sh"

MODE="update"
case "${1:-}" in
  "") MODE="update" ;;
  --refresh) MODE="refresh"; export REFRESH=1 ;;
  --check)   MODE="check" ;;
  --adopt)   MODE="adopt" ;;
  -h|--help)
    sed -n '2,15p' "$0" | sed 's/^# \?//'
    exit 0
    ;;
  *) echo "mk-agents.sh: unknown arg '$1' (use --help)" >&2; exit 2 ;;
esac

ROOT="$(repo_root)"
HARNESS="$(_tools_dir)/.."
AGENTS="$ROOT/AGENTS.md"

# Safe temp cleanup on any exit
TMP_DIRS=()
cleanup() {
  for d in "${TMP_DIRS[@]}"; do
    [ -d "$d" ] && rm -rf "$d"
  done
}
trap cleanup EXIT INT TERM

# --- Text & YAML Sanitization Helpers ---------------------------------------

# Escape markdown table characters and collapse newlines into spaces
esc() {
  printf '%s' "$1" | tr '\n' ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/|/\\|/g'
}

# Clean leading/trailing quotes from parsed yaml scalars
unquote() {
  sed -e 's/^[[:space:]]*["'"'"']//' -e 's/["'"'"'][[:space:]]*$//'
}

# Robust frontmatter value extractor (handles single-line, folded, and strips quotes)
fm_value() { # <file> <key>
  awk -v k="$2" '
    /^---[[:space:]]*$/ { fm++; next }
    fm != 1 { next }
    $0 ~ "^" k ":[[:space:]]*" && !started {
      sub("^" k ":[[:space:]]*", "")
      val = ($0 ~ /^[>|][[:space:]]*$/ || $0 == "") ? "" : $0
      started = 1
      next
    }
    started {
      if ($0 ~ /^(---|[A-Za-z0-9_.-]+[[:space:]]*:)/) exit
      if ($0 ~ /^[[:space:]]+/) {
        sub(/^[ \t]+/, "")
        val = (val == "") ? $0 : val " " $0
      }
      next
    }
    END { if (started && val != "") print val }
  ' "$1" | unquote
}

# Extract globs supporting both inline `["a", "b"]` and multiline `- "a"` styles
fm_globs() { # <file>
  awk '
    /^---[[:space:]]*$/ { fm++; next }
    fm != 1 { next }
    /^globs:[[:space:]]*$/ { in_globs=1; next }
    /^globs:[[:space:]]*\[/ {
      sub(/^globs:[[:space:]]*\[/, "")
      sub(/\].*$/, "")
      gsub(/["'"'"']/, "")
      gsub(/,[[:space:]]*/, " ")
      print
      exit
    }
    in_globs {
      if ($0 ~ /^[[:space:]]*-[[:space:]]*/) {
        sub(/^[[:space:]]*-[[:space:]]*/, "")
        gsub(/["'"'"']/, "")
        printf "%s ", $0
      } else {
        exit
      }
    }
    END { printf "\n" }
  ' "$1" | sed 's/[[:space:]]*$//'
}

# Tools/README.md table parser
md_table() { # <file>
  [ -f "$1" ] || return 0
  awk -F'|' '
    /^\|/ {
      s = $0; sub(/^\|[[:space:]]*/, "", s)
      n = split(s, c, "|")
      if (n < 2) next
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", c[1])
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", c[2])
      gsub(/`/, "", c[1])
      if (c[1] == "" || c[1] == "Tool" || c[1] ~ /^[-: ]+$/) next
      print c[1] "\t" c[2]
    }
  ' "$1"
}

# --- Section Generators -----------------------------------------------------

sec_project_facts() {
  local facts="" digest=""
  [ -x "$DIR/facts.sh" ] && facts="$( (cd "$ROOT" && "$DIR/facts.sh") 2>/dev/null || true )"
  [ -x "$DIR/digest.sh" ] && digest="$( (cd "$ROOT" && "$DIR/digest.sh") 2>/dev/null || true )"

  echo '## Project facts'
  echo
  echo 'Generated dynamically by `tools/facts.sh` and `tools/digest.sh`. Re-run `/init-agents` to refresh.'
  echo

  echo '**Stack / languages**:'
  local langs
  langs="$(printf '%s\n' "$facts" | sed -n '/^## Languages$/,/^##/{ /^- /p; }')"
  [ -n "$langs" ] && echo "$langs" || echo "- None detected"
  echo

  echo '**Build / test / lint**:'
  local btl
  btl="$(printf '%s\n' "$facts" | sed -n '/^## Build \/ test \/ lint$/,/^##/{ /^- /p; }')"
  [ -n "$btl" ] && echo "$btl" || echo "- Run configurations not detected in manifests"
  echo

  echo '**Quality gates** (run via `tools/quality.sh`):'
  local qg
  qg="$(printf '%s\n' "$facts" | sed -n '/^- present:/p;/^- absent (install/p')"
  [ -n "$qg" ] && echo "$qg" || echo "- Standard linters/formatters not detected"
  echo

  echo '**Test framework**:'
  local tf
  tf="$(printf '%s\n' "$facts" | sed -n '/^## Test framework/,/^##/{/^- /p;}' | grep -v '^_Generated' || true)"
  [ -n "$tf" ] && echo "$tf" || echo "- Test runner not detected"
  echo

  echo '**Untested source**:'
  local ut
  ut="$(printf '%s\n' "$digest" | grep -E '^- [0-9]+ of [0-9]+ source files' || true)"
  [ -n "$ut" ] && echo "$ut" || echo "- No test gap summary available"
}

sec_commands() {
  local f did usg desc name has_entries=0
  echo '## Commands — one-shot actions (invoked `/name <args>`)'
  echo
  echo '| Command | Does |'
  echo '| --- | --- |'
  for f in "$HARNESS"/commands/*.md; do
    [ -e "$f" ] || continue
    name="$(basename "$f" .md)"
    desc="$(fm_value "$f" description)"
    [ -n "$desc" ] || continue

    if [[ "$desc" == *"Usage: "* ]]; then
      usg="${desc##*Usage: }"
      did="${desc%% Usage: *}"
    else
      usg="/$name"
      did="$desc"
    fi
    printf '| `%s` | %s |\n' "$(esc "$usg")" "$(esc "$did")"
    has_entries=1
  done
  [ "$has_entries" -eq 1 ] || echo '| *None* | No custom commands discovered in `commands/` |'
}

sec_workflows() {
  local f did usg desc name has_entries=0
  echo '## Workflows — multi-step operational procedures'
  echo
  echo '| Workflow | Does |'
  echo '| --- | --- |'
  for f in "$HARNESS"/commands/workflow/*.md; do
    [ -e "$f" ] || continue
    name="$(basename "$f" .md)"
    desc="$(fm_value "$f" description)"
    [ -n "$desc" ] || continue

    if [[ "$desc" == *"Usage: "* ]]; then
      usg="${desc##*Usage: }"
      did="${desc%% Usage: *}"
      usg="${usg#/workflow:}"
    else
      usg="/workflow:$name"
      did="$desc"
    fi
    printf '| `%s` | %s |\n' "$(esc "$usg")" "$(esc "$did")"
    has_entries=1
  done
  [ "$has_entries" -eq 1 ] || echo '| *None* | No workflows discovered in `commands/workflow/` |'
}

sec_skills() {
  local f name desc trig has_entries=0
  echo '## Skills — auto-firing capabilities'
  echo
  echo '| Skill | Triggers on |'
  echo '| --- | --- |'
  for f in "$HARNESS"/skills/*/SKILL.md; do
    [ -e "$f" ] || continue
    name="$(fm_value "$f" name)"
    [ -n "$name" ] || name="$(basename "$(dirname "$f")")"
    desc="$(fm_value "$f" description)"

    if [[ "$desc" == *"Auto-triggers on:"* ]]; then
      trig="${desc#*Auto-triggers on:}"
      trig="${trig# }"
    else
      trig="${desc:-Explicit invocation}"
    fi
    printf '| `%s` | %s |\n' "$(esc "$name")" "$(esc "$trig")"
    has_entries=1
  done
  [ "$has_entries" -eq 1 ] || echo '| *None* | No skills discovered in `skills/` |'
}

sec_agents() {
  local f name desc has_entries=0
  echo '## Agents — specialist personas'
  echo
  for f in "$HARNESS"/agents/*.md; do
    [ -e "$f" ] || continue
    name="$(basename "$f" .md)"
    desc="$(fm_value "$f" description)"
    printf -- '- **`%s`** — %s\n' "$name" "$(esc "${desc:-Specialist agent}")"
    has_entries=1
  done
  [ "$has_entries" -eq 1 ] || echo '- *No specialized agents registered.*'
}

sec_rules() {
  local f name desc fm globs uni="" scoped=""
  for f in "$HARNESS"/rules/*.md; do
    [ -e "$f" ] || continue
    name="$(basename "$f" .md)"
    desc="$(fm_value "$f" description)"
    fm="$(awk '/^---[[:space:]]*$/{n++; next} n==1{print}' "$f")"

    if printf '%s\n' "$fm" | grep -q '^alwaysApply:[[:space:]]*true'; then
      uni="${uni}- \`${name}\` — $(esc "${desc:-Enforced globally}")"$'\n'
    else
      globs="$(fm_globs "$f")"
      [ -n "$globs" ] || globs="*"
      scoped="${scoped}- \`${name}\` (\`${globs}\`) — $(esc "${desc:-Scoped rule}")"$'\n'
    fi
  done

  echo '## Rules — durable constraints'
  echo
  echo '**Always applied (`alwaysApply: true`):**'
  [ -n "$uni" ] && printf '%s' "$uni" || echo '- *None registered*'
  echo
  echo '**Scoped (`globs`):**'
  [ -n "$scoped" ] && printf '%s' "$scoped" || echo '- *None registered*'
}

sec_tools() {
  local tool ans has_entries=0
  echo '## Tools — repository inspection layer (`tools/`)'
  echo
  echo '| Tool | Answers |'
  echo '| --- | --- |'
  if [ -f "$HARNESS/tools/README.md" ]; then
    while IFS=$'\t' read -r tool ans; do
      [ -e "$HARNESS/tools/$tool" ] || continue
      printf '| `%s` | %s |\n' "$tool" "$(esc "$ans")"
      has_entries=1
    done < <(md_table "$HARNESS/tools/README.md")
  fi
  if [ -e "$HARNESS/tools/lib/common.sh" ]; then
    echo '| `lib/common.sh` | Shared shell library for repo parsing |'
    has_entries=1
  fi
  [ "$has_entries" -eq 1 ] || echo '| *None* | No tools registered in `tools/README.md` |'
}

# --- Core Composition -------------------------------------------------------

emit_section() {
  echo "<!-- GEN:init-agents:$1 -->"
  "$2"
  echo "<!-- GEN:init-agents:end -->"
}

build_agents() {
  cat <<'EOF'
# AGENTS.md — orientation for agents

This repo ships the `.opencode/` harness. Sections bounded by
`<!-- GEN:init-agents:<id> --> ... <!-- GEN:init-agents:end -->` are dynamically
compiled from harness manifests. User-defined sections outside markers survive refresh.

EOF
  emit_section project-facts sec_project_facts
  emit_section commands      sec_commands
  emit_section workflows     sec_workflows
  emit_section skills        sec_skills
  emit_section agents        sec_agents
  emit_section rules         sec_rules
  emit_section tools         sec_tools
}

# --- Safe In-Place Assembly -------------------------------------------------

install_sections() { # <file> <doc>
  local file="$1" doc="$2"
  local blocks_dir ids id tmp_out
  
  blocks_dir="$(mktemp -d)"
  TMP_DIRS+=("$blocks_dir")

  # Split generated document into individual section payload files
  ids="$(printf '%s\n' "$doc" | sed -n 's/^<!-- GEN:init-agents:\([a-z0-9-]*\) -->$/\1/p' | grep -vx 'end' || true)"
  for id in $ids; do
    printf '%s\n' "$doc" | awk -v id="$id" '
      $0 == ("<!-- GEN:init-agents:" id " -->") { c = 1; next }
      c && $0 == "<!-- GEN:init-agents:end -->" { c = 0; next }
      c { print }
    ' > "$blocks_dir/$id"
  done

  tmp_out="$(mktemp)"
  TMP_DIRS+=("$tmp_out")

  # Stream update file with safety guard: prevent unbounded skipping if end-marker is lost
  awk -v bd="$blocks_dir" '
    /^<!-- GEN:init-agents:[a-z0-9-]+ -->$/ && $0 !~ /:end -->$/ {
      id = $0
      sub(/^<!-- GEN:init-agents:/, "", id)
      sub(/ -->$/, "", id)
      print $0
      blk = bd "/" id
      if ((getline line < blk) > 0) {
        do { print line } while ((getline line < blk) > 0)
      }
      close(blk)
      skip = 1
      found_end = 0
      next
    }
    skip {
      if ($0 == "<!-- GEN:init-agents:end -->") {
        print $0
        skip = 0
        found_end = 1
      } else if ($0 ~ /^<!-- GEN:init-agents:[a-z0-9-]+ -->$/) {
        # Defensive catch: hit another marker before seeing end. Force-close previous block.
        print "<!-- GEN:init-agents:end -->"
        print $0
        skip = 0
      }
      next
    }
    { print }
    END {
      if (skip) {
        # File ended while still in skip mode. Append closing marker.
        print "<!-- GEN:init-agents:end -->"
      }
    }
  ' "$file" > "$tmp_out"

  # Append any missing sections not currently present in target file
  for id in $ids; do
    if ! grep -q -- "^<!-- GEN:init-agents:$id -->$" "$tmp_out"; then
      {
        echo ""
        echo "<!-- GEN:init-agents:$id -->"
        cat "$blocks_dir/$id"
        echo "<!-- GEN:init-agents:end -->"
      } >> "$tmp_out"
    fi
  done

  # Atomically update file
  cat "$tmp_out" > "$file"
}

# --- Controller -------------------------------------------------------------

main() {
  local generated
  # Bypass emit_cached to ensure fresh builds on --refresh
  if [ "$MODE" = "refresh" ] || [ ! -e "$AGENTS" ]; then
    generated="$(build_agents)"
  else
    generated="$(emit_cached agents.md build_agents 2>/dev/null || build_agents)"
  fi

  if [ ! -f "$AGENTS" ]; then
    printf '%s\n' "$generated" > "$AGENTS"
    echo "mk-agents.sh: created $AGENTS"
    exit 0
  fi

  # Check for marker presence
  if ! grep -q -- '<!-- GEN:init-agents:' "$AGENTS"; then
    if [ "$MODE" = "adopt" ]; then
      echo "mk-agents.sh: adopting legacy $AGENTS (wrapping existing content and appending markers)..."
      local backup="${AGENTS}.legacy"
      cp "$AGENTS" "$backup"
      echo "mk-agents.sh: original file backed up to $backup"
      # Append harness blocks to the end of legacy file
      printf '\n\n%s\n' "$generated" >> "$AGENTS"
      echo "mk-agents.sh: successfully adopted $AGENTS"
      exit 0
    else
      echo "mk-agents.sh: '$AGENTS' lacks GEN:init-agents markers (handwritten/legacy)." >&2
      echo "Refusing to overwrite. Run 'mk-agents.sh --adopt' to safely append harness sections." >&2
      exit 1
    fi
  fi

  if [ "$MODE" = "check" ]; then
    local check_tmp
    check_tmp="$(mktemp)"
    TMP_DIRS+=("$check_tmp")
    cp "$AGENTS" "$check_tmp"
    install_sections "$check_tmp" "$generated"
    if ! diff -u "$AGENTS" "$check_tmp" >&2; then
      echo "mk-agents.sh: AGENTS.md is out of sync with live harness. Run '/init-agents --refresh'." >&2
      exit 1
    fi
    echo "mk-agents.sh: AGENTS.md is up to date."
    exit 0
  fi

  install_sections "$AGENTS" "$generated"
  echo "mk-agents.sh: refreshed GEN:init-agents blocks in $AGENTS (custom content preserved)."
}

main