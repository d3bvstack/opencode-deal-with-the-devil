#!/usr/bin/env bash
# mk-agents.sh — compose or refresh the generated AGENTS.md at repo_root().
# Every marker-wrapped section is DERIVED from the live harness files (never
# hand-written tables): commands/ (incl. commands/workflow/), skills/, agents/, rules/ and
# tools/*.sh + tools/README.md, plus tools/digest.sh + tools/facts.sh output.
#
# Locations are always relative to this tool's own directory (the _tools_dir
# pattern in lib/common.sh), so it works both at the source repo root
# (tools/../commands) and after deployment (.opencode/tools/../commands).
#
# In-place: only <!-- GEN:init-agents:<section> --> .. <!-- GEN:init-agents:end -->
# blocks are rewritten; anything outside the markers survives. An AGENTS.md that
# exists with NO markers is legacy/hand-written and is refused, never clobbered.
#
# Usage: mk-agents.sh [--refresh]
# Exit: 0 = wrote or refreshed; 1 = legacy AGENTS.md refused; 2 = bad args.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$DIR/lib/common.sh"

case "${1:-}" in
  "" | --refresh) ;;
  *) echo "mk-agents.sh: unknown arg '$1'" >&2; exit 2 ;;
esac
[ "${1:-}" = "--refresh" ] && export REFRESH=1

ROOT="$(repo_root)"
HARNESS="$(_tools_dir)/.."
AGENTS="$ROOT/AGENTS.md"

# --- shared helpers ----------------------------------------------------------

esc() { printf '%s' "$1" | sed 's/|/\\|/g'; }

# Folded value of one frontmatter key (single-line or ">" style).
fm_value() { # <md-file> <key>
  awk -v k="$2" '
    /^---[[:space:]]*$/ { fm++; next }
    fm != 1 { next }
    $0 ~ "^" k ":" && !started {
      sub("^" k ":[[:space:]]*", "")
      val = ($0 ~ /^[>|][[:space:]]*$/ || $0 == "") ? "" : $0
      started = 1
      next
    }
    started {
      if ($0 ~ /^(---|[A-Za-z0-9_.-]+[[:space:]]*:)/) exit
      if ($0 ~ /^[[:space:]]+/) { sub(/^[ \t]+/, ""); val = (val == "") ? $0 : val " " $0 }
      next
    }
    END { if (started && val != "") print val }
  ' "$1"
}

