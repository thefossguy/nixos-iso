{ lib, pkgs, config, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  boot = {
    # use the latest Linux kernel
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "copytoram"
      "nomodeset"
    ];
    # Needed for https://github.com/NixOS/nixpkgs/issues/58959
    supportedFilesystems = lib.mkForce [
      "ext4"
      "f2fs"
      "vfat"
      "xfs"
    ];
  };

  networking = {
    networkmanager.enable = true;
    wireless.enable = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    firewall = {
      enable = true;
      allowPing = true;
    };
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
