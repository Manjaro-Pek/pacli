#!/bin/bash
# show packages description
[[ "${HTTP_USER_AGENT:0:5}" == 'pamac' ]] && exit 0
[ -f "/usr/bin/yaourt" ] || exit 0
declare -r max="${1:-10}"
declare -a packages=($(cat -))
echo ''>/tmp/pacli-desc
if ((${#packages[@]} <= $max)); then
	for package in "${packages[@]}"; do
	   LANG=C yaourt -Si "${package}" 2>/dev/null | awk -F':' '/^Desc/ {print "'${package}': "$2}' &>>/tmp/pacli-desc
	done
fi
