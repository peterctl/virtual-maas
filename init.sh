#!/bin/bash

source variables.sh

mkdir -p $OUT_DIR

calculate-missing() {
	local installed="$1"

	for pkg in $@; do
		if ! echo "$installed" | grep -q $pkg; then
			echo $pkg
		fi
	done
}

apt-dependency() {
	local installed=$(apt list --installed 2>/dev/null | cut -d/ -f1)
	local missing=$(calculate-missing "$installed" $@)
	[[ -z "$missing" ]] && return
	echo installing missing apt packages: $missing
	sudo apt install $missing
}

snap-dependency() {
	local installed=$(snap list | awk '{print $1}' | tail -n +2)
	local missing=$(calculate-missing "$installed" $@)
	[[ -z "$missing" ]] && return
	echo installing missing snap packages: $missing
	sudo snap install $missing
}

apt-dependency jq pwgen
snap-dependency lxd maas maas-test-db

set -x
