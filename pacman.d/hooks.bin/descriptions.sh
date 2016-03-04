#!/bin/bash
# show packages description
declare -r max="${1:-10}"
declare -a packages=($(cat -))
if ((${#packages[@]} <= $max)); then
	for package in "${packages[@]}"; do
	   #LANG=C yaourt -Si "${package}" | awk -F':' '/^Desc/ {print "'${package}': "$2}'
      LANG=C yaourt -Si "${package}" | awk -F':' '/^Desc/ {print "'${package}': "$2}' &>/tmp/pacli-desc
	done
fi
