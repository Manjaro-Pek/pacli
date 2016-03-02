#!/bin/bash
# show packages description
declare -r max="${1:-5}"
declare -a packages=($(cat -))
if ((${#packages[@]} <= $max)); then
	for package in "${packages[@]}"; do
	   LANG=C yaourt -Si "${package}" | awk -F':' '/^Desc/ {print "'${package}': "$2}'
# or if only for pacli, save in a file /tmp/descriptions.list and view after with pacli ?
	done
fi
