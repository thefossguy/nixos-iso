#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash nix nix-output-monitor

set -xeu

nom build .

for resultISO in $(basename result/iso/nixos-*-"$(uname -m)"-linux.iso); do
    cp result/iso/"${resultISO}" .
    sha512sum "${resultISO}" | awk '{print $1}' | tee "${resultISO}.sha512"
    sha256sum "${resultISO}" | awk '{print $1}' | tee "${resultISO}.sha256"
    chown "${USER}:${USER}" "${resultISO}"
    chmod 644 "${resultISO}"
done
