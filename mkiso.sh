#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash nix nix-output-monitor

set -xeu

if [ "$(uname -s)" != 'Linux' ]; then
    echo 'What operating system is even this?'
    exit 1
fi

time nom build --show-trace .

for resultISO in $(basename result/iso/nixos-*-linux.iso); do
    if [ ! -f "${resultISO}" ]; then
        cp result/iso/"${resultISO}" .
    fi
    if [ ! -f "${resultISO}.sha512" ]; then
        sha512sum "${resultISO}" | awk '{print $1}' 1> "${resultISO}.sha512"
    fi
    chown "${USER}:${USER}" "${resultISO}"
    chmod 644 "${resultISO}"
done
