#!/usr/bin/env bash
# Formula check (beta.36 RC2, T1): the formula ships the version its caveats and brew
# test were written for (the caveats-for line), and no shipped tap text names Gemini or
# Windows. Red on the tap PR until the version bump lands on the branch, so it cannot
# be merged with new caveats on an old version (or old caveats on a new one).
# Usage: scripts/check-formula.sh [Formula/vibead.rb] [README.md]
set -euo pipefail
f=${1:-Formula/vibead.rb}; readme=${2:-README.md}
fail=0
version=$(sed -nE 's/^  version "([^"]+)"$/\1/p' "$f")
caveats_for=$(sed -nE 's/^  # caveats-for: ([^ ]+)$/\1/p' "$f")
[ -n "$version" ] && [ -n "$caveats_for" ] || { echo "FAIL $f needs a version line and a caveats-for line"; exit 1; }
if [ "$version" = "$caveats_for" ]; then echo "ok   $f ships $version, the version its caveats were written for"
else echo "FAIL $f ships $version, but its caveats and brew test were written for $caveats_for: run VIBEAD_TAP_VERSION=$caveats_for scripts/update-formula.sh on this branch (after the GitHub Release and npm next exist) before merging"; fail=1; fi
# The brew test's refute_match line names what must not appear; it is not shipped text.
for p in "$f" "$readme"; do
  if grep -n -v 'refute_match' "$p" | grep -i -E 'gemini|windows|powershell|\.exe\b|\.ps1'; then echo "FAIL $p names Gemini or Windows"; fail=1; else echo "ok   $p names neither Gemini nor Windows"; fi
done
exit "$fail"
