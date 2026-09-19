#!/usr/bin/env bash
# Refresh the vendored OmniRoute agent skills from upstream.
#
#   Upstream: https://github.com/diegosouzapw/OmniRoute (MIT)
#   Source:   skills/{id}/SKILL.md on branch main
#
# Skill files are instructions this agent follows, so review `git diff` after
# running this and before committing.

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/diegosouzapw/OmniRoute/refs/heads/main/skills"
SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKILL_IDS=(
  omni-combos-routing
  omni-providers
  omni-inference
  omni-compression
  omni-mcp
  omni-auth
  omni-resilience
  cli-serve
  cli-chat
  cli-setup
  omni-github-skills
)

failed=0

for id in "${SKILL_IDS[@]}"; do
  target_dir="$SKILLS_DIR/$id"
  target="$target_dir/SKILL.md"
  tmp="$(mktemp)"

  if curl -fsSL --max-time 30 "$BASE_URL/$id/SKILL.md" -o "$tmp"; then
    mkdir -p "$target_dir"
    mv "$tmp" "$target"
    printf '%-22s updated (%s bytes)\n' "$id" "$(wc -c < "$target" | tr -d ' ')"
  else
    rm -f "$tmp"
    printf '%-22s FAILED\n' "$id"
    failed=$((failed + 1))
  fi
done

echo
if [ "$failed" -gt 0 ]; then
  echo "$failed skill(s) failed to download; existing copies left untouched."
fi
echo "Review changes before committing:  git diff -- $SKILLS_DIR"

exit "$failed"
