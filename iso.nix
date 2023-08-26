{ lib, pkgs, config, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  boot = {
    # use the latest Linux kernel
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [
      "audit=0"
      "boot.shell_on_fail"
      "copytoram"
      "ignore_loglevel"
      "nomodeset"
    ];
    # Needed for https://github.com/NixOS/nixpkgs/issues/58959
    supportedFilesystems = lib.mkForce [
      "ext4"
      "vfat"
      "xfs"
      "zfs"
    ];
  };

  systemd.network.wait-online = {
    enable = true;
    anyInterface = true;
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

  console = {
    enable = true;
    earlySetup = true;
  };

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

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 75;
  };

  environment.systemPackages = with pkgs; [
    # base system packages + packages what I *need*
    cloud-utils # provides growpart
    coreutils
    dmidecode
    doas
    file
    findutils
    gawk
    gettext # for translation (human lang; Eng <-> Hindi)
    git
    gnugrep
    gnupg
    gnused
    hdparm
    inotify-tools
    iproute
    iputils
    linux-firmware
    lsof
    mlocate
    mtr
    nvme-cli
    openssh
    openssl
    parallel
    pciutils # provides lspci and setpci
    pinentry
    procps # provides pgrep, kill, watch, ps, pidof, uptime, sysctl, free, etc
    psmisc # provides killall, fuser, pslog, pstree, etc
    rsync
    shadow
    smartmontools
    tmux
    tree
    usbutils
    util-linux # provides blkid, losetup, lsblk, rfkill, fallocate, dmesg, etc
    wol

    # text editors
    nano
    neovim
    vim

    # shells
    bash
    dash

    # download clients
    aria2
    curl
    wget
    yt-dlp

    # compression and decompression
    bzip2
    gnutar
    gzip
    #rar # absent on aarch64, and not really needed
    unzip
    xz
    zip
    zip
    zstd

    # power management
    acpi
    lm_sensors

    # system monitoring
    btop
    htop
    iotop
    usbtop

    # network monitoring
    iperf # this is iperf3
    iperf2 # this is what is usually 'iperf' on other distros
    nload

    # other utilities
    android-tools
    fzf
    picocom
    shellcheck

    # utilities written in Rust
    bandwhich
    bat
    bottom
    broot
    choose
    dog
    du-dust
    dua
    fd
    hyperfine
    procs
    ripgrep
    sd
    skim
    sniffnet
    tealdeer
    tre-command
  ];
}
