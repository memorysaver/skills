#!/usr/bin/env bash
# link-skills.sh — regenerate per-skill discovery symlinks for this repo.
#
# Source of truth: skills/<group>/<skill>/SKILL.md   (grouped, mirrors
# .claude-plugin/marketplace.json plugin layout).
# Discovery surface (this script writes):
#   .claude/skills/<skill> -> ../../skills/<group>/<skill>
#   .agents/skills/<skill> -> ../../skills/<group>/<skill>
#
# Why per-skill symlinks instead of a single passthrough? Claude Code and
# agents.md-compatible scanners only read the first level of
# .claude/skills/<skill>/SKILL.md. With grouped sources, the SKILL.md is two
# levels deep, so the top-level passthrough symlink hides the skills from
# project-local discovery. Per-skill symlinks flatten the discovery surface
# while keeping the grouped source-of-truth intact.
#
# This is a deliberate deviation from the single-symlink invariant in the
# canonical-skills skill — see AGENTS.md for the rationale.
#
# Idempotent. Safe to re-run. Use --dry-run to preview.

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: bash scripts/link-skills.sh [OPTIONS]

Regenerate per-skill discovery symlinks under .claude/skills/ and .agents/skills/
from the grouped source tree at skills/<group>/<skill>/.

Options:
  --dry-run    Preview actions without modifying anything
  --help       Show this message

