#!/usr/bin/env bash
# beta.36 RC2 (Gaurav, 02:09 AEDT Oct 30): no unapproved-wording marker may ship. Scans every
# tracked file except .github/ and this script: PENDING NINA (any case), TODO(nina) (any case),
# an all-caps PENDING, and "pending approval/sign-off/wording/review" (any case). The same
# patterns as vibead/cli install/test/no-pending-markers.test.mjs. Offline, no secrets.
set -euo pipefail
cd "$(dirname "$0")/.."
ci='pending[[:space:]]+nina|todo[[:space:]]*\([[:space:]]*nina[[:space:]]*\)|\bpending[[:space:]]+(approval|sign[- ]?off|wording|review)\b'
cs='\bPENDING\b'
scan() { grep -nHIE -i -e "$ci" -- "$@" || true; grep -nHIE -e "$cs" -- "$@" || true; }

# Self-test: every marker form is caught, code-style identifiers are not.
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
printf '%s\n' '(PENDING NINA)' 'pending nina' '**PENDING**' 'TODO(nina)' 'todo( Nina )' 'pending approval' 'Pending sign-off' > "$t/bad"
printf '%s\n' "skipped: 'pending-sign-off'" 'NOTICE_PENDING_MARKER' 'the toast is pending vibead#141' 'Approved by Nina' > "$t/good"
[ "$(scan "$t/bad" | cut -d: -f2 | sort -u | wc -l)" -eq 7 ] || { echo "self-test: a marker form was not caught"; exit 1; }
[ -z "$(scan "$t/good")" ] || { echo "self-test: a non-marker was flagged:"; scan "$t/good"; exit 1; }

files=()
while IFS= read -r -d '' f; do
  case "$f" in .github/*|scripts/check-no-pending.sh) ;; *) files+=("$f") ;; esac
done < <(git ls-files -z)
for must in README.md Formula/vibead.rb; do
  printf '%s\n' "${files[@]}" | grep -qx "$must" || { echo "scan misses $must"; exit 1; }
done
hits=$(scan "${files[@]}")
if [ -n "$hits" ]; then echo "unapproved-wording markers ship:"; echo "$hits"; exit 1; fi
echo "ok: no PENDING NINA, PENDING or TODO(nina) marker in ${#files[@]} shipped files"
