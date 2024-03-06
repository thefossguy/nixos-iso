{ lib, pkgs, config, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # since the latest kernel package is installed, there will be a ZFS conflict because
    # 1. ZFS is developed out of tree and needs to catch up to the latest release
    # 2. NixOS has ZFS enabled as a default
    # so force a list of filesystems which I use; sans-ZFS
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

  # yes I know that 'programs.<pkg>.enable' exist but this is just an ISO
  environment.systemPackages = with pkgs; [
    bat
    btop
    curl
    dmidecode
    file
    git
    gnutar
    htop
    iperf
    neovim
    parted
    pciutils
    perl
    ripgrep
    rsync
    tmux
    tree
    unzip
    vim
    wget
  ];

  environment.variables = {
    # for 'sudo -e' || 'sudoedit'
    EDITOR = "nvim";
    VISUAL = "nvim";
    # systemd
    SYSTEMD_PAGER = "";
    SYSTEMD_EDITOR = "nvim";
    TERM = "xterm-256color";
  };

  isoImage.squashfsCompression = "zstd -Xcompression-level 22";

  # yes, I want docs
  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
  };
}
