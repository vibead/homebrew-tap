#!/usr/bin/env bash
# beta.36 RC3 (W1, approved by Nina, delegated wording owner (Gaurav, Oct 29 2026), 02:29
# AEDT Oct 30): VibeAd does not support Windows, so no shipped file and no README may point
# anyone at a Windows install: irm, iex, iwr, Invoke-Expression/RestMethod/WebRequest, a
# .ps1 download URL, or winget/scoop/choco install, any case. Scans every tracked file
# except .github/ and this script. The same patterns as vibead/cli
# install/test/no-windows-pointer.test.mjs. Offline, no secrets.
set -euo pipefail
cd "$(dirname "$0")/.."
ci='\birm\b|\biex\b|\biwr\b|\binvoke-(expression|restmethod|webrequest)\b|https?://[^[:space:]"'"'"'`)<>]*\.ps1\b|\b(winget|scoop|choco)[[:space:]]+install\b'
scan() { grep -nHIE -i -e "$ci" -- "$@" || true; }

# Self-test: every pointer form is caught, the refusal and look-alike words are not.
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
printf '%s\n' 'irm https://www.vibead.ai/install.ps1 | iex' 'IRM x' '... | IEX' 'iwr -useb x' 'Invoke-Expression (x)' 'invoke-restmethod x' 'Invoke-WebRequest x' \
  'powershell -c x https://www.vibead.ai/install.ps1' 'winget install vibead' 'scoop install vibead' 'choco install vibead' > "$t/bad"
printf '%s\n' 'vibead: Windows is not supported yet.' 'www.vibead.ai/install.ps1 prints the refusal' 'firmware' 'irmgard' 'the iexec tool' > "$t/good"
[ "$(scan "$t/bad" | cut -d: -f2 | sort -u | wc -l)" -eq 11 ] || { echo "self-test: a Windows install pointer was not caught"; exit 1; }
[ -z "$(scan "$t/good")" ] || { echo "self-test: a non-pointer was flagged:"; scan "$t/good"; exit 1; }

files=()
while IFS= read -r -d '' f; do
  case "$f" in .github/*|scripts/check-no-windows.sh) ;; *) files+=("$f") ;; esac
done < <(git ls-files -z)
for must in README.md Formula/vibead.rb; do
  printf '%s\n' "${files[@]}" | grep -qx "$must" || { echo "scan misses $must"; exit 1; }
done
hits=$(scan "${files[@]}")
if [ -n "$hits" ]; then echo "Windows install pointers ship:"; echo "$hits"; exit 1; fi
echo "ok: no Windows install pointer in ${#files[@]} shipped files"
