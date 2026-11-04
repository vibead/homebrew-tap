#!/usr/bin/env bash
# semver_cmp A B: prints -1, 0 or 1 by SemVer 2.0.0 precedence (section 11),
# prerelease included: 0.1.0-beta.9 < 0.1.0-beta.10 < 0.1.0-beta.36 < 0.1.0.
# Numeric identifiers compare as numbers and sort before alphanumeric ones;
# a longer identifier list wins when every shared one is equal. Build metadata
# (+…) is not accepted by update-formula.sh, so it is not handled here.
semver_cmp() {
  local a=$1 b=$2 ac bc ap bp i x y
  ac=${a%%-*}; bc=${b%%-*}
  [[ $a == *-* ]] && ap=${a#*-} || ap=
  [[ $b == *-* ]] && bp=${b#*-} || bp=
  local -a an bn
  IFS=. read -r -a an <<< "$ac"; IFS=. read -r -a bn <<< "$bc"
  for i in 0 1 2; do
    x=$((10#${an[i]:-0})); y=$((10#${bn[i]:-0}))
    if (( x > y )); then echo 1; return; elif (( x < y )); then echo -1; return; fi
  done
  # A release outranks any of its prereleases.
  if [[ -z $ap && -z $bp ]]; then echo 0; return; fi
  if [[ -z $ap ]]; then echo 1; return; fi
  if [[ -z $bp ]]; then echo -1; return; fi
  local -a ai bi
  IFS=. read -r -a ai <<< "$ap"; IFS=. read -r -a bi <<< "$bp"
  for ((i = 0; i < ${#ai[@]} && i < ${#bi[@]}; i++)); do
    x=${ai[i]}; y=${bi[i]}
    if [[ $x =~ ^[0-9]+$ && $y =~ ^[0-9]+$ ]]; then
      if (( 10#$x > 10#$y )); then echo 1; return; elif (( 10#$x < 10#$y )); then echo -1; return; fi
    elif [[ $x =~ ^[0-9]+$ ]]; then echo -1; return
    elif [[ $y =~ ^[0-9]+$ ]]; then echo 1; return
    elif [[ $x > $y ]]; then echo 1; return
    elif [[ $x < $y ]]; then echo -1; return
    fi
  done
  if (( ${#ai[@]} > ${#bi[@]} )); then echo 1; elif (( ${#ai[@]} < ${#bi[@]} )); then echo -1; else echo 0; fi
}
