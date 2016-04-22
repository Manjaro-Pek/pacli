#!/bin/bash
# show packages description

declare -r max="${1:-10}"
declare -a packages=($(cat -))
echo ''>/tmp/pacli-desc
if ((${#packages[@]} <= $max)); then
	for package in "${packages[@]}"; do
        LANG=C pacman -Qi "${package}" 2>/dev/null | awk -F: '/^Desc/ {print "'${package}': "$2}' &>>/tmp/pacli-desc
	done
fi
