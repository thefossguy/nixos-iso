{ lib, pkgs, config, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

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
    git
    htop
    iperf
    neovim
    ripgrep
    rsync
    tmux
    tree
    vim
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

  # all this just because I don't want to clone my NixOS config repo
  environment.etc."custom-scripts/clone-nixos-config.sh" = {
    text = ''
      #!${pkgs.bash}/bin/bash
      set -xeuf -o pipefail

      ${pkgs.git}/bin/git clone https://gitlab.com/thefossguy/prathams-nixos.git $HOME/prathams-nixos
    '';
    mode = "0777";
  };
  systemd.services = {
    "clone-nixos-config" = {
      serviceConfig = {
        Type = "oneshot";
        Environment = [ "PATH=\"${pkgs.openssl}/bin\"" ]; # just in case
        ExecStart = "${pkgs.sudo}/bin/sudo -i -u nixos ${pkgs.bash}/bin/bash /etc/custom-scripts/clone-nixos-config.sh";
        #                                        ^^^^^ is the user in the ISO
      };
      requiredBy = [ "getty-pre.target" ];
      requires = [ "network-online.target" ];
    };
  };

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
