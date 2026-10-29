#!/usr/bin/env bash
# Regenerate Formula/vibead.rb for the version on the npm `latest` dist-tag of
# @vibead/cli. Public reads only, no token. Exits 0 and changes nothing when the
# formula is already at that version. Fails (changes nothing) unless:
#   1. npm's tarball for that version matches npm's dist.integrity (SHA-512), and
#   2. the SHA-256 of each platform archive in the tarball's releases.json equals
#      the one in the public GitHub Release's SHA256SUMS.
# Usage: [VIBEAD_TAP_VERSION=X] scripts/update-formula.sh [Formula/vibead.rb]   (prints the new version when changed)
set -euo pipefail
f=${1:-Formula/vibead.rb}
pkg='@vibead/cli'
platforms='darwin-arm64 darwin-x64 linux-x64'

# VIBEAD_TAP_VERSION pins a version that is not (yet) npm `latest`, e.g. a `next`
# release the tap must ship; the same npm and SHA256SUMS checks apply.
version=${VIBEAD_TAP_VERSION:-$(npm view "$pkg" dist-tags.latest)}
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$ ]] || { echo "bad npm latest version: $version" >&2; exit 1; }
old=$(sed -nE 's/^  version "([^"]+)"$/\1/p' "$f")
[ -n "$old" ] || { echo "no version line in $f" >&2; exit 1; }
if [ "$old" = "$version" ]; then echo "tap already at $version"; exit 0; fi

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
have=$(npm view "$pkg@$version" dist.integrity)
tarball=$(npm view "$pkg@$version" dist.tarball)
[[ "$tarball" == https://registry.npmjs.org/* ]] || { echo "unexpected tarball host: $tarball" >&2; exit 1; }
curl -fsSL --retry 3 -o "$tmp/cli.tgz" "$tarball"
want="sha512-$(openssl dgst -sha512 -binary "$tmp/cli.tgz" | base64 -w0)"
[ "$have" = "$want" ] || { echo "npm tarball does not match its integrity" >&2; exit 1; }
tar -xOzf "$tmp/cli.tgz" package/releases.json > "$tmp/releases.json"
[ "$(jq -r .version "$tmp/releases.json")" = "$version" ] || { echo "releases.json is not $version" >&2; exit 1; }
curl -fsSL --retry 3 -o "$tmp/SHA256SUMS" "https://github.com/vibead/cli/releases/download/v$version/SHA256SUMS"

cp "$f" "$tmp/new.rb"
sed -i "s/${old//./\\.}/$version/g" "$tmp/new.rb"
for p in $platforms; do
  npm_sum=$(jq -r --arg p "$p" '.platforms[$p] // empty' "$tmp/releases.json")
  rel_sum=$(awk -v n="vibead-beta-$version-$p.tar.gz" '$2 == n {print $1}' "$tmp/SHA256SUMS")
  [[ "$npm_sum" =~ ^[0-9a-f]{64}$ ]] || { echo "releases.json has no valid $p sum" >&2; exit 1; }
  [ "$npm_sum" = "$rel_sum" ] || { echo "$p: release SHA256SUMS differs from the npm package" >&2; exit 1; }
  # The sha256 line follows its url line in the formula.
  sed -i "/vibead-beta-$version-$p.tar.gz\"/{n;s/sha256 \"[0-9a-f]\{64\}\"/sha256 \"$npm_sum\"/}" "$tmp/new.rb"
  grep -q "sha256 \"$npm_sum\"" "$tmp/new.rb" || { echo "could not write the $p sum" >&2; exit 1; }
done
cp "$tmp/new.rb" "$f"
echo "$version"
