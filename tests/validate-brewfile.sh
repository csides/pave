#!/usr/bin/env bash
set -euo pipefail

brewfile="${1:?usage: validate-brewfile.sh PATH}"

fail=0
while read -r kind name; do
  case "$kind" in
    brew) brew info --formula "$name" >/dev/null 2>&1 || {
      echo "missing formula: $name"
      fail=1
    } ;;
    cask) brew info --cask "$name" >/dev/null 2>&1 || {
      echo "missing cask: $name"
      fail=1
    } ;;
    *) ;;
  esac
done < <(sed -E 's/#.*//; s/"//g' "$brewfile" | awk '/^(brew|cask) /{print $1, $2}')

exit "$fail"