# Tools/README.md table -> "tool<TAB>answers" per data row.
md_table() { # <md-file>
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

# --- sections (each emits ONE marker-wrapped block of inner content) ---------

sec_project_facts() {
  local facts digest langs
  facts="$( (cd "$ROOT" && "$DIR/facts.sh") 2>/dev/null || true )"
  digest="$( (cd "$ROOT" && "$DIR/digest.sh") 2>/dev/null || true )"

  echo '## Project facts'
  echo
  echo 'Every line below is copied verbatim from `tools/facts.sh` + `tools/digest.sh`'
  echo 'output at generation time — nothing invented. Re-run `/init-agents` to refresh.'
  echo
  echo '**Stack / languages** — from `tools/facts.sh` (`## Languages`):'
  printf '%s\n' "$facts" | sed -n '/^## Languages$/{n;p;}' | sed 's/[[:space:]]*$//' | sed 's/^/- /'
  echo
  echo '**Build / test / lint** — from `tools/facts.sh` (`## Build / test / lint`):'
  printf '%s\n' "$facts" | sed -n '/^## Build \/ test \/ lint$/,/^## Entry/{ /^- /p; }'
  echo
  echo '**Quality gates** — from `tools/facts.sh` (`## Quality gates`), run via `tools/quality.sh`:'
  printf '%s\n' "$facts" | sed -n '/^- present:/p;/^- absent (install/p'
  echo
  echo '**Test framework** — from `tools/facts.sh` (`## Test framework`):'
  printf '%s\n' "$facts" | sed -n '/^## Test framework/,/^_Generated/{/^- /p;}'
  echo
  echo '**Heaviest files** — from `tools/digest.sh` → `tools/codemap.sh --summary`:'
  printf '%s\n' "$digest" | sed -n '/^Heaviest files:/,/^_Drill/{/^- /p;}'
  echo
  echo '**Untested source** — from `tools/digest.sh` → `tools/untested.sh --summary`:'
  printf '%s\n' "$digest" | grep -E '^- [0-9]+ of [0-9]+ source files' || true
}

sec_commands() {
  local f did usg desc
  echo '## Commands — one-shot actions (invoked `/name <args>`)'
  echo
  echo '| Command | Does |'
  echo '| --- | --- |'
  for f in "$HARNESS"/commands/*.md; do
    [ -e "$f" ] || continue
    desc="$(fm_value "$f" description)"
    [ -n "$desc" ] || continue
    usg="${desc##*Usage: }"
    did="${desc%% Usage: *}"
    printf '| `%s` | %s |\n' "$(esc "$usg")" "$(esc "$did")"
  done
}

sec_workflows() {
  local f did usg desc
  echo '## Workflows — reusable procedures (invoked `/workflow:<name>`)'
  echo
  echo '| Workflow | Does |'
  echo '| --- | --- |'
  for f in "$HARNESS"/commands/workflow/*.md; do
    [ -e "$f" ] || continue
    desc="$(fm_value "$f" description)"
    [ -n "$desc" ] || continue
    usg="${desc##*Usage: }"
    did="${desc%% Usage: *}"
    printf '| `%s` | %s |\n' "$(esc "${usg#/workflow:}")" "$(esc "$did")"
  done
}

sec_skills() {
  local f name desc trig
  echo '## Skills — auto-firing capabilities'
  echo
  echo '| Skill | Triggers on |'
  echo '| --- | --- |'
  for f in "$HARNESS"/skills/*/SKILL.md; do
    [ -e "$f" ] || continue
    name="$(fm_value "$f" name)"
    desc="$(fm_value "$f" description)"
    trig="${desc#*Auto-triggers on:}"
    trig="${trig# }"
    printf '| `%s` | %s |\n' "$name" "$(esc "$trig")"
  done
}

sec_agents() {
  local f name desc
  echo '## Agents — specialist personas (invoke by name or trigger)'
  echo
  for f in "$HARNESS"/agents/*.md; do
    [ -e "$f" ] || continue
    name="$(basename "$f" .md)"
    desc="$(fm_value "$f" description)"
    printf -- '- **`%s`** — %s\n' "$name" "$(esc "$desc")"
  done
}

sec_rules() {
  local f name desc fm globs uni="" scoped=""
  for f in "$HARNESS"/rules/*.md; do
    [ -e "$f" ] || continue
    name="$(basename "$f" .md)"
    desc="$(fm_value "$f" description)"
    fm="$(awk '/^---[[:space:]]*$/{n++; next} n==1{print}' "$f")"
    if printf '%s\n' "$fm" | grep -q '^alwaysApply: true'; then
      uni="${uni}- \`${name}\` — ${desc}"$'\n'
    else
      globs="$(printf '%s\n' "$fm" | sed -n 's/^globs:[[:space:]]*//p' | tr -d '"[]' | tr ',' ' ' | tr -s ' ')"
      scoped="${scoped}- \`${name}\` (\`${globs}\`) — ${desc}"$'\n'
    fi
  done
  echo '## Rules — durable constraints (applied by scope)'
  echo
  echo '**Always applied (`alwaysApply: true`):**'
  printf '%s' "$uni"
  echo
  echo '**Scoped (`globs`):**'
  printf '%s' "$scoped"
}

sec_tools() {
  local tool ans
  echo '## Tools — the parsing layer (`tools/`, index in `tools/README.md`)'
  echo
  echo '| Tool | Answers |'
  echo '| --- | --- |'
  while IFS=$'\t' read -r tool ans; do
    [ -e "$HARNESS/tools/$tool" ] || continue
    printf '| `%s` | %s |\n' "$tool" "$(esc "$ans")"
  done < <(md_table "$HARNESS/tools/README.md")
  if [ -e "$HARNESS/tools/lib/common.sh" ]; then
    echo '| `lib/common.sh` | shared library the tools are thin glue over (library-first, dogfooded) |'
  fi
}

# --- compose ------------------------------------------------------------

emit_section() { # <id> <builder-fn>
  echo "<!-- GEN:init-agents:$1 -->"
  "$2"
  echo "<!-- GEN:init-agents:end -->"
}

build_agents() {
  cat <<'EOF'
# AGENTS.md — orientation for agents

This repo ships the `.opencode/` harness: rules, commands, skills, workflows,
tools, and agents. The marker-wrapped sections below are regenerated by
`/init-agents` (`tools/mk-agents.sh`) from the LIVE harness files — edit the
source files, not these tables. Anything OUTSIDE the
`<!-- GEN:init-agents:... -->` markers is yours and survives regeneration.

## How to use the opencode tools

These index rows are derived, not hand-maintained. Read the actual file behind a
row before acting — the table only points.

EOF
  emit_section project-facts sec_project_facts
  emit_section commands      sec_commands
  emit_section workflows     sec_workflows
  emit_section skills        sec_skills
  emit_section agents        sec_agents
  emit_section rules         sec_rules
  emit_section tools         sec_tools
}

# --- in-place update ---------------------------------------------------------

# Rewrite only the GEN:init-agents blocks of <file> from the freshly composed
# <doc>, verbatim-preserving everything else. Appends not-yet-present blocks.
install_sections() { # <file> <doc>
  local file="$1" doc="$2" blocks ids id tmp
  blocks="$(mktemp -d)"
  ids="$(printf '%s\n' "$doc" | sed -n 's/^<!-- GEN:init-agents:\([a-z0-9-]*\) -->$/\1/p' | grep -vx 'end' || true)"
  for id in $ids; do
    printf '%s\n' "$doc" | awk -v id="$id" '
      $0 == ("<!-- GEN:init-agents:" id " -->") { c = 1; next }
      c && $0 == "<!-- GEN:init-agents:end -->" { c = 0; next }
      c { print }
    ' > "$blocks/$id"
  done
  tmp="$(mktemp)"
  awk -v bd="$blocks" '
    $0 ~ /^<!-- GEN:init-agents:[a-z0-9-]+ -->$/ && $0 != "<!-- GEN:init-agents:end -->" {
      id = $0; sub(/^<!-- GEN:init-agents:/, "", id); sub(/ -->$/, "", id)
      print $0
      blk = bd "/" id
      if ((getline line < blk) > 0) { do { print line } while ((getline line < blk) > 0) }
      close(blk)
      skip = 1
      next
    }
    skip {
      if ($0 == "<!-- GEN:init-agents:end -->") { print $0; skip = 0 }
      next
    }
    { print }
  ' "$file" > "$tmp"
  for id in $ids; do
    grep -q -- "^<!-- GEN:init-agents:$id -->$" "$tmp" || {
      {
        echo "<!-- GEN:init-agents:$id -->"
        cat "$blocks/$id"
        echo "<!-- GEN:init-agents:end -->"
      } >> "$tmp"
    }
  done
  cat "$tmp" > "$file"
  rm -rf "$blocks" "$tmp"
}

main() {
  local generated
  generated="$(emit_cached agents.md build_agents)"
  if [ -f "$AGENTS" ]; then
    if ! grep -q -- '<!-- GEN:init-agents:' "$AGENTS"; then
      echo "mk-agents.sh: '$AGENTS' has no GEN:init-agents markers — it is hand-written/legacy, not generated." >&2
      echo "Refusing to overwrite it. Remove it, or add the marker blocks, to let /init-agents manage it." >&2
      exit 1
    fi
    install_sections "$AGENTS" "$generated"
    echo "mk-agents.sh: refreshed the GEN:init-agents blocks in $AGENTS (everything else preserved)."
  else
    printf '%s\n' "$generated" > "$AGENTS"
    echo "mk-agents.sh: wrote $AGENTS"
  fi
}

main