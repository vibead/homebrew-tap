#!/usr/bin/env bash
# Tests for the forward-only guard: semver_cmp precedence, and update-formula.sh
# leaving the formula alone when npm `latest` is not newer. Offline: a stub `npm`
# answers dist-tags.latest; nothing is downloaded. Usage: scripts/test-update-formula.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
. "$here/semver.sh"
fail=0
check() { local got; got=$(semver_cmp "$1" "$2"); if [ "$got" = "$3" ]; then echo "ok   $1 vs $2 = $3"; else echo "FAIL $1 vs $2: got $got, want $3"; fail=1; fi; }
check 0.1.0-beta.36 0.1.0-beta.34 1
check 0.1.0-beta.34 0.1.0-beta.36 -1
check 0.1.0-beta.10 0.1.0-beta.9 1     # numeric, not string, order
check 0.1.0-beta.9 0.1.0-beta.10 -1
check 0.1.0-beta.36 0.1.0-beta.36 0
check 0.1.0 0.1.0-beta.99 1            # a release outranks its prereleases
check 0.1.0-beta.99 0.1.0 -1
check 0.1.1-beta.1 0.1.0 1
check 0.2.0 0.10.0 -1
check 1.0.0 0.99.99 1
check 1.0.0-alpha 1.0.0-alpha.1 -1      # SemVer 2.0.0 section 11 examples
check 1.0.0-alpha.1 1.0.0-alpha.beta -1
check 1.0.0-alpha.beta 1.0.0-beta -1
check 1.0.0-beta 1.0.0-beta.2 -1
check 1.0.0-beta.2 1.0.0-beta.11 -1
check 1.0.0-beta.11 1.0.0-rc.1 -1
check 1.0.0-rc.1 1.0.0 -1
check 0.1.0-beta.36 0.1.0-alpha.99 1

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/tap/scripts"
cp "$here/update-formula.sh" "$here/semver.sh" "$tmp/tap/scripts/"
sed 's/^  version "[^"]*"$/  version "0.1.0-beta.36"/' "$here/../Formula/vibead.rb" > "$tmp/vibead.rb"
before=$(sha256sum "$tmp/vibead.rb")
run() { # LATEST [env...]: run the script with a stub npm, print "exit=N" and its output
  local latest=$1; shift
  printf '#!/bin/sh\n[ "$3" = dist-tags.latest ] && { echo %s; exit 0; }\necho "unexpected npm $*" >&2; exit 9\n' "$latest" > "$tmp/bin/npm"; chmod +x "$tmp/bin/npm"
  set +e; out=$(env "$@" PATH="$tmp/bin:$PATH" "$tmp/tap/scripts/update-formula.sh" "$tmp/vibead.rb" 2>&1); code=$?; set -e
}
expect() { if [ "$1" = "$2" ]; then echo "ok   $3"; else echo "FAIL $3: got '$1', want '$2'"; fail=1; fi; }
for older in 0.1.0-beta.35 0.1.0-beta.34 0.1.0-beta.9 0.1.0-alpha.40; do
  run "$older"
  expect "$code" 0 "npm latest $older: exit 0"
  expect "$out" "tap stays at 0.1.0-beta.36: npm latest $older is not newer" "npm latest $older: no rollback"
  expect "$(sha256sum "$tmp/vibead.rb")" "$before" "npm latest $older: formula unchanged"
done
run 0.1.0-beta.36
expect "$out" "tap already at 0.1.0-beta.36" "same version: nothing to do"
run 0.1.0-beta.40 VIBEAD_TAP_VERSION=0.1.0-beta.35
expect "$code" 1 "pinned older version: exit 1"
expect "$out" "refusing to move the tap back from 0.1.0-beta.36 to 0.1.0-beta.35" "pinned older version: refused"
expect "$(sha256sum "$tmp/vibead.rb")" "$before" "pinned older version: formula unchanged"
# A newer version gets past the guard (the next step is the npm tarball read, which the stub refuses).
run 0.1.0-beta.37
expect "$(grep -c 'unexpected npm view @vibead/cli@0.1.0-beta.37 dist.integrity' <<< "$out")" 1 "newer version passes the guard"
expect "$(sha256sum "$tmp/vibead.rb")" "$before" "newer version, failed check: formula unchanged"
[ "$fail" = 0 ] && echo "all passed" || { echo "some checks failed"; exit 1; }
