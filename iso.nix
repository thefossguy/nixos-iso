{ lib, pkgs, config, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  boot = {
    # use the latest Linux kernel
    kernelPackages = pkgs.linuxPackages_latest;
    # Needed for https://github.com/NixOS/nixpkgs/issues/58959
    supportedFilesystems = lib.mkForce [
      "ext4"
      "f2fs"
      "vfat"
      "xfs"
    ];
  };

  time = {
    timeZone = "Asia/Kolkata";
    hardwareClockInLocalTime = true;
  };

  environment.systemPackages = with pkgs; [
    bat
    btop
    git
    htop
    ripgrep
    rsync
    tmux
  ];
}
