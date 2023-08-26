#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash nix nix-output-monitor

nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix --log-format internal-json -v 2>&1 | nom --json