Behavior:
  - Discovers every skills/*/*/SKILL.md (grouped) or skills/*/SKILL.md (flat).
  - Refuses if two skills share a leaf name (would collide at the flat surface).
  - Replaces a top-level passthrough symlink (.claude/skills -> ../skills) with
    a real directory; mirrors the same for .agents/skills.
  - For each skill, ensures both <runtime>/skills/<skill> -> <relative path into
    skills/<group>/<skill>> exists with the right target.
  - Removes stale symlinks (broken or no-longer-discovered names). Refuses to
    touch non-symlink entries inside the discovery dirs.
  - When run in a git repo, git-adds resulting symlinks so the change appears
    in the diff.
HELP
}

DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --help|-h) show_help; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; echo "Run with --help for usage." >&2; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
SKILLS_DIR="$REPO_ROOT/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "ERROR: no skills/ directory at $SKILLS_DIR" >&2
  exit 1
fi

is_git_repo() {
  git -C "$REPO_ROOT" rev-parse --git-dir >/dev/null 2>&1
}

GIT_REPO=no
if is_git_repo; then GIT_REPO=yes; fi

CHANGES=0
REFUSED=0

note() { echo "  $1"; }
plan() { echo "  Would $1"; }

# --- Step 1: discover skills ---

# Outputs lines: "<skill-name>\t<relative-source-path-from-repo-root>"
# Supports both grouped (skills/<group>/<skill>) and flat (skills/<skill>).
discover_skills() {
  local skill_md
  while IFS= read -r skill_md; do
    [ -z "$skill_md" ] && continue
    local dir name rel
    dir="$(dirname "$skill_md")"
    name="$(basename "$dir")"
    rel="${dir#"$REPO_ROOT"/}"
    printf '%s\t%s\n' "$name" "$rel"
  done < <(find "$SKILLS_DIR" -mindepth 2 -maxdepth 3 -name SKILL.md -type f 2>/dev/null | sort)
}

echo "link-skills"
echo "  repo: $REPO_ROOT"
[ "$DRY_RUN" = true ] && echo "  mode: dry-run"
echo ""

echo "Step 1: discover skills"
DISCOVERED="$(discover_skills)"

if [ -z "$DISCOVERED" ]; then
  note "no skills found under skills/ (expected skills/<group>/<skill>/SKILL.md or skills/<skill>/SKILL.md)"
else
  while IFS=$'\t' read -r name rel; do
    note "found: $name → $rel"
  done <<< "$DISCOVERED"
fi
echo ""

# --- Step 2: name-uniqueness check ---

echo "Step 2: check for duplicate skill names"
DUP_REPORT=""
if [ -n "$DISCOVERED" ]; then
  DUP_REPORT="$(awk -F'\t' '{print $1}' <<< "$DISCOVERED" | sort | uniq -d || true)"
fi

if [ -n "$DUP_REPORT" ]; then
  echo "  REFUSE: duplicate skill names across groups (would collide at .claude/skills/<name>):" >&2
  while IFS= read -r dup; do
    [ -z "$dup" ] && continue
    echo "    - $dup" >&2
    awk -F'\t' -v n="$dup" '$1==n {print "        in: " $2}' <<< "$DISCOVERED" >&2
  done <<< "$DUP_REPORT"
  echo "  Rename one of the conflicting skills, then re-run." >&2
  REFUSED=$((REFUSED + 1))
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "aborted — see refusals above"
  exit 3
fi
note "OK — no duplicates"
echo ""

# --- Step 3: ensure discovery dirs ---

ensure_discovery_dir() {
  local label="$1"
  local dir_rel="$2"
  local dir_abs="$REPO_ROOT/$dir_rel"
  local parent_rel
  parent_rel="$(dirname "$dir_rel")"
  local parent_abs="$REPO_ROOT/$parent_rel"

  echo "$label"

  if [ -L "$dir_abs" ]; then
    # Passthrough symlink (likely → ../skills). Remove it; recreate as real dir.
    local target
    target="$(readlink "$dir_abs")"
    if [ "$DRY_RUN" = true ]; then
      plan "remove passthrough symlink $dir_rel → $target and recreate as real directory"
    else
      ( cd "$parent_abs" && rm "$(basename "$dir_rel")" )
      mkdir -p "$dir_abs"
      [ "$GIT_REPO" = "yes" ] && ( cd "$REPO_ROOT" && git add -A "$dir_rel" >/dev/null 2>&1 || true )
      note "removed passthrough symlink $dir_rel → $target; created real dir"
    fi
    CHANGES=$((CHANGES + 1))
  elif [ -d "$dir_abs" ]; then
    note "OK — $dir_rel is a real directory"
  elif [ ! -e "$dir_abs" ]; then
    if [ "$DRY_RUN" = true ]; then
      plan "create directory $dir_rel"
    else
      mkdir -p "$dir_abs"
      note "created $dir_rel"
    fi
    CHANGES=$((CHANGES + 1))
  else
    echo "  REFUSE: $dir_rel exists but is neither dir nor symlink" >&2
    REFUSED=$((REFUSED + 1))
  fi
  echo ""
}

ensure_discovery_dir "Step 3a: .claude/skills" ".claude/skills"
ensure_discovery_dir "Step 3b: .agents/skills" ".agents/skills"

# --- Step 4: create per-skill symlinks ---

# Compute the relative target from <discovery-dir>/<skill> to the source.
# Discovery dir is at depth 2 from repo root (.claude/skills, .agents/skills),
# so to reach the source at skills/<group>/<skill> we go up two levels.
#
# Args: <discovery-dir-rel> <source-rel>
# Echoes the relative target to use for `ln -s`.
relative_target() {
  local discovery_rel="$1"
  local source_rel="$2"
  local depth
  # Count '/' separators in discovery_rel; that's the depth.
  depth="$(awk -F'/' '{print NF}' <<< "$discovery_rel")"
  local prefix=""
  local i
  for ((i = 0; i < depth; i++)); do
    prefix+="../"
  done
  printf '%s%s\n' "$prefix" "$source_rel"
}

ensure_symlinks_for() {
  local discovery_rel="$1"
  local label="$2"
  local discovery_abs="$REPO_ROOT/$discovery_rel"

  echo "$label"

  if [ ! -d "$discovery_abs" ] && [ "$DRY_RUN" != "true" ]; then
    echo "  REFUSE: discovery dir $discovery_rel is not present" >&2
    REFUSED=$((REFUSED + 1))
    echo ""
    return
  fi

  # Track desired names to drive GC below.
  local desired_names=()

  if [ -n "$DISCOVERED" ]; then
    while IFS=$'\t' read -r name rel; do
      [ -z "$name" ] && continue
      desired_names+=("$name")
      local target want_link_path
      target="$(relative_target "$discovery_rel" "$rel")"
      want_link_path="$discovery_abs/$name"

      if [ -L "$want_link_path" ]; then
        local current
        current="$(readlink "$want_link_path")"
        if [ "$current" = "$target" ]; then
          note "OK $name → $target"
          continue
        fi
        if [ "$DRY_RUN" = true ]; then
          plan "retarget $discovery_rel/$name from $current → $target"
        else
          rm "$want_link_path"
          ( cd "$discovery_abs" && ln -s "$target" "$name" )
          [ "$GIT_REPO" = "yes" ] && ( cd "$REPO_ROOT" && git add "$discovery_rel/$name" >/dev/null 2>&1 || true )
          note "retargeted $name → $target (was $current)"
        fi
        CHANGES=$((CHANGES + 1))
      elif [ ! -e "$want_link_path" ] && [ ! -L "$want_link_path" ]; then
        if [ "$DRY_RUN" = true ]; then
          plan "create $discovery_rel/$name → $target"
        else
          ( cd "$discovery_abs" && ln -s "$target" "$name" )
          [ "$GIT_REPO" = "yes" ] && ( cd "$REPO_ROOT" && git add "$discovery_rel/$name" >/dev/null 2>&1 || true )
          note "created $name → $target"
        fi
        CHANGES=$((CHANGES + 1))
      else
        echo "  REFUSE: $discovery_rel/$name exists and is not a symlink — leave it alone or remove manually" >&2
        REFUSED=$((REFUSED + 1))
      fi
    done <<< "$DISCOVERED"
  fi

  # --- GC: remove symlinks under discovery dir that aren't in the desired set,
  # or whose targets don't resolve. Refuse on non-symlinks.
  if [ -d "$discovery_abs" ]; then
    local entry entry_name
    while IFS= read -r entry; do
      [ -z "$entry" ] && continue
      entry_name="$(basename "$entry")"
      # Skip .gitkeep and similar dotfiles that we explicitly allow.
      case "$entry_name" in
        .gitkeep|.DS_Store) continue ;;
      esac

      if [ -L "$entry" ]; then
        local keep=no
        for d in "${desired_names[@]:-}"; do
          if [ "$d" = "$entry_name" ]; then keep=yes; break; fi
        done
        if [ "$keep" = "no" ]; then
          if [ "$DRY_RUN" = true ]; then
            plan "remove stale symlink: $discovery_rel/$entry_name → $(readlink "$entry")"
          else
            if [ "$GIT_REPO" = "yes" ] && git -C "$REPO_ROOT" ls-files --error-unmatch "$discovery_rel/$entry_name" >/dev/null 2>&1; then
              ( cd "$REPO_ROOT" && git rm -q "$discovery_rel/$entry_name" )
            else
              rm "$entry"
            fi
            note "removed stale symlink: $entry_name"
          fi
          CHANGES=$((CHANGES + 1))
        fi
      else
        echo "  REFUSE: $discovery_rel/$entry_name is not a symlink — refusing to touch it" >&2
        REFUSED=$((REFUSED + 1))
      fi
    done < <(find "$discovery_abs" -mindepth 1 -maxdepth 1 2>/dev/null | sort)
  fi
  echo ""
}

ensure_symlinks_for ".claude/skills" "Step 4a: ensure .claude/skills/<skill> symlinks"
ensure_symlinks_for ".agents/skills" "Step 4b: ensure .agents/skills/<skill> symlinks"

# --- Summary ---

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$DRY_RUN" = true ]; then
  if [ "$CHANGES" -eq 0 ] && [ "$REFUSED" -eq 0 ]; then
    echo "already in sync (no changes needed)"
  else
    echo "dry run complete"
    [ "$CHANGES" -gt 0 ] && echo "  $CHANGES step(s) would change"
    [ "$REFUSED" -gt 0 ] && echo "  $REFUSED step(s) would refuse — see messages above"
  fi
else
  if [ "$CHANGES" -eq 0 ] && [ "$REFUSED" -eq 0 ]; then
    echo "already in sync"
  else
    echo "link-skills complete"
    [ "$CHANGES" -gt 0 ] && echo "  $CHANGES change(s) applied"
    [ "$REFUSED" -gt 0 ] && echo "  $REFUSED step(s) refused — see messages above"
  fi
fi

[ "$REFUSED" -gt 0 ] && exit 3
exit 0
